//
//  ValaHighlightTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests that Vala syntax highlighting rules produce correct output.
struct ValaHighlightTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "vala")
    }

    // MARK: Keywords

    @Test func keywordsAreHighlighted() {
        let html = highlight("abstract")
        #expect(html.contains("<font CLASS=keyword>abstract</font>"))
    }

    // MARK: Types

    @Test func typesAreHighlighted() {
        let html = highlight("bool")
        #expect(html.contains("<font CLASS=keytype>bool</font>"))
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

    // MARK: Preprocessor

    @Test func preprocessorDirectivesAreHighlighted() {
        let html = highlight("#define FOO")
        #expect(html.contains("<font CLASS=preproc>"))
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

    // MARK: Triple-quoted Strings

    @Test func tripleQuotedStringsAreHighlighted() {
        let source = """
        \"\"\"
        content
        \"\"\"
        """
        let html = highlight(source)
        #expect(html.contains("<font CLASS=dblquot>"))
    }

    // MARK: - Comprehensive Snippet

    @Test func comprehensiveSnippetHighlightsAllRules() {
        let source = """
        /* Block comment */
        #if HAVE_FEATURE
        // Line comment
        abstract class Example : Object {
            bool flag;
            int x = 42;
            double pi = 3.14;
            async void run() {
                string s = "hello";
                char c = 'x';
                x = x + 1;
            }
        }
        #endif
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=keyword>abstract</font>"))
        #expect(html.contains("<font CLASS=keyword>async</font>"))
        #expect(html.contains("<font CLASS=keytype>bool</font>"))
        #expect(html.contains("<font CLASS=integer>42</font>"))
        #expect(html.contains("<font CLASS=floatpt>3.14</font>"))
        #expect(html.contains("<font CLASS=dblquot>")) // double-quoted string highlighted
        #expect(html.contains("<font CLASS=sinquot>")) // single-quoted char highlighted
        #expect(html.contains("<font CLASS=symbols>+</font>"))
        #expect(html.contains("<font CLASS=preproc>#if</font>"))
        #expect(html.contains("<font CLASS=comment>/* Block comment */</font>"))
        #expect(html.contains("<font CLASS=comment>// Line comment</font>"))
    }
}
