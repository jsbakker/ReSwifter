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

    @Test func backtickStringsAreHighlighted() {
        // PHP uses backtick for shell command execution
        let html = highlight("`ls -la`")
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

    // MARK: Variables

    @Test func scalarVariablesAreHighlighted() {
        let html = highlight("$variable")
        #expect(html.contains("<font CLASS=preproc>"))
    }

    /// Robustness: PHP variables ($var) don't use a closing $, but the
    /// engine must not infinite-loop on malformed input.
    @Test func dollarKeywordDollarDoesNotHang() {
        let html = highlight("$echo$ function")
        #expect(html.contains("<font CLASS=preproc>"))
        // Highlighting must continue past the malformed $echo$
        #expect(html.contains("<font CLASS=keyword>function</font>"))
    }

    // MARK: - Heredoc strings

    /// PHP heredoc (<<<TAG...TAG;) should highlight as a string.
    @Test func heredocStringIsHighlighted() {
        let source = "$text = <<<EOT\nhello world\nEOT;"
        let html = highlight(source)
        #expect(html.contains("<font CLASS=dblquot>"))
    }

    /// PHP heredoc with quoted marker (<<<'EOT'...EOT;).
    @Test func heredocQuotedMarkerIsHighlighted() {
        let source = "$text = <<<'EOT'\nraw text\nEOT;"
        let html = highlight(source)
        #expect(html.contains("<font CLASS=dblquot>"))
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
        # Hash comment
        <?php
        $arr = array();
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
