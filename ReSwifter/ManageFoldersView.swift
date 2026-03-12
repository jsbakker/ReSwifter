//
//  ManageFoldersView.swift
//  ReSwifter
//
//  Created by Jeffrey Bakker on 2026-03-11.
//

import SwiftData
import SwiftUI

struct ManageFoldersView: View {
    @ObservedObject var viewModel: SnippetViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \FolderItem.name) private var folders: [FolderItem]

    @State private var renamingFolder: FolderItem?
    @State private var renameText = ""
    @State private var isCreatingFolder = false
    @State private var deletingFolder: FolderItem?

    var body: some View {
        VStack(spacing: 0) {
            Text("Manage Snippets Folders")
                .font(.headline)
                .padding()

            if folders.isEmpty {
                Text("No folders yet.")
                    .foregroundStyle(.secondary)
                    .frame(maxHeight: .infinity)
            } else {
                List {
                    ForEach(folders) { folder in
                        HStack {
                            Image(systemName: "folder")
                                .foregroundStyle(.secondary)

                            Text(folder.name)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text("^[\(folder.snippets.count) snippet](inflect: true)")
                                .foregroundStyle(.secondary)
                                .font(.caption)

                            Button {
                                renamingFolder = folder
                            } label: {
                                Image(systemName: "pencil")
                            }
                            .buttonStyle(.borderless)
                            .help("Rename")

                            Button(role: .destructive) {
                                if folder.snippets.isEmpty {
                                    viewModel.deleteFolder(folder, deleteSnippets: false, modelContext: modelContext)
                                } else {
                                    deletingFolder = folder
                                }
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.borderless)
                            .help("Delete")
                        }
                    }
                }
            }

            Divider()

            HStack {
                Button {
                    let newFolder = FolderItem(name: "New Snippet Folder")
                    modelContext.insert(newFolder)
                    isCreatingFolder = true
                    renamingFolder = newFolder
                } label: {
                    Image(systemName: "plus")
                }
                .help("New Folder")

                Spacer()
                Button("Done") { dismiss() }
                    .keyboardShortcut(.return, modifiers: .command)
                    .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(minWidth: 400, minHeight: 250)
        .alert(isCreatingFolder ? "New Folder" : "Rename Folder", isPresented: Binding(
            get: { renamingFolder != nil },
            set: { if !$0 { renamingFolder = nil } }
        ), presenting: renamingFolder) { folder in
            TextField("Folder name", text: $renameText)
            Button(isCreatingFolder ? "Create" : "Rename") {
                viewModel.renameFolder(folder, to: renameText, allFolders: folders)
                isCreatingFolder = false
                renamingFolder = nil
            }
            Button("Cancel", role: .cancel) {
                if isCreatingFolder {
                    modelContext.delete(folder)
                }
                isCreatingFolder = false
                renamingFolder = nil
            }
        } message: { _ in
            Text(isCreatingFolder
                 ? "Enter a name for the new folder."
                 : "Enter a new name for the folder.")
        }
        .onChange(of: renamingFolder) {
            renameText = renamingFolder?.name ?? ""
        }
        .confirmationDialog(
            deletionTitle,
            isPresented: Binding(
                get: { deletingFolder != nil },
                set: { if !$0 { deletingFolder = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete folder and all its snippets", role: .destructive) {
                if let folder = deletingFolder {
                    viewModel.deleteFolder(folder, deleteSnippets: true, modelContext: modelContext)
                }
                deletingFolder = nil
            }
            Button("Remove folder only (keep snippets)") {
                if let folder = deletingFolder {
                    viewModel.deleteFolder(folder, deleteSnippets: false, modelContext: modelContext)
                }
                deletingFolder = nil
            }
            Button("Cancel", role: .cancel) {
                deletingFolder = nil
            }
        }
    }

    private var deletionTitle: String {
        guard let folder = deletingFolder else { return "Delete Folder" }
        let count = folder.snippets.count
        if count == 0 {
            return "Delete \"\(folder.name)\"?"
        }
        return "Delete \"\(folder.name)\"? It contains \(count) snippet\(count == 1 ? "" : "s")."
    }
}
