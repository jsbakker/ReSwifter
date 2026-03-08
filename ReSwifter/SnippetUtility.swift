//
//  SnippetUtility.swift
//  ReSwifter
//
//  Created by Jeffrey Bakker on 2026-03-07.
//

import Conduit
import Foundation
import FoundationModels

struct SnippetUtility {

    let model: SystemLanguageModel = SystemLanguageModel.default
    let session: LanguageModelSession?

    init() {
        if self.model.availability == .available {
            self.session = LanguageModelSession(model: self.model)
            self.session?.prewarm()
        } else {
            self.session = nil
        }
    }

    func summarize(_ snippet: String) async -> String {

        guard let session else { return "Summary Unavailable" }

//        if session.isResponding {
//        }

        if !session.isResponding {
            let query = "Summarize this in one sentence:\n\(snippet)"
            do {
                let response = try await session.respond(to: query)
                print("Summary:\n\(response.content)")
                return response.content
            } catch {
                print("Summary Error:\n\(error)")
                return "Summary Error"
            }
        }
        return "Summary Busy"

//        let model = SystemLanguageModel.default
//        if model.availability == .available {
//
//            let query = "Summarize this in one sentence:\n\(snippet)"
//            let session = LanguageModelSession()
//            do {
//                let response = try await session.respond(to: query)
//                print("Summary:\n\(response.content)")
//                return response.content
//            } catch {
//                print("I don't have an answer for that.")
//                return "Unknown"
//            }
//        }
//        return "Unknown"
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
