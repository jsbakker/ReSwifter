//
//  PythonHighlightTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests that Python syntax highlighting rules produce correct output.
struct PythonHighlightTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "py")
    }

    // MARK: Keywords

    @Test func keywordsAreHighlighted() {
        let html = highlight("@abstractmethod")
        #expect(html.contains("<font CLASS=keyword>@abstractmethod</font>"))
    }

    // MARK: Types

    @Test func typesAreHighlighted() {
        let html = highlight("Any")
        #expect(html.contains("<font CLASS=keytype>Any</font>"))
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

    @Test func backtickStringsAreNotHighlighted() {
        // Python does not use backtick strings
        let html = highlight("`hello`")
        #expect(!html.contains("<font CLASS=preproc>"))
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

    // MARK: Symbols

    @Test func symbolsAreHighlighted() {
        let html = highlight("x + y")
        #expect(html.contains("<font CLASS=symbols>+</font>"))
    }

    // MARK: Comments


    @Test func inlineCommentsAreHighlighted() {
        let html = highlight("# comment")
        #expect(html.contains("<font CLASS=comment># comment</font>"))
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
        # Python comment
        class Example:
            def run(self):
                x: int = 42
                y: float = 3.14
                s: str = "hello"
                t: str = 'world'
                flag: bool = True
                x = x + 1
                result: Any = None
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=keyword>class</font>"))
        #expect(html.contains("<font CLASS=keyword>def</font>"))
        #expect(html.contains("<font CLASS=keytype>Any</font>"))
        #expect(html.contains("<font CLASS=integer>42</font>"))
        #expect(html.contains("<font CLASS=floatpt>3.14</font>"))
        #expect(html.contains("<font CLASS=dblquot>")) // double-quoted string highlighted
        #expect(html.contains("<font CLASS=sinquot>")) // single-quoted string highlighted
        #expect(html.contains("<font CLASS=symbols>+</font>"))
        #expect(html.contains("<font CLASS=comment># Python comment</font>"))
    }
}
