//
//  ShellBackslashContinuationTests.swift
//  ReSwifterTests
//
//  Backslash line-continuation in Shell string literals.
//  The Bash manual specifies that \<newline> inside double-quoted strings is a
//  line continuation (both characters removed).  Single-quoted strings preserve
//  every character literally — backslash has no special meaning there — so
//  single-quote continuation is NOT tested here.
//  Backtick command substitution follows the same backslash rules as
//  double-quoted strings inside bash.
//

import Testing
import WebCpp

struct ShellBackslashContinuationTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "sh")
    }

    // MARK: Double-quoted

    @Test func dblQuoteOpeningLineHasClosedFontTag() {
        let source = "MSG=\"hello \\\nworld\""
        let html = highlight(source)
        let lines = html.components(separatedBy: "\n")
        let opening = lines.first(where: { $0.contains("hello") })
        #expect(opening?.contains("<font CLASS=dblquot>") == true,
                "Shell dbl opening must have dblquot: \(opening ?? "NOT FOUND")")
        #expect(opening?.contains("</font>") == true,
                "Shell dbl opening font tag must be closed: \(opening ?? "NOT FOUND")")
    }

    @Test func dblQuoteContinuationLineIsColoured() {
        let source = "MSG=\"hello \\\nworld\""
        let html = highlight(source)
        let lines = html.components(separatedBy: "\n")
        let cont = lines.first(where: { $0.contains("world") && !$0.contains("MSG") })
        #expect(cont?.contains("<font CLASS=dblquot>") == true,
                "Shell dbl continuation must have dblquot: \(cont ?? "NOT FOUND")")
    }

    // MARK: Backtick command substitution

    @Test func backtickOpeningLineHasClosedFontTag() {
        let source = "OUT=`echo \\\nhello`"
        let html = highlight(source)
        let lines = html.components(separatedBy: "\n")
        let opening = lines.first(where: { $0.contains("echo") })
        #expect(opening?.contains("<font CLASS=preproc>") == true,
                "Shell backtick opening must have preproc: \(opening ?? "NOT FOUND")")
        #expect(opening?.contains("</font>") == true,
                "Shell backtick opening font tag must be closed: \(opening ?? "NOT FOUND")")
    }

    @Test func backtickContinuationLineIsColoured() {
        let source = "OUT=`echo \\\nhello`"
        let html = highlight(source)
        let lines = html.components(separatedBy: "\n")
        let cont = lines.first(where: { $0.contains("hello") && !$0.contains("echo") })
        #expect(cont?.contains("<font CLASS=preproc>") == true,
                "Shell backtick continuation must have preproc: \(cont ?? "NOT FOUND")")
    }
}
