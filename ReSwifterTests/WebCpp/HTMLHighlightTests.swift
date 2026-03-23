//
//  HTMLHighlightTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests that HTML syntax highlighting rules produce correct output.
struct HTMLHighlightTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "html")
    }

    // MARK: Keywords

    @Test func keywordsAreHighlighted() {
        let html = highlight("?")
        #expect(html.contains("<font CLASS=keyword>?</font>"))
    }

    // MARK: Types

    @Test func typesAreHighlighted() {
        let html = highlight("ACCEPT")
        #expect(html.contains("<font CLASS=keytype>ACCEPT</font>"))
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
        let html = highlight("<!-- a comment -->")
        #expect(html.contains("<font CLASS=comment>"))
    }

    // MARK: HTML Tags

    @Test func htmlTagsAreHighlighted() {
        let html = highlight("<div>")
        #expect(html.contains("<font CLASS=preproc>"))
    }

    // MARK: - String edge cases

    /// Quoted attributes inside HTML tags should be highlighted as strings,
    /// not confused by the surrounding angle brackets.
    @Test func quotedAttributeInsideTagIsHighlighted() {
        let source = "<div class=\"main\">"
        let html = highlight(source)
        #expect(html.contains("<font CLASS=dblquot>"))
        #expect(html.contains("<font CLASS=preproc>")) // tag itself
    }

    /// Single-quoted attribute inside an HTML tag.
    @Test func singleQuotedAttributeInsideTagIsHighlighted() {
        let source = "<div id='content'>"
        let html = highlight(source)
        #expect(html.contains("<font CLASS=sinquot>"))
    }

    // MARK: - Comprehensive Snippet

    @Test func comprehensiveSnippetHighlightsAllRules() {
        let source = """
        <!-- HTML comment -->
        <!DOCTYPE html>
        <html>
        <head>
            <title>Test 42</title>
        </head>
        <body class="main" id='content'>
            <p>Value is 3.14</p>
        </body>
        </html>
        """
        let html = highlight(source)

        // Numbers inside element content are not highlighted in HTML
        #expect(!html.contains("<font CLASS=integer>42</font>"))
        #expect(!html.contains("<font CLASS=floatpt>3.14</font>"))
        // HTML does not highlight floats inside element content
        #expect(html.contains("<font CLASS=dblquot>")) // double-quoted attribute highlighted
        #expect(html.contains("<font CLASS=sinquot>")) // single-quoted attribute highlighted
        #expect(html.contains("<font CLASS=preproc>")) // HTML tag highlighted
        #expect(html.contains("<font CLASS=comment>")) // HTML comment highlighted
    }
}
