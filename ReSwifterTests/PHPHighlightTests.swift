//
//  PHPHighlightTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests that PHP syntax highlighting rules produce correct output.
struct PHPHighlightTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "php")
    }

    // MARK: Keywords

    @Test func keywordsAreHighlighted() {
        let html = highlight("abstract")
        #expect(html.contains("<font CLASS=keyword>abstract</font>"))
    }

    // MARK: Types

    @Test func typesAreHighlighted() {
        let html = highlight("array")
        #expect(html.contains("<font CLASS=keytype>array</font>"))
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

    // MARK: Variables

    @Test func scalarVariablesAreHighlighted() {
        let html = highlight("$variable")
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

    // MARK: - Comprehensive Snippet

    @Test func comprehensiveSnippetHighlightsAllRules() {
        let source = """
        /* Block comment */
        // Line comment
        # Hash comment
        <?php
        abstract class Example {
            public $name;
            function run() {
                $x = 42;
                $y = 3.14;
                $s = "hello";
                $t = 'world';
                $x = $x + 1;
            }
        }
        ?>
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=keyword>abstract</font>"))
        #expect(html.contains("<font CLASS=keytype>array</font>"))
        #expect(html.contains("<font CLASS=integer>42</font>"))
        #expect(html.contains("<font CLASS=floatpt>3.14</font>"))
        #expect(html.contains("<font CLASS=dblquot>")) // double-quoted string highlighted
        #expect(html.contains("<font CLASS=sinquot>")) // single-quoted string highlighted
        #expect(html.contains("<font CLASS=symbols>+</font>"))
        #expect(html.contains("<font CLASS=comment>/* Block comment */</font>"))
        #expect(html.contains("<font CLASS=comment>// Line comment</font>"))
        #expect(html.contains("<font CLASS=comment># Hash comment</font>"))
        #expect(html.contains("<font CLASS=preproc>")) // scalar variable highlighted
    }
}
