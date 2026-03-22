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
}
