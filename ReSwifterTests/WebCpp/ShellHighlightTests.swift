//
//  ShellHighlightTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests that Shell syntax highlighting rules produce correct output.
struct ShellHighlightTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "sh")
    }

    // MARK: Keywords

    @Test func keywordsAreHighlighted() {
        let html = highlight("break")
        #expect(html.contains("<font CLASS=keyword>break</font>"))
    }

    // MARK: Types

    @Test func typesAreHighlighted() {
        let html = highlight("apt")
        #expect(html.contains("<font CLASS=keytype>apt</font>"))
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

    // MARK: Variables

    @Test func scalarVariablesAreHighlighted() {
        let html = highlight("$variable")
        #expect(html.contains("<font CLASS=preproc>"))
    }

    /// Robustness: Shell variables ($VAR, ${VAR}) don't use a closing $,
    /// but the engine must not infinite-loop on malformed input.
    @Test func dollarKeywordDollarDoesNotHang() {
        let html = highlight("$if$ while")
        #expect(html.contains("<font CLASS=preproc>"))
        // Highlighting must continue past the malformed $if$
        #expect(html.contains("<font CLASS=keyword>while</font>"))
    }

    // MARK: - Backtick strings

    /// Backtick command substitution should be highlighted.
    @Test func backtickCommandSubstitutionIsHighlighted() {
        let source = "result=`echo hello`"
        let html = highlight(source)
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

    // MARK: - Heredoc strings

    /// Shell heredoc (<<TAG...TAG) should highlight as a string.
    @Test func heredocStringIsHighlighted() {
        let source = "cat <<EOF\nhello world\nEOF"
        let html = highlight(source)
        #expect(html.contains("<font CLASS=dblquot>"))
    }

    /// Heredoc with quoted marker (<<'EOF') prevents variable expansion.
    @Test func heredocQuotedMarkerIsHighlighted() {
        let source = "cat <<'DONE'\nraw $text\nDONE"
        let html = highlight(source)
        #expect(html.contains("<font CLASS=dblquot>"))
    }

    /// Heredoc marker after a # comment should not start a heredoc.
    @Test func heredocAfterCommentIsNotTriggered() {
        let source = "# use <<EOF for heredocs"
        let html = highlight(source)
        #expect(html.contains("<font CLASS=comment>"))
        #expect(!html.contains("<font CLASS=dblquot>"))
    }

    // MARK: Comments


    @Test func inlineCommentsAreHighlighted() {
        let html = highlight("# comment")
        #expect(html.contains("<font CLASS=comment># comment</font>"))
    }

    // MARK: - Comprehensive Snippet

    @Test func comprehensiveSnippetHighlightsAllRules() {
        let source = """
        #!/bin/bash
        # Shell comment
        x=42
        y=3.14
        s="hello"
        t='world'
        echo $x
        arr=(apt ar awk)
        if [ $x -gt 0 ]; then
            echo "positive"
        fi
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=keytype>echo</font>"))
        #expect(html.contains("<font CLASS=keytype>apt</font>"))
        #expect(html.contains("<font CLASS=integer>42</font>"))
        #expect(html.contains("<font CLASS=floatpt>3.14</font>"))
        #expect(html.contains("<font CLASS=dblquot>")) // double-quoted string highlighted
        #expect(html.contains("<font CLASS=sinquot>")) // single-quoted string highlighted
        #expect(html.contains("<font CLASS=comment># Shell comment</font>"))
        #expect(html.contains("<font CLASS=preproc>")) // scalar variable highlighted
    }
}
