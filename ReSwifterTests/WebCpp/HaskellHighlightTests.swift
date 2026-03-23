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
            let z = x + 1
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=keyword>module</font>"))
        #expect(html.contains("<font CLASS=keytype>IO</font>"))
        #expect(html.contains("<font CLASS=integer>42</font>"))
        #expect(html.contains("<font CLASS=floatpt>3.14</font>"))
        #expect(html.contains("<font CLASS=dblquot>")) // double-quoted string highlighted
        #expect(html.contains("<font CLASS=symbols>+</font>"))
        #expect(html.contains("<font CLASS=comment>{- Block comment -}</font>"))
        #expect(html.contains("<font CLASS=comment>-- Line comment</font>"))
    }
}
