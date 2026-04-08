//
//  SnippetItem.swift
//  ReSwifter
//
//  Created by Jeffrey Bakker on 2026-03-07.
//

import Foundation
import SwiftData

@Model class SnippetItem: Identifiable {

    var id: UUID = UUID()
    var date: Date = Date()
    var summary: String = "Generating summary..."
    var fullText: String = ""
    var favorite: Bool = false
    var folder: FolderItem?
    var language: String = "swift"
    var generated: Bool = false

    @Transient var pendingUpdate: Bool = false

    init(fullText: String) {
        self.fullText = fullText
    }

    init(summary: String, fullText: String) {
        self.summary = summary
        self.fullText = fullText
    }
}

