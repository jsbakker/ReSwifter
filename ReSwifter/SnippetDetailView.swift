//
//  SnippetDetailView.swift
//  ReSwifter
//
//  Created by Jeffrey Bakker on 2026-03-09.
//

import SwiftUI
import Textual

struct SnippetDetailView: View {
    @EnvironmentObject private var extensionService: ExtensionIPCService
    @ObservedObject var viewModel: SnippetViewModel

    @State private var language: WebCppLanguage = .swift

    let selectedSnippet: SnippetItem?

    var body: some View {
        VStack {
            if extensionService.hasPendingRequest {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                    Text("""
                        The XCode extension is requesting to modify its current file or selection.
                        """)

                    Spacer()

                    Button("Cancel Text Replacement") {
                        extensionService.cancelResponse()
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Send Selected Snippet to XCode") {
                        let fullText = selectedSnippet?.fullText ?? ""
                        extensionService.sendResponse(viewModel.extractCode(from: fullText))
                    }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.return, modifiers: .command)
                }
                .keyboardShortcut(.return, modifiers: .command)
            }

            if selectedSnippet != nil && selectedSnippet!.generated {
                ScrollView {
                    StructuredText(
                        markdown: selectedSnippet!.fullText
                    )
                    .font(.custom("Avenir Next", size: 14))
                    .textual.inlineStyle(
                        InlineStyle()
                            .code(
                                .monospaced,
                                .fontScale(0.9),
                                .foregroundColor(.gray)
                            )
                            .emphasis(.italic, .underlineStyle(.single))
                    )
                    .textual.textSelection(.enabled)
                    .textual.highlighterTheme(.xcode)
                    .textual.structuredTextStyle(.default)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .cornerRadius(8)
            }
            else {
                HighlightedEditorView(
                    text: Binding(
                        get: { selectedSnippet?.fullText ?? "" },
                        set: { selectedSnippet?.fullText = $0 }
                    ),
                    language: language
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .cornerRadius(8)

                HStack {
                    Picker("Language", selection: $language) {
                        ForEach(WebCppLanguage.allCases) { lang in
                            Text(lang.displayName)
                                .tag(lang)
                        }
                    }
                }
                .padding(8)
            }
        }
        .onChange(of: selectedSnippet) {
            let raw = selectedSnippet?.language ?? "swift"
            language = WebCppLanguage.from(rawValue: raw)
        }
        .onChange(of: language) {
            selectedSnippet?.language = language.rawValue
        }
    }
}
