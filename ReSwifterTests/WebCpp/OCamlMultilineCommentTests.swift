//
//  OCamlMultilineCommentTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests for (* *) block comment highlighting in OCaml.
struct OCamlMultilineCommentTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "ml")
    }

    // MARK: Block comment basics

    @Test func singleLineMultilineCommentIsHighlighted() {
        let source = "(* this is a comment *)"
        let html = highlight(source)

        #expect(html.contains("<font CLASS=comment>(* this is a comment *)</font>"))
    }

    @Test func multilineMultilineCommentIsHighlighted() {
        let source = """
        (* first line
           second line
           third line *)
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=comment>(* first line"))
        #expect(html.contains("third line *)</font>"))
    }

    @Test func inlineMultilineCommentInCodeIsHighlighted() {
        let source = "let x = 1 (* inline *) + 2"
        let html = highlight(source)

        #expect(html.contains("<font CLASS=comment>(* inline *)</font>"))
    }

    // MARK: Nothing inside block comments should highlight

    @Test func keywordsInsideMultilineCommentAreNotHighlighted() {
        let source = """
        (* let rec match
           module open type *)
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=keyword>"))
    }

    @Test func numbersInsideMultilineCommentAreNotHighlighted() {
        let source = """
        (* 42 3.14
           0xFF 100 *)
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=integer>"))
        #expect(!html.contains("<font CLASS=floatpt>"))
    }

    @Test func typesInsideMultilineCommentAreNotHighlighted() {
        let source = """
        (* int string bool
           float char *)
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=keytype>"))
    }

    @Test func symbolsInsideMultilineCommentAreNotHighlighted() {
        let source = """
        (* + - * = < >
           -> |> :: *)
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=symbols>"))
    }

    @Test func stringsInsideMultilineCommentAreNotHighlighted() {
        let source = """
        (* "hello world"
           'c' *)
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=dblquot>"))
    }
}
