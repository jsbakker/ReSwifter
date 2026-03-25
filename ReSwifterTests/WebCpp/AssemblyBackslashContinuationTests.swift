//
//  AssemblyBackslashContinuationTests.swift
//  ReSwifterTests
//
//  Backslash line-continuation in Assembly (NASM) string literals.
//  NASM's preprocessor collapses all lines ending in \ before any further
//  processing — the same global mechanism as C translation phase 2.  This
//  makes backslash-continuation valid inside db "..." and db '...' directives.
//

import Testing
import WebCpp

struct AssemblyBackslashContinuationTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "asm")
    }

    // MARK: Double-quoted

    @Test func dblQuoteOpeningLineHasClosedFontTag() {
        let source = "msg db \"hello \\\nworld\", 0"
        let html = highlight(source)
        let lines = html.components(separatedBy: "\n")
        let opening = lines.first(where: { $0.contains("hello") })
        #expect(opening?.contains("<font CLASS=dblquot>") == true,
                "ASM dbl opening must have dblquot: \(opening ?? "NOT FOUND")")
        #expect(opening?.contains("</font>") == true,
                "ASM dbl opening font tag must be closed: \(opening ?? "NOT FOUND")")
    }

    @Test func dblQuoteContinuationLineIsColoured() {
        let source = "msg db \"hello \\\nworld\", 0"
        let html = highlight(source)
        let lines = html.components(separatedBy: "\n")
        let cont = lines.first(where: { $0.contains("world") && !$0.contains("msg") })
        #expect(cont?.contains("<font CLASS=dblquot>") == true,
                "ASM dbl continuation must have dblquot: \(cont ?? "NOT FOUND")")
    }

    // MARK: Single-quoted

    @Test func sinQuoteOpeningLineHasClosedFontTag() {
        let source = "msg db 'hello \\\nworld', 0"
        let html = highlight(source)
        let lines = html.components(separatedBy: "\n")
        let opening = lines.first(where: { $0.contains("hello") })
        #expect(opening?.contains("<font CLASS=sinquot>") == true,
                "ASM sin opening must have sinquot: \(opening ?? "NOT FOUND")")
        #expect(opening?.contains("</font>") == true,
                "ASM sin opening font tag must be closed: \(opening ?? "NOT FOUND")")
    }

    @Test func sinQuoteContinuationLineIsColoured() {
        let source = "msg db 'hello \\\nworld', 0"
        let html = highlight(source)
        let lines = html.components(separatedBy: "\n")
        let cont = lines.first(where: { $0.contains("world") && !$0.contains("msg") })
        #expect(cont?.contains("<font CLASS=sinquot>") == true,
                "ASM sin continuation must have sinquot: \(cont ?? "NOT FOUND")")
    }
}
