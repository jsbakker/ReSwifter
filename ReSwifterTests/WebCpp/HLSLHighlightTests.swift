//
//  HLSLHighlightTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests that HLSL syntax highlighting rules produce correct output.
struct HLSLHighlightTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "hlsl")
    }

    // MARK: Keywords

    @Test func keywordsAreHighlighted() {
        let html = highlight("break")
        #expect(html.contains("<font CLASS=keyword>break</font>"))
    }

    // MARK: Types

    @Test func typesAreHighlighted() {
        let html = highlight("AppendStructuredBuffer")
        #expect(html.contains("<font CLASS=keytype>AppendStructuredBuffer</font>"))
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

    @Test func singleQuotedStringsAreNotHighlighted() {
        let html = highlight("'hello'")
        #expect(!html.contains("<font CLASS=sinquot>"))
    }

    @Test func backtickStringsAreNotHighlighted() {
        let html = highlight("`hello`")
        #expect(!html.contains("<font CLASS=preproc>"))
    }

    @Test func apostropheInsideDoubleQuoteIsNotSeparatelyHighlighted() {
        let html = highlight("\"it's fine\"")
        #expect(html.contains("<font CLASS=dblquot>"))
        #expect(!html.contains("<font CLASS=sinquot>"))
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
        #include "common.hlsli"
        // Line comment
        cbuffer Constants : register(b0) {
            float4x4 worldMatrix;
            bool flag;
            int x = 42;
            float y = 3.14;
            Buffer buf;
        }
        float4 main() : SV_Target {
            return x + 1;
        }
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=keyword>cbuffer</font>"))
        #expect(html.contains("<font CLASS=keytype>Buffer</font>"))
        #expect(html.contains("<font CLASS=keytype>bool</font>"))
        #expect(html.contains("<font CLASS=integer>42</font>"))
        #expect(html.contains("<font CLASS=floatpt>3.14</font>"))
        #expect(html.contains("<font CLASS=dblquot>")) // double-quoted string highlighted
        #expect(!html.contains("<font CLASS=sinquot>")) // single quotes not supported in HLSL
        #expect(html.contains("<font CLASS=symbols>+</font>"))
        #expect(html.contains("<font CLASS=preproc>#include</font>"))
        #expect(html.contains("<font CLASS=comment>/* Block comment */</font>"))
        #expect(html.contains("<font CLASS=comment>// Line comment</font>"))
    }
}
