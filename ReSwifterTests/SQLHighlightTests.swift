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
}
