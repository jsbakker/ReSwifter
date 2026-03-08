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
    var description: String = "Generating description..."
    var fullText: String
    var pendingUpdate: Bool = false
    var favorite: Bool = false
    var path: String = ""

    init(fullText: String) {
        self.fullText = fullText
    }

    init(description: String, fullText: String) {
        self.description = description
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

//@State private var items = [
//    SnippetItem(fullText: "Foo bar baz"),
//    SnippetItem(fullText: "Bar baz qux"),
//    SnippetItem(fullText: "Baz qux quux"),
//    SnippetItem(fullText: "Corge grault garply"),
//    SnippetItem(fullText: "Garply biz burp"),
//    SnippetItem(fullText: "Grault blimity plugh"),
//    SnippetItem(fullText: "Quux plugh thud"),
//    SnippetItem(fullText: "Quux thud waldo"),
//    SnippetItem(fullText: "Waldo quux thud"),
//    SnippetItem(fullText: "Plugh thud waldo"),
//    SnippetItem(fullText: "Baz qux quux waldo"),
//    SnippetItem(fullText: "Foo bar baz quux"),
//    SnippetItem(fullText: "Foo bar baz quux quux"),
//    SnippetItem(fullText: "Foo bar baz quux quux waldo"),
//    SnippetItem(fullText: "Foo bar baz quux quux quux")
//]
