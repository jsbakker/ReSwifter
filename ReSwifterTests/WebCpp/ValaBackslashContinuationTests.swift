//
//  ValaBackslashContinuationTests.swift
//  ReSwifterTests
//
//  Backslash line-continuation in Vala string literals.
//  Vala is a C-based language that compiles to C.  Its regular string literals
//  inherit C-style escape handling; \<newline> splices the next physical line,
//  making continuation valid in double-quoted strings.
//  Single-quoted strings in Vala are character literals, not full strings,
//  so continuation is not tested for single quotes.
//

import Testing
import WebCpp

struct ValaBackslashContinuationTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "vala")
    }

    @Test func openingLineHasClosedFontTag() {
        let source = "string s = \"hello \\\nworld\";"
        let html = highlight(source)
        let lines = html.components(separatedBy: "\n")
        let opening = lines.first(where: { $0.contains("hello") })
        #expect(opening?.contains("<font CLASS=dblquot>") == true,
                "Vala opening must have dblquot: \(opening ?? "NOT FOUND")")
        #expect(opening?.contains("</font>") == true,
                "Vala opening font tag must be closed: \(opening ?? "NOT FOUND")")
    }

    @Test func continuationLineIsColoured() {
        let source = "string s = \"hello \\\nworld\";"
        let html = highlight(source)
        let lines = html.components(separatedBy: "\n")
        let cont = lines.first(where: { $0.contains("world") && !$0.contains("string") })
        #expect(cont?.contains("<font CLASS=dblquot>") == true,
                "Vala continuation must have dblquot: \(cont ?? "NOT FOUND")")
    }

    @Test func multiLineContinuationAllColoured() {
        let source = "string s = \"line1 \\\nline2 \\\nline3\";"
        let html = highlight(source)
        for label in ["line1", "line2", "line3"] {
            let line = html.components(separatedBy: "\n").first(where: { $0.contains(label) })
            #expect(line?.contains("<font CLASS=dblquot>") == true,
                    "Vala \(label) must be inside dblquot span: \(line ?? "NOT FOUND")")
        }
    }
}
