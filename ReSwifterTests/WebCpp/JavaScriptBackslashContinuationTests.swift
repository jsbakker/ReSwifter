//
//  JavaScriptBackslashContinuationTests.swift
//  ReSwifterTests
//
//  Backslash line-continuation in JavaScript string literals.
//  ECMAScript defines LineContinuation (\ followed by LineTerminatorSequence)
//  for both double-quoted and single-quoted strings.  Template literals
//  (backtick strings) do NOT use this mechanism — they span lines natively —
//  so backtick continuation is not tested here.
//

import Testing
import WebCpp

struct JavaScriptBackslashContinuationTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "js")
    }

    // MARK: Double-quoted

    @Test func dblQuoteOpeningLineHasClosedFontTag() {
        let source = "var s = \"hello \\\nworld\";"
        let html = highlight(source)
        let lines = html.components(separatedBy: "\n")
        let opening = lines.first(where: { $0.contains("hello") })
        #expect(opening?.contains("<font CLASS=dblquot>") == true,
                "JS dbl opening must have dblquot: \(opening ?? "NOT FOUND")")
        #expect(opening?.contains("</font>") == true,
                "JS dbl opening font tag must be closed: \(opening ?? "NOT FOUND")")
    }

    @Test func dblQuoteContinuationLineIsColoured() {
        let source = "var s = \"hello \\\nworld\";"
        let html = highlight(source)
        let lines = html.components(separatedBy: "\n")
        let cont = lines.first(where: { $0.contains("world") && !$0.contains("var") })
        #expect(cont?.contains("<font CLASS=dblquot>") == true,
                "JS dbl continuation must have dblquot: \(cont ?? "NOT FOUND")")
    }

    // MARK: Single-quoted

    @Test func sinQuoteOpeningLineHasClosedFontTag() {
        let source = "var s = 'hello \\\nworld';"
        let html = highlight(source)
        let lines = html.components(separatedBy: "\n")
        let opening = lines.first(where: { $0.contains("hello") })
        #expect(opening?.contains("<font CLASS=sinquot>") == true,
                "JS sin opening must have sinquot: \(opening ?? "NOT FOUND")")
        #expect(opening?.contains("</font>") == true,
                "JS sin opening font tag must be closed: \(opening ?? "NOT FOUND")")
    }

    @Test func sinQuoteContinuationLineIsColoured() {
        let source = "var s = 'hello \\\nworld';"
        let html = highlight(source)
        let lines = html.components(separatedBy: "\n")
        let cont = lines.first(where: { $0.contains("world") && !$0.contains("var") })
        #expect(cont?.contains("<font CLASS=sinquot>") == true,
                "JS sin continuation must have sinquot: \(cont ?? "NOT FOUND")")
    }
}
