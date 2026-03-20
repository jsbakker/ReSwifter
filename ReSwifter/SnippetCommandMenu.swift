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
    @Query(sort: \SnippetItem.date, order: .reverse) private var items: [SnippetItem]

    private var selectedSnippet: SnippetItem? {
        viewModel.selectedSnippet(from: items)
    }

    private var hasSelection: Bool {
        selectedSnippet != nil
    }

    var body: some View {
        Button("Add Snippet From Clipboard", systemImage: "doc.on.clipboard") {
            viewModel.addFromClipboard(modelContext: modelContext, folders: folders)
        }
        .keyboardShortcut("V", modifiers: [.command, .shift])

        Button("Copy to Clipboard", systemImage: "doc.on.doc") {
            guard let item = selectedSnippet else { return }
            viewModel.copySnippet(item)
        }
        .keyboardShortcut("C", modifiers: [.command, .shift])
        .disabled(!hasSelection)

        Divider()

        Toggle("Favorite", systemImage: "heart", isOn: Binding(
            get: { selectedSnippet?.favorite ?? false },
            set: { newValue in selectedSnippet?.favorite = newValue }
        ))
        .keyboardShortcut("H", modifiers: [.command, .shift])
        .disabled(!hasSelection)

        Toggle("Show Only Favorites", systemImage: "heart", isOn: $viewModel.showOnlyFavorites)
            .keyboardShortcut("H", modifiers: [.command, .control])

        Divider()

        Button("Explain", systemImage: "info") {
            guard let item = selectedSnippet else { return }
            viewModel.explain(item, modelContext: modelContext, folders: folders)
        }
        .disabled(!hasSelection)
        .keyboardShortcut("E", modifiers: [.command])

        Button("Document", systemImage: "document") {
            guard let item = selectedSnippet else { return }
            viewModel.document(item, modelContext: modelContext, folders: folders)
        }
        .disabled(!hasSelection)
        .keyboardShortcut("D", modifiers: [.command])

        Button("Review", systemImage: "quote.bubble") {
            guard let item = selectedSnippet else { return }
            viewModel.review(item, modelContext: modelContext, folders: folders)
        }
        .disabled(!hasSelection)
        .keyboardShortcut("R", modifiers: [.command, .shift])

        Button("Cleanup", systemImage: "wand.and.stars") {
            guard let item = selectedSnippet else { return }
            viewModel.cleanup(item, modelContext: modelContext, folders: folders)
        }
        .disabled(!hasSelection)
        .keyboardShortcut("U", modifiers: [.command])

        Button("Refactor", systemImage: "lightbulb") {
            guard let item = selectedSnippet else { return }
            viewModel.refactor(item, modelContext: modelContext, folders: folders)
        }
        .disabled(!hasSelection)
        .keyboardShortcut("R", modifiers: [.command])

        Button("Convert to Swift", systemImage: "brain") {
            guard let item = selectedSnippet else { return }
            viewModel.convert(item, modelContext: modelContext, folders: folders)
        }
        .disabled(!hasSelection)
        .keyboardShortcut("S", modifiers: [.command, .shift])

        Divider()

        Button("Edit Summary...", systemImage: "square.and.pencil") {
            guard let item = selectedSnippet else { return }
            viewModel.beginEditSummary(for: item)
        }
        .disabled(!hasSelection)
        .keyboardShortcut("S", modifiers: [.command])

        Divider()

        Menu("Move to", systemImage: "folder") {
            Button {
                selectedSnippet?.folder = nil
            } label: {
                if selectedSnippet?.folder == nil {
                    Label("All", systemImage: "checkmark")
                } else {
                    Text("All")
                }
            }

            ForEach(folders) { folder in
                Button {
                    selectedSnippet?.folder = folder
                } label: {
                    if selectedSnippet?.folder?.id == folder.id {
                        Label(folder.name, systemImage: "checkmark")
                    } else {
                        Text(folder.name)
                    }
                }
            }
        }
        .disabled(!hasSelection)
    }
}
