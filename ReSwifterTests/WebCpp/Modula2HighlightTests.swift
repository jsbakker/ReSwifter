//
//  Modula2HighlightTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests that Modula2 syntax highlighting rules produce correct output.
struct Modula2HighlightTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "mod")
    }

    // MARK: Keywords

    @Test func keywordsAreHighlighted() {
        let html = highlight("ABSTRACT")
        #expect(html.contains("<font CLASS=keyword>ABSTRACT</font>"))
    }

    // MARK: Types

    @Test func typesAreHighlighted() {
        let html = highlight("ACHAR")
        #expect(html.contains("<font CLASS=keytype>ACHAR</font>"))
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

    // MARK: Comments

    @Test func blockCommentsAreHighlighted() {
        let html = highlight("(* a comment *)")
        #expect(html.contains("<font CLASS=comment>(* a comment *)</font>"))
    }

    // MARK: - Underscore Numbers

    @Test func underscoreNumbersAreNotFullyHighlighted() {
        let html = highlight("1_000")
        #expect(!html.contains("<font CLASS=integer>1_000</font>"))
    }

    // MARK: - Comprehensive Snippet

    @Test func comprehensiveSnippetHighlightsAllRules() {
        let source = """
        (* Block comment *)
        MODULE Hello;
        FROM InOut IMPORT WriteString;
        VAR
            x : INTEGER;
            y : REAL;
            s : ARRAY [0..10] OF CHAR;
        BEGIN
            x := 42;
            y := 3.14;
            s := "hello";
            WriteString('world');
        END Hello.
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=keyword>MODULE</font>"))
        #expect(html.contains("<font CLASS=keytype>INTEGER</font>"))
        #expect(html.contains("<font CLASS=integer>42</font>"))
        #expect(html.contains("<font CLASS=floatpt>3.14</font>"))
        #expect(html.contains("<font CLASS=dblquot>")) // double-quoted string highlighted
        #expect(html.contains("<font CLASS=sinquot>")) // single-quoted string highlighted
        #expect(html.contains("<font CLASS=comment>(* Block comment *)</font>"))
    }
}
