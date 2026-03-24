//
//  RHighlightTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests that R syntax highlighting rules produce correct output.
struct RHighlightTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "r")
    }

    // MARK: Keywords

    @Test func keywordsAreHighlighted() {
        let html = highlight("FALSE")
        #expect(html.contains("<font CLASS=keyword>FALSE</font>"))
    }

    // MARK: Types

    @Test func typesAreHighlighted() {
        let html = highlight("array")
        #expect(html.contains("<font CLASS=keytype>array</font>"))
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
        let html = highlight("# comment")
        #expect(html.contains("<font CLASS=comment># comment</font>"))
    }

    // MARK: - Underscore Numbers

    @Test func underscoreNumbersAreNotFullyHighlighted() {
        let html = highlight("1_000")
        #expect(!html.contains("<font CLASS=integer>1_000</font>"))
    }

    // MARK: - Comprehensive Snippet

    @Test func comprehensiveSnippetHighlightsAllRules() {
        let source = """
        # R comment
        x <- 42
        y <- 3.14
        s <- "hello"
        t <- 'world'
        flag <- FALSE
        v <- array(c(1, 2, 3))
        result <- x + 1
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=keyword>FALSE</font>"))
        #expect(html.contains("<font CLASS=keytype>array</font>"))
        #expect(html.contains("<font CLASS=integer>42</font>"))
        #expect(html.contains("<font CLASS=floatpt>3.14</font>"))
        #expect(html.contains("<font CLASS=dblquot>")) // double-quoted string highlighted
        #expect(html.contains("<font CLASS=sinquot>")) // single-quoted string highlighted
        #expect(html.contains("<font CLASS=symbols>+</font>"))
        #expect(html.contains("<font CLASS=comment># R comment</font>"))
    }
}
