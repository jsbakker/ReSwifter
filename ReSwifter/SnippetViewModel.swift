//
//  SnippetViewModel.swift
//  ReSwifter
//
//  Created by Jeffrey Bakker on 2026-03-09.
//

import AppKit
import Combine
import Foundation
import SwiftData

@MainActor
class SnippetViewModel: ObservableObject {

    // MARK: - Published State

    @Published var selectedSnippetId: UUID?
    @Published var showOnlyFavorites = false
    @Published var showHud = false
    @Published var editSummaryItemId: UUID?
    @Published var editSummaryText = ""
    @Published var showNewFolderPrompt = false
    @Published var newFolderName = ""
    @Published var selectedFolderId: UUID?
    @Published var searchText = ""
    @Published var pendingItemIds: Set<UUID> = []
    @Published var aiAvailable: Bool

    // MARK: - Dependencies

    let snippetUtility = SnippetUtility()
    let pasteBoard = NSPasteboard.general
    let dateFormatter: DateFormatter

    // MARK: - Init

    init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd - HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        aiAvailable = snippetUtility.isAvailable
    }

    // MARK: - Computed

    func selectedFolderItem(from folders: [FolderItem]) -> FolderItem? {
        guard let id = selectedFolderId else { return nil }
        return folders.first { $0.id == id }
    }

    func selectedSnippet(from items: [SnippetItem]) -> SnippetItem? {
        items.first { $0.id == selectedSnippetId }
    }

    func displayedItems(from items: [SnippetItem]) -> [SnippetItem] {
        items.filter {
            (!showOnlyFavorites || $0.favorite) &&
            (selectedFolderId == nil || $0.folder?.id == selectedFolderId) &&
            (searchText.isEmpty || $0.summary.localizedCaseInsensitiveContains(searchText))
        }
    }

    // MARK: - Actions

    func openAppleIntelligenceSettings() {
        let urlString = "x-apple.systempreferences:com.apple.Siri"
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }

    func addNewSnippet(fullText: String, modelContext: ModelContext, folders: [FolderItem]) {
        let newItem = SnippetItem(fullText: fullText)
        newItem.folder = selectedFolderItem(from: folders)
        pendingItemIds.insert(newItem.id)
        modelContext.insert(newItem)
        selectedSnippetId = newItem.id

        Task {
            newItem.summary = await snippetUtility.summarize(newItem.fullText)
            pendingItemIds.remove(newItem.id)
        }
    }

    func addUpdatedSnippet(summary: String, fullText: String, modelContext: ModelContext, folders: [FolderItem]) {
        let newItem = SnippetItem(summary: summary, fullText: fullText)
        newItem.folder = selectedFolderItem(from: folders)
        modelContext.insert(newItem)
        selectedSnippetId = newItem.id
    }

    func addFromClipboard(modelContext: ModelContext, folders: [FolderItem]) {
        guard let pasted = pasteBoard.string(forType: .string) else { return }
        addNewSnippet(fullText: pasted, modelContext: modelContext, folders: folders)
    }

    // MARK: - AI Actions

    func performAIAction(
        on item: SnippetItem,
        summaryPrefix: String,
        transform: @escaping (SnippetUtility, String) async -> String,
        modelContext: ModelContext,
        folders: [FolderItem]
    ) {
        pendingItemIds.insert(item.id)
        Task {
            let newDesc = "\(summaryPrefix): \(item.summary)"
            let newText = await transform(snippetUtility, item.fullText)
            pendingItemIds.remove(item.id)
            addUpdatedSnippet(summary: newDesc, fullText: newText, modelContext: modelContext, folders: folders)
        }
    }

    func cleanup(_ item: SnippetItem, modelContext: ModelContext, folders: [FolderItem]) {
        performAIAction(on: item, summaryPrefix: "Cleaned up", transform: { await $0.cleanup($1) }, modelContext: modelContext, folders: folders)
    }

    func refactor(_ item: SnippetItem, modelContext: ModelContext, folders: [FolderItem]) {
        performAIAction(on: item, summaryPrefix: "Refactored", transform: { await $0.refactor($1) }, modelContext: modelContext, folders: folders)
    }

    func convert(_ item: SnippetItem, modelContext: ModelContext, folders: [FolderItem]) {
        performAIAction(on: item, summaryPrefix: "Converted", transform: { await $0.convert($1) }, modelContext: modelContext, folders: folders)
    }

    func document(_ item: SnippetItem, modelContext: ModelContext, folders: [FolderItem]) {
        performAIAction(on: item, summaryPrefix: "Documented", transform: { await $0.document($1) }, modelContext: modelContext, folders: folders)
    }

    func review(_ item: SnippetItem, modelContext: ModelContext, folders: [FolderItem]) {
        performAIAction(on: item, summaryPrefix: "Reviewed", transform: { await $0.review($1) }, modelContext: modelContext, folders: folders)
    }

    func triggerHUD() {
        showHud = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.showHud = false
        }
    }

    func copySnippet(_ item: SnippetItem) {
        pasteBoard.clearContents()
        pasteBoard.setString(extractCode(from: item.fullText), forType: .string)
        triggerHUD()
    }

    func createFolder(modelContext: ModelContext, folders: [FolderItem]) {
        let name = newFolderName.trimmingCharacters(in: .whitespaces)
        if !name.isEmpty && !folders.contains(where: { $0.name == name }) {
            let folder = FolderItem(name: name)
            modelContext.insert(folder)
            selectedFolderId = folder.id
        }
    }

    func beginEditSummary(for item: SnippetItem) {
        editSummaryText = item.summary
        editSummaryItemId = item.id
    }

    func saveSummary(items: [SnippetItem]) {
        if let id = editSummaryItemId,
           let item = items.first(where: { $0.id == id }) {
            item.summary = editSummaryText
        }
        editSummaryItemId = nil
    }

    // MARK: - Utilities

    func extractCode(from text: String) -> String {
        let pattern = "```[^\\n]*\\n([\\s\\S]*?)```"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              let codeRange = Range(match.range(at: 1), in: text) else {
            return text
        }
        return String(text[codeRange])
    }
}
