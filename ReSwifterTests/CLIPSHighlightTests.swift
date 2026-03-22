//
//  CLIPSHighlightTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests that CLIPS syntax highlighting rules produce correct output.
struct CLIPSHighlightTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "clp")
    }

    // MARK: Keywords

    @Test func keywordsAreHighlighted() {
        let html = highlight("FALSE")
        #expect(html.contains("<font CLASS=keyword>FALSE</font>"))
    }

    // MARK: Types

    @Test func typesAreHighlighted() {
        let html = highlight("ADDRESS")
        #expect(html.contains("<font CLASS=keytype>ADDRESS</font>"))
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


    @Test func inlineCommentsAreHighlighted() {
        let html = highlight("; comment")
        #expect(html.contains("<font CLASS=comment>; comment</font>"))
    }
}
