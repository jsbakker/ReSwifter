//
//  CPlusPlusMultilineStringTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests for C++ raw string literal highlighting (R"(...)").
struct CPlusPlusMultilineStringTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "cpp")
    }

    // MARK: Code before raw string delimiter is highlighted

    @Test func typeBeforeRawStringIsHighlighted() {
        let source = """
        int x; const char *s = R"(
        content
        )";
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=keytype>int</font>"))
    }

    @Test func keywordBeforeRawStringIsHighlighted() {
        let source = """
        const char *s = R"(
        content
        )";
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=keyword>const</font>"))
    }

    // MARK: Content inside raw string is not highlighted

    @Test func keywordsInsideRawStringAreNotHighlighted() {
        let source = """
        auto x = R"(
        if else for while return
        )";
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=keyword>if</font>"))
        #expect(!html.contains("<font CLASS=keyword>for</font>"))
    }

    @Test func numbersInsideRawStringAreNotHighlighted() {
        let source = """
        auto x = R"(
        42 3.14
        )";
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=integer>42</font>"))
        #expect(!html.contains("<font CLASS=floatpt>3.14</font>"))
    }

    // MARK: Raw string opens and closes correctly

    @Test func rawStringProducesOpenAndCloseTag() {
        let source = """
        auto x = R"(
        content
        )";
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=dblquot>"))
        #expect(html.contains("</font>"))
    }
}
