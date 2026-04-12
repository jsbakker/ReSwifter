//
//  SnippetViewModelFilterTests.swift
//  ReSwifterTests
//
//  Created by Jeffrey Bakker on 2026-04-11.
//

import XCTest
import SwiftData
@testable import ReSwifter

@MainActor
final class SnippetViewModelFilterTests: XCTestCase {

    var sut: SnippetViewModel!
    var folderA: FolderItem!
    var folderB: FolderItem!
    var items: [SnippetItem]!

    override func setUp() {
        super.setUp()
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

    override func tearDown() {
        sut = nil
        items = nil
        super.tearDown()
    }

    func test_displayedItems_noFilters_returnsAll() {
        let result = sut.displayedItems(from: items)
        XCTAssertEqual(result.count, 4)
    }

    func test_displayedItems_favoritesOnly_filtersNonFavorites() {
        sut.showOnlyFavorites = true
        let result = sut.displayedItems(from: items)
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.allSatisfy { $0.favorite })
    }

    func test_displayedItems_selectedFolder_filtersOtherFolders() {
        sut.selectedFolderId = folderA.id
        let result = sut.displayedItems(from: items)
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.allSatisfy { $0.folder?.id == folderA.id })
    }

    func test_displayedItems_selectedFolder_excludesUnfolderedItems() {
        sut.selectedFolderId = folderA.id
        let result = sut.displayedItems(from: items)
        XCTAssertFalse(result.contains { $0.folder == nil })
    }

    func test_displayedItems_searchText_matchesCaseInsensitive() {
        sut.searchText = "hello"
        let result = sut.displayedItems(from: items)
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.allSatisfy { $0.summary.localizedCaseInsensitiveContains("hello") })
    }

    func test_displayedItems_searchText_emptyMatchesAll() {
        sut.searchText = ""
        let result = sut.displayedItems(from: items)
        XCTAssertEqual(result.count, 4)
    }

    func test_displayedItems_combinedFilters_favoritesAndFolder() {
        sut.showOnlyFavorites = true
        sut.selectedFolderId = folderA.id
        let result = sut.displayedItems(from: items)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.summary, "Hello World")
    }

    func test_displayedItems_combinedFilters_favoritesAndSearch() {
        sut.showOnlyFavorites = true
        sut.searchText = "again"
        let result = sut.displayedItems(from: items)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.summary, "Hello Again")
    }

    func test_displayedItems_allFilters_combined() {
        sut.showOnlyFavorites = true
        sut.selectedFolderId = folderB.id
        sut.searchText = "hello"
        let result = sut.displayedItems(from: items)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.summary, "Hello Again")
    }
}
