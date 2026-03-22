//
//  GherkinHighlightTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests that Gherkin syntax highlighting rules produce correct output.
struct GherkinHighlightTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "feature")
    }

    // MARK: Keywords

    @Test func keywordsAreHighlighted() {
        let html = highlight("Abstract")
        #expect(html.contains("<font CLASS=keyword>Abstract</font>"))
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

    @Test func scalarVariablesAreHighlighted() {
        let html = highlight("$variable")
        #expect(html.contains("<font CLASS=preproc>"))
    }

    // MARK: Comments


    @Test func inlineCommentsAreHighlighted() {
        let html = highlight("# comment")
        #expect(html.contains("<font CLASS=comment># comment</font>"))
    }
}
