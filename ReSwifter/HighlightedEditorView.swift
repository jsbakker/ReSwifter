//
//  HighlightedEditorView.swift
//  ReSwifter
//
//  An editable NSTextView wrapped for SwiftUI that applies live WebCpp
//  syntax highlighting on every edit.
//
//  Strategy: after each text change, WebCppDriver re-highlights the full
//  source, parseWebCppHTML() extracts the token ranges, and we apply only
//  the .foregroundColor / .font attributes to the existing NSTextStorage.
//  Because the text content itself is never replaced, the cursor position
//  and undo stack are preserved across re-highlighting passes.
//

import SwiftUI
import AppKit

struct HighlightedEditorView: NSViewRepresentable {

    @Environment(\.colorScheme) var systemColorScheme

    @Binding var text: String
    var language: WebCppLanguage

    // MARK: - NSViewRepresentable

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        guard let textView = scrollView.documentView as? NSTextView else {
            return scrollView
        }

        configureTextView(textView, coordinator: context.coordinator)
        context.coordinator.textView = textView
        context.coordinator.currentColorScheme = systemColorScheme
        context.coordinator.setContent(text, language: language)
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        let coord = context.coordinator

        // Always refresh the binding so the coordinator writes to the current snippet.
        coord.binding = $text

        if textView.string != text {
            // External change (e.g. snippet selection switched): replace content.
            coord.setContent(text, language: language)
        } else if coord.currentLanguage != language {
            // Language picker changed: re-highlight existing text.
            coord.currentLanguage = language
            coord.applyHighlighting(to: textView, text: text, language: language)
        } else if coord.currentColorScheme != systemColorScheme {
            // Color scheme changed: update background and re-apply token colors.
            coord.currentColorScheme = systemColorScheme
            textView.backgroundColor    = WebCppTheme.backgroundColor
            textView.insertionPointColor = WebCppTheme.color(for: "nortext")
            coord.applyHighlighting(to: textView, text: text, language: language)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(binding: $text)
    }

    static func dismantleNSView(_ scrollView: NSScrollView, coordinator: Coordinator) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        textView.undoManager?.removeAllActions()
    }

    // MARK: - Private setup

    private func configureTextView(_ textView: NSTextView, coordinator: Coordinator) {
        textView.isEditable                             = true
        textView.isSelectable                           = true
        textView.allowsUndo                             = true
        textView.isRichText                             = true   // We control all attributes
        textView.usesFontPanel                          = false
        textView.usesFindPanel                          = true
        textView.isAutomaticQuoteSubstitutionEnabled    = false
        textView.isAutomaticDashSubstitutionEnabled     = false
        textView.isAutomaticSpellingCorrectionEnabled   = false
        textView.isAutomaticTextReplacementEnabled      = false
        textView.smartInsertDeleteEnabled               = false
        textView.isVerticallyResizable                  = true
        textView.isHorizontallyResizable                = false
        textView.autoresizingMask                       = [.width]
        textView.textContainer?.widthTracksTextView     = true

        textView.backgroundColor    = WebCppTheme.backgroundColor
        textView.insertionPointColor = WebCppTheme.color(for: "nortext")

        let font = Self.monoFont
        textView.font = font
        textView.typingAttributes = [
            .font:            font,
            .foregroundColor: WebCppTheme.color(for: "nortext")
        ]

        textView.delegate = coordinator
    }

    // MARK: - Font helpers

    static let monoFont     = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
    static let monoBold     = NSFont.monospacedSystemFont(ofSize: 13, weight: .bold)
    static let monoItalic: NSFont = {
        // On macOS, withSymbolicTraits returns NSFontDescriptor (non-optional).
        let descriptor = monoFont.fontDescriptor.withSymbolicTraits(.italic)
        return NSFont(descriptor: descriptor, size: 13) ?? monoFont
    }()

    // MARK: - Coordinator

    final class Coordinator: NSObject, NSTextViewDelegate {

        var binding: Binding<String>
        var currentLanguage: WebCppLanguage = .swift
        var currentColorScheme: ColorScheme = .light
        weak var textView: NSTextView?
        private var debounceItem: DispatchWorkItem?

        init(binding: Binding<String>) {
            self.binding = binding
        }

        /// Replaces the full text content and re-highlights.
        /// Used on initial load and when an external selection change occurs.
        func setContent(_ text: String, language: WebCppLanguage) {
            guard let textView else { return }
            currentLanguage = language

            textView.scroll(.zero)
            // Replace text — this resets the selection to position 0.
            textView.string = text
            // Clear the undo stack so actions from the previous snippet
            // don't bleed into this one.
            textView.undoManager?.removeAllActions()
            textView.typingAttributes = [
                .font:            HighlightedEditorView.monoFont,
                .foregroundColor: WebCppTheme.color(for: "nortext")
            ]

            applyHighlighting(to: textView, text: text, language: language)
        }

        /// Applies WebCpp syntax highlighting attributes to the text storage
        /// without modifying the text content (cursor position is preserved).
        func applyHighlighting(to textView: NSTextView, text: String, language: WebCppLanguage) {
            guard !text.isEmpty,
                  let html = WebCppDriver.highlightString(text, filename: language.dummyFilename),
                  let storage = textView.textStorage else { return }

            var result = parseWebCppHTML(html)

            // WebCpp may insert extra characters (e.g. trailing spaces on
            // preprocessor lines).  Realign the parsed ranges to the actual
            // source text so the colours land on the right characters.
            if result.plainText != text {
                result = rebaseTokenRanges(result, to: text)
            }
            let monoFont = HighlightedEditorView.monoFont
            let monoBold = HighlightedEditorView.monoBold
            let monoItalic = HighlightedEditorView.monoItalic
            let nortextColor = WebCppTheme.color(for: "nortext")
            let fullRange = NSRange(location: 0, length: storage.length)

            // Capture scroll position before attribute changes trigger layout invalidation.
            let scrollView = textView.enclosingScrollView
            let savedScrollOrigin = scrollView?.contentView.bounds.origin

            storage.beginEditing()

            // Reset everything to nortext / regular monospace
            storage.addAttribute(.foregroundColor, value: nortextColor, range: fullRange)
            storage.addAttribute(.font,            value: monoFont,     range: fullRange)

            // Apply per-token color (and bold / italic where applicable)
            for token in result.tokenRanges {
                guard token.range.location + token.range.length <= storage.length else { continue }

                storage.addAttribute(.foregroundColor,
                                     value: WebCppTheme.color(for: token.tokenClass),
                                     range: token.range)

                if WebCppTheme.isBold(for: token.tokenClass) {
                    storage.addAttribute(.font, value: monoBold, range: token.range)
                } else if WebCppTheme.isItalic(for: token.tokenClass) {
                    storage.addAttribute(.font, value: monoItalic, range: token.range)
                }
            }

            storage.endEditing()

            // endEditing() marks layout as needing invalidation but defers
            // actual computation.  Force it now so any frame/scroll
            // adjustments happen before we restore the scroll position.
            if let scrollView, let savedScrollOrigin {
                if let layoutManager = textView.layoutManager,
                   let textContainer = textView.textContainer {
                    layoutManager.ensureLayout(for: textContainer)
                }

                let maxY = max(0, (scrollView.documentView?.frame.height ?? 0)
                                - scrollView.contentView.bounds.height)
                let clampedOrigin = NSPoint(
                    x: savedScrollOrigin.x,
                    y: min(savedScrollOrigin.y, maxY)
                )
                scrollView.contentView.setBoundsOrigin(clampedOrigin)
                scrollView.reflectScrolledClipView(scrollView.contentView)
            }
        }

        // MARK: NSTextViewDelegate

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            let newText = textView.string

            // Propagate the plain-text change to the SwiftUI binding immediately.
            binding.wrappedValue = newText

            // Re-highlight with a short debounce to avoid redundant work during
            // fast typing. 50 ms is imperceptible to the user and well within the
            // sub-100 ms highlighting budget for typical snippet sizes.
            debounceItem?.cancel()
            let lang = currentLanguage
            let item = DispatchWorkItem { [weak self, weak textView] in
                guard let self, let textView else { return }
                self.applyHighlighting(to: textView, text: newText, language: lang)
            }
            debounceItem = item
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: item)
        }
    }
}
