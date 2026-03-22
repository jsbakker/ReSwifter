//
//  ZigHighlightTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests that Zig syntax highlighting rules produce correct output.
struct ZigHighlightTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "zig")
    }

    // MARK: Keywords

    @Test func keywordsAreHighlighted() {
        let html = highlight("addrspace")
        #expect(html.contains("<font CLASS=keyword>addrspace</font>"))
    }

    // MARK: Types

    @Test func typesAreHighlighted() {
        let html = highlight("anyerror")
        #expect(html.contains("<font CLASS=keytype>anyerror</font>"))
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
        let html = highlight("// comment")
        #expect(html.contains("<font CLASS=comment>// comment</font>"))
    }
}
