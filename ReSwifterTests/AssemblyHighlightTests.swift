//
//  AssemblyHighlightTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests that Assembly syntax highlighting rules produce correct output.
struct AssemblyHighlightTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "asm")
    }

    // MARK: Keywords

    @Test func keywordsAreHighlighted() {
        let html = highlight(".abort")
        #expect(html.contains("<font CLASS=keyword>.abort</font>"))
    }

    // MARK: Types

    @Test func typesAreHighlighted() {
        let html = highlight("ah")
        #expect(html.contains("<font CLASS=keytype>ah</font>"))
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
        let html = highlight("; comment")
        #expect(html.contains("<font CLASS=comment>; comment</font>"))
    }

    // MARK: Labels

    @Test func labelsAreHighlighted() {
        let html = highlight("label:")
        #expect(html.contains("<font CLASS=preproc>label:</font>"))
    }

    // MARK: - Comprehensive Snippet

    @Test func comprehensiveSnippetHighlightsAllRules() {
        let source = """
        ; Assembly comment
        .section .text
        .global _start
        _start:
            mov eax, 42
            add eax, 3
            int 0x80
        /* block comment */
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=keyword>mov</font>"))
        #expect(html.contains("<font CLASS=keyword>add</font>"))
        #expect(html.contains("<font CLASS=keytype>eax</font>"))
        #expect(html.contains("<font CLASS=integer>42</font>"))
        #expect(html.contains("<font CLASS=comment>; Assembly comment</font>"))
        #expect(html.contains("<font CLASS=comment>/* block comment */</font>"))
        #expect(html.contains("<font CLASS=keyword>.section</font>"))
        #expect(html.contains("<font CLASS=preproc>_start:</font>"))
    }
}
