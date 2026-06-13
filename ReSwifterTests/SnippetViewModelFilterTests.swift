//
//  SnippetViewModelFilterTests.swift
//  ReSwifterTests
//
//  Created by Jeffrey Bakker on 2026-04-11.
//

import Testing
import Foundation
import SwiftData
@testable import ReSwifter

@MainActor
struct SnippetViewModelFilterTests {

    var sut: SnippetViewModel
    var folderA: FolderItem
    var folderB: FolderItem
    var items: [SnippetItem]

    init() {
        sut = SnippetViewModel()
        sut.selectedFolderId = nil
        sut.showOnlyFavorites = false
        sut.searchText = ""

        folderA = makeFolder(name: "Swift")
        folderB = makeFolder(name: "Python")

        let s1 = makeSnippet(summary: "Hello World", favorite: true)
        s1.folder = folderA
        let s2 = makeSnippet(summary: "Goodbye World", favorite: false)
        s2.folder = folderA
        let s3 = makeSnippet(summary: "Hello Again", favorite: true)
        s3.folder = folderB
        let s4 = makeSnippet(summary: "No folder item", favorite: false)

        items = [s1, s2, s3, s4]
    }

    @Test
    func displayedItems_noFilters_returnsAll() {
        let result = sut.displayedItems(from: items)
        #expect(result.count == 4)
    }

    @Test
    func displayedItems_favoritesOnly_filtersNonFavorites() {
        sut.showOnlyFavorites = true
        let result = sut.displayedItems(from: items)
        #expect(result.count == 2)
        #expect(result.allSatisfy { $0.favorite })
    }

    @Test
    func displayedItems_selectedFolder_filtersOtherFolders() {
        sut.selectedFolderId = folderA.id
        let result = sut.displayedItems(from: items)
        #expect(result.count == 2)
        #expect(result.allSatisfy { $0.folder?.id == folderA.id })
    }

    @Test
    func displayedItems_selectedFolder_excludesUnfolderedItems() {
        sut.selectedFolderId = folderA.id
        let result = sut.displayedItems(from: items)
        #expect(!result.contains { $0.folder == nil })
    }

    @Test
    func displayedItems_searchText_matchesCaseInsensitive() {
        sut.searchText = "hello"
        let result = sut.displayedItems(from: items)
        #expect(result.count == 2)
        #expect(result.allSatisfy { $0.summary.localizedCaseInsensitiveContains("hello") })
    }

    @Test
    func displayedItems_searchText_emptyMatchesAll() {
        sut.searchText = ""
        let result = sut.displayedItems(from: items)
        #expect(result.count == 4)
    }

    @Test
    func displayedItems_combinedFilters_favoritesAndFolder() {
        sut.showOnlyFavorites = true
        sut.selectedFolderId = folderA.id
        let result = sut.displayedItems(from: items)
        #expect(result.count == 1)
        #expect(result.first?.summary == "Hello World")
    }

    @Test
    func displayedItems_combinedFilters_favoritesAndSearch() {
        sut.showOnlyFavorites = true
        sut.searchText = "again"
        let result = sut.displayedItems(from: items)
        #expect(result.count == 1)
        #expect(result.first?.summary == "Hello Again")
    }

    @Test
    func displayedItems_allFilters_combined() {
        sut.showOnlyFavorites = true
        sut.selectedFolderId = folderB.id
        sut.searchText = "hello"
        let result = sut.displayedItems(from: items)
        #expect(result.count == 1)
        #expect(result.first?.summary == "Hello Again")
    }
}
