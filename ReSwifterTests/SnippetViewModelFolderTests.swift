//
//  SnippetViewModelFolderTests.swift
//  ReSwifterTests
//
//  Created by Jeffrey Bakker on 2026-04-11.
//

import Testing
import Foundation
import SwiftData
@testable import ReSwifter

@MainActor
struct SnippetViewModelFolderTests {

    var sut: SnippetViewModel

    init() {
        sut = SnippetViewModel()
    }

    // MARK: - validateFolderSelection

    @Test
    func validateFolderSelection_existingFolder_keepsSelection() {
        let folder = makeFolder(name: "Utils")
        sut.selectedFolderId = folder.id
        sut.validateFolderSelection(folders: [folder])
        #expect(sut.selectedFolderId == folder.id)
    }

    @Test
    func validateFolderSelection_missingFolder_resetsToNil() {
        sut.selectedFolderId = UUID()
        let folder = makeFolder(name: "Utils")
        sut.validateFolderSelection(folders: [folder])
        #expect(sut.selectedFolderId == nil)
    }

    @Test
    func validateFolderSelection_alreadyNil_staysNil() {
        sut.selectedFolderId = nil
        let folder = makeFolder(name: "Utils")
        sut.validateFolderSelection(folders: [folder])
        #expect(sut.selectedFolderId == nil)
    }

    @Test
    func validateFolderSelection_emptyFolderList_resetsToNil() {
        sut.selectedFolderId = UUID()
        sut.validateFolderSelection(folders: [])
        #expect(sut.selectedFolderId == nil)
    }

    // MARK: - selectedFolderItem

    @Test
    func selectedFolderItem_matchingId_returnsFolder() {
        let folder = makeFolder(name: "Utils")
        sut.selectedFolderId = folder.id
        let result = sut.selectedFolderItem(from: [folder])
        #expect(result?.id == folder.id)
    }

    @Test
    func selectedFolderItem_noSelection_returnsNil() {
        sut.selectedFolderId = nil
        let folder = makeFolder(name: "Utils")
        #expect(sut.selectedFolderItem(from: [folder]) == nil)
    }

    @Test
    func selectedFolderItem_wrongId_returnsNil() {
        sut.selectedFolderId = UUID()
        let folder = makeFolder(name: "Utils")
        #expect(sut.selectedFolderItem(from: [folder]) == nil)
    }

    @Test
    func selectedFolderItem_multipleFolders_returnsCorrectOne() {
        let folderA = makeFolder(name: "Swift")
        let folderB = makeFolder(name: "Python")
        sut.selectedFolderId = folderB.id
        let result = sut.selectedFolderItem(from: [folderA, folderB])
        #expect(result?.name == "Python")
    }

    // MARK: - selectedSnippet

    @Test
    func selectedSnippet_matchingId_returnsSnippet() {
        let snippet = makeSnippet(summary: "Test")
        sut.selectedSnippetId = snippet.id
        let result = sut.selectedSnippet(from: [snippet])
        #expect(result?.id == snippet.id)
    }

    @Test
    func selectedSnippet_noSelection_returnsNil() {
        sut.selectedSnippetId = nil
        let snippet = makeSnippet(summary: "Test")
        #expect(sut.selectedSnippet(from: [snippet]) == nil)
    }

    @Test
    func selectedSnippet_wrongId_returnsNil() {
        sut.selectedSnippetId = UUID()
        let snippet = makeSnippet(summary: "Test")
        #expect(sut.selectedSnippet(from: [snippet]) == nil)
    }

    // MARK: - renameFolder

    @Test
    func renameFolder_validName_updatesName() {
        let folder = makeFolder(name: "Old")
        sut.renameFolder(folder, to: "New", allFolders: [folder])
        #expect(folder.name == "New")
    }

    @Test
    func renameFolder_emptyName_doesNotUpdate() {
        let folder = makeFolder(name: "Utils")
        sut.renameFolder(folder, to: "   ", allFolders: [folder])
        #expect(folder.name == "Utils")
    }

    @Test
    func renameFolder_duplicateName_doesNotUpdate() {
        let folderA = makeFolder(name: "Utils")
        let folderB = makeFolder(name: "Other")
        sut.renameFolder(folderB, to: "Utils", allFolders: [folderA, folderB])
        #expect(folderB.name == "Other")
    }

    @Test
    func renameFolder_sameNameAsSelf_succeeds() {
        let folder = makeFolder(name: "Utils")
        sut.renameFolder(folder, to: "Utils", allFolders: [folder])
        #expect(folder.name == "Utils")
    }

    @Test
    func renameFolder_trimsWhitespace() {
        let folder = makeFolder(name: "Old")
        sut.renameFolder(folder, to: "  New  ", allFolders: [folder])
        #expect(folder.name == "New")
    }
}
