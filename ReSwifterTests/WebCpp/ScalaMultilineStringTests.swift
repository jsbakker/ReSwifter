//
//  ScalaMultilineStringTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests for triple-quoted multiline string highlighting in Scala.
/// Scala uses `/* */` block comments and `//` single-line comments.
struct ScalaMultilineStringTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "scala")
    }

    // MARK: Block comments inside multiline strings

    @Test func blockCommentInsideMultilineStringIsNotHighlighted() {
        let source = """
        val x = \"\"\"
        /* not a comment */
        \"\"\"
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
        val x = \"\"\"
        if else for while return
        \"\"\"
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=keyword>if</font>"))
        #expect(!html.contains("<font CLASS=keyword>for</font>"))
    }

    @Test func numbersInsideMultilineStringAreNotHighlighted() {
        let source = """
        val x = \"\"\"
        42 3.14
        \"\"\"
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=integer>42</font>"))
        #expect(!html.contains("<font CLASS=floatpt>3.14</font>"))
    }

    @Test func singleLineCommentInsideMultilineStringIsNotHighlighted() {
        let source = """
        val x = \"\"\"
        // not a comment
        \"\"\"
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=comment>// not a comment</font>"))
    }

    @Test func typesInsideMultilineStringAreNotHighlighted() {
        let source = """
        val x = \"\"\"
        Int String Boolean Array
        \"\"\"
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=keytype>"))
    }

    @Test func symbolsInsideMultilineStringAreNotHighlighted() {
        let source = """
        \"\"\"
        + - * = < > => ::
        \"\"\"
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=symbols>"))
    }

    // MARK: Code before multiline string delimiter is highlighted

    @Test func keywordBeforeMultilineStringIsHighlighted() {
        let source = """
        val x = \"\"\"
        content
        \"\"\"
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=keyword>val</font>"))
    }

    // MARK: Multiline string opens and closes correctly

    @Test func multilineStringProducesOpenAndCloseTag() {
        let source = """
        val x = \"\"\"
        content
        \"\"\"
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=dblquot>\"\"\""))
        #expect(html.contains("\"\"\"</font>"))
    }
}
