//
//  FolderMenuContent.swift
//  ReSwifter
//
//  Created by Jeffrey Bakker on 2026-03-09.
//

import SwiftUI

/// Reusable folder menu items. Can be placed inside a toolbar Menu
/// or a CommandMenu in the app's menu bar.
struct FolderMenuContent: View {
    let folders: [FolderItem]
    @Binding var selectedFolderId: UUID?
    var onNewFolder: () -> Void
    var onManageFolders: () -> Void

    var body: some View {
        Button {
            selectedFolderId = nil
        } label: {
            if selectedFolderId == nil {
                Label("All", systemImage: "checkmark")
            } else {
                Text("All")
            }
        }

        Divider()

        ForEach(folders) { folder in
            Button {
                selectedFolderId = folder.id
            } label: {
                if selectedFolderId == folder.id {
                    Label(folder.name, systemImage: "checkmark")
                } else {
                    Text(folder.name)
                }
            }
        }

        Divider()

        Button("New Snippets Folder...", systemImage: "folder.badge.plus") {
            onNewFolder()
        }

        Button("Manage Snippets Folders...", systemImage: "folder.badge.gearshape") {
            onManageFolders()
        }
    }
}
