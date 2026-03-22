//
//  ValaMultilineStringTests.swift
//  ReSwifterTests
//

import Testing
@testable import ReSwifter

/// Tests for triple-quoted multiline string highlighting in Vala.
/// Vala uses `/* */` block comments and `//` single-line comments.
struct ValaMultilineStringTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "vala")
    }

    // MARK: Block comments inside multiline strings

    @Test func blockCommentInsideMultilineStringIsNotHighlighted() {
        let source = """
        string x = \"\"\"
        /* not a comment */
        \"\"\";
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=comment>/* not a comment */</font>"))
        #expect(html.contains("<font CLASS=dblquot>"))
    }

    // MARK: Regular block comments still work

    @Test func regularBlockCommentIsHighlighted() {
        let source = "/* this is a comment */"
        let html = highlight(source)

        #expect(html.contains("<font CLASS=comment>/* this is a comment */</font>"))
    }

    @Test func multilineBlockCommentIsHighlighted() {
        let source = """
        /* first line
           second line */
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=comment>/* first line"))
        #expect(html.contains("second line */</font>"))
    }

    // MARK: Multiline string content is uniformly string-colored

    @Test func keywordsInsideMultilineStringAreNotHighlighted() {
        let source = """
        string x = \"\"\"
        if else for while return
        \"\"\";
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=keyword>if</font>"))
        #expect(!html.contains("<font CLASS=keyword>for</font>"))
    }

    @Test func numbersInsideMultilineStringAreNotHighlighted() {
        let source = """
        string x = \"\"\"
        42 3.14
        \"\"\";
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=integer>42</font>"))
        #expect(!html.contains("<font CLASS=floatpt>3.14</font>"))
    }

    @Test func singleLineCommentInsideMultilineStringIsNotHighlighted() {
        let source = """
        string x = \"\"\"
        // not a comment
        \"\"\";
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=comment>// not a comment</font>"))
    }

    // MARK: Multiline string opens and closes correctly

    @Test func multilineStringProducesOpenAndCloseTag() {
        let source = """
        string x = \"\"\"
        content
        \"\"\";
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=dblquot>\"\"\""))
        #expect(html.contains("\"\"\"</font>"))
    }
}
