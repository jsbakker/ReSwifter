//
//  BatchHighlightTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests that Batch syntax highlighting rules produce correct output.
struct BatchHighlightTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "bat")
    }

    // MARK: Keywords

    @Test func keywordsAreHighlighted() {
        let html = highlight("assoc")
        #expect(html.contains("<font CLASS=keyword>assoc</font>"))
    }

    // MARK: Types

    @Test func typesAreHighlighted() {
        let html = highlight("at")
        #expect(html.contains("<font CLASS=keytype>at</font>"))
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

    // MARK: Variables

    @Test func hashVariablesAreHighlighted() {
        let html = highlight("%variable")
        #expect(html.contains("<font CLASS=preproc>"))
    }

    // MARK: Comments


    @Test func inlineCommentsAreHighlighted() {
        let html = highlight("REM comment")
        #expect(html.contains("<font CLASS=comment>REM comment</font>"))
    }
}
