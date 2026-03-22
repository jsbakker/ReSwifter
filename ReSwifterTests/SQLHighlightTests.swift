//
//  SQLHighlightTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests that SQL syntax highlighting rules produce correct output.
struct SQLHighlightTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "sql")
    }

    // MARK: Keywords

    @Test func keywordsAreHighlighted() {
        let html = highlight("ADD")
        #expect(html.contains("<font CLASS=keyword>ADD</font>"))
    }

    // MARK: Types

    @Test func typesAreHighlighted() {
        let html = highlight("BIGINT")
        #expect(html.contains("<font CLASS=keytype>BIGINT</font>"))
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

    // MARK: Comments

    @Test func blockCommentsAreHighlighted() {
        let html = highlight("/* a comment */")
        #expect(html.contains("<font CLASS=comment>/* a comment */</font>"))
    }

    @Test func inlineCommentsAreHighlighted() {
        let html = highlight("-- comment")
        #expect(html.contains("<font CLASS=comment>-- comment</font>"))
    }

    // MARK: - Comprehensive Snippet

    @Test func comprehensiveSnippetHighlightsAllRules() {
        let source = """
        -- SQL comment
        /* Block comment */
        SELECT name, age
        FROM users
        WHERE age > 42
        AND salary = 3.14
        AND status = "active"
        ORDER BY name;
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=keyword>SELECT</font>"))
        #expect(html.contains("<font CLASS=keyword>FROM</font>"))
        #expect(html.contains("<font CLASS=keytype>BIGINT</font>"))
        #expect(html.contains("<font CLASS=integer>42</font>"))
        #expect(html.contains("<font CLASS=floatpt>3.14</font>"))
        #expect(html.contains("<font CLASS=dblquot>")) // double-quoted string highlighted
        #expect(html.contains("<font CLASS=comment>-- SQL comment</font>"))
        #expect(html.contains("<font CLASS=comment>/* Block comment */</font>"))
    }
}
