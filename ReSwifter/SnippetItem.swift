//
//  SnippetItem.swift
//  ReSwifter
//
//  Created by Jeffrey Bakker on 2026-03-07.
//

import Foundation
import Combine

@Observable class SnippetItem : Identifiable, Equatable {

    static func == (lhs: SnippetItem, rhs: SnippetItem) -> Bool {
        return lhs.id == rhs.id
    }

    let id = UUID()
    let date: Date = Date()
    var summary: String = "Generating summary..."
    var fullText: String
    var pendingUpdate: Bool = false
    var favorite: Bool = false
    var path: String = ""

    init(fullText: String) {
        self.fullText = fullText
    }

    init(summary: String, fullText: String) {
        self.summary = summary
        self.fullText = fullText
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
