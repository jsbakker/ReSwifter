//
//  SwiftHighlightTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests that Swift syntax highlighting rules produce correct output.
struct SwiftHighlightTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "swift")
    }

    // MARK: Keywords

    @Test func keywordsAreHighlighted() {
        let html = highlight("@AppStorage")
        #expect(html.contains("<font CLASS=keyword>@AppStorage</font>"))
    }

    // MARK: Types

    @Test func typesAreHighlighted() {
        let html = highlight("Any")
        #expect(html.contains("<font CLASS=keytype>Any</font>"))
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

    // MARK: Symbols

    @Test func symbolsAreHighlighted() {
        let html = highlight("x + y")
        #expect(html.contains("<font CLASS=symbols>+</font>"))
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

    // MARK: Triple-quoted Strings

    @Test func tripleQuotedStringsAreHighlighted() {
        let source = """
        \"\"\"
        content
        \"\"\"
        """
        let html = highlight(source)
        #expect(html.contains("<font CLASS=dblquot>"))
    }

    // MARK: - String Interpolation

    @Test func interpolationDoesNotBreakStringHighlighting() {
        let html = highlight("\"Hello, \\(name)!\"")
        #expect(html.contains("<font CLASS=dblquot>"))
    }

    @Test func integerInsideInterpolationIsHighlighted() {
        let html = highlight("\"Value: \\(42)\"")
        #expect(html.contains("<font CLASS=dblquot>"))
        #expect(html.contains("<font CLASS=integer>42</font>"))
    }

    @Test func symbolInsideInterpolationIsHighlighted() {
        let html = highlight("\"Sum: \\(a + b)\"")
        #expect(html.contains("<font CLASS=symbols>+</font>"))
    }

    @Test func keywordInsideInterpolationIsHighlighted() {
        let html = highlight("\"Val: \\(nil)\"")
        #expect(html.contains("<font CLASS=keyword>nil</font>"))
    }

    @Test func typeInsideInterpolationIsHighlighted() {
        let html = highlight("\"Cast: \\(Int(x))\"")
        #expect(html.contains("<font CLASS=keytype>Int</font>"))
    }

    @Test func integerInStringWithoutInterpolationIsNotHighlighted() {
        let html = highlight("\"count is 42\"")
        #expect(html.contains("<font CLASS=dblquot>"))
        #expect(!html.contains("<font CLASS=integer>42</font>"))
    }

    @Test func multilineTripleQuotedStringInterpolation() {
        let source = "\"\"\"\\nvalue is \\(42 + 1)\\n\"\"\""
        let html = highlight(source)
        #expect(html.contains("<font CLASS=dblquot>"))
        #expect(html.contains("<font CLASS=integer>42</font>"))
        #expect(html.contains("<font CLASS=symbols>+</font>"))
    }

    // MARK: - Underscore Numbers

    @Test func underscoreIntegersAreHighlighted() {
        let html = highlight("1_000_000")
        #expect(html.contains("<font CLASS=integer>1_000_000</font>"))
    }

    @Test func underscoreFloatsAreHighlighted() {
        let html = highlight("1.123_456")
        #expect(html.contains("<font CLASS=floatpt>1.123_456</font>"))
    }

    // MARK: - Comprehensive Snippet

    @Test func comprehensiveSnippetHighlightsAllRules() {
        let source = """
        /* Block comment */
        // Line comment
        actor MyActor {
            var x: Int = 42
            var pi: Double = 3.14
            func run() async {
                let s: String = "hello"
                let c: Character = "x"
                let flag: Any = true
                x = x + 1
            }
        }
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=keyword>actor</font>"))
        #expect(html.contains("<font CLASS=keyword>async</font>"))
        #expect(html.contains("<font CLASS=keytype>Any</font>"))
        #expect(html.contains("<font CLASS=integer>42</font>"))
        #expect(html.contains("<font CLASS=floatpt>3.14</font>"))
        #expect(html.contains("<font CLASS=dblquot>")) // double-quoted string highlighted
        #expect(html.contains("<font CLASS=symbols>+</font>"))
        #expect(html.contains("<font CLASS=comment>/* Block comment */</font>"))
        #expect(html.contains("<font CLASS=comment>// Line comment</font>"))
    }
}
