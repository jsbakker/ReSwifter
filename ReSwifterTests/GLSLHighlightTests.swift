//
//  GLSLHighlightTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests that GLSL syntax highlighting rules produce correct output.
struct GLSLHighlightTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "glsl")
    }

    // MARK: Keywords

    @Test func keywordsAreHighlighted() {
        let html = highlight("attribute")
        #expect(html.contains("<font CLASS=keyword>attribute</font>"))
    }

    // MARK: Types

    @Test func typesAreHighlighted() {
        let html = highlight("bool")
        #expect(html.contains("<font CLASS=keytype>bool</font>"))
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

    // MARK: - Comprehensive Snippet

    @Test func comprehensiveSnippetHighlightsAllRules() {
        let source = """
        /* Block comment */
        #version 330 core
        // Line comment
        uniform bool flag;
        attribute vec3 position;
        void main() {
            int x = 42;
            float y = 3.14;
            gl_Position = vec4(position, 1.0);
            x = x + 1;
        }
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=keyword>attribute</font>"))
        #expect(html.contains("<font CLASS=keytype>bool</font>"))
        #expect(html.contains("<font CLASS=integer>42</font>"))
        #expect(html.contains("<font CLASS=floatpt>3.14</font>"))
        // GLSL does not use string literals; doStrings is default-on but
        // the language simply never uses quoted strings in valid code.
        // Verify the engine does NOT produce dblquot tags for this shader snippet.
        #expect(!html.contains("<font CLASS=dblquot>"))
        #expect(html.contains("<font CLASS=symbols>+</font>"))
        #expect(html.contains("<font CLASS=preproc>#version</font>"))
        #expect(html.contains("<font CLASS=comment>/* Block comment */</font>"))
        #expect(html.contains("<font CLASS=comment>// Line comment</font>"))
    }
}
