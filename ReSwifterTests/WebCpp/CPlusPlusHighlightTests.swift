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
