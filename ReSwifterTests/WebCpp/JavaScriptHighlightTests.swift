//
//  JavaScriptHighlightTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests that JavaScript syntax highlighting rules produce correct output.
struct JavaScriptHighlightTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "js")
    }

    // MARK: Keywords

    @Test func keywordsAreHighlighted() {
        let html = highlight("as")
        #expect(html.contains("<font CLASS=keyword>as</font>"))
    }

    // MARK: Types

    @Test func typesAreHighlighted() {
        let html = highlight("Array")
        #expect(html.contains("<font CLASS=keytype>Array</font>"))
    }

    // MARK: Numbers

    @Test func integersAreHighlighted() {
        let html = highlight("42")
        #expect(html.contains("<font CLASS=integer>42</font>"))
    }

    @Test func floatsAreHighlighted() {
        let html = highlight("3.14")
        #expect(html.contains("<font CLASS=floatpt>3.14</font>"))
    }

    // MARK: Strings

    @Test func doubleQuotedStringsAreHighlighted() {
        let html = highlight("\"hello\"")
        #expect(html.contains("<font CLASS=dblquot>"))
    }

    @Test func singleQuotedStringsAreHighlighted() {
        let html = highlight("'hello'")
        #expect(html.contains("<font CLASS=sinquot>"))
    }

    @Test func backtickTemplateStringsAreHighlighted() {
        // JS uses backtick template literals
        let html = highlight("`hello world`")
        #expect(html.contains("<font CLASS=preproc>"))
    }

    // MARK: - Quote Combination Tests

    @Test func apostropheInsideDoubleQuoteIsNotSeparatelyHighlighted() {
        let html = highlight("\"it's fine\"")
        #expect(html.contains("<font CLASS=dblquot>"))
        #expect(!html.contains("<font CLASS=sinquot>"))
    }

    @Test func doubleQuoteInsideSingleQuoteIsNotSeparatelyHighlighted() {
        let html = highlight("'say \"hi\"'")
        #expect(html.contains("<font CLASS=sinquot>"))
        #expect(!html.contains("<font CLASS=dblquot>"))
    }

    @Test func singleQuoteInsideBacktickIsNotSeparatelyHighlighted() {
        let html = highlight("`it's fine`")
        #expect(html.contains("<font CLASS=preproc>"))
        #expect(!html.contains("<font CLASS=sinquot>"))
    }

    // MARK: Symbols

    @Test func symbolsAreHighlighted() {
        let html = highlight("x + y")
        #expect(html.contains("<font CLASS=symbols>+</font>"))
    }

    // MARK: Comments

    @Test func blockCommentsAreHighlighted() {
        let html = highlight("/* a comment */")
        #expect(html.contains("<font CLASS=comment>/* a comment */</font>"))
    }

    @Test func inlineCommentsAreHighlighted() {
        let html = highlight("// comment")
        #expect(html.contains("<font CLASS=comment>// comment</font>"))
    }

    // MARK: - String Interpolation

    @Test func interpolationDoesNotBreakBacktickStringHighlighting() {
        let html = highlight("`Hello, ${name}!`")
        #expect(html.contains("<font CLASS=preproc>"))
    }

    @Test func integerInsideInterpolationIsHighlighted() {
        let html = highlight("`Value: ${42}`")
        #expect(html.contains("<font CLASS=preproc>"))
        #expect(html.contains("<font CLASS=integer>42</font>"))
    }

    @Test func symbolInsideInterpolationIsHighlighted() {
        let html = highlight("`Sum: ${a + b}`")
        #expect(html.contains("<font CLASS=symbols>+</font>"))
    }

    @Test func keywordInsideInterpolationIsHighlighted() {
        let html = highlight("`Val: ${null}`")
        #expect(html.contains("<font CLASS=keyword>null</font>"))
    }

    @Test func typeInsideInterpolationIsHighlighted() {
        let html = highlight("`Cast: ${Boolean(x)}`")
        #expect(html.contains("<font CLASS=keytype>Boolean</font>"))
    }

    @Test func integerInBacktickStringWithoutInterpolationIsNotHighlighted() {
        let html = highlight("`count is 42`")
        #expect(html.contains("<font CLASS=preproc>"))
        #expect(!html.contains("<font CLASS=integer>42</font>"))
    }

    @Test func doubleQuotedStringDoesNotInterpolate() {
        // Regular double-quoted strings don't interpolate in JS
        let html = highlight("\"${42}\"")
        #expect(html.contains("<font CLASS=dblquot>"))
        #expect(!html.contains("<font CLASS=integer>42</font>"))
    }

    // MARK: - Comprehensive Snippet

    @Test func comprehensiveSnippetHighlightsAllRules() {
        let source = """
        /* Block comment */
        // Line comment
        async function example() {
            const x = 42;
            let pi = 3.14;
            var s = "hello";
            var c = 'world';
            var arr = Array(x + 1);
            await fetch(s);
        }
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=keyword>async</font>"))
        #expect(html.contains("<font CLASS=keyword>const</font>"))
        #expect(html.contains("<font CLASS=keytype>Array</font>"))
        #expect(html.contains("<font CLASS=integer>42</font>"))
        #expect(html.contains("<font CLASS=floatpt>3.14</font>"))
        #expect(html.contains("<font CLASS=dblquot>")) // double-quoted string highlighted
        #expect(html.contains("<font CLASS=sinquot>")) // single-quoted string highlighted
        #expect(html.contains("<font CLASS=symbols>+</font>"))
        #expect(html.contains("<font CLASS=comment>/* Block comment */</font>"))
        #expect(html.contains("<font CLASS=comment>// Line comment</font>"))
    }
}
