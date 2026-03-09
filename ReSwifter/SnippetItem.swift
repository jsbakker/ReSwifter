//
//  SnippetItem.swift
//  ReSwifter
//
//  Created by Jeffrey Bakker on 2026-03-07.
//

import Foundation
import SwiftData

@Model class SnippetItem: Identifiable {

    var id: UUID = UUID()
    var date: Date = Date()
    var summary: String = "Generating summary..."
    var fullText: String = ""
    var favorite: Bool = false
    var folder: FolderItem?

    @Transient var pendingUpdate: Bool = false

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
