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
    @StateObject private var extensionService = ExtensionXPCService()
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
            CommandMenu("Folders") {
                FolderCommandMenu(viewModel: viewModel)
                    .modelContainer(modelContainer)
            }
        }
    }
}
