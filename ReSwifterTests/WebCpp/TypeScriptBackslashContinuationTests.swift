//
//  TypeScriptBackslashContinuationTests.swift
//  ReSwifterTests
//
//  Backslash line-continuation in TypeScript string literals.
//  TypeScript is a strict superset of ECMAScript and inherits the identical
//  LineContinuation rule for double-quoted and single-quoted strings.
//  Template literals (backtick strings) do NOT use this mechanism.
//

import Testing
import WebCpp

struct TypeScriptBackslashContinuationTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "ts")
    }

    // MARK: Double-quoted

    @Test func dblQuoteOpeningLineHasClosedFontTag() {
        let source = "const s: string = \"hello \\\nworld\";"
        let html = highlight(source)
        let lines = html.components(separatedBy: "\n")
        let opening = lines.first(where: { $0.contains("hello") })
        #expect(opening?.contains("<font CLASS=dblquot>") == true,
                "TS dbl opening must have dblquot: \(opening ?? "NOT FOUND")")
        #expect(opening?.contains("</font>") == true,
                "TS dbl opening font tag must be closed: \(opening ?? "NOT FOUND")")
    }

    @Test func dblQuoteContinuationLineIsColoured() {
        let source = "const s: string = \"hello \\\nworld\";"
        let html = highlight(source)
        let lines = html.components(separatedBy: "\n")
        let cont = lines.first(where: { $0.contains("world") && !$0.contains("const") })
        #expect(cont?.contains("<font CLASS=dblquot>") == true,
                "TS dbl continuation must have dblquot: \(cont ?? "NOT FOUND")")
    }

    // MARK: Single-quoted

    @Test func sinQuoteOpeningLineHasClosedFontTag() {
        let source = "const s = 'hello \\\nworld';"
        let html = highlight(source)
        let lines = html.components(separatedBy: "\n")
        let opening = lines.first(where: { $0.contains("hello") })
        #expect(opening?.contains("<font CLASS=sinquot>") == true,
                "TS sin opening must have sinquot: \(opening ?? "NOT FOUND")")
        #expect(opening?.contains("</font>") == true,
                "TS sin opening font tag must be closed: \(opening ?? "NOT FOUND")")
    }

    @Test func sinQuoteContinuationLineIsColoured() {
        let source = "const s = 'hello \\\nworld';"
        let html = highlight(source)
        let lines = html.components(separatedBy: "\n")
        let cont = lines.first(where: { $0.contains("world") && !$0.contains("const") })
        #expect(cont?.contains("<font CLASS=sinquot>") == true,
                "TS sin continuation must have sinquot: \(cont ?? "NOT FOUND")")
    }
}
