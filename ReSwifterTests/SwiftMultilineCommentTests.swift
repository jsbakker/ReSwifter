//
//  SwiftMultilineCommentTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests for /* */ block comment highlighting in Swift.
struct SwiftMultilineCommentTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "swift")
    }

    // MARK: Block comment basics

    @Test func singleLineMultilineCommentIsHighlighted() {
        let source = "/* this is a comment */"
        let html = highlight(source)

        #expect(html.contains("<font CLASS=comment>/* this is a comment */</font>"))
    }

    @Test func multilineMultilineCommentIsHighlighted() {
        let source = """
        /* first line
           second line
           third line */
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=comment>/* first line"))
        #expect(html.contains("third line */</font>"))
    }

    @Test func inlineMultilineCommentInCodeIsHighlighted() {
        let source = "let x = 1 /* inline */ + 2"
        let html = highlight(source)

        #expect(html.contains("<font CLASS=comment>/* inline */</font>"))
    }

    // MARK: Nothing inside block comments should highlight

    @Test func keywordsInsideMultilineCommentAreNotHighlighted() {
        let source = """
        /* if else for while
           return func struct class */
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=keyword>"))
    }

    @Test func numbersInsideMultilineCommentAreNotHighlighted() {
        let source = """
        /* 42 3.14
           0xFF 100 */
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=integer>"))
        #expect(!html.contains("<font CLASS=floatpt>"))
    }

    @Test func stringsInsideMultilineCommentAreNotHighlighted() {
        let source = """
        /* "hello world"
           'c' */
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=dblquot>"))
        #expect(!html.contains("<font CLASS=squot>"))
    }

    @Test func tripleQuoteInsideMultilineCommentDoesNotStartMultilineString() {
        let source = """
        /* \"\"\"
           this should still be a comment
           \"\"\" */
        let x = 42
        """
        let html = highlight(source)

        // The line after the comment should NOT be string-colored
        #expect(html.contains("<font CLASS=keyword>let</font>"))
        #expect(html.contains("<font CLASS=integer>42</font>"))
    }

    @Test func typesInsideMultilineCommentAreNotHighlighted() {
        let source = """
        /* Int String Bool
           Double Array */
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=keytype>"))
    }

    @Test func symbolsInsideMultilineCommentAreNotHighlighted() {
        let source = """
        /* + - * = < >
           -> => :: */
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=symbols>"))
    }

    @Test func singleLineCommentInsideMultilineCommentDoesNotBreak() {
        let source = """
        /* // not a line comment
           still a block comment */
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=comment>/* // not a line comment"))
        #expect(html.contains("still a block comment */</font>"))
    }
}
