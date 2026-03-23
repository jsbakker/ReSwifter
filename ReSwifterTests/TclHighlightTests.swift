//
//  TclHighlightTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests that Tcl syntax highlighting rules produce correct output.
struct TclHighlightTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "tcl")
    }

    // MARK: Keywords

    @Test func keywordsAreHighlighted() {
        let html = highlight("after")
        #expect(html.contains("<font CLASS=keyword>after</font>"))
    }

    // MARK: Types

    @Test func typesAreHighlighted() {
        let html = highlight("binary")
        #expect(html.contains("<font CLASS=keytype>binary</font>"))
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

    /// Robustness: Tcl variables ($var, ${var}) don't use a closing $,
    /// but the engine must not infinite-loop on malformed input.
    @Test func dollarKeywordDollarDoesNotHang() {
        let html = highlight("$proc$ while")
        #expect(html.contains("<font CLASS=preproc>"))
        // Highlighting must continue past the malformed $proc$
        #expect(html.contains("<font CLASS=keyword>while</font>"))
    }

    // MARK: Comments


    @Test func inlineCommentsAreHighlighted() {
        let html = highlight("# comment")
        #expect(html.contains("<font CLASS=comment># comment</font>"))
    }

    // MARK: - Comprehensive Snippet

    @Test func comprehensiveSnippetHighlightsAllRules() {
        let source = """
        # Tcl comment
        set x 42
        set y 3.14
        set s "hello"
        set t 'world'
        set $var value
        puts $s
        if {$x > 0} {
            binary scan $s a5 result
        }
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=keyword>set</font>"))
        #expect(html.contains("<font CLASS=keytype>binary</font>"))
        #expect(html.contains("<font CLASS=integer>42</font>"))
        #expect(html.contains("<font CLASS=floatpt>3.14</font>"))
        #expect(html.contains("<font CLASS=dblquot>")) // double-quoted string highlighted
        #expect(html.contains("<font CLASS=sinquot>")) // single-quoted string highlighted
        #expect(html.contains("<font CLASS=comment># Tcl comment</font>"))
        #expect(html.contains("<font CLASS=preproc>")) // scalar variable highlighted
    }
}
