//
//  XMLMultilineCommentTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests for <!-- --> block comment highlighting in XML.
struct XMLMultilineCommentTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "xml")
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
        <!-- <root attr="value">
             <child/>
             </root> -->
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=comment>&lt;!-- &lt;root"))
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
