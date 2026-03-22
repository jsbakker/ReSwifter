//
//  XMLHighlightTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests that XML syntax highlighting rules produce correct output.
struct XMLHighlightTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "xml")
    }

    // MARK: Keywords

    @Test func keywordsAreHighlighted() {
        let html = highlight("?xml")
        #expect(html.contains("<font CLASS=keyword>?xml</font>"))
    }

    // MARK: Types

    @Test func typesAreHighlighted() {
        let html = highlight("encoding")
        #expect(html.contains("<font CLASS=keytype>encoding</font>"))
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
