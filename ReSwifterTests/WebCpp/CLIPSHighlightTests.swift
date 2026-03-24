//
//  CLIPSHighlightTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests that CLIPS syntax highlighting rules produce correct output.
struct CLIPSHighlightTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "clp")
    }

    // MARK: Keywords

    @Test func keywordsAreHighlighted() {
        let html = highlight("FALSE")
        #expect(html.contains("<font CLASS=keyword>FALSE</font>"))
    }

    // MARK: Types

    @Test func typesAreHighlighted() {
        let html = highlight("ADDRESS")
        #expect(html.contains("<font CLASS=keytype>ADDRESS</font>"))
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

    // MARK: Symbols

    @Test func symbolsAreHighlighted() {
        let html = highlight("x + y")
        #expect(html.contains("<font CLASS=symbols>+</font>"))
    }

    // MARK: Comments


    @Test func inlineCommentsAreHighlighted() {
        let html = highlight("; comment")
        #expect(html.contains("<font CLASS=comment>; comment</font>"))
    }

    // MARK: - Underscore Numbers

    @Test func underscoreNumbersAreNotFullyHighlighted() {
        let html = highlight("1_000")
        #expect(!html.contains("<font CLASS=integer>1_000</font>"))
    }

    // MARK: - Comprehensive Snippet

    @Test func comprehensiveSnippetHighlightsAllRules() {
        let source = """
        ; CLIPS comment
        (defrule example
            (test (abs 42))
            =>
            (printout t "Hello" crlf)
            (bind ?x 'world')
            (assert (result TRUE))
        )
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=keyword>TRUE</font>"))
        #expect(html.contains("<font CLASS=integer>42</font>"))
        #expect(html.contains("<font CLASS=dblquot>")) // double-quoted string highlighted
        #expect(!html.contains("<font CLASS=sinquot>")) // single quotes not supported in CLIPS
        #expect(html.contains("<font CLASS=comment>; CLIPS comment</font>"))
        // The &gt; in => must not trigger doAsmComnt (the ; inside &gt; is not a comment)
        #expect(html.contains("&gt;"))
        #expect(!html.contains("<font CLASS=comment>&gt;"))
    }
}
