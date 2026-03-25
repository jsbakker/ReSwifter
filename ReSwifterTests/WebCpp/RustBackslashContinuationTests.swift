//
//  RustBackslashContinuationTests.swift
//  ReSwifterTests
//
//  Backslash line-continuation in Rust string literals.
//  The Rust Reference explicitly defines a "string continue" escape: \<newline>
//  followed by optional leading whitespace on the next line is discarded.
//  Single-quoted strings in Rust are character literals, not strings,
//  so only double-quoted continuation is tested.
//

import Testing
import WebCpp

struct RustBackslashContinuationTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "rs")
    }

    @Test func openingLineHasClosedFontTag() {
        let source = "let s = \"hello \\\n    world\";"
        let html = highlight(source)
        let lines = html.components(separatedBy: "\n")
        let opening = lines.first(where: { $0.contains("hello") })
        #expect(opening?.contains("<font CLASS=dblquot>") == true,
                "Rust opening must have dblquot: \(opening ?? "NOT FOUND")")
        #expect(opening?.contains("</font>") == true,
                "Rust opening font tag must be closed: \(opening ?? "NOT FOUND")")
    }

    @Test func continuationLineIsColoured() {
        let source = "let s = \"hello \\\n    world\";"
        let html = highlight(source)
        let lines = html.components(separatedBy: "\n")
        let cont = lines.first(where: { $0.contains("world") && !$0.contains("let") })
        #expect(cont?.contains("<font CLASS=dblquot>") == true,
                "Rust continuation must have dblquot: \(cont ?? "NOT FOUND")")
    }

    @Test func multiLineContinuationAllColoured() {
        let source = "let s = \"alpha \\\n    beta \\\n    gamma\";"
        let html = highlight(source)
        for label in ["alpha", "beta", "gamma"] {
            let line = html.components(separatedBy: "\n").first(where: { $0.contains(label) })
            #expect(line?.contains("<font CLASS=dblquot>") == true,
                    "Rust \(label) must be inside dblquot: \(line ?? "NOT FOUND")")
        }
    }
}
