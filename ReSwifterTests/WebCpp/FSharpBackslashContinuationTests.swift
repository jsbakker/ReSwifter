//
//  FSharpBackslashContinuationTests.swift
//  ReSwifterTests
//
//  Backslash line-continuation in F# string literals.
//  The F# language reference documents that when \ is the last character
//  before a line break in a regular string literal, both the backslash and
//  the newline are discarded, and leading whitespace on the continuation
//  line is also ignored.  Single-quoted syntax in F# is character literals.
//

import Testing
import WebCpp

struct FSharpBackslashContinuationTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "fs")
    }

    @Test func openingLineHasClosedFontTag() {
        let source = "let s = \"hello \\\n    world\""
        let html = highlight(source)
        let lines = html.components(separatedBy: "\n")
        let opening = lines.first(where: { $0.contains("hello") })
        #expect(opening?.contains("<font CLASS=dblquot>") == true,
                "F# opening must have dblquot: \(opening ?? "NOT FOUND")")
        #expect(opening?.contains("</font>") == true,
                "F# opening font tag must be closed: \(opening ?? "NOT FOUND")")
    }

    @Test func continuationLineIsColoured() {
        let source = "let s = \"hello \\\n    world\""
        let html = highlight(source)
        let lines = html.components(separatedBy: "\n")
        let cont = lines.first(where: { $0.contains("world") && !$0.contains("let") })
        #expect(cont?.contains("<font CLASS=dblquot>") == true,
                "F# continuation must have dblquot: \(cont ?? "NOT FOUND")")
    }
}
