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

    @Test func singleQuotedStringsAreHighlighted() {
        // Standard SQL string literals use single quotes
        let html = highlight("'hello'")
        #expect(html.contains("<font CLASS=sinquot>"))
    }

    @Test func singleQuoteInsideCommentIsNotHighlighted() {
        // Single quotes that appear inside a -- comment must not be highlighted
        let html = highlight("-- it's a comment")
        #expect(!html.contains("<font CLASS=sinquot>"))
        #expect(html.contains("<font CLASS=comment>"))
    }

    @Test func backtickStringsAreHighlighted() {
        // MySQL uses backtick for identifier quoting
        let html = highlight("`table_name`")
        #expect(html.contains("<font CLASS=preproc>"))
    }

    // MARK: - Quote Combination Tests

    @Test func apostropheInsideDoubleQuoteIsNotSeparatelyHighlighted() {
        let html = highlight("\"it's fine\"")
        #expect(html.contains("<font CLASS=dblquot>"))
        #expect(!html.contains("<font CLASS=sinquot>"))
    }

    @Test func doubleQuoteInsideSingleQuoteIsNotSeparatelyHighlighted() {
        // The outer '...' is highlighted as sinquot; the inner "hi" is inside
        // a sinquot span so the dblquot parser skips it (escap1 = "'").
        let html = highlight("'say \"hi\"'")
        #expect(html.contains("<font CLASS=sinquot>"))
        #expect(!html.contains("<font CLASS=dblquot>"))
    }

    @Test func singleQuoteInsideBacktickIsNotSeparatelyHighlighted() {
        let html = highlight("`it's fine`")
        #expect(html.contains("<font CLASS=preproc>"))
        #expect(!html.contains("<font CLASS=sinquot>"))
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

    // MARK: - Underscore Numbers

    @Test func underscoreNumbersAreNotFullyHighlighted() {
        let html = highlight("1_000")
        #expect(!html.contains("<font CLASS=integer>1_000</font>"))
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
        AND status = 'active'
        AND label = "tagged"
        AND `table_name` IS NOT NULL
        CAST(age AS BIGINT)
        ORDER BY name;
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=keyword>SELECT</font>"))
        #expect(html.contains("<font CLASS=keyword>FROM</font>"))
        #expect(html.contains("<font CLASS=keytype>BIGINT</font>"))
        #expect(html.contains("<font CLASS=integer>42</font>"))
        #expect(html.contains("<font CLASS=floatpt>3.14</font>"))
        #expect(html.contains("<font CLASS=sinquot>")) // single-quoted string highlighted
        #expect(html.contains("<font CLASS=dblquot>")) // double-quoted string highlighted
        #expect(html.contains("<font CLASS=preproc>")) // backtick-quoted identifier highlighted
        #expect(html.contains("<font CLASS=comment>-- SQL comment</font>"))
        #expect(html.contains("<font CLASS=comment>/* Block comment */</font>"))
    }
}
