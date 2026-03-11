//
//  SnippetRowView.swift
//  ReSwifter
//
//  Created by Jeffrey Bakker on 2026-03-09.
//

import SwiftUI
import SwiftData

struct SnippetRowView: View {
    @ObservedObject var viewModel: SnippetViewModel
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \FolderItem.name) private var folders: [FolderItem]

    let item: SnippetItem

    private var isPending: Bool {
        viewModel.pendingItemIds.contains(item.id)
    }

    var body: some View {
        HStack {
            Image(systemName: "text.magnifyingglass")
                .buttonStyle(.borderless)

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
            }

            VStack(alignment: .leading) {
                Text(item.summary).font(.subheadline).bold()
                Text(viewModel.dateFormatter.string(from: item.date)).font(.caption)
            }

            if isPending {
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

            Button("Copy", systemImage: "doc.on.doc") {
                viewModel.copySnippet(item)
            }

            Button("Delete", systemImage: "trash", role: .destructive) {
                modelContext.delete(item)
            }
            .disabled(isPending)

            Divider()

            Menu {
                Button("Cleanup", systemImage: "wand.and.stars") {
                    viewModel.pendingItemIds.insert(item.id)
                    Task {
                        let newDesc = "Cleaned up: \(item.summary)"
                        let newText = await viewModel.snippetUtility.cleanup(item.fullText)
                        viewModel.pendingItemIds.remove(item.id)
                        viewModel.addUpdatedSnippet(summary: newDesc, fullText: newText, modelContext: modelContext, folders: folders)
                    }
                }
                .disabled(isPending)

                Button("Refactor", systemImage: "lightbulb") {
                    viewModel.pendingItemIds.insert(item.id)
                    Task {
                        let newDesc = "Refactored: \(item.summary)"
                        let newText = await viewModel.snippetUtility.refactor(item.fullText)
                        viewModel.pendingItemIds.remove(item.id)
                        viewModel.addUpdatedSnippet(summary: newDesc, fullText: newText, modelContext: modelContext, folders: folders)
                    }
                }
                .disabled(isPending)

                Button("Convert", systemImage: "brain") {
                    viewModel.pendingItemIds.insert(item.id)
                    Task {
                        let newDesc = "Converted: \(item.summary)"
                        let newText = await viewModel.snippetUtility.convert(item.fullText)
                        viewModel.pendingItemIds.remove(item.id)
                        viewModel.addUpdatedSnippet(summary: newDesc, fullText: newText, modelContext: modelContext, folders: folders)
                    }
                }
                .disabled(isPending)

                Button("Document", systemImage: "document") {
                    viewModel.pendingItemIds.insert(item.id)
                    Task {
                        let newDesc = "Documented: \(item.summary)"
                        let newText = await viewModel.snippetUtility.document(item.fullText)
                        viewModel.pendingItemIds.remove(item.id)
                        viewModel.addUpdatedSnippet(summary: newDesc, fullText: newText, modelContext: modelContext, folders: folders)
                    }
                }
                .disabled(isPending)

                Button("Review", systemImage: "quote.bubble") {
                    viewModel.pendingItemIds.insert(item.id)
                    Task {
                        let newDesc = "Reviwed: \(item.summary)"
                        let newText = await viewModel.snippetUtility.review(item.fullText)
                        viewModel.pendingItemIds.remove(item.id)
                        viewModel.addUpdatedSnippet(summary: newDesc, fullText: newText, modelContext: modelContext, folders: folders)
                    }
                }
                .disabled(isPending)

                Divider()

                Button("Edit Summary...", systemImage: "square.and.pencil") {
                    viewModel.beginEditSummary(for: item)
                }
                .disabled(isPending)
            } label: {
                Image(systemName: "sparkles")
                    .foregroundStyle(item.favorite ? .red : .gray)
                Text("More")
            }
        }
    }
}
