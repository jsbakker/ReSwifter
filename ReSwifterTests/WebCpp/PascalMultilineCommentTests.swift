//
//  PascalMultilineCommentTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests for (* *) block comment highlighting in Pascal.
struct PascalMultilineCommentTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "pas")
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
        (* begin end procedure
           function program unit *)
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=keyword>"))
    }

    @Test func numbersInsideMultilineCommentAreNotHighlighted() {
        let source = """
        (* 42 3.14
           $FF 100 *)
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=integer>"))
        #expect(!html.contains("<font CLASS=floatpt>"))
    }

    @Test func stringsInsideMultilineCommentAreNotHighlighted() {
        let source = """
        (* 'hello world'
           "test" *)
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=dblquot>"))
        #expect(!html.contains("<font CLASS=squot>"))
    }

    @Test func typesInsideMultilineCommentAreNotHighlighted() {
        let source = """
        (* Integer Boolean String
           Byte Cardinal *)
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=keytype>"))
    }

    @Test func hashVariablesInsideMultilineCommentAreNotHighlighted() {
        let source = """
        (* %variable
           %hash *)
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=preproc>"))
    }

    @Test func singleLineCommentInsideMultilineCommentDoesNotBreak() {
        let source = """
        (* // not a line comment
           still a block comment *)
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=comment>(* // not a line comment"))
        #expect(html.contains("still a block comment *)</font>"))
    }
}
