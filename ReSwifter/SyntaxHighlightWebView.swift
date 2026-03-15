//
//  SyntaxHighlightWebView.swift
//  ReSwifter
//
//  Displays syntax-highlighted source code using WebCpp and a native WebView.
//

import SwiftUI
import WebKit

struct SyntaxHighlightWebView: View {
    let sourceCode: String
    var language: WebCppLanguage = .swift

    @State private var page = WebPage()

    var body: some View {
        WebView(page)
            .webViewContentBackground(.hidden)
            .webViewContextMenu { _ in }
            .task(id: "\(sourceCode)\(language.rawValue)") {
                loadHighlightedHTML()
            }
    }

    private func loadHighlightedHTML() {
        guard !sourceCode.isEmpty else { return }

        // Extract just the code from a fenced code block if the snippet contains markdown.
        let code = extractCodeBlock(from: sourceCode)

        let html = WebCppDriver.highlightString(code, filename: language.dummyFilename) ?? fallbackHTML(for: code)
        _ = page.load(html: html, baseURL: URL(string: "about:blank")!)
    }

    /// Pulls the contents of the first ``` fenced code block, or returns the original text as-is.
    private func extractCodeBlock(from text: String) -> String {
        let pattern = "```[^\\n]*\\n([\\s\\S]*?)```"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              let codeRange = Range(match.range(at: 1), in: text) else {
            return text
        }
        return String(text[codeRange])
    }

    private func fallbackHTML(for text: String) -> String {
        let escaped = text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
        return "<html><body><pre>\(escaped)</pre></body></html>"
    }
}
