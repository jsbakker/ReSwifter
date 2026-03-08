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
        WindowGroup {
            ContentView()
                .environmentObject(extensionService)
        }
        .modelContainer(for: SnippetItem.self)
    }
}
