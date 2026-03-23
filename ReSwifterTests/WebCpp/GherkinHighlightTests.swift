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

    @Test func singleQuotedStringsAreNotHighlighted() {
        let html = highlight("'hello'")
        #expect(!html.contains("<font CLASS=sinquot>"))
    }

    @Test func backtickStringsAreNotHighlighted() {
        let html = highlight("`hello`")
        #expect(!html.contains("<font CLASS=preproc>"))
    }

    @Test func apostropheInsideDoubleQuoteIsNotSeparatelyHighlighted() {
        let html = highlight("\"it's fine\"")
        #expect(html.contains("<font CLASS=dblquot>"))
        #expect(!html.contains("<font CLASS=sinquot>"))
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

    // MARK: - Comprehensive Snippet

    @Test func comprehensiveSnippetHighlightsAllRules() {
        let source = """
        # Gherkin comment
        Feature: Login
          Background: User exists
          Scenario: Valid login
            Given a user "admin"
            When they enter 'password'
            Then they see $dashboard
            And the count is <total>
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=keyword>Given</font>"))
        #expect(html.contains("<font CLASS=keyword>Feature</font>"))
        #expect(html.contains("<font CLASS=dblquot>")) // double-quoted string highlighted
        #expect(!html.contains("<font CLASS=sinquot>")) // single quotes not supported in Gherkin
        #expect(html.contains("<font CLASS=preproc>")) // scalar variable highlighted
        #expect(html.contains("<font CLASS=comment># Gherkin comment</font>"))
    }
}
