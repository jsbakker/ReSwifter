//
//  EmfHighlightTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests that Emf syntax highlighting rules produce correct output.
struct EmfHighlightTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "emf")
    }

    // MARK: Keywords

    @Test func keywordsAreHighlighted() {
        let html = highlight("!abort")
        #expect(html.contains("<font CLASS=keyword>!abort</font>"))
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

    @Test func arrayVariablesAreHighlighted() {
        let html = highlight("@array")
        #expect(html.contains("<font CLASS=preproc>"))
    }

    @Test func hashVariablesAreHighlighted() {
        let html = highlight("%hash")
        #expect(html.contains("<font CLASS=preproc>"))
    }

    // MARK: Comments


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
        ; Emf comment
        !force
        $scalar = "hello"
        @array = 'world'
        %hash
        label1:
            !bell
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=keyword>"))
        #expect(html.contains("<font CLASS=dblquot>")) // double-quoted string highlighted
        #expect(html.contains("<font CLASS=sinquot>")) // single-quoted string highlighted
        #expect(html.contains("<font CLASS=comment>; Emf comment</font>"))
        #expect(html.contains("<font CLASS=preproc>")) // scalar/array/hash variable highlighted
        #expect(html.contains("<font CLASS=preproc>label1:</font>"))
    }
}
