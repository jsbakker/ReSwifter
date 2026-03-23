//
//  HTMLMultilineCommentTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests for <!-- --> block comment highlighting in HTML.
struct HTMLMultilineCommentTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "html")
    }

    // MARK: Block comment basics

    @Test func singleLineMultilineCommentIsHighlighted() {
        let source = "<!-- this is a comment -->"
        let html = highlight(source)

        #expect(html.contains("<font CLASS=comment>&lt;!-- this is a comment --&gt;</font>"))
    }

    @Test func multilineMultilineCommentIsHighlighted() {
        let source = """
        <!-- first line
             second line
             third line -->
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=comment>&lt;!-- first line"))
        #expect(html.contains("third line --&gt;</font>"))
    }

    // MARK: Nothing inside block comments should highlight

    @Test func tagsInsideMultilineCommentAreNotHighlighted() {
        let source = """
        <!-- <div class="test">
             <p>hello</p>
             </div> -->
        """
        let html = highlight(source)

        // Tags inside comments should not get tag highlighting
        #expect(html.contains("<font CLASS=comment>&lt;!-- &lt;div"))
    }

    @Test func numbersInsideMultilineCommentAreNotHighlighted() {
        let source = """
        <!-- 42 3.14
             0xFF 100 -->
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=integer>"))
        #expect(!html.contains("<font CLASS=floatpt>"))
    }

    @Test func stringsInsideMultilineCommentAreNotHighlighted() {
        let source = """
        <!-- "hello world"
             'test string' -->
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=dblquot>"))
    }
}
