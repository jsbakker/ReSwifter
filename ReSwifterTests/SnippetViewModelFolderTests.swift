//
//  SnippetViewModelFolderTests.swift
//  ReSwifterTests
//
//  Created by Jeffrey Bakker on 2026-04-11.
//

import XCTest
import SwiftData
@testable import ReSwifter

@MainActor
final class SnippetViewModelFolderTests: XCTestCase {

    var sut: SnippetViewModel!

    override func setUp() {
        super.setUp()
        sut = SnippetViewModel()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - validateFolderSelection

    func test_validateFolderSelection_existingFolder_keepsSelection() {
        let folder = makeFolder(name: "Utils")
        sut.selectedFolderId = folder.id
        sut.validateFolderSelection(folders: [folder])
        XCTAssertEqual(sut.selectedFolderId, folder.id)
    }

    func test_validateFolderSelection_missingFolder_resetsToNil() {
        sut.selectedFolderId = UUID()
        let folder = makeFolder(name: "Utils")
        sut.validateFolderSelection(folders: [folder])
        XCTAssertNil(sut.selectedFolderId)
    }

    func test_validateFolderSelection_alreadyNil_staysNil() {
        sut.selectedFolderId = nil
        let folder = makeFolder(name: "Utils")
        sut.validateFolderSelection(folders: [folder])
        XCTAssertNil(sut.selectedFolderId)
    }

    func test_validateFolderSelection_emptyFolderList_resetsToNil() {
        sut.selectedFolderId = UUID()
        sut.validateFolderSelection(folders: [])
        XCTAssertNil(sut.selectedFolderId)
    }

    // MARK: - selectedFolderItem

    func test_selectedFolderItem_matchingId_returnsFolder() {
        let folder = makeFolder(name: "Utils")
        sut.selectedFolderId = folder.id
        let result = sut.selectedFolderItem(from: [folder])
        XCTAssertEqual(result?.id, folder.id)
    }

    func test_selectedFolderItem_noSelection_returnsNil() {
        sut.selectedFolderId = nil
        let folder = makeFolder(name: "Utils")
        XCTAssertNil(sut.selectedFolderItem(from: [folder]))
    }

    func test_selectedFolderItem_wrongId_returnsNil() {
        sut.selectedFolderId = UUID()
        let folder = makeFolder(name: "Utils")
        XCTAssertNil(sut.selectedFolderItem(from: [folder]))
    }

    func test_selectedFolderItem_multipleFolders_returnsCorrectOne() {
        let folderA = makeFolder(name: "Swift")
        let folderB = makeFolder(name: "Python")
        sut.selectedFolderId = folderB.id
        let result = sut.selectedFolderItem(from: [folderA, folderB])
        XCTAssertEqual(result?.name, "Python")
    }

    // MARK: - selectedSnippet

    func test_selectedSnippet_matchingId_returnsSnippet() {
        let snippet = makeSnippet(summary: "Test")
        sut.selectedSnippetId = snippet.id
        let result = sut.selectedSnippet(from: [snippet])
        XCTAssertEqual(result?.id, snippet.id)
    }

    func test_selectedSnippet_noSelection_returnsNil() {
        sut.selectedSnippetId = nil
        let snippet = makeSnippet(summary: "Test")
        XCTAssertNil(sut.selectedSnippet(from: [snippet]))
    }

    func test_selectedSnippet_wrongId_returnsNil() {
        sut.selectedSnippetId = UUID()
        let snippet = makeSnippet(summary: "Test")
        XCTAssertNil(sut.selectedSnippet(from: [snippet]))
    }

    // MARK: - renameFolder

    func test_renameFolder_validName_updatesName() {
        let folder = makeFolder(name: "Old")
        sut.renameFolder(folder, to: "New", allFolders: [folder])
        XCTAssertEqual(folder.name, "New")
    }

    func test_renameFolder_emptyName_doesNotUpdate() {
        let folder = makeFolder(name: "Utils")
        sut.renameFolder(folder, to: "   ", allFolders: [folder])
        XCTAssertEqual(folder.name, "Utils")
    }

    func test_renameFolder_duplicateName_doesNotUpdate() {
        let folderA = makeFolder(name: "Utils")
        let folderB = makeFolder(name: "Other")
        sut.renameFolder(folderB, to: "Utils", allFolders: [folderA, folderB])
        XCTAssertEqual(folderB.name, "Other")
    }

    func test_renameFolder_sameNameAsSelf_succeeds() {
        let folder = makeFolder(name: "Utils")
        sut.renameFolder(folder, to: "Utils", allFolders: [folder])
        XCTAssertEqual(folder.name, "Utils")
    }

    func test_renameFolder_trimsWhitespace() {
        let folder = makeFolder(name: "Old")
        sut.renameFolder(folder, to: "  New  ", allFolders: [folder])
        XCTAssertEqual(folder.name, "New")
    }
}
