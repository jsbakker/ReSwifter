//
//  SwiftMultilineStringTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests for triple-quoted multiline string highlighting in Swift.
struct SwiftMultilineStringTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "swift")
    }

    // MARK: Block comments inside multiline strings

    @Test func blockCommentInsideMultilineStringIsNotHighlighted() {
        let source = """
        let x = \"\"\"
        /* not a comment */
        \"\"\"
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=comment>/* not a comment */</font>"))
        #expect(html.contains("<font CLASS=dblquot>"))
    }

    @Test func blockCommentInsideIndentedMultilineStringIsNotHighlighted() {
        let source = """
        func f() {
            let x = \"\"\"
                /* not a comment */
                \"\"\"
        }
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=comment>/* not a comment */</font>"))
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

    @Test func inlineBlockCommentInCodeIsHighlighted() {
        let source = "_ = nums.map { (/* unused */ _: Int) in 0 }"
        let html = highlight(source)

        #expect(html.contains("<font CLASS=comment>/* unused */</font>"))
    }

    // MARK: Multiline string content is uniformly string-colored

    @Test func keywordsInsideMultilineStringAreNotHighlighted() {
        let source = """
        let x = \"\"\"
        if else for while return
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
        Int String Bool Double
        \"\"\"
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=keytype>"))
    }

    @Test func symbolsInsideMultilineStringAreNotHighlighted() {
        let source = """
        \"\"\"
        + - * = < > -> =>
        \"\"\"
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=symbols>"))
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
