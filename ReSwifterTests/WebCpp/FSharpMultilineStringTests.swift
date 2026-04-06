//
//  FSharpMultilineStringTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests for triple-quoted multiline string highlighting in F#.
/// F# uses `(* *)` block comments and `//` single-line comments (no `/* */`).
struct FSharpMultilineStringTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "fs")
    }

    // MARK: Pascal-style block comments inside multiline strings

    @Test func pascalBlockCommentInsideMultilineStringIsNotHighlighted() {
        let source = """
        let x = \"\"\"
        (* not a comment *)
        \"\"\"
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=comment>(* not a comment *)</font>"))
        #expect(html.contains("<font CLASS=dblquot>"))
    }

    // MARK: Regular block comments still work

    @Test func regularPascalBlockCommentIsHighlighted() {
        let source = "(* this is a comment *)"
        let html = highlight(source)

        #expect(html.contains("<font CLASS=comment>(* this is a comment *)</font>"))
    }

    @Test func multilinePascalBlockCommentIsHighlighted() {
        let source = """
        (* first line
           second line *)
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=comment>(* first line"))
        #expect(html.contains("second line *)</font>"))
    }

    // MARK: Multiline string content is uniformly string-colored

    @Test func keywordsInsideMultilineStringAreNotHighlighted() {
        let source = """
        let x = \"\"\"
        if else for while match
        \"\"\"
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=keyword>if</font>"))
        #expect(!html.contains("<font CLASS=keyword>for</font>"))
    }

    @Test func numbersInsideMultilineStringAreNotHighlighted() {
        let source = """
        let x = \"\"\"
        42 3.14
        \"\"\"
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=integer>42</font>"))
        #expect(!html.contains("<font CLASS=floatpt>3.14</font>"))
    }

    @Test func singleLineCommentInsideMultilineStringIsNotHighlighted() {
        let source = """
        let x = \"\"\"
        // not a comment
        \"\"\"
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=comment>// not a comment</font>"))
    }

    @Test func typesInsideMultilineStringAreNotHighlighted() {
        let source = """
        let x = \"\"\"
        int string bool float
        \"\"\"
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=keytype>"))
    }

    @Test func symbolsInsideMultilineStringAreNotHighlighted() {
        let source = """
        \"\"\"
        + - * = < > |> >>
        \"\"\"
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=symbols>"))
    }

    // MARK: Code before multiline string delimiter is highlighted

    @Test func keywordBeforeMultilineStringIsHighlighted() {
        let source = """
        let x = \"\"\"
        content
        \"\"\"
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=keyword>let</font>"))
    }

    // MARK: Multiline string opens and closes correctly

    @Test func multilineStringProducesOpenAndCloseTag() {
        let source = """
        let x = \"\"\"
        content
        \"\"\"
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=dblquot>\"\"\""))
        #expect(html.contains("\"\"\"</font>"))
    }
}
