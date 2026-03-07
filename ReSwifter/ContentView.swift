//
//  ContentView.swift
//  ReSwifter
//
//  Created by Jeffrey Bakker on 2026-02-27.
//

import SwiftUI
import SwiftData
import CodeEditor

struct ContentView: View {
    @EnvironmentObject private var extensionService: ExtensionXPCService

    @State private var source: String = "" // = extensionService.receivedText ?? ""

    var body: some View {
        VStack(spacing: 16) {
            if extensionService.hasPendingRequest {
                Text("Text received from Xcode extension:")
                    .font(.headline)

                
//                ScrollView {
                CodeEditor(source: extensionService.receivedText ?? "", language: .swift, theme: .ocean)
//                    CodeEditor(source: $source, language: .swift)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()

//                    Text(extensionService.receivedText ?? "")
//                        .font(.system(.body, design: .monospaced))
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .padding()
//                }
//                .frame(maxHeight: .infinity)
//                .background(Color(nsColor: .textBackgroundColor))
//                .cornerRadius(8)

                HStack {
                    Button("Cancel") {
                        extensionService.cancelResponse()
                    }

                    Spacer()

                    Button("Send Back") {
                        if let text = extensionService.receivedText {
                            extensionService.sendResponse(text)
                        }
                    }
                    .keyboardShortcut(.return, modifiers: .command)
                }
            } else {
                Spacer()
                Text("Waiting for text from Xcode extension...")
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
        .padding()
        .frame(minWidth: 400, minHeight: 300)
    }
}

#Preview {
    ContentView()
        .environmentObject(ExtensionXPCService())
}
