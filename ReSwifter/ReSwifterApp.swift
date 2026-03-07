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
    /// The XPC listener that accepts connections from the Xcode extension.
    private let xpcDelegate = XPCServiceDelegate()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        xpcDelegate.startListening()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
