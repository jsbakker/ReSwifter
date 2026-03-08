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

@Observable class SnippetItem : Identifiable {
    let id = UUID()
    let date: Date = Date()
    var description: String = "Generating description..."
    var fullText: String
    var hasDescription: Bool = false

    init(fullText: String) {
        self.fullText = fullText
    }
}

struct HUDNotification: View {
    let text: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 30))
            Text(text)
                .fontWeight(.medium)
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(radius: 10)
        .transition(.opacity.combined(with: .scale)) // Smooth entrance
    }
}

struct ContentView: View {
    @EnvironmentObject private var extensionService: ExtensionXPCService

    @State private var source: String = "" // = extensionService.receivedText ?? ""

    @State private var selectedSnipetId: UUID?

    var selectedSnippet: SnippetItem? {
        items.first { $0.id == selectedSnipetId }
    }

    let pasteBoard = NSPasteboard.general

    @State private var showHud = false

    @State private var items: [SnippetItem] = []
//    @State private var items = [
//        SnippetItem(fullText: "Foo bar baz"),
//        SnippetItem(fullText: "Bar baz qux"),
//        SnippetItem(fullText: "Baz qux quux"),
//        SnippetItem(fullText: "Corge grault garply"),
//        SnippetItem(fullText: "Garply biz burp"),
//        SnippetItem(fullText: "Grault blimity plugh"),
//        SnippetItem(fullText: "Quux plugh thud"),
//        SnippetItem(fullText: "Quux thud waldo"),
//        SnippetItem(fullText: "Waldo quux thud"),
//        SnippetItem(fullText: "Plugh thud waldo"),
//        SnippetItem(fullText: "Baz qux quux waldo"),
//        SnippetItem(fullText: "Foo bar baz quux"),
//        SnippetItem(fullText: "Foo bar baz quux quux"),
//        SnippetItem(fullText: "Foo bar baz quux quux waldo"),
//        SnippetItem(fullText: "Foo bar baz quux quux quux")
//    ]

    var sortedItems: [SnippetItem] {
        items.sorted { lhs, rhs in
            lhs.date > rhs.date
        }
    }

    let dateFormatter = DateFormatter()

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

    var body: some View {
        HStack(spacing: 16) {

            VStack {
                Button("Add Snippet") {
                    var newItem = SnippetItem(fullText: sampleMultilineText)
                    items.append(newItem)

                    Task {
                        newItem.description = await SnippetUtility.analyzeDescription(newItem.fullText)
                        newItem.hasDescription = true
                    }
                }
                .buttonStyle(.borderedProminent)

                ZStack {
                    List(sortedItems, selection: $selectedSnipetId) { item in

                        HStack {
                            Image(systemName: "text.magnifyingglass")
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
                            Button("Copy", systemImage: "doc.on.doc") {
                                pasteBoard.clearContents()
                                pasteBoard.setString(item.fullText, forType: .string)
                                triggerHUD()
                            }
                            .buttonStyle(.borderless)

//                            Button("View", systemImage: "text.magnifyingglass") {
//                                extensionService.receivedText = item.fullText
//                                extensionService.hasPendingRequest = true
//                            }
//                            .buttonStyle(.borderless)
                        }  // HStack
                    }
                    .onChange(of: selectedSnipetId) {
                        if let snippet = selectedSnippet {
                            extensionService.receivedText = snippet.fullText
                            extensionService.hasPendingRequest = true
                        }
                    }  // end List

                    if showHud {
                        HUDNotification(text: "Copied to clipboard", icon: "doc.on.doc")
                            .zIndex(1)
                    }
                }
                .animation(.spring(), value: showHud)
                // End ZStack
            } // End VStack

            VStack {
                if extensionService.hasPendingRequest {
                    Text("Text received from Xcode extension:")
                        .font(.headline)

                    CodeEditor(source: extensionService.receivedText ?? "", language: .swift, theme: .ocean)
                    //                    CodeEditor(source: $source, language: .swift)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()

                    HStack {
                        Button("Cancel") {
                            extensionService.cancelResponse()
                        }

                        Spacer()

                        Button("Send Back") {
                            if let text = extensionService.receivedText {
                                extensionService.sendResponse(text)
                            }
                        }
                        .keyboardShortcut(.return, modifiers: .command)
                    }
                } else {
                    Spacer()
                    Text("Waiting for text from Xcode extension...")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }  // VStack
        }
        .padding()
        .frame(minWidth: 400, minHeight: 300)
    }
}

#Preview {
    ContentView()
        .environmentObject(ExtensionXPCService())
}
