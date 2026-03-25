//
//  PythonBackslashContinuationTests.swift
//  ReSwifterTests
//
//  Backslash line-continuation in Python string literals.
//  Python 3 defines \<newline> as a recognized escape inside regular (non-triple)
//  single-quoted and double-quoted strings; both the backslash and the newline
//  are discarded from the string value.
//

import Testing
import WebCpp

struct PythonBackslashContinuationTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "py")
    }

    // MARK: Double-quoted

    @Test func dblQuoteOpeningLineHasClosedFontTag() {
        let source = "s = \"hello \\\nworld\""
        let html = highlight(source)
        let lines = html.components(separatedBy: "\n")
        let opening = lines.first(where: { $0.contains("hello") })
        #expect(opening?.contains("<font CLASS=dblquot>") == true,
                "Python dbl opening must have dblquot: \(opening ?? "NOT FOUND")")
        #expect(opening?.contains("</font>") == true,
                "Python dbl opening font tag must be closed: \(opening ?? "NOT FOUND")")
    }

    @Test func dblQuoteContinuationLineIsColoured() {
        let source = "s = \"hello \\\nworld\""
        let html = highlight(source)
        let lines = html.components(separatedBy: "\n")
        let cont = lines.first(where: { $0.contains("world") && !$0.contains("s =") })
        #expect(cont?.contains("<font CLASS=dblquot>") == true,
                "Python dbl continuation must have dblquot: \(cont ?? "NOT FOUND")")
    }

    // MARK: Single-quoted

    @Test func sinQuoteOpeningLineHasClosedFontTag() {
        let source = "s = 'hello \\\nworld'"
        let html = highlight(source)
        let lines = html.components(separatedBy: "\n")
        let opening = lines.first(where: { $0.contains("hello") })
        #expect(opening?.contains("<font CLASS=sinquot>") == true,
                "Python sin opening must have sinquot: \(opening ?? "NOT FOUND")")
        #expect(opening?.contains("</font>") == true,
                "Python sin opening font tag must be closed: \(opening ?? "NOT FOUND")")
    }

    @Test func sinQuoteContinuationLineIsColoured() {
        let source = "s = 'hello \\\nworld'"
        let html = highlight(source)
        let lines = html.components(separatedBy: "\n")
        let cont = lines.first(where: { $0.contains("world") && !$0.contains("s =") })
        #expect(cont?.contains("<font CLASS=sinquot>") == true,
                "Python sin continuation must have sinquot: \(cont ?? "NOT FOUND")")
    }
}
