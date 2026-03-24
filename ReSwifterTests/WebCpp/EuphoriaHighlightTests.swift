//
//  EuphoriaHighlightTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests that Euphoria syntax highlighting rules produce correct output.
struct EuphoriaHighlightTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "eu")
    }

    // MARK: Keywords

    @Test func keywordsAreHighlighted() {
        let html = highlight("and")
        #expect(html.contains("<font CLASS=keyword>and</font>"))
    }

    // MARK: Types

    @Test func typesAreHighlighted() {
        let html = highlight("atom")
        #expect(html.contains("<font CLASS=keytype>atom</font>"))
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
        let html = highlight("-- comment")
        #expect(html.contains("<font CLASS=comment>-- comment</font>"))
    }

    // MARK: - Underscore Numbers

    @Test func underscoreIntegersAreHighlighted() {
        let html = highlight("1_000_000")
        #expect(html.contains("<font CLASS=integer>1_000_000</font>"))
    }

    @Test func underscoreFloatsAreHighlighted() {
        let html = highlight("1.123_456")
        #expect(html.contains("<font CLASS=floatpt>1.123_456</font>"))
    }

    // MARK: - Comprehensive Snippet

    @Test func comprehensiveSnippetHighlightsAllRules() {
        let source = """
        -- Euphoria comment
        integer x
        x = 42
        atom y
        y = 3.14
        sequence s
        s = "hello"
        if x > 0 then
            puts(1, 'c')
        end if
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=keyword>then</font>"))
        #expect(html.contains("<font CLASS=keytype>integer</font>"))
        #expect(html.contains("<font CLASS=keytype>atom</font>"))
        #expect(html.contains("<font CLASS=integer>42</font>"))
        #expect(html.contains("<font CLASS=floatpt>3.14</font>"))
        #expect(html.contains("<font CLASS=dblquot>")) // double-quoted string highlighted
        #expect(html.contains("<font CLASS=comment>-- Euphoria comment</font>"))
    }
}
