//
//  Modula2HighlightTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests that Modula2 syntax highlighting rules produce correct output.
struct Modula2HighlightTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "mod")
    }

    // MARK: Keywords

    @Test func keywordsAreHighlighted() {
        let html = highlight("ABSTRACT")
        #expect(html.contains("<font CLASS=keyword>ABSTRACT</font>"))
    }

    // MARK: Types

    @Test func typesAreHighlighted() {
        let html = highlight("ACHAR")
        #expect(html.contains("<font CLASS=keytype>ACHAR</font>"))
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
        let html = highlight("(* a comment *)")
        #expect(html.contains("<font CLASS=comment>(* a comment *)</font>"))
    }
}
