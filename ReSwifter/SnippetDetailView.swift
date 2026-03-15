//
//  SnippetDetailView.swift
//  ReSwifter
//
//  Created by Jeffrey Bakker on 2026-03-09.
//

import SwiftUI

struct SnippetDetailView: View {
    @EnvironmentObject private var extensionService: ExtensionXPCService
    @ObservedObject var viewModel: SnippetViewModel

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

            SyntaxHighlightWebView(sourceCode: selectedSnippet?.fullText ?? "")
                .frame(maxWidth: .infinity, alignment: .leading)
                .cornerRadius(8)
        }
    }
}
