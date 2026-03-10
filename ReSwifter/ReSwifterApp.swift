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
    /// Listens for text-processing requests from the Xcode
    /// Source Editor Extension via DistributedNotifications.
    @StateObject private var extensionService = ExtensionXPCService()

    var body: some Scene {
        Window("ReSwifter", id: "main") {
            ContentView()
                .environmentObject(extensionService)
        }
        .windowResizability(.contentSize)
        .modelContainer(for: [SnippetItem.self, FolderItem.self])
        .commands {
            CommandMenu("Snippets") {
                Button("Add Snippet From Clipboard") {
                }
                .keyboardShortcut("V", modifiers: [.command])

                Divider()

                Button("Show Only Favorites") {
                }
                .keyboardShortcut("H", modifiers: [.command])
            }
        }
    }
}
