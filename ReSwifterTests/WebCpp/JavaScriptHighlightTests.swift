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
