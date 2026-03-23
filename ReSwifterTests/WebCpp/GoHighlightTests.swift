//
//  GoHighlightTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests that Go syntax highlighting rules produce correct output.
struct GoHighlightTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "go")
    }

    // MARK: Keywords

    @Test func keywordsAreHighlighted() {
        let html = highlight("break")
        #expect(html.contains("<font CLASS=keyword>break</font>"))
    }

    // MARK: Types

    @Test func typesAreHighlighted() {
        let html = highlight("any")
        #expect(html.contains("<font CLASS=keytype>any</font>"))
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

    // MARK: - Comprehensive Snippet

    @Test func comprehensiveSnippetHighlightsAllRules() {
        let source = """
        /* Block comment */
        // Line comment
        package main
        func main() {
            var x int = 42
            var pi float64 = 3.14
            var s string = "hello"
            var c byte = 'x'
            var flag bool = true
            x = x + 1
        }
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=keyword>func</font>"))
        #expect(html.contains("<font CLASS=keytype>bool</font>"))
        #expect(html.contains("<font CLASS=keytype>int</font>"))
        #expect(html.contains("<font CLASS=integer>42</font>"))
        #expect(html.contains("<font CLASS=floatpt>3.14</font>"))
        #expect(html.contains("<font CLASS=dblquot>")) // double-quoted string highlighted
        #expect(html.contains("<font CLASS=sinquot>")) // single-quoted char highlighted
        #expect(html.contains("<font CLASS=symbols>+</font>"))
        #expect(html.contains("<font CLASS=comment>/* Block comment */</font>"))
        #expect(html.contains("<font CLASS=comment>// Line comment</font>"))
    }
}
