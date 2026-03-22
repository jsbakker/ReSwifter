//
//  PythonMultilineStringTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests for triple-quoted multiline string highlighting in Python.
/// Python uses `#` for single-line comments (no block comments).
struct PythonMultilineStringTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "py")
    }

    // MARK: Multiline string content is uniformly string-colored

    @Test func keywordsInsideMultilineStringAreNotHighlighted() {
        let source = """
        x = \"\"\"
        if else for while return
        \"\"\"
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=keyword>if</font>"))
        #expect(!html.contains("<font CLASS=keyword>for</font>"))
    }

    @Test func numbersInsideMultilineStringAreNotHighlighted() {
        let source = """
        x = \"\"\"
        42 3.14
        \"\"\"
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=integer>42</font>"))
        #expect(!html.contains("<font CLASS=floatpt>3.14</font>"))
    }

    @Test func hashCommentInsideMultilineStringIsNotHighlighted() {
        let source = """
        x = \"\"\"
        # not a comment
        \"\"\"
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=comment># not a comment</font>"))
    }

    // MARK: Regular comments still work

    @Test func regularHashCommentIsHighlighted() {
        let source = "# this is a comment"
        let html = highlight(source)

        #expect(html.contains("<font CLASS=comment># this is a comment</font>"))
    }

    @Test func typesInsideMultilineStringAreNotHighlighted() {
        let source = """
        x = \"\"\"
        int str float list
        \"\"\"
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=keytype>"))
    }

    @Test func symbolsInsideMultilineStringAreNotHighlighted() {
        let source = """
        \"\"\"
        + - * = < > ** //
        \"\"\"
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=symbols>"))
    }

    // MARK: Multiline string opens and closes correctly

    @Test func multilineStringProducesOpenAndCloseTag() {
        let source = """
        x = \"\"\"
        content
        \"\"\"
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=dblquot>\"\"\""))
        #expect(html.contains("\"\"\"</font>"))
    }
}
