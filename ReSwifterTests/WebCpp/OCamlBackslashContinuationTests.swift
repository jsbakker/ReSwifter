//
//  OCamlBackslashContinuationTests.swift
//  ReSwifterTests
//
//  Backslash line-continuation in OCaml string literals.
//  The OCaml manual defines that \<newline> followed by spaces or tabs is
//  entirely ignored inside double-quoted string literals (the backslash,
//  newline, and all following indentation are discarded).
//  Single-quoted syntax in OCaml is character literals, not full strings.
//

import Testing
import WebCpp

struct OCamlBackslashContinuationTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "ml")
    }

    @Test func openingLineHasClosedFontTag() {
        let source = "let s = \"hello \\\n  world\""
        let html = highlight(source)
        let lines = html.components(separatedBy: "\n")
        let opening = lines.first(where: { $0.contains("hello") })
        #expect(opening?.contains("<font CLASS=dblquot>") == true,
                "OCaml opening must have dblquot: \(opening ?? "NOT FOUND")")
        #expect(opening?.contains("</font>") == true,
                "OCaml opening font tag must be closed: \(opening ?? "NOT FOUND")")
    }

    @Test func continuationLineIsColoured() {
        let source = "let s = \"hello \\\n  world\""
        let html = highlight(source)
        let lines = html.components(separatedBy: "\n")
        let cont = lines.first(where: { $0.contains("world") && !$0.contains("let") })
        #expect(cont?.contains("<font CLASS=dblquot>") == true,
                "OCaml continuation must have dblquot: \(cont ?? "NOT FOUND")")
    }
}
