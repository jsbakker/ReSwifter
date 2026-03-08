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
    var hasDescription: Bool = false
    var favorite: Bool = false

    init(fullText: String) {
        self.fullText = fullText
    }
}

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
