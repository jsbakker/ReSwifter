//
//  SnippetRowView.swift
//  ReSwifter
//
//  Created by Jeffrey Bakker on 2026-03-09.
//

import HighlightedEditorView
import SwiftUI
import SwiftData

struct SnippetRowView: View {
    @ObservedObject var viewModel: SnippetViewModel
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \FolderItem.name) private var folders: [FolderItem]

    @State private var showingDeleteAlert: Bool = false

    let item: SnippetItem

    private var isPending: Bool {
        viewModel.pendingItemIds.contains(item.id)
    }

    var body: some View {
        HStack {
            Image(systemName: "text.magnifyingglass")
                .buttonStyle(.borderless)

            VStack(alignment: .leading) {
                Text(item.summary).font(.subheadline).bold()
                    .accessibilityIdentifier("snippetRowSummaryText")
                HStack {
                    Text(viewModel.dateFormatter.string(from: item.date)).font(.caption)
                    Text(WebCppLanguage.from(rawValue: item.language).displayName).font(.caption)
                }
            }

            if isPending {
                Image(systemName: "sparkles")
                    .font(.largeTitle)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                ProgressView()
                    .controlSize(.small)
                    .accessibilityIdentifier("snippetRowSpinner")
            }

            Spacer()

            Button {
                item.favorite.toggle()
            } label: {
                Image(systemName: item.favorite ? "heart.fill" : "heart")
                    .foregroundStyle(item.favorite ? .red : .gray)
            }
            .buttonStyle(.plain)
            .help("Add to Favorites")

            Button("", systemImage: "doc.on.doc") {
                viewModel.copySnippet(item)
            }
            .buttonStyle(.plain)
            .help("Copy to Clipboard")

            Button("", systemImage: "trash", role: .destructive) {
                showingDeleteAlert = true
            }
            .buttonStyle(.plain)
            .help("Delete Snippet")
            .disabled(isPending)
            .confirmationDialog(
                "Delete Snippet",
                isPresented: $showingDeleteAlert,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    withAnimation {
                        modelContext.delete(item)
                    }
                }
            }

            Divider()

            Menu {
                Button("Edit Summary...", systemImage: "square.and.pencil") {
                    viewModel.beginEditSummary(for: item)
                }
                .disabled(isPending)

                Divider()

                Button("Explain", systemImage: "info") {
                    viewModel.explain(item, modelContext: modelContext, folders: folders)
                }
                .disabled(isPending)

                Button("Document", systemImage: "document") {
                    viewModel.document(item, modelContext: modelContext, folders: folders)
                }
                .disabled(isPending)

                Button("Review", systemImage: "quote.bubble") {
                    viewModel.review(item, modelContext: modelContext, folders: folders)
                }
                .disabled(isPending)

                Button("Cleanup", systemImage: "wand.and.stars") {
                    viewModel.cleanup(item, modelContext: modelContext, folders: folders)
                }
                .disabled(isPending)

                Button("Refactor", systemImage: "lightbulb") {
                    viewModel.refactor(item, modelContext: modelContext, folders: folders)
                }
                .disabled(isPending)

                Button("Convert to Swift", systemImage: "brain") {
                    viewModel.convert(item, modelContext: modelContext, folders: folders)
                }
                .disabled(isPending)

                Divider()

                Menu("Move to", systemImage: "folder") {
                    Button {
                        item.folder = nil
                    } label: {
                        if item.folder == nil {
                            Label("All", systemImage: "checkmark")
                        } else {
                            Text("All")
                        }
                    }

                    ForEach(folders) { folder in
                        Button {
                            item.folder = folder
                        } label: {
                            if item.folder?.id == folder.id {
                                Label(folder.name, systemImage: "checkmark")
                            } else {
                                Text(folder.name)
                            }
                        }
                    }
                }
            } label: {
                Image(systemName: "sparkles")
                    .foregroundStyle(item.favorite ? .red : .gray)
                Text("More")
            }
        }
    }
}
