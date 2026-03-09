//
//  ContentView.swift
//  ReSwifter
//
//  Created by Jeffrey Bakker on 2026-02-27.
//

import AppKit
import SwiftUI
import SwiftData
import CodeEditor

struct ContentView: View {
    @EnvironmentObject private var extensionService: ExtensionXPCService

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SnippetItem.date, order: .reverse) private var items: [SnippetItem]

    @State private var source: String = ""
    @State private var selectedSnipetId: UUID?
    @State private var showOnlyFavorites = false
    @State private var showHud = false
    @State private var editSummaryItemId: UUID?
    @State private var editSummaryText = ""
    @State private var showNewFolderPrompt = false
    @State private var newFolderName = ""
    @State private var selectedFolderId: UUID?

    @Query(sort: \FolderItem.name) private var folders: [FolderItem]

    var selectedFolderItem: FolderItem? {
        guard let id = selectedFolderId else { return nil }
        return folders.first { $0.id == id }
    }

    let dateFormatter = DateFormatter()
    let pasteBoard = NSPasteboard.general
    let snippetUtility = SnippetUtility()

    var selectedSnippet: SnippetItem? {
        items.first { $0.id == selectedSnipetId }
    }

    var displayedItems: [SnippetItem] {
        items.filter {
            (!showOnlyFavorites || $0.favorite) &&
            (selectedFolderId == nil || $0.folder?.id == selectedFolderId)
        }
    }

    init() {
        dateFormatter.dateFormat = "yyyy/MM/dd - HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    }

    func triggerHUD () {
        showHud = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showHud = false
        }
    }

    func addNewSnippet(fullText: String) {

        let newItem = SnippetItem(fullText: fullText)
        newItem.folder = selectedFolderItem
        newItem.pendingUpdate = true
        modelContext.insert(newItem)
        selectedSnipetId = newItem.id

        Task {
            newItem.summary = await snippetUtility.summarize(newItem.fullText)
            newItem.pendingUpdate = false
        }
    }

    /// Extracts code from inside triple-backtick fenced code blocks if present.
    /// If no fenced block is found, returns the original text unchanged.
    func extractCode(from text: String) -> String {
        // Match ```<optional language/version>\n...\n```
        let pattern = "```[^\\n]*\\n([\\s\\S]*?)```"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              let codeRange = Range(match.range(at: 1), in: text) else {
            return text
        }
        return String(text[codeRange])
    }

    func addUpdatedSnippet(summary: String, fullText: String) {

        let newItem = SnippetItem(summary: summary, fullText: fullText)
        newItem.folder = selectedFolderItem
        modelContext.insert(newItem)
        selectedSnipetId = newItem.id
    }

    var body: some View {
        HStack(spacing: 16) {

//            if extensionService.hasPendingRequest {
//                addNewSnippet(extensionService.receivedText!)
//            }

            VStack {

                HStack {
//                    Button("Add Snippet") {
//                        addNewSnippet(fullText: sampleMultilineText)
//                    }
//                    .buttonStyle(.borderedProminent)

                    Menu {
                        Button {
                            selectedFolderId = nil
                        } label: {
                            if selectedFolderId == nil {
                                Label("All", systemImage: "checkmark")
                            } else {
                                Text("All")
                            }
                        }

                        Divider()

                        ForEach(folders) { folder in
                            Button {
                                selectedFolderId = folder.id
                            } label: {
                                if selectedFolderId == folder.id {
                                    Label(folder.name, systemImage: "checkmark")
                                } else {
                                    Text(folder.name)
                                }
                            }
                        }

                        Divider()

                        Button("New Folder...", systemImage: "folder.badge.plus") {
                            newFolderName = ""
                            showNewFolderPrompt = true
                        }
                    } label: {
                        Image(systemName: "folder")
                        Text(selectedFolderItem?.name ?? "All")
                    }

                    Button("Add From Clipboard") {
                        let pasted = pasteBoard.string(forType: .string)
                        guard let pasted else { return }

                        addNewSnippet(fullText: pasted)
                    }
                    .buttonStyle(.borderedProminent)

                    Spacer()

                    Button("Filter", systemImage: showOnlyFavorites ? "heart.fill" : "heart") {
                        showOnlyFavorites.toggle()
                    }
                    .buttonStyle(.borderedProminent)
                }

                ZStack {
                    List(displayedItems, selection: $selectedSnipetId) { item in

                        HStack {
                            Image(systemName: "text.magnifyingglass")
                                .buttonStyle(.borderless)

                            if item.pendingUpdate {
                                Image(systemName: "sparkles")
                                    .font(.largeTitle)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.blue, .purple, .pink],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }

                            VStack(alignment: .leading) {
                                Text(item.summary).font(.subheadline).bold()
                                Text(dateFormatter.string(from: item.date)).font(.caption)
                            }

                            if item.pendingUpdate {
                                ProgressView()
                                    .controlSize(.small)
                            }

                            Spacer()

                            Button {
                                item.favorite.toggle()
                            } label: {
                                Image(systemName: item.favorite ? "heart.fill" : "heart")
                                    .foregroundStyle(item.favorite ? .red : .gray)
                            }
                            .buttonStyle(.borderless)
//                            .disabled(item.pendingUpdate)

                            Button("Copy", systemImage: "doc.on.doc") {
                                pasteBoard.clearContents()
                                pasteBoard.setString(extractCode(from: item.fullText), forType: .string)
                                triggerHUD()
                            }
//                            .buttonStyle(.borderless)
//                            .disabled(item.pendingUpdate)

                            Button("Delete", systemImage: "trash", role: .destructive) {
                                modelContext.delete(item)
                            }
//                            .buttonStyle(.borderless)
                            .disabled(item.pendingUpdate)

                            Divider()

                            Menu {
                                Button("Cleanup", systemImage: "wand.and.stars") {
                                    item.pendingUpdate = true
                                    Task {
                                        let newDesc = "Cleaned up: \(item.summary)"
                                        let newText = await snippetUtility.cleanup(item.fullText)
                                        item.pendingUpdate = false
                                        addUpdatedSnippet(summary: newDesc, fullText: newText)
                                    }
                                }
                                .disabled(item.pendingUpdate)

                                Button("Refactor", systemImage: "lightbulb") {
                                    item.pendingUpdate = true
                                    Task {
                                        let newDesc = "Refactored: \(item.summary)"
                                        let newText = await snippetUtility.refactor(item.fullText)
                                        item.pendingUpdate = false
                                        addUpdatedSnippet(summary: newDesc, fullText: newText)
                                    }
                                }
                                .disabled(item.pendingUpdate)

                                Button("Convert", systemImage: "brain") {
                                    item.pendingUpdate = true
                                    Task {
                                        let newDesc = "Converted: \(item.summary)"
                                        let newText = await snippetUtility.convert(item.fullText)
                                        item.pendingUpdate = false
                                        addUpdatedSnippet(summary: newDesc, fullText: newText)
                                    }
                                }
                                .disabled(item.pendingUpdate)

                                Button("Document", systemImage: "document") {
                                    item.pendingUpdate = true
                                    Task {
                                        let newDesc = "Documented: \(item.summary)"
                                        let newText = await snippetUtility.document(item.fullText)
                                        item.pendingUpdate = false
                                        addUpdatedSnippet(summary: newDesc, fullText: newText)
                                    }
                                }
                                .disabled(item.pendingUpdate)

                                Divider()

                                Button("Edit Summary...", systemImage: "square.and.pencil") {
                                    editSummaryText = item.summary
                                    editSummaryItemId = item.id
                                }
                            } label: {
                                Image(systemName: "sparkles")
                                    .foregroundStyle(item.favorite ? .red : .gray)
                                Text("More")
                            }
//                            .menuStyle(.borderlessButton)
//                            .menuIndicator(.hidden)

                        }  // HStack
                    }
                    .animation(.default, value: displayedItems.map(\.id))
                    .onChange(of: extensionService.receivedText ?? "") {
                        if let text = extensionService.receivedText, !text.isEmpty {
                            addNewSnippet(fullText: text)
                        }
                    }
//                    .onChange(of: selectedSnipetId) {
//                        if let snippet = selectedSnippet {
//                            extensionService.receivedText = snippet.fullText
//                            extensionService.hasPendingRequest = true
//                        }
//                    }  // end List

                    if showHud {
                        HudNotification(text: "Copied to clipboard", icon: "doc.on.doc")
                            .zIndex(1)
                    }
                }
                .animation(.spring(), value: showHud)
                // End ZStack
            } // End VStack


            VStack {
                if extensionService.hasPendingRequest {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                        Text("""
                            The XCode extension is requesting to modify its current file or selection.
                            """)

                        Spacer()

                        Button("Cancel Text Replacement") {
                            extensionService.cancelResponse()
                        }
                        .buttonStyle(.borderedProminent)

                        Button("Send Selected Snippet to XCode") {
                            let fullText = selectedSnippet?.fullText ?? ""
                            extensionService.sendResponse(extractCode(from: fullText))
                        }
                        .buttonStyle(.borderedProminent)
                        .keyboardShortcut(.return, modifiers: .command)
                    }
                    .keyboardShortcut(.return, modifiers: .command)
                }

                CodeEditor(source: selectedSnippet?.fullText ?? "", language: .swift, theme: .ocean)
                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding()
            }  // End VStack

//            VStack {
//                if extensionService.hasPendingRequest {
//                    Text("Text received from Xcode extension:")
//                        .font(.headline)
//
//                    CodeEditor(source: extensionService.receivedText ?? "", language: .swift, theme: .ocean)
//                    //                    CodeEditor(source: $source, language: .swift)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .padding()
//
//                    HStack {
//                        Button("Cancel") {
//                            extensionService.cancelResponse()
//                        }
//
//                        Spacer()
//
//                        Button("Send Back") {
//                            if let text = extensionService.receivedText {
//                                extensionService.sendResponse(text)
//                            }
//                        }
//                        .keyboardShortcut(.return, modifiers: .command)
//                    }
//                } else {
//                    Spacer()
//                    Text("Waiting for text from Xcode extension...")
//                        .foregroundStyle(.secondary)
//                    Spacer()
//                }
//            }  // VStack
        }  // HStack
        .padding()
        .frame(minWidth: 400, minHeight: 300)
        .sheet(isPresented: Binding(
            get: { editSummaryItemId != nil },
            set: { if !$0 { editSummaryItemId = nil } }
        )) {
            VStack(spacing: 12) {
                Text("Edit Summary")
                    .font(.headline)

                TextEditor(text: $editSummaryText)
                    .font(.body)
                    .frame(minHeight: 80)
                    .border(Color.secondary.opacity(0.3))

                HStack {
                    Button("Cancel") {
                        editSummaryItemId = nil
                    }
                    .keyboardShortcut(.escape, modifiers: [])

                    Spacer()

                    Button("Save") {
                        if let id = editSummaryItemId,
                           let item = items.first(where: { $0.id == id }) {
                            item.summary = editSummaryText
                        }
                        editSummaryItemId = nil
                    }
                    .keyboardShortcut(.return, modifiers: .command)
                }
            }
            .padding()
            .frame(minWidth: 400, minHeight: 180)
        }
        .alert("New Folder", isPresented: $showNewFolderPrompt) {
            TextField("Folder name", text: $newFolderName)
            Button("Create") {
                let name = newFolderName.trimmingCharacters(in: .whitespaces)
                if !name.isEmpty && !folders.contains(where: { $0.name == name }) {
                    let folder = FolderItem(name: name)
                    modelContext.insert(folder)
                    selectedFolderId = folder.id
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }  // View
}

#Preview {
    ContentView()
        .environmentObject(ExtensionXPCService())
        .modelContainer(for: [SnippetItem.self, FolderItem.self], inMemory: true)
}
