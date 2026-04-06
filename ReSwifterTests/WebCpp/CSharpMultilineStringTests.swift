//
//  CSharpMultilineStringTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests for triple-quoted multiline string highlighting in C#.
/// C# uses `/* */` block comments and `//` single-line comments.
struct CSharpMultilineStringTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "cs")
    }

    // MARK: Block comments inside multiline strings

    @Test func blockCommentInsideMultilineStringIsNotHighlighted() {
        let source = """
        var x = \"\"\"
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
        var x = \"\"\"
        if else for while return
        \"\"\";
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=keyword>if</font>"))
        #expect(!html.contains("<font CLASS=keyword>for</font>"))
    }

    @Test func numbersInsideMultilineStringAreNotHighlighted() {
        let source = """
        var x = \"\"\"
        42 3.14
        \"\"\";
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=integer>42</font>"))
        #expect(!html.contains("<font CLASS=floatpt>3.14</font>"))
    }

    @Test func singleLineCommentInsideMultilineStringIsNotHighlighted() {
        let source = """
        var x = \"\"\"
        // not a comment
        \"\"\";
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=comment>// not a comment</font>"))
    }

    @Test func typesInsideMultilineStringAreNotHighlighted() {
        let source = """
        var x = \"\"\"
        Boolean Int32 String
        \"\"\";
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

    @Test func preprocessorInsideMultilineStringIsNotHighlighted() {
        let source = """
        var x = \"\"\"
        #if DEBUG
        #define FOO
        #endif
        \"\"\";
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=preproc>"))
    }

    // MARK: Tokens before multiline string delimiter are highlighted

    @Test func keywordBeforeMultilineStringIsHighlighted() {
        let source = """
        var x = \"\"\"
        content
        \"\"\";
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=keyword>var</font>"))
    }

    // MARK: Multiline string opens and closes correctly

    @Test func multilineStringProducesOpenAndCloseTag() {
        let source = """
        var x = \"\"\"
        content
        \"\"\";
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=dblquot>\"\"\""))
        #expect(html.contains("\"\"\"</font>"))
    }
}
