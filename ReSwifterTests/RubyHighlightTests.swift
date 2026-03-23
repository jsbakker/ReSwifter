//
//  RubyHighlightTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests that Ruby syntax highlighting rules produce correct output.
struct RubyHighlightTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "rb")
    }

    // MARK: Keywords

    @Test func keywordsAreHighlighted() {
        let html = highlight("BEGIN")
        #expect(html.contains("<font CLASS=keyword>BEGIN</font>"))
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

    // MARK: Variables

    @Test func scalarVariablesAreHighlighted() {
        let html = highlight("$variable")
        #expect(html.contains("<font CLASS=preproc>"))
    }

    @Test func arrayVariablesAreHighlighted() {
        let html = highlight("@array")
        #expect(html.contains("<font CLASS=preproc>"))
    }

    @Test func hashVariablesAreHighlighted() {
        let html = highlight("%hash")
        #expect(html.contains("<font CLASS=preproc>"))
    }

    /// Robustness: Ruby variables ($global, @instance, %w{}) don't use a
    /// closing sigil, but the engine must not infinite-loop on malformed
    /// input where a keyword appears between matching sigils.
    @Test func duplicateSigilsDoNotHang() {
        let html = highlight("%class% $if$ @end@ yield")
        #expect(html.contains("<font CLASS=preproc>"))
        // Highlighting must continue past the malformed sigils
        #expect(html.contains("<font CLASS=keyword>yield</font>"))
    }

    // MARK: Comments


    @Test func inlineCommentsAreHighlighted() {
        let html = highlight("# comment")
        #expect(html.contains("<font CLASS=comment># comment</font>"))
    }

    // MARK: - Comprehensive Snippet

    @Test func comprehensiveSnippetHighlightsAllRules() {
        let source = """
        # Ruby comment
        class Example
            def run
                @instance = 42
                $global = 3.14
                %hash = {}
                s = "hello"
                t = 'world'
                arr = Array.new
                x = @instance + 1
            end
        end
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=keyword>class</font>"))
        #expect(html.contains("<font CLASS=keyword>def</font>"))
        #expect(html.contains("<font CLASS=keytype>Array</font>"))
        #expect(html.contains("<font CLASS=integer>42</font>"))
        #expect(html.contains("<font CLASS=floatpt>3.14</font>"))
        #expect(html.contains("<font CLASS=dblquot>")) // double-quoted string highlighted
        #expect(html.contains("<font CLASS=sinquot>")) // single-quoted string highlighted
        #expect(html.contains("<font CLASS=symbols>+</font>"))
        #expect(html.contains("<font CLASS=comment># Ruby comment</font>"))
        #expect(html.contains("<font CLASS=preproc>")) // instance/global variable highlighted
    }
}
