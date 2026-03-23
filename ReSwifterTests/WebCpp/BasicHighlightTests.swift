//
//  BasicHighlightTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests that Basic syntax highlighting rules produce correct output.
struct BasicHighlightTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "bas")
    }

    // MARK: Keywords

    @Test func keywordsAreHighlighted() {
        let html = highlight("ABS")
        #expect(html.contains("<font CLASS=keyword>ABS</font>"))
    }

    // MARK: Numbers

    @Test func integersAreHighlighted() {
        let html = highlight("42")
        #expect(html.contains("<font CLASS=integer>42</font>"))
    }

    @Test func floatsAreHighlighted() {
        let html = highlight("3.14")
        #expect(html.contains("<font CLASS=floatpt>3.14</font>"))
    }

    // MARK: Strings

    @Test func doubleQuotedStringsAreHighlighted() {
        let html = highlight("\"hello\"")
        #expect(html.contains("<font CLASS=dblquot>"))
    }

    @Test func singleQuotedStringsAreNotHighlighted() {
        let html = highlight("'hello'")
        #expect(!html.contains("<font CLASS=sinquot>"))
    }

    @Test func backtickStringsAreNotHighlighted() {
        let html = highlight("`hello`")
        #expect(!html.contains("<font CLASS=preproc>"))
    }

    @Test func apostropheInsideDoubleQuoteIsNotSeparatelyHighlighted() {
        let html = highlight("\"it's fine\"")
        #expect(html.contains("<font CLASS=dblquot>"))
        #expect(!html.contains("<font CLASS=sinquot>"))
    }

    // MARK: Comments


    @Test func inlineCommentsAreHighlighted() {
        let html = highlight("; comment")
        #expect(html.contains("<font CLASS=comment>; comment</font>"))
    }

    // MARK: Labels

    @Test func labelsAreHighlighted() {
        let html = highlight("label:")
        #expect(html.contains("<font CLASS=preproc>label:</font>"))
    }

    // MARK: - Comprehensive Snippet

    @Test func comprehensiveSnippetHighlightsAllRules() {
        let source = """
        REM This is a BASIC remark
        ; Also a comment
        DIM x AS INTEGER
        x = 42
        y = 3.14
        PRINT "Hello"
        IF x > 0 THEN
            PRINT 'greeting'
        END IF
        label1:
            GOTO label1
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=keyword>PRINT</font>"))
        #expect(html.contains("<font CLASS=keyword>GOTO</font>"))
        #expect(html.contains("<font CLASS=integer>42</font>"))
        #expect(html.contains("<font CLASS=floatpt>3.14</font>"))
        #expect(html.contains("<font CLASS=dblquot>")) // double-quoted string highlighted
        #expect(!html.contains("<font CLASS=sinquot>")) // single quotes not supported in Basic
        #expect(html.contains("<font CLASS=comment>REM"))
        #expect(html.contains("<font CLASS=comment>; Also a comment</font>"))
        #expect(html.contains("<font CLASS=preproc>label1:</font>"))
        // The > in "IF x > 0 THEN" must not trigger doAsmComnt (&gt; contains ;)
        // THEN is not a keyword in webcpp's Basic definition, but 0 after > must not become a comment
        #expect(!html.contains("<font CLASS=comment>&gt;"))
    }
}
