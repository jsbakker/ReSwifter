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

    @Test func singleLineBlockCommentIsHighlighted() {
        let source = "<!-- this is a comment -->"
        let html = highlight(source)

        #expect(html.contains("<font CLASS=comment>&lt;!-- this is a comment --&gt;</font>"))
    }

    @Test func multilineBlockCommentIsHighlighted() {
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

    @Test func tagsInsideBlockCommentAreNotHighlighted() {
        let source = """
        <!-- <div class="test">
             <p>hello</p>
             </div> -->
        """
        let html = highlight(source)

        // Tags inside comments should not get tag highlighting
        #expect(html.contains("<font CLASS=comment>&lt;!-- &lt;div"))
    }

    @Test func stringsInsideBlockCommentAreNotHighlighted() {
        let source = """
        <!-- "hello world"
             'test string' -->
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=dblquot>"))
    }
}
