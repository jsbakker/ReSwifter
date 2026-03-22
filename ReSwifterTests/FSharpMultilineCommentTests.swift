//
//  FSharpMultilineCommentTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests for (* *) block comment highlighting in F#.
struct FSharpMultilineCommentTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "fs")
    }

    // MARK: Block comment basics

    @Test func singleLineBlockCommentIsHighlighted() {
        let source = "(* this is a comment *)"
        let html = highlight(source)

        #expect(html.contains("<font CLASS=comment>(* this is a comment *)</font>"))
    }

    @Test func multilineBlockCommentIsHighlighted() {
        let source = """
        (* first line
           second line
           third line *)
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=comment>(* first line"))
        #expect(html.contains("third line *)</font>"))
    }

    @Test func inlineBlockCommentInCodeIsHighlighted() {
        let source = "let x = 1 (* inline *) + 2"
        let html = highlight(source)

        #expect(html.contains("<font CLASS=comment>(* inline *)</font>"))
    }

    // MARK: Nothing inside block comments should highlight

    @Test func keywordsInsideBlockCommentAreNotHighlighted() {
        let source = """
        (* let rec match
           module open type *)
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=keyword>"))
    }

    @Test func numbersInsideBlockCommentAreNotHighlighted() {
        let source = """
        (* 42 3.14
           0xFF 100 *)
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=integer>"))
        #expect(!html.contains("<font CLASS=floatpt>"))
    }

    @Test func stringsInsideBlockCommentAreNotHighlighted() {
        let source = """
        (* "hello world"
           'c' *)
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=dblquot>"))
    }

    @Test func tripleQuoteInsideBlockCommentDoesNotStartMultilineString() {
        let source = """
        (* \"\"\"
           this should still be a comment
           \"\"\" *)
        let x = 42
        """
        let html = highlight(source)

        // The line after the comment should NOT be string-colored
        #expect(html.contains("<font CLASS=keyword>let</font>"))
        #expect(html.contains("<font CLASS=integer>42</font>"))
    }

    @Test func singleLineCommentInsideBlockCommentDoesNotBreak() {
        let source = """
        (* // not a line comment
           still a block comment *)
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=comment>(* // not a line comment"))
        #expect(html.contains("still a block comment *)</font>"))
    }
}
