//
//  Modula2MultilineCommentTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests for (* *) block comment highlighting in Modula-2.
struct Modula2MultilineCommentTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "mod")
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
        let source = "x := 1 (* inline *) + 2;"
        let html = highlight(source)

        #expect(html.contains("<font CLASS=comment>(* inline *)</font>"))
    }

    // MARK: Nothing inside block comments should highlight

    @Test func keywordsInsideMultilineCommentAreNotHighlighted() {
        let source = """
        (* MODULE PROCEDURE
           BEGIN END TYPE *)
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=keyword>"))
    }

    @Test func numbersInsideMultilineCommentAreNotHighlighted() {
        let source = """
        (* 42 3.14
           0FFH 100 *)
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=integer>"))
        #expect(!html.contains("<font CLASS=floatpt>"))
    }

    @Test func typesInsideMultilineCommentAreNotHighlighted() {
        let source = """
        (* INTEGER BOOLEAN
           CARDINAL ARRAY *)
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=keytype>"))
    }

    @Test func stringsInsideMultilineCommentAreNotHighlighted() {
        let source = """
        (* "hello world"
           'test' *)
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=dblquot>"))
        #expect(!html.contains("<font CLASS=squot>"))
    }
}
