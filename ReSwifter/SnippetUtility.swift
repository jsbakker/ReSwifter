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
