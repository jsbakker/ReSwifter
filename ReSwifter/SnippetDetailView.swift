//
//  SnippetDetailView.swift
//  ReSwifter
//
//  Created by Jeffrey Bakker on 2026-03-09.
//

import CodeEditor
import SwiftUI

struct SnippetDetailView: View {
    @EnvironmentObject private var extensionService: ExtensionXPCService
    @ObservedObject var viewModel: SnippetViewModel

    @State private var language = CodeEditor.Language.swift
    @State private var theme = CodeEditor.ThemeName.ocean

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

            CodeEditor(source: selectedSnippet?.fullText ?? "", language: language, theme: theme)
                .frame(maxWidth: .infinity, alignment: .leading)
                .cornerRadius(8)

            HStack {
              Picker("Language", selection: $language) {
                ForEach(CodeEditor.availableLanguages) { language in
                  Text("\(language.rawValue.capitalized)")
                    .tag(language)
                }
              }
              Picker("Theme", selection: $theme) {
                ForEach(CodeEditor.availableThemes) { theme in
                  Text("\(theme.rawValue.capitalized)")
                    .tag(theme)
                }
              }
            }
            .padding(8)
        }
        .onChange(of: selectedSnippet) {
            let raw = selectedSnippet?.language ?? "swift"
            language = CodeEditor.Language(rawValue: raw)
        }
        .onChange(of: language) {
            selectedSnippet?.language = language.rawValue
        }
    }
}
