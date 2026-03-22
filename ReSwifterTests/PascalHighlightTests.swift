//
//  PascalHighlightTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests that Pascal syntax highlighting rules produce correct output.
struct PascalHighlightTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "pas")
    }

    // MARK: Keywords

    @Test func keywordsAreHighlighted() {
        let html = highlight("absolute")
        #expect(html.contains("<font CLASS=keyword>absolute</font>"))
    }

    // MARK: Types

    @Test func typesAreHighlighted() {
        let html = highlight("AnsiChar")
        #expect(html.contains("<font CLASS=keytype>AnsiChar</font>"))
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

    @Test func hashVariablesAreHighlighted() {
        let html = highlight("%variable")
        #expect(html.contains("<font CLASS=preproc>"))
    }

    // MARK: Comments

    @Test func blockCommentsAreHighlighted() {
        let html = highlight("(* a comment *)")
        #expect(html.contains("<font CLASS=comment>(* a comment *)</font>"))
    }

    @Test func inlineCommentsAreHighlighted() {
        let html = highlight("// comment")
        #expect(html.contains("<font CLASS=comment>// comment</font>"))
    }

    // MARK: - Comprehensive Snippet

    @Test func comprehensiveSnippetHighlightsAllRules() {
        let source = """
        (* Block comment *)
        // Line comment
        program Hello;
        var
            x : Integer;
            y : Real;
            s : AnsiString;
            c : AnsiChar;
        begin
            x := 42;
            y := 3.14;
            s := "hello";
            c := 'x';
        end.
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=keyword>program</font>"))
        #expect(html.contains("<font CLASS=keytype>AnsiString</font>"))
        #expect(html.contains("<font CLASS=integer>42</font>"))
        #expect(html.contains("<font CLASS=floatpt>3.14</font>"))
        #expect(html.contains("<font CLASS=dblquot>")) // double-quoted string highlighted
        #expect(html.contains("<font CLASS=sinquot>")) // single-quoted string highlighted
        #expect(html.contains("<font CLASS=comment>(* Block comment *)</font>"))
        #expect(html.contains("<font CLASS=comment>// Line comment</font>"))
    }
}
