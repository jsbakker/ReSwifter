//
//  ASPHighlightTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests that ASP syntax highlighting rules produce correct output.
struct ASPHighlightTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "asp")
    }

    // MARK: Keywords

    @Test func keywordsAreHighlighted() {
        let html = highlight("and")
        #expect(html.contains("<font CLASS=keyword>and</font>"))
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

    @Test func inlineCommentsAreHighlighted() {
        let html = highlight("' comment")
        #expect(html.contains("<font CLASS=comment>' comment</font>"))
    }
}
