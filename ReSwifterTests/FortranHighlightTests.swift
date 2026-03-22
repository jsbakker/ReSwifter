//
//  FortranHighlightTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests that Fortran syntax highlighting rules produce correct output.
struct FortranHighlightTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "f90")
    }

    // MARK: Keywords

    @Test func keywordsAreHighlighted() {
        let html = highlight("ABSTRACT")
        #expect(html.contains("<font CLASS=keyword>ABSTRACT</font>"))
    }

    // MARK: Types

    @Test func typesAreHighlighted() {
        let html = highlight("BYTE")
        #expect(html.contains("<font CLASS=keytype>BYTE</font>"))
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

    // MARK: - Comprehensive Snippet

    @Test func comprehensiveSnippetHighlightsAllRules() {
        let source = """
        ! Fortran comment
        /* Block comment */
        PROGRAM Hello
            INTEGER :: x = 42
            REAL :: y = 3.14
            CHARACTER(len=5) :: s = "world"
            BYTE :: b
            IF (x > 0) THEN
                PRINT *, 'Hello'
            END IF
        END PROGRAM
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=keyword>PROGRAM</font>"))
        #expect(html.contains("<font CLASS=keytype>BYTE</font>"))
        #expect(html.contains("<font CLASS=integer>42</font>"))
        #expect(html.contains("<font CLASS=floatpt>3.14</font>"))
        #expect(html.contains("<font CLASS=dblquot>")) // double-quoted string highlighted
        #expect(html.contains("<font CLASS=sinquot>")) // single-quoted string highlighted
        #expect(html.contains("<font CLASS=comment>/* Block comment */</font>"))
        #expect(html.contains("<font CLASS=comment>! Fortran comment</font>"))
    }
}
