//
//  ReSwifterApp.swift
//  ReSwifter
//
//  Created by Jeffrey Bakker on 2026-02-27.
//

import SwiftUI
import SwiftData

@main
struct ReSwifterApp: App {
    @StateObject private var extensionService = ExtensionIPCService()
    @StateObject private var viewModel = SnippetViewModel()

    let modelContainer: ModelContainer = {
        try! ModelContainer(for: SnippetItem.self, FolderItem.self)
    }()

    var body: some Scene {
        Window("ReSwifter", id: "main") {
            ContentView()
                .environmentObject(extensionService)
                .environmentObject(viewModel)
        }
        .windowResizability(.contentMinSize)
        .modelContainer(modelContainer)
        .commands {
            CommandGroup(replacing: .newItem) {
                FolderCommandMenu(viewModel: viewModel)
                    .modelContainer(modelContainer)
            }
            CommandMenu("Snippets") {
                SnippetCommandMenu(viewModel: viewModel)
                    .modelContainer(modelContainer)
            }

            CommandGroup(replacing: .appInfo) {
                Button("About ReSwifter") {
                    NSApplication.shared.orderFrontStandardAboutPanel(
                        options: [
                            .credits: NSAttributedString(
                                string: """
                                ReSwifter Copyright (c) 2026 Jeffrey Bakker

                                Syntax highlighted live editor aided by WebCpp, Copyright (c) 2001-2026 Jeffrey Bakker under the MIT License

                                Markdown with syntax highlighted blocks by Textual, Copyright (c) 2024 Guille Gonzalez under the MIT License

                                MIT License

                                Permission is hereby granted, free of charge, to any person obtaining a copy
                                of this software and associated documentation files (the "Software"), to deal
                                in the Software without restriction, including without limitation the rights
                                to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
                                copies of the Software, and to permit persons to whom the Software is
                                furnished to do so, subject to the following conditions:

                                The above copyright notice and this permission notice shall be included in all
                                copies or substantial portions of the Software.

                                THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
                                IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
                                FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
                                AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
                                LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
                                OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
                                SOFTWARE.
                                """,
                                attributes: [
                                    .font: NSFont.systemFont(ofSize: 11),
                                    .foregroundColor: NSColor.textColor
                                ]
                            ),
                            .applicationName: "ReSwifter",
                            .applicationVersion: "26.03",
                        ]
                    )
                }
            }
        }
    }
}
