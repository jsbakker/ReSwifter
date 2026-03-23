//
//  CSharpHighlightTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests that CSharp syntax highlighting rules produce correct output.
struct CSharpHighlightTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "cs")
    }

    // MARK: Keywords

    @Test func keywordsAreHighlighted() {
        let html = highlight("abstract")
        #expect(html.contains("<font CLASS=keyword>abstract</font>"))
    }

    // MARK: Types

    @Test func typesAreHighlighted() {
        let html = highlight("Action")
        #expect(html.contains("<font CLASS=keytype>Action</font>"))
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

    // MARK: Labels

    @Test func labelsAreHighlighted() {
        let html = highlight("label:")
        #expect(html.contains("<font CLASS=preproc>label:</font>"))
    }

    // MARK: - Comprehensive Snippet

    @Test func comprehensiveSnippetHighlightsAllRules() {
        let source = """
        /* Block comment */
        #region MyRegion
        // Line comment
        abstract class Example {
            Action callback;
            int x = 42;
            double pi = 3.14;
            void Run() {
                string s = "hello";
                char c = 'x';
                x = x + 1;
        label:
                Console.WriteLine(x);
            }
        }
        #endregion
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=keyword>abstract</font>"))
        #expect(html.contains("<font CLASS=keytype>Action</font>"))
        #expect(html.contains("<font CLASS=integer>42</font>"))
        #expect(html.contains("<font CLASS=floatpt>3.14</font>"))
        #expect(html.contains("<font CLASS=dblquot>")) // double-quoted string highlighted
        #expect(html.contains("<font CLASS=sinquot>")) // single-quoted char highlighted
        #expect(html.contains("<font CLASS=symbols>+</font>"))
        #expect(html.contains("<font CLASS=preproc>#region</font>"))
        #expect(html.contains("<font CLASS=comment>/* Block comment */</font>"))
        #expect(html.contains("<font CLASS=comment>// Line comment</font>"))
        #expect(html.contains("<font CLASS=preproc>label:</font>"))
    }
}
