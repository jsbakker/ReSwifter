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

    @State private var source: String = "" // = extensionService.receivedText ?? ""
    @State private var selectedSnipetId: UUID?
    @State private var items: [SnippetItem] = []
    @State private var showOnlyFavorites = false
    @State private var showHud = false

    let dateFormatter = DateFormatter()
    let pasteBoard = NSPasteboard.general
    let snippetUtility = SnippetUtility()

    var selectedSnippet: SnippetItem? {
        items.first { $0.id == selectedSnipetId }
    }

    // todo apply filter
    var displayedItems: [SnippetItem] {
        items
            .filter { !showOnlyFavorites || $0.favorite }
            .sorted { lhs, rhs in
                lhs.date > rhs.date
            }
    }

    let sampleMultilineText = """
        func registerAppWait(reply: @escaping (String) -> Void) {
            queue.async {
                if let text = self.pendingText {
                    // Work is already queued — deliver immediately
                    self.pendingText = nil
                    reply(text)
                } else {
                    // No work yet — hold the reply until extension submits
                    self.appWaitReply = reply
                }
            }
        }
        """

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

        var newItem = SnippetItem(fullText: fullText)
        items.append(newItem)
        selectedSnipetId = newItem.id

        Task {
//                        newItem.description = await SnippetUtility.analyzeDescription(newItem.fullText)
            newItem.description = await snippetUtility.summarize(newItem.fullText)
            newItem.hasDescription = true
        }
    }

    var body: some View {
        HStack(spacing: 16) {

//            if extensionService.hasPendingRequest {
//                var insertedItem = SnippetItem(fullText: extensionService.receivedText!)
//                items.append(insertedItem)
//
//                Task {
//                    insertedItem.description = await SnippetUtility.analyzeDescription(insertedItem.fullText)
//                    insertedItem.hasDescription = true
//                }
//            }

            VStack {
                Button("Add Snippet") {
                    addNewSnippet(fullText: sampleMultilineText)
//                    var newItem = SnippetItem(fullText: sampleMultilineText)
//                    items.append(newItem)
//                    selectedSnipetId = newItem.id
//
//                    Task {
////                        newItem.description = await SnippetUtility.analyzeDescription(newItem.fullText)
//                        newItem.description = await snippetUtility.summarize(newItem.fullText)
//                        newItem.hasDescription = true
//                    }
                }
                .buttonStyle(.borderedProminent)

                Button("Add From Clipboard") {
                    let pasted = pasteBoard.string(forType: .string)
                    guard let pasted else { return }

                    addNewSnippet(fullText: pasted)
                }

                Button("Filter", systemImage: showOnlyFavorites ? "heart.fill" : "heart") {
                    showOnlyFavorites.toggle()
                }
//                .buttonStyle(.borderless)

                ZStack {
                    List(displayedItems, selection: $selectedSnipetId) { item in

                        HStack {
                            Image(systemName: "text.magnifyingglass")
                                .buttonStyle(.borderless)

                            if !item.hasDescription {
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
                            if !item.hasDescription {
                                ProgressView()
                                    .controlSize(.small)
                            }

                            VStack {
                                Text(item.description).font(.headline)
                                Text(dateFormatter.string(from: item.date)).font(.subheadline)
                            }
//                            if !item.hasDescription {
//                                ProgressView()
//                                    .controlSize(.small)
//                            }

                            Spacer()
//                            Image(systemName: "text.magnifyingglass")
//                            Button("Copy", systemImage: "doc.on.doc") {
//                                pasteBoard.clearContents()
//                                pasteBoard.setString(item.fullText, forType: .string)
//                                triggerHUD()
//                            }
//                            .buttonStyle(.borderless)

                            Button {
                                item.favorite.toggle()
                            } label: {
                                Image(systemName: item.favorite ? "heart.fill" : "heart")
                                    .foregroundStyle(item.favorite ? .red : .gray)
                            }
                            .buttonStyle(.borderless)

                            Button("Copy", systemImage: "doc.on.doc") {
                                pasteBoard.clearContents()
                                pasteBoard.setString(item.fullText, forType: .string)
                                triggerHUD()
                            }
                            .buttonStyle(.borderless)

                            Button("Delete", systemImage: "trash") {
                                items.removeAll { $0.id == item.id }
                            }
                            .buttonStyle(.borderless)

//                            Button("View", systemImage: "text.magnifyingglass") {
//                                extensionService.receivedText = item.fullText
//                                extensionService.hasPendingRequest = true
//                            }
//                            .buttonStyle(.borderless)
                        }  // HStack
                    }
                    .animation(.default, value: items)
                    .onChange(of: extensionService.receivedText ?? "") {
                        addNewSnippet(fullText: extensionService.receivedText!)
//                        var insertedItem = SnippetItem(fullText: extensionService.receivedText!)
//                        items.append(insertedItem)
//                        selectedSnipetId = insertedItem.id
////                        extensionService.cancelResponse()
//
//                        Task {
//                            insertedItem.description = await snippetUtility.summarize(insertedItem.fullText)
//                            insertedItem.hasDescription = true
//                        }
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
                CodeEditor(source: selectedSnippet?.fullText ?? "", language: .swift, theme: .ocean)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
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
        }
        .padding()
        .frame(minWidth: 400, minHeight: 300)
    }
}

#Preview {
    ContentView()
        .environmentObject(ExtensionXPCService())
}
