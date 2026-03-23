//
//  ScalaHighlightTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests that Scala syntax highlighting rules produce correct output.
struct ScalaHighlightTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "scala")
    }

    // MARK: Keywords

    @Test func keywordsAreHighlighted() {
        let html = highlight("abstract")
        #expect(html.contains("<font CLASS=keyword>abstract</font>"))
    }

    // MARK: Types

    @Test func typesAreHighlighted() {
        let html = highlight("Any")
        #expect(html.contains("<font CLASS=keytype>Any</font>"))
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

    @Test func singleQuotedStringsAreHighlighted() {
        let html = highlight("'hello'")
        #expect(html.contains("<font CLASS=sinquot>"))
    }

    @Test func backtickStringsAreHighlighted() {
        // Scala uses backtick-escaped identifiers
        let html = highlight("`type`")
        #expect(html.contains("<font CLASS=preproc>"))
    }

    // MARK: - Quote Combination Tests

    @Test func apostropheInsideDoubleQuoteIsNotSeparatelyHighlighted() {
        let html = highlight("\"it's fine\"")
        #expect(html.contains("<font CLASS=dblquot>"))
        #expect(!html.contains("<font CLASS=sinquot>"))
    }

    @Test func doubleQuoteInsideSingleQuoteIsNotSeparatelyHighlighted() {
        let html = highlight("'say \"hi\"'")
        #expect(html.contains("<font CLASS=sinquot>"))
        #expect(!html.contains("<font CLASS=dblquot>"))
    }

    @Test func singleQuoteInsideBacktickIsNotSeparatelyHighlighted() {
        let html = highlight("`it's fine`")
        #expect(html.contains("<font CLASS=preproc>"))
        #expect(!html.contains("<font CLASS=sinquot>"))
    }

    // MARK: Symbols

    @Test func symbolsAreHighlighted() {
        let html = highlight("x + y")
        #expect(html.contains("<font CLASS=symbols>+</font>"))
    }

    // MARK: Comments

    @Test func blockCommentsAreHighlighted() {
        let html = highlight("/* a comment */")
        #expect(html.contains("<font CLASS=comment>/* a comment */</font>"))
    }

    @Test func inlineCommentsAreHighlighted() {
        let html = highlight("// comment")
        #expect(html.contains("<font CLASS=comment>// comment</font>"))
    }

    // MARK: Triple-quoted Strings

    @Test func tripleQuotedStringsAreHighlighted() {
        let source = """
        \"\"\"
        content
        \"\"\"
        """
        let html = highlight(source)
        #expect(html.contains("<font CLASS=dblquot>"))
    }

    // MARK: - Comprehensive Snippet

    @Test func comprehensiveSnippetHighlightsAllRules() {
        let source = """
        /* Block comment */
        // Line comment
        abstract class Example {
            val flag: Boolean = true
            var x: Int = 42
            val pi: Double = 3.14
            def run(): Unit = {
                val s: String = "hello"
                val c: Char = 'x'
                val result: Any = x + 1
            }
        }
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=keyword>abstract</font>"))
        #expect(html.contains("<font CLASS=keytype>Any</font>"))
        #expect(html.contains("<font CLASS=integer>42</font>"))
        #expect(html.contains("<font CLASS=floatpt>3.14</font>"))
        #expect(html.contains("<font CLASS=dblquot>")) // double-quoted string highlighted
        #expect(html.contains("<font CLASS=sinquot>")) // single-quoted char highlighted
        #expect(html.contains("<font CLASS=symbols>+</font>"))
        #expect(html.contains("<font CLASS=comment>/* Block comment */</font>"))
        #expect(html.contains("<font CLASS=comment>// Line comment</font>"))
    }
}
