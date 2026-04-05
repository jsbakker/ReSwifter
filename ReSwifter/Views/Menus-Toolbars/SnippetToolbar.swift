//
//  SnippetToolbar.swift
//  ReSwifter
//
//  Created by Jeffrey Bakker on 2026-03-09.
//

import SwiftData
import SwiftUI

struct SnippetToolbar: ToolbarContent {
    @ObservedObject var viewModel: SnippetViewModel
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \FolderItem.name) private var folders: [FolderItem]

    var body: some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            Menu {
                FolderMenuContent(
                    folders: folders,
                    selectedFolderId: $viewModel.selectedFolderId,
                    onNewFolder: {
                        viewModel.newFolderName = ""
                        viewModel.showNewFolderPrompt = true
                    },
                    onManageFolders: {
                        viewModel.showManageFolders = true
                    }
                )
            } label: {
                let name = viewModel.selectedFolderItem(from: folders)?.name ?? "All"
                Label(name, systemImage: "folder")
            }
            .help("Snippets In Folder...")
            .accessibilityIdentifier("folderMenuButton")
        }

        ToolbarItem(placement: .primaryAction) {
            Button {
                viewModel.addNewSnippet(fullText: "", modelContext: modelContext, folders: folders)
            } label: {
                Label("Create New Snippet", systemImage: "doc.badge.plus")
            }
            .help("Create New Snippet")
        }

        ToolbarItem(placement: .primaryAction) {
            Button {
                viewModel.addFromClipboard(modelContext: modelContext, folders: folders)
            } label: {
                Label("Add From Clipboard", systemImage: "doc.on.clipboard")
            }
            .help("Add From Clipboard")
            .accessibilityIdentifier("addFromClipboardButton")
        }

        ToolbarItem(placement: .primaryAction) {
            Button {
                viewModel.showOnlyFavorites.toggle()
            } label: {
                Label("Show Favorites Only", systemImage: viewModel.showOnlyFavorites ? "heart.fill" : "heart")
            }
            .help("Show Favorites Only")
        }
    }
}
