//
//  FolderCommandMenu.swift
//  ReSwifter
//
//  Created by Jeffrey Bakker on 2026-03-09.
//

import SwiftData
import SwiftUI

/// A view that provides folder data from SwiftData to the
/// reusable FolderMenuContent. Used inside CommandMenu where
/// @Query is available (since Commands use View builders).
struct FolderCommandMenu: View {
    @ObservedObject var viewModel: SnippetViewModel
    @Query(sort: \FolderItem.name) private var folders: [FolderItem]

    var body: some View {
        FolderMenuContent(
            folders: folders,
            selectedFolderId: $viewModel.selectedFolderId,
            onNewFolder: {
                viewModel.newFolderName = ""
                viewModel.showNewFolderPrompt = true
            }
        )
    }
}
