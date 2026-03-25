//
//  RubyBackslashContinuationTests.swift
//  ReSwifterTests
//
//  Backslash line-continuation in Ruby string literals.
//  Ruby documents \<newline> as a continuation escape in double-quoted strings
//  (both backslash and newline are discarded).  Single-quoted strings in Ruby
//  only recognise \\ and \'; \<newline> is NOT a continuation there.
//  Backtick strings (command execution) follow the same escape rules as
//  double-quoted strings, so backtick continuation is also valid.
//

import Testing
import WebCpp

struct RubyBackslashContinuationTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "rb")
    }

    // MARK: Double-quoted

    @Test func dblQuoteOpeningLineHasClosedFontTag() {
        let source = "s = \"hello \\\nworld\""
        let html = highlight(source)
        let lines = html.components(separatedBy: "\n")
        let opening = lines.first(where: { $0.contains("hello") })
        #expect(opening?.contains("<font CLASS=dblquot>") == true,
                "Ruby dbl opening must have dblquot: \(opening ?? "NOT FOUND")")
        #expect(opening?.contains("</font>") == true,
                "Ruby dbl opening font tag must be closed: \(opening ?? "NOT FOUND")")
    }

    @Test func dblQuoteContinuationLineIsColoured() {
        let source = "s = \"hello \\\nworld\""
        let html = highlight(source)
        let lines = html.components(separatedBy: "\n")
        let cont = lines.first(where: { $0.contains("world") && !$0.contains("s =") })
        #expect(cont?.contains("<font CLASS=dblquot>") == true,
                "Ruby dbl continuation must have dblquot: \(cont ?? "NOT FOUND")")
    }

    // MARK: Backtick (command string — same escape rules as double-quoted)

    @Test func backtickOpeningLineHasClosedFontTag() {
        let source = "result = `echo \\\nhello`"
        let html = highlight(source)
        let lines = html.components(separatedBy: "\n")
        let opening = lines.first(where: { $0.contains("echo") })
        #expect(opening?.contains("<font CLASS=preproc>") == true,
                "Ruby backtick opening must have preproc: \(opening ?? "NOT FOUND")")
        #expect(opening?.contains("</font>") == true,
                "Ruby backtick opening font tag must be closed: \(opening ?? "NOT FOUND")")
    }

    @Test func backtickContinuationLineIsColoured() {
        let source = "result = `echo \\\nhello`"
        let html = highlight(source)
        let lines = html.components(separatedBy: "\n")
        let cont = lines.first(where: { $0.contains("hello") && !$0.contains("echo") })
        #expect(cont?.contains("<font CLASS=preproc>") == true,
                "Ruby backtick continuation must have preproc: \(cont ?? "NOT FOUND")")
    }
}
