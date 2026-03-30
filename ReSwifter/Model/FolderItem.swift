//
//  FolderItem.swift
//  ReSwifter
//
//  Created by Jeffrey Bakker on 2026-03-09.
//

import Foundation
import SwiftData

@Model class FolderItem: Identifiable {

    var id: UUID = UUID()
    var name: String = ""

    @Relationship(deleteRule: .nullify, inverse: \SnippetItem.folder)
    var snippets: [SnippetItem] = []

    init(name: String) {
        self.name = name
    }
}
