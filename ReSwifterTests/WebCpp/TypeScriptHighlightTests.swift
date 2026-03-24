//
//  TypeScriptHighlightTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests that TypeScript syntax highlighting rules produce correct output.
struct TypeScriptHighlightTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "ts")
    }

    // MARK: Keywords

    @Test func keywordsAreHighlighted() {
        let html = highlight("abstract")
        #expect(html.contains("<font CLASS=keyword>abstract</font>"))
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
        // TypeScript uses backtick template literals
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
        let html = highlight("\"${42}\"")
        #expect(html.contains("<font CLASS=dblquot>"))
        #expect(!html.contains("<font CLASS=integer>42</font>"))
    }

    // MARK: - Underscore Numbers

    @Test func underscoreIntegersAreHighlighted() {
        let html = highlight("1_000_000")
        #expect(html.contains("<font CLASS=integer>1_000_000</font>"))
    }

    @Test func underscoreFloatsAreHighlighted() {
        let html = highlight("1.123_456")
        #expect(html.contains("<font CLASS=floatpt>1.123_456</font>"))
    }

    // MARK: - Comprehensive Snippet

    @Test func comprehensiveSnippetHighlightsAllRules() {
        let source = """
        /* Block comment */
        // Line comment
        abstract class Example {
            async run(): Promise<void> {
                const x: number = 42;
                let pi: number = 3.14;
                let s: string = "hello";
                let c: string = 'world';
                let arr: Array<number> = [x + 1];
            }
        }
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=keyword>abstract</font>"))
        #expect(html.contains("<font CLASS=keyword>async</font>"))
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
