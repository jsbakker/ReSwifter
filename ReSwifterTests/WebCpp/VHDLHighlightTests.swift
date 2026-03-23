//
//  VHDLHighlightTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests that VHDL syntax highlighting rules produce correct output.
struct VHDLHighlightTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "vhd")
    }

    // MARK: Keywords

    @Test func keywordsAreHighlighted() {
        let html = highlight("ABS")
        #expect(html.contains("<font CLASS=keyword>ABS</font>"))
    }

    // MARK: Types

    @Test func typesAreHighlighted() {
        let html = highlight("BIT")
        #expect(html.contains("<font CLASS=keytype>BIT</font>"))
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

    // MARK: Symbols

    @Test func symbolsAreHighlighted() {
        let html = highlight("x + y")
        #expect(html.contains("<font CLASS=symbols>+</font>"))
    }

    // MARK: Comments


    @Test func inlineCommentsAreHighlighted() {
        let html = highlight("-- comment")
        #expect(html.contains("<font CLASS=comment>-- comment</font>"))
    }

    // MARK: Labels

    @Test func labelsAreHighlighted() {
        let html = highlight("label:")
        #expect(html.contains("<font CLASS=preproc>label:</font>"))
    }

    // MARK: - Comprehensive Snippet

    @Test func comprehensiveSnippetHighlightsAllRules() {
        let source = """
        -- VHDL comment
        library IEEE;
        use IEEE.STD_LOGIC_1164.ALL;
        entity counter is
            port(
                clk : in BIT;
                count : out BIT_VECTOR(7 downto 0)
            );
        end counter;
        architecture rtl of counter is
            signal x : INTEGER := 42;
            signal y : REAL := 3.14;
            signal s : STRING := "hello";
        label1:
            process(clk)
            begin
                x <= x + 1;
            end process;
        end rtl;
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=keyword>entity</font>"))
        #expect(html.contains("<font CLASS=keyword>architecture</font>"))
        #expect(html.contains("<font CLASS=keytype>BIT</font>"))
        #expect(html.contains("<font CLASS=keytype>INTEGER</font>"))
        #expect(html.contains("<font CLASS=integer>42</font>"))
        #expect(html.contains("<font CLASS=floatpt>3.14</font>"))
        #expect(html.contains("<font CLASS=dblquot>")) // double-quoted string highlighted
        #expect(html.contains("<font CLASS=symbols>+</font>"))
        #expect(html.contains("<font CLASS=comment>-- VHDL comment</font>"))
        #expect(html.contains("<font CLASS=preproc>label1:</font>"))
    }
}
