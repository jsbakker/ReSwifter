//
//  TclBackslashContinuationTests.swift
//  ReSwifterTests
//
//  Backslash line-continuation in Tcl string literals.
//  The Tcl manual defines backslash substitution rule 9: a backslash followed
//  by a newline (and any leading spaces/tabs on the next line) is replaced by
//  a single space.  This applies inside double-quoted strings, making
//  multi-line continuation valid Tcl syntax.
//

import Testing
import WebCpp

struct TclBackslashContinuationTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "tcl")
    }

    @Test func openingLineHasClosedFontTag() {
        let source = "set s \"hello \\\nworld\""
        let html = highlight(source)
        let lines = html.components(separatedBy: "\n")
        let opening = lines.first(where: { $0.contains("hello") })
        #expect(opening?.contains("<font CLASS=dblquot>") == true,
                "Tcl opening must have dblquot: \(opening ?? "NOT FOUND")")
        #expect(opening?.contains("</font>") == true,
                "Tcl opening font tag must be closed: \(opening ?? "NOT FOUND")")
    }

    @Test func continuationLineIsColoured() {
        let source = "set s \"hello \\\nworld\""
        let html = highlight(source)
        let lines = html.components(separatedBy: "\n")
        let cont = lines.first(where: { $0.contains("world") && !$0.contains("set") })
        #expect(cont?.contains("<font CLASS=dblquot>") == true,
                "Tcl continuation must have dblquot: \(cont ?? "NOT FOUND")")
    }
}
