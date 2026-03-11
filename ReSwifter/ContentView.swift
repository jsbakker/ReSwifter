//
//  ContentView.swift
//  ReSwifter
//
//  Created by Jeffrey Bakker on 2026-02-27.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject private var extensionService: ExtensionXPCService
    @EnvironmentObject private var viewModel: SnippetViewModel

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SnippetItem.date, order: .reverse) private var items: [SnippetItem]
    @Query(sort: \FolderItem.name) private var folders: [FolderItem]

    @State private var selection: UUID?

    var body: some View {
        NavigationStack {
            VStack {
                if !viewModel.aiAvailable {
                    HStack {
                        Image(systemName: "sparkles")
                            .font(.title)
                        Text("AI features are unavailable. Ensure you have Apple Intelligence enabled.\nYou must restart ReSwifter after the Intelligence models are downloaded.")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                        Button("Enable Now") {
                            viewModel.openAppleIntelligenceSettings()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(4)
                }
                HStack(spacing: 16) {
                    // Left side — snippet list
                    if items.isEmpty {
                        VStack(alignment: .center, spacing: 8) {
                            Image(systemName: "doc.on.clipboard")
                                .font(.largeTitle)
                            Text("Press Command + Shift + V to add a\nnew snippet from the clipboard.")
                                .font(.title)
                                .multilineTextAlignment(.center)
                            Text("or")
                                .font(.largeTitle)
                                .multilineTextAlignment(.center)
                            Text("Send selections through the\nReSwifter Editor Extension for XCode.")
                                .font(.title)
                                .multilineTextAlignment(.center)
                            Text("(XCode Menu ⮕ Editor ⮕ ReSwifter)")
                                .font(.headline)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    else {
                        ZStack {
                            List(viewModel.displayedItems(from: items), selection: $selection) { item in
                                SnippetRowView(viewModel: viewModel, item: item)
                            }
                            .animation(.default, value: viewModel.displayedItems(from: items).map(\.id))
                            .onChange(of: selection) {
                                viewModel.selectedSnippetId = selection
                            }
                            .onChange(of: viewModel.selectedSnippetId) {
                                selection = viewModel.selectedSnippetId
                            }
                            if viewModel.showHud {
                                HudNotification(text: "Copied to clipboard", icon: "doc.on.doc")
                                    .zIndex(1)
                            }
                        }  // End ZStack
                        .animation(.spring(), value: viewModel.showHud)
                    }

                    // Right side — code editor + extension bar
                    if !items.isEmpty {
                        SnippetDetailView(
                            viewModel: viewModel,
                            selectedSnippet: viewModel.selectedSnippet(from: items)
                        )
                    }
                }
                .padding()
                .frame(minWidth: 400, minHeight: 300)
                .onChange(of: extensionService.receivedText ?? "") {
                    if let text = extensionService.receivedText, !text.isEmpty {
                        viewModel.addNewSnippet(fullText: text, modelContext: modelContext, folders: folders)
                    }
                }
                .searchable(text: $viewModel.searchText, prompt: "Search snippets")
                .toolbar {
                    SnippetToolbar(viewModel: viewModel)
                }  // HStack
            }  // VStack
        }  // Navigation Stack
        .sheet(isPresented: Binding(
            get: { viewModel.editSummaryItemId != nil },
            set: { if !$0 { viewModel.editSummaryItemId = nil } }
        )) {
            VStack(spacing: 12) {
                Text("Edit Summary")
                    .font(.headline)

                TextEditor(text: $viewModel.editSummaryText)
                    .font(.body)
                    .frame(minHeight: 80)
                    .border(Color.secondary.opacity(0.3))

                HStack {
                    Button("Cancel") {
                        viewModel.editSummaryItemId = nil
                    }
                    .keyboardShortcut(.escape, modifiers: [])

                    Spacer()

                    Button("Save") {
                        viewModel.saveSummary(items: items)
                    }
                    .keyboardShortcut(.return, modifiers: .command)
                }
            }
            .padding()
            .frame(minWidth: 400, minHeight: 180)
        }
        .alert("New Folder", isPresented: $viewModel.showNewFolderPrompt) {
            TextField("Folder name", text: $viewModel.newFolderName)
            Button("Create") {
                viewModel.createFolder(modelContext: modelContext, folders: folders)
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ExtensionXPCService())
        .environmentObject(SnippetViewModel())
        .modelContainer(for: [SnippetItem.self, FolderItem.self], inMemory: true)
}
