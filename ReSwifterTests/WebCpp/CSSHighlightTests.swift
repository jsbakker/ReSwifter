//
//  CSSHighlightTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests that CSS syntax highlighting rules produce correct output.
struct CSSHighlightTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "css")
    }

    // MARK: Keywords

    @Test func keywordsAreHighlighted() {
        let html = highlight("@charset")
        #expect(html.contains("<font CLASS=keyword>@charset</font>"))
    }

    // MARK: Types

    @Test func typesAreHighlighted() {
        let html = highlight("align-content")
        #expect(html.contains("<font CLASS=keytype>align-content</font>"))
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

    // MARK: Comments

    @Test func blockCommentsAreHighlighted() {
        let html = highlight("/* a comment */")
        #expect(html.contains("<font CLASS=comment>/* a comment */</font>"))
    }

    // MARK: - Comprehensive Snippet

    @Test func comprehensiveSnippetHighlightsAllRules() {
        let source = """
        /* CSS comment */
        @import url("style.css");
        body {
            color: red;
            margin: 42px;
            opacity: 3.14;
            font-family: 'serif';
        }
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=keyword>@import</font>"))
        #expect(html.contains("<font CLASS=keytype>color</font>"))
        #expect(html.contains("<font CLASS=integer>42</font>"))
        #expect(html.contains("<font CLASS=floatpt>3.14</font>"))
        #expect(html.contains("<font CLASS=dblquot>")) // double-quoted string highlighted
        #expect(html.contains("<font CLASS=sinquot>")) // single-quoted string highlighted
        #expect(html.contains("<font CLASS=comment>/* CSS comment */</font>"))
    }
}
