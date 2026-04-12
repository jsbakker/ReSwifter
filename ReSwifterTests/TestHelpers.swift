//
//  TestHelpers.swift
//  ReSwifterTests
//
//  Created by Jeffrey Bakker on 2026-04-11.
//

import Foundation
@testable import ReSwifter

@MainActor
func makeSnippet(
    summary: String = "Test snippet",
    fullText: String = "let x = 1",
    favorite: Bool = false
) -> SnippetItem {
    let item = SnippetItem(summary: summary, fullText: fullText)
    item.favorite = favorite
    return item
}

@MainActor
func makeFolder(name: String) -> FolderItem {
    FolderItem(name: name)
}
