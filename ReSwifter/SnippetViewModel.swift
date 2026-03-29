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
    @Published var showManageFolders = false
    @Published var searchText = ""
    @Published var pendingItemIds: Set<UUID> = []
    @Published var aiAvailable: Bool

    // MARK: - Dependencies

    let snippetUtility = SnippetUtility()
    let pasteBoard = NSPasteboard.general
    let dateFormatter: DateFormatter

    private static let selectedFolderKey = "selectedFolderId"
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd - HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        aiAvailable = snippetUtility.isAvailable

        // Restore persisted folder selection
        if let stored = UserDefaults.standard.string(forKey: Self.selectedFolderKey),
           let uuid = UUID(uuidString: stored) {
            selectedFolderId = uuid
        }

        // Persist folder selection on change
        $selectedFolderId
            .sink { newValue in
                UserDefaults.standard.set(newValue?.uuidString, forKey: Self.selectedFolderKey)
            }
            .store(in: &cancellables)
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

        // Queue up for AI summary generation
        if !fullText.isEmpty {
            pendingItemIds.insert(newItem.id)
        } else {
            newItem.fullText = "// Add some code here..."
            newItem.summary = "Update this description with: More ⮕ Edit Summary..."
        }

        modelContext.insert(newItem)
        selectedSnippetId = newItem.id

        // If folder name is same as supported language name,
        // then new snippet can use that language by default
        for lang in WebCppLanguage.allCases {
            if lang.displayName == newItem.folder?.name {
                newItem.language = lang.rawValue
                break
            }
        }

        if fullText.isEmpty {
            return
        }

        Task {
            newItem.summary = await snippetUtility.summarize(newItem.fullText)
            pendingItemIds.remove(newItem.id)
        }
    }

    func addUpdatedSnippet(summary: String, fullText: String, modelContext: ModelContext, folders: [FolderItem]) {
        let newItem = SnippetItem(summary: summary, fullText: fullText)
        newItem.folder = selectedFolderItem(from: folders)
        newItem.language = "txt"
        newItem.generated = true
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

    func explain(_ item: SnippetItem, modelContext: ModelContext, folders: [FolderItem]) {
        performAIAction(on: item, summaryPrefix: "Explained", transform: { await $0.explain($1) }, modelContext: modelContext, folders: folders)
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

    func renameFolder(_ folder: FolderItem, to newName: String, allFolders: [FolderItem]) {
        let trimmed = newName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty,
              !allFolders.contains(where: { $0.id != folder.id && $0.name == trimmed })
        else { return }
        folder.name = trimmed
    }

    func deleteFolder(_ folder: FolderItem, deleteSnippets: Bool, modelContext: ModelContext) {
        if deleteSnippets {
            for snippet in folder.snippets {
                modelContext.delete(snippet)
            }
        } else {
            for snippet in folder.snippets {
                snippet.folder = nil
            }
        }
        if selectedFolderId == folder.id {
            selectedFolderId = nil
        }
        modelContext.delete(folder)
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
