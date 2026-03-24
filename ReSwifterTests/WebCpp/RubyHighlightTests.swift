//
//  RubyHighlightTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests that Ruby syntax highlighting rules produce correct output.
struct RubyHighlightTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "rb")
    }

    // MARK: Keywords

    @Test func keywordsAreHighlighted() {
        let html = highlight("BEGIN")
        #expect(html.contains("<font CLASS=keyword>BEGIN</font>"))
    }

    // MARK: Types

    @Test func typesAreHighlighted() {
        let html = highlight("Array")
        #expect(html.contains("<font CLASS=keytype>Array</font>"))
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

    /// Robustness: Ruby variables ($global, @instance, %w{}) don't use a
    /// closing sigil, but the engine must not infinite-loop on malformed
    /// input where a keyword appears between matching sigils.
    @Test func duplicateSigilsDoNotHang() {
        let html = highlight("%class% $if$ @end@ yield")
        #expect(html.contains("<font CLASS=preproc>"))
        // Highlighting must continue past the malformed sigils
        #expect(html.contains("<font CLASS=keyword>yield</font>"))
    }

    // MARK: - Multiline string delimiters

    /// Bug: %Q{...} strings containing #{interpolation} would end prematurely
    /// at the } inside the interpolation block, leaving the actual closing }
    /// unhighlighted. The fix tracks nested brace depth so interpolation
    /// braces are properly skipped.
    @Test func percentQBracesWithInterpolationHighlightsClosingBrace() {
        // %Q{...#{status}...} — the } inside #{status} must not end the string
        let source = "%Q{HTTP \\#{status} response}"
        let html = highlight(source)

        // The entire string including the closing } must be wrapped in dblquot
        #expect(html.contains("<font CLASS=dblquot>"))

        // The closing } should be inside the font tag, not left as plain text.
        // If the bug is present, the font tag closes before "response}".
        // Check that "response}" is inside the highlighted region.
        // The } at the end should NOT appear as unhighlighted plain text after </font>
        let afterLastClose = html.components(separatedBy: "</font>").last ?? ""
        #expect(!afterLastClose.contains("response}"),
                "Closing } should be inside the string highlight, not after it")
    }

    /// %q{} (lowercase) should also handle nested braces correctly.
    @Test func percentQLowercaseWithNestedBraces() {
        let source = "%q{a {nested} value}"
        let html = highlight(source)
        #expect(html.contains("<font CLASS=sinquot>"))
    }

    // MARK: - Heredoc strings

    /// Heredoc strings (<<TAG...TAG) should highlight the content as a string.
    @Test func heredocStringIsHighlighted() {
        let source = "text = <<HEREDOC\nhello world\nHEREDOC"
        let html = highlight(source)
        #expect(html.contains("<font CLASS=dblquot>"))
    }

    /// Heredoc with indented closing marker (<<~TAG).
    @Test func heredocIndentedMarkerIsHighlighted() {
        let source = "text = <<~END\n  hello\n  END"
        let html = highlight(source)
        #expect(html.contains("<font CLASS=dblquot>"))
    }

    /// Heredoc with dash (<<-TAG) for stripping leading whitespace from marker.
    @Test func heredocDashMarkerIsHighlighted() {
        let source = "text = <<-TAG\nhello\n  TAG"
        let html = highlight(source)
        #expect(html.contains("<font CLASS=dblquot>"))
    }

    /// Heredoc with quoted marker (<<'TAG') suppresses interpolation.
    @Test func heredocQuotedMarkerIsHighlighted() {
        let source = "x = <<'EOF'\nhello\nEOF"
        let html = highlight(source)
        #expect(html.contains("<font CLASS=dblquot>"))
    }

    // MARK: - Quote Combination Tests

    @Test func apostropheInsideDoubleQuoteIsNotSeparatelyHighlighted() {
        let html = highlight("\"it's fine\"")
        #expect(html.contains("<font CLASS=dblquot>"))
        #expect(!html.contains("<font CLASS=sinquot>"))
    }

    @Test func doubleQuoteInsideSingleQuoteIsNotSeparatelyHighlighted() {
        let html = highlight("'say \"hi\"'")
        #expect(html.contains("<font CLASS=sinquot>"))
        #expect(!html.contains("<font CLASS=dblquot>"))
    }

    @Test func singleQuoteInsideBacktickIsNotSeparatelyHighlighted() {
        let html = highlight("`it's fine`")
        #expect(html.contains("<font CLASS=preproc>"))
        #expect(!html.contains("<font CLASS=sinquot>"))
    }

    // MARK: - Comment edge cases

    /// A # inside a string literal should not start a comment.
    @Test func hashInsideStringIsNotComment() {
        let source = "x = \"has # inside\""
        let html = highlight(source)
        #expect(html.contains("<font CLASS=dblquot>"))
        // The # is inside the string, so no comment tag should appear
        #expect(!html.contains("<font CLASS=comment>"))
    }

    /// A # preceded by a backslash should not start a comment.
    @Test func escapedHashIsNotComment() {
        let source = "\\# not a comment"
        let html = highlight(source)
        #expect(!html.contains("<font CLASS=comment>"))
    }

    // MARK: - String Interpolation

    @Test func interpolationDoesNotBreakStringHighlighting() {
        // The non-interpolated parts of the string retain dblquot highlighting
        let html = highlight("\"Hello, #{name}!\"")
        #expect(html.contains("<font CLASS=dblquot>"))
    }

    @Test func integerInsideInterpolationIsHighlighted() {
        let html = highlight("\"Age: #{42}\"")
        #expect(html.contains("<font CLASS=dblquot>"))
        #expect(html.contains("<font CLASS=integer>42</font>"))
    }

    @Test func floatInsideInterpolationIsHighlighted() {
        let html = highlight("\"Pi: #{3.14}\"")
        #expect(html.contains("<font CLASS=floatpt>3.14</font>"))
    }

    @Test func symbolInsideInterpolationIsHighlighted() {
        let html = highlight("\"Sum: #{a + b}\"")
        #expect(html.contains("<font CLASS=symbols>+</font>"))
    }

    @Test func keywordInsideInterpolationIsHighlighted() {
        let html = highlight("\"Val: #{nil}\"")
        #expect(html.contains("<font CLASS=keyword>nil</font>"))
    }

    @Test func typeInsideInterpolationIsHighlighted() {
        let html = highlight("\"Size: #{Array.new.size}\"")
        #expect(html.contains("<font CLASS=keytype>Array</font>"))
    }

    @Test func multipleInterpolationBlocksAreHighlighted() {
        // Each interpolation block is independently highlighted
        let html = highlight("\"#{42} and #{3.14}\"")
        #expect(html.contains("<font CLASS=dblquot>"))
        #expect(html.contains("<font CLASS=integer>42</font>"))
        #expect(html.contains("<font CLASS=floatpt>3.14</font>"))
    }

    @Test func nestedBracesInsideInterpolationAreHandled() {
        // #{arr.select{|x| x > 0}.size} — inner {} must not prematurely end interpolation
        let html = highlight("\"#{arr.select{|x| x > 0}.size}\"")
        #expect(html.contains("<font CLASS=dblquot>"))
        #expect(html.contains("<font CLASS=integer>0</font>"))
    }

    @Test func escapedInterpolationIsNotProcessed() {
        // \#{ is escaped — the whole string should remain as one dblquot span
        let html = highlight("\"literal \\#{expr}\"")
        #expect(html.contains("<font CLASS=dblquot>"))
        // The 'expr' text is NOT highlighted as a keyword (it's inside the string)
        #expect(!html.contains("<font CLASS=keyword>expr</font>"))
    }

    @Test func singleQuotedStringDoesNotInterpolate() {
        // Single-quoted strings never interpolate in Ruby
        let html = highlight("'not #{interpolated}'")
        #expect(html.contains("<font CLASS=sinquot>"))
        // The content inside '...' is plain — no keyword or integer tag
        #expect(!html.contains("<font CLASS=integer>"))
    }

    @Test func integerInStringWithoutInterpolationIsNotHighlighted() {
        // A bare number inside a plain string is NOT highlighted as integer
        let html = highlight("\"count is 42\"")
        #expect(html.contains("<font CLASS=dblquot>"))
        #expect(!html.contains("<font CLASS=integer>42</font>"))
    }

    @Test func symbolInStringWithoutInterpolationIsNotHighlighted() {
        // A symbol inside a plain string is NOT highlighted separately
        let html = highlight("\"a + b\"")
        #expect(html.contains("<font CLASS=dblquot>"))
        #expect(!html.contains("<font CLASS=symbols>+</font>"))
    }

    @Test func interpolationWithTypecast() {
        // Integer() cast inside interpolation — keyword and integer highlighted
        let html = highlight("\"val: #{Integer(x) + 1}\"")
        #expect(html.contains("<font CLASS=keytype>Integer</font>"))
        #expect(html.contains("<font CLASS=integer>1</font>"))
    }

    @Test func multipleInterpolatedExpressionsOnOneLine() {
        // Two interpolation blocks on the same line; each can contain highlights
        let source = "greeting = \"Hello, #{name}! You have #{count + 2} messages.\""
        let html = highlight(source)
        #expect(html.contains("<font CLASS=dblquot>"))
        #expect(html.contains("<font CLASS=integer>2</font>"))
        #expect(html.contains("<font CLASS=symbols>+</font>"))
    }

    @Test func multilineStringInterpolationHighlightsContentOnContinuationLine() {
        // On a multi-line string continuation line, content inside #{...} is highlighted
        // but content outside (plain string body) is not.
        let source = "\"first line\n  value is #{42 + 1} here\""
        let html = highlight(source)
        #expect(html.contains("<font CLASS=dblquot>"))
        // Integer and symbol inside interpolation should be highlighted
        #expect(html.contains("<font CLASS=integer>42</font>"))
        #expect(html.contains("<font CLASS=symbols>+</font>"))
        #expect(html.contains("<font CLASS=integer>1</font>"))
        // 'here' after the interpolation is plain string body — no keyword highlight
        #expect(!html.contains("<font CLASS=keyword>here</font>"))
    }

    @Test func multilineStringBodyOutsideInterpolationIsNotHighlighted() {
        // Content on a continuation line that is plain string body (no interpolation)
        // should not be highlighted as keywords or numbers.
        let source = "\"first line\n  nil and 42 inside string\""
        let html = highlight(source)
        #expect(html.contains("<font CLASS=dblquot>"))
        // nil and 42 are inside a plain string body — must not be highlighted
        #expect(!html.contains("<font CLASS=keyword>nil</font>"))
        #expect(!html.contains("<font CLASS=integer>42</font>"))
    }

    // MARK: Comments


    @Test func inlineCommentsAreHighlighted() {
        let html = highlight("# comment")
        #expect(html.contains("<font CLASS=comment># comment</font>"))
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
        # Ruby comment
        class Example
            def run
                @instance = 42
                $global = 3.14
                %hash = {}
                s = "hello"
                t = 'world'
                arr = Array.new
                x = @instance + 1
            end
        end
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=keyword>class</font>"))
        #expect(html.contains("<font CLASS=keyword>def</font>"))
        #expect(html.contains("<font CLASS=keytype>Array</font>"))
        #expect(html.contains("<font CLASS=integer>42</font>"))
        #expect(html.contains("<font CLASS=floatpt>3.14</font>"))
        #expect(html.contains("<font CLASS=dblquot>")) // double-quoted string highlighted
        #expect(html.contains("<font CLASS=sinquot>")) // single-quoted string highlighted
        #expect(html.contains("<font CLASS=symbols>+</font>"))
        #expect(html.contains("<font CLASS=comment># Ruby comment</font>"))
        #expect(html.contains("<font CLASS=preproc>")) // instance/global variable highlighted
    }
}
