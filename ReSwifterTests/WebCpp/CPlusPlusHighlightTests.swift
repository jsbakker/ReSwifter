//
//  CPlusPlusHighlightTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests that CPlusPlus syntax highlighting rules produce correct output.
struct CPlusPlusHighlightTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "cpp")
    }

    // MARK: Keywords

    @Test func keywordsAreHighlighted() {
        let html = highlight("alignas")
        #expect(html.contains("<font CLASS=keyword>alignas</font>"))
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

    // MARK: Raw Strings

    @Test func rawStringsAreHighlighted() {
        let html = highlight("R\"(raw string)\"")
        #expect(html.contains("<font CLASS=dblquot>"))
    }

    // MARK: Labels

    @Test func labelsAreHighlighted() {
        let html = highlight("label:")
        #expect(html.contains("<font CLASS=preproc>label:</font>"))
    }

    // MARK: - String escape edge cases

    /// Escaped quote inside a string should not terminate the string.
    @Test func escapedQuoteInStringDoesNotTerminate() {
        let source = "\"hello \\\"world\\\" end\" + x"
        let html = highlight(source)
        // The entire string including escaped quotes should be one token
        #expect(html.contains("<font CLASS=dblquot>"))
        // x after the closing quote should not be inside the string
        #expect(html.contains("</font> <font CLASS=symbols>+</font>"))
    }

    /// Backtick-quoted strings should be highlighted (used in shell-embedded contexts).
    @Test func backtickStringsAreHighlighted() {
        let source = "`command`"
        let html = highlight(source)
        // Backtick strings get preproc class
        #expect(html.contains("<font CLASS=preproc>"))
    }

    /// A comment delimiter inside a string should not start a comment.
    @Test func commentDelimiterInsideStringIsIgnored() {
        let source = "\"has // inside\""
        let html = highlight(source)
        // The entire thing should be a string, no comment tag
        #expect(html.contains("<font CLASS=dblquot>"))
        #expect(!html.contains("<font CLASS=comment>"))
    }

    // MARK: - Tab handling (pre_parse)

    /// With tab expansion enabled (-t), tabs in source code should be
    /// converted to spaces without breaking syntax highlighting.
    @Test func tabExpansionDoesNotBreakHighlighting() {
        let source = "\tint\tx\t=\t42;"
        let html = HighlightTestHelper.highlight(source, language: "cpp", options: ["-t"])
        #expect(html.contains("<font CLASS=keytype>int</font>"))
        #expect(html.contains("<font CLASS=integer>42</font>"))
        // Verify tabs were converted inside the <pre> block
        if let preRange = html.range(of: "<pre>"),
           let endRange = html.range(of: "</pre>") {
            let content = String(html[preRange.upperBound..<endRange.lowerBound])
            #expect(!content.contains("\t"), "Tabs should be converted to spaces")
        }
    }

    /// Tab expansion with non-aligned positions should produce correct
    /// spacing (tabstops at multiples of the tab width).
    @Test func tabExpansionAlignsTabs() {
        let source = "a\tb"
        let html = HighlightTestHelper.highlight(source, language: "cpp", options: ["-t"])
        // After tab expansion, there should be spaces between a and b
        if let preRange = html.range(of: "<pre>"),
           let endRange = html.range(of: "</pre>") {
            let content = String(html[preRange.upperBound..<endRange.lowerBound])
            #expect(content.contains("a "), "Tab should be expanded to spaces")
            #expect(!content.contains("\t"))
        }
    }

    // MARK: - Block comment regression

    /// Bug: when two block comments appear on the same line (e.g. commenting
    /// out unused parameter names in a lambda), keywords between them were not
    /// highlighted. The parity-based isInsideIt() counted /* and */ that were
    /// already wrapped in <font> tags, producing incorrect results.
    @Test func keywordBetweenTwoBlockCommentsIsHighlighted() {
        let source = "int /* unused int */, int /* unused */, int c"
        let html = highlight(source)

        // All three "int" keywords must be highlighted
        let intCount = html.components(separatedBy: "<font CLASS=keytype>int</font>").count - 1
        #expect(intCount == 3, "Expected 3 highlighted 'int' keywords, got \(intCount)")

        // Both block comments must be highlighted
        #expect(html.contains("<font CLASS=comment>/* unused int */</font>"))
        #expect(html.contains("<font CLASS=comment>/* unused */</font>"))
    }

    /// Ensure a single block comment still works correctly after the fix.
    @Test func singleBlockCommentDoesNotBreakKeywords() {
        let source = "int /* comment */ x = 42;"
        let html = highlight(source)
        #expect(html.contains("<font CLASS=keytype>int</font>"))
        #expect(html.contains("<font CLASS=comment>/* comment */</font>"))
        #expect(html.contains("<font CLASS=integer>42</font>"))
    }

    // MARK: - Comprehensive Snippet

    @Test func comprehensiveSnippetHighlightsAllRules() {
        let source = """
        /* Block comment */
        #include <iostream>
        // Line comment
        class Example {
        public:
            bool flag = true;
            int x = 42;
            double pi = 3.14;
            void run() {
                auto s = "hello";
                char c = 'x';
                auto raw = R"(raw string)";
                x = x + 1;
        label:
                std::cout << x;
            }
        };
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=keyword>class</font>"))
        #expect(html.contains("<font CLASS=keytype>bool</font>"))
        #expect(html.contains("<font CLASS=integer>42</font>"))
        #expect(html.contains("<font CLASS=floatpt>3.14</font>"))
        #expect(html.contains("<font CLASS=dblquot>")) // double-quoted string highlighted
        #expect(html.contains("<font CLASS=sinquot>")) // single-quoted char highlighted
        #expect(html.contains("<font CLASS=symbols>+</font>"))
        #expect(html.contains("<font CLASS=preproc>#include</font>"))
        #expect(html.contains("<font CLASS=comment>/* Block comment */</font>"))
        #expect(html.contains("<font CLASS=comment>// Line comment</font>"))
        #expect(html.contains("<font CLASS=preproc>label:</font>"))
    }
}
