//
//  SnippetUtility.swift
//  ReSwifter
//
//  Created by Jeffrey Bakker on 2026-03-07.
//

import Conduit
import Foundation
import FoundationModels

/// Serializes all LanguageModelSession calls through a single processing loop
/// so that only one session.respond is in flight at a time.
/// Each request uses a fresh session to avoid context window exhaustion.
final class SnippetUtility: Sendable {

    private let isAvailable: Bool
    private let model: SystemLanguageModel
    private let stream: AsyncStream<WorkItem>
    private let continuation: AsyncStream<WorkItem>.Continuation

    private struct WorkItem: Sendable {
        let query: String
        let reply: @Sendable (String) -> Void
    }

    init() {
        let model = SystemLanguageModel.default
        self.model = model
        self.isAvailable = model.availability == .available

        let (stream, continuation) = AsyncStream.makeStream(of: WorkItem.self)
        self.stream = stream
        self.continuation = continuation

        if self.isAvailable {
            // Prewarm once at startup
            LanguageModelSession(model: model).prewarm()

            // Single processing loop — pulls one item at a time, ensuring
            // only one respond call is in flight at any time.
            // Each item gets a fresh session to avoid context window buildup.
            let capturedModel = model
            Task {
                for await item in stream {
                    let session = LanguageModelSession(model: capturedModel)
                    do {
                        let response = try await session.respond(to: item.query)
                        item.reply(response.content)
                    } catch {
                        print("Session error: \(error)")
                        item.reply("Error")
                    }
                }
            }
        }
    }

    /// Submits a query to the serial queue and waits for the result.
    private func submit(query: String) async -> String {
        guard isAvailable else { return "Unavailable" }
        return await withCheckedContinuation { cont in
            continuation.yield(WorkItem(query: query, reply: { result in
                cont.resume(returning: result)
            }))
        }
    }

    func summarize(_ snippet: String) async -> String {
        let result = await submit(query: "Summarize this in one sentence:\n\(snippet)")
        print("Summary:\n\(result)")
        return result == "Error" ? "Summary Error" : result
    }

    func cleanup(_ snippet: String) async -> String {
        let result = await submit(query: "Cleanup this code and use standard conventions:\n\(snippet)")
        print("Cleaned up code:\n\(result)")
        return result == "Error" ? "Cleanup Error" : result
    }

    func refactor(_ snippet: String) async -> String {
        let result = await submit(query: "Refactor this code to use best practices:\n\(snippet)")
        print("Refactored code:\n\(result)")
        return result == "Error" ? "Refactor Error" : result
    }

    func convert(_ snippet: String) async -> String {
        let result = await submit(query: "Convert this code to Swift and use Swift conventions:\n\(snippet)")
        print("Converted code:\n\(result)")
        return result == "Error" ? "Convert Error" : result
    }

    func document(_ snippet: String) async -> String {
        let result = await submit(query: "Add doc comments into this code for Swift DocC:\n\(snippet)")
        print("Documented code:\n\(result)")
        return result == "Error" ? "Document code Error" : result
    }

    func review(_ snippet: String) async -> String {
        let result = await submit(query: "Review this code to catch code smells, potential bugs or opportunuties for improvement:\n\(snippet)")
        print("Reviewed code:\n\(result)")
        return result == "Error" ? "Review Error" : result
    }

    static func analyzeDescription(_ fullText: String) async -> String {

        let question = "Describe in one sentence what the following code does, or what it is for?\n\(fullText)"

        let config = OpenAIConfiguration(
            endpoint: .ollama(),
            authentication: .none,
            ollamaConfig: OllamaConfiguration(
                keepAlive: "30m",      // Keep model in memory
                pullOnMissing: true,   // Auto-download models
                numGPU: 35             // GPU layers to use
            )
        )
        let provider = OpenAIProvider(configuration: config)

        do {
            let response = try await provider.generate(
                question,
                model: .ollama("gemma3:4b")
//                        model: .ollama("llama3.2")
            )
            print("Description response:\n\(response)")
            return response
        } catch {
            print("I don't have an answer for that.")
            return "Unknown"
        }
    }
}
