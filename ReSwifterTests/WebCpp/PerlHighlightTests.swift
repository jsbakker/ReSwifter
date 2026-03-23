//
//  PerlHighlightTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests that Perl syntax highlighting rules produce correct output.
struct PerlHighlightTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "pl")
    }

    // MARK: Keywords

    @Test func keywordsAreHighlighted() {
        let html = highlight("and")
        #expect(html.contains("<font CLASS=keyword>and</font>"))
    }

    // MARK: Types

    @Test func typesAreHighlighted() {
        let html = highlight("binmode")
        #expect(html.contains("<font CLASS=keytype>binmode</font>"))
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

    @Test func backtickStringsAreHighlighted() {
        // Perl uses backtick for shell command execution
        let html = highlight("`ls -la`")
        #expect(html.contains("<font CLASS=preproc>"))
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

    /// Robustness: Perl variables ($scalar, @array, %hash) don't use a
    /// closing sigil, but the engine must not infinite-loop on malformed
    /// input where a keyword appears between matching sigils.
    @Test func duplicateSigilsDoNotHang() {
        let html = highlight("%for% $die$ @keys@ bless")
        #expect(html.contains("<font CLASS=preproc>"))
        // Highlighting must continue past the malformed sigils
        #expect(html.contains("<font CLASS=keyword>bless</font>"))
    }

    // MARK: - Heredoc strings

    /// Perl heredoc (<<TAG...TAG) should highlight as a string.
    @Test func heredocStringIsHighlighted() {
        let source = "my $text = <<HEREDOC;\nhello world\nHEREDOC"
        let html = highlight(source)
        #expect(html.contains("<font CLASS=dblquot>"))
    }

    /// Heredoc with quoted marker (<<'EOF') suppresses interpolation.
    @Test func heredocQuotedMarkerIsHighlighted() {
        let source = "my $t = <<'EOF';\nraw text\nEOF"
        let html = highlight(source)
        #expect(html.contains("<font CLASS=dblquot>"))
    }

    /// Heredoc should not start inside a string literal.
    @Test func heredocInsideStringIsNotTriggered() {
        let source = "my $s = \"use <<EOF for heredocs\";"
        let html = highlight(source)
        // The entire thing should be a double-quoted string, not a heredoc
        #expect(html.contains("<font CLASS=dblquot>"))
    }

    // MARK: Comments


    @Test func inlineCommentsAreHighlighted() {
        let html = highlight("# comment")
        #expect(html.contains("<font CLASS=comment># comment</font>"))
    }

    // MARK: Labels

    @Test func labelsAreHighlighted() {
        let html = highlight("label:")
        #expect(html.contains("<font CLASS=preproc>label:</font>"))
    }

    // MARK: - Comprehensive Snippet

    @Test func comprehensiveSnippetHighlightsAllRules() {
        let source = """
        # Perl comment
        use strict;
        my $scalar = 42;
        my @array = (3.14, "hello");
        my %hash = ('key' => 'value');
        binmode STDOUT;
        sub example {
            bless {}, 'Example';
            $scalar = $scalar + 1;
        label:
            print $scalar;
        }
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=keyword>bless</font>"))
        #expect(html.contains("<font CLASS=keytype>binmode</font>"))
        #expect(html.contains("<font CLASS=integer>42</font>"))
        #expect(html.contains("<font CLASS=floatpt>3.14</font>"))
        #expect(html.contains("<font CLASS=dblquot>")) // double-quoted string highlighted
        #expect(html.contains("<font CLASS=sinquot>")) // single-quoted string highlighted
        #expect(html.contains("<font CLASS=symbols>+</font>"))
        #expect(html.contains("<font CLASS=comment># Perl comment</font>"))
        #expect(html.contains("<font CLASS=preproc>")) // scalar variable highlighted
        #expect(html.contains("<font CLASS=preproc>label:</font>"))
    }
}
