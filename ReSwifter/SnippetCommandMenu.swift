//
//  SnippetCommandMenu.swift
//  ReSwifter
//
//  Created by Jeffrey Bakker on 2026-03-10.
//

import SwiftData
import SwiftUI

/// Provides SwiftData context for the Snippets command menu.
/// Used inside CommandMenu where @Query is available.
struct SnippetCommandMenu: View {
    @ObservedObject var viewModel: SnippetViewModel
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FolderItem.name) private var folders: [FolderItem]

    var body: some View {
        Button("Add Snippet From Clipboard") {
            viewModel.addFromClipboard(modelContext: modelContext, folders: folders)
        }
        .keyboardShortcut("V", modifiers: [.command])

        Divider()

        Toggle("Show Only Favorites", isOn: $viewModel.showOnlyFavorites)
            .keyboardShortcut("H", modifiers: [.command])
    }
}
