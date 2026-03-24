//
//  HaskellHighlightTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests that Haskell syntax highlighting rules produce correct output.
struct HaskellHighlightTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "hs")
    }

    // MARK: Keywords

    @Test func keywordsAreHighlighted() {
        let html = highlight("ANN")
        #expect(html.contains("<font CLASS=keyword>ANN</font>"))
    }

    // MARK: Types

    @Test func typesAreHighlighted() {
        let html = highlight("Alternative")
        #expect(html.contains("<font CLASS=keytype>Alternative</font>"))
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
        // Haskell uses 'x' for character literals
        let html = highlight("'x'")
        #expect(html.contains("<font CLASS=sinquot>"))
    }

    @Test func singleQuoteInsideCommentIsNotHighlighted() {
        // Single quotes that appear inside a -- comment must not be highlighted
        let html = highlight("-- it's a comment")
        #expect(!html.contains("<font CLASS=sinquot>"))
        #expect(html.contains("<font CLASS=comment>"))
    }

    @Test func backtickStringsAreHighlighted() {
        // Haskell uses backtick for infix function application
        let html = highlight("`elem`")
        #expect(html.contains("<font CLASS=preproc>"))
    }

    // MARK: - Quote Combination Tests

    @Test func apostropheInsideDoubleQuoteIsNotSeparatelyHighlighted() {
        let html = highlight("\"it's fine\"")
        #expect(html.contains("<font CLASS=dblquot>"))
        #expect(!html.contains("<font CLASS=sinquot>"))
    }

    @Test func doubleQuoteInsideSingleQuoteIsNotSeparatelyHighlighted() {
        // The outer '...' is highlighted as sinquot; the inner "hi" is inside
        // a sinquot span so the dblquot parser skips it (escap1 = "'").
        let html = highlight("'say \"hi\"'")
        #expect(html.contains("<font CLASS=sinquot>"))
        #expect(!html.contains("<font CLASS=dblquot>"))
    }

    @Test func singleQuoteInsideBacktickIsNotSeparatelyHighlighted() {
        let html = highlight("`it's fine`")
        #expect(html.contains("<font CLASS=preproc>"))
        #expect(!html.contains("<font CLASS=sinquot>"))
    }

    // MARK: Symbols

    @Test func symbolsAreHighlighted() {
        let html = highlight("x + y")
        #expect(html.contains("<font CLASS=symbols>+</font>"))
    }

    // MARK: Comments

    @Test func blockCommentsAreHighlighted() {
        let html = highlight("{- a comment -}")
        #expect(html.contains("<font CLASS=comment>{- a comment -}</font>"))
    }

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
        {- Block comment -}
        -- Line comment
        module Main where
        import Data.List
        main :: IO ()
        main = do
            let x = 42
            let y = 3.14
            putStrLn "hello"
            let c = 'x'
            let z = x + 1
            let r = x `div` 2
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=keyword>module</font>"))
        #expect(html.contains("<font CLASS=keytype>IO</font>"))
        #expect(html.contains("<font CLASS=integer>42</font>"))
        #expect(html.contains("<font CLASS=floatpt>3.14</font>"))
        #expect(html.contains("<font CLASS=dblquot>")) // double-quoted string highlighted
        #expect(html.contains("<font CLASS=sinquot>")) // single-quoted char literal highlighted
        #expect(html.contains("<font CLASS=preproc>")) // backtick infix function highlighted
        #expect(html.contains("<font CLASS=symbols>+</font>"))
        #expect(html.contains("<font CLASS=comment>{- Block comment -}</font>"))
        #expect(html.contains("<font CLASS=comment>-- Line comment</font>"))
    }
}
