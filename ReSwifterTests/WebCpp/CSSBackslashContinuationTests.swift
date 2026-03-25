//
//  CSSBackslashContinuationTests.swift
//  ReSwifterTests
//
//  Backslash line-continuation in CSS string literals.
//  The CSS specification defines that a \ immediately before a newline inside
//  a string value causes both characters to be discarded, continuing the string
//  on the next line.  This applies to both double-quoted and single-quoted
//  CSS strings.
//

import Testing
import WebCpp

struct CSSBackslashContinuationTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "css")
    }

    // MARK: Double-quoted

    @Test func dblQuoteOpeningLineHasClosedFontTag() {
        let source = "content: \"hello \\\nworld\";"
        let html = highlight(source)
        let lines = html.components(separatedBy: "\n")
        let opening = lines.first(where: { $0.contains("hello") })
        #expect(opening?.contains("<font CLASS=dblquot>") == true,
                "CSS dbl opening must have dblquot: \(opening ?? "NOT FOUND")")
        #expect(opening?.contains("</font>") == true,
                "CSS dbl opening font tag must be closed: \(opening ?? "NOT FOUND")")
    }

    @Test func dblQuoteContinuationLineIsColoured() {
        let source = "content: \"hello \\\nworld\";"
        let html = highlight(source)
        let lines = html.components(separatedBy: "\n")
        let cont = lines.first(where: { $0.contains("world") && !$0.contains("content") })
        #expect(cont?.contains("<font CLASS=dblquot>") == true,
                "CSS dbl continuation must have dblquot: \(cont ?? "NOT FOUND")")
    }

    // MARK: Single-quoted

    @Test func sinQuoteOpeningLineHasClosedFontTag() {
        let source = "content: 'hello \\\nworld';"
        let html = highlight(source)
        let lines = html.components(separatedBy: "\n")
        let opening = lines.first(where: { $0.contains("hello") })
        #expect(opening?.contains("<font CLASS=sinquot>") == true,
                "CSS sin opening must have sinquot: \(opening ?? "NOT FOUND")")
        #expect(opening?.contains("</font>") == true,
                "CSS sin opening font tag must be closed: \(opening ?? "NOT FOUND")")
    }

    @Test func sinQuoteContinuationLineIsColoured() {
        let source = "content: 'hello \\\nworld';"
        let html = highlight(source)
        let lines = html.components(separatedBy: "\n")
        let cont = lines.first(where: { $0.contains("world") && !$0.contains("content") })
        #expect(cont?.contains("<font CLASS=sinquot>") == true,
                "CSS sin continuation must have sinquot: \(cont ?? "NOT FOUND")")
    }
}
