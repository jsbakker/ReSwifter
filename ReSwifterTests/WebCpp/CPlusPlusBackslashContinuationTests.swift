//
//  CPlusPlusBackslashContinuationTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests for backslash-continuation string highlighting in C/C++.
/// A `\` at the end of a string literal line continues it onto the next
/// physical line.  Every continuation line must be coloured as a string and
/// must not allow other highlighters (keywords, types, comments, symbols,
/// numbers) to fire inside it.
struct CPlusPlusBackslashContinuationTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "cpp")
    }

    // MARK: Baseline

    @Test func singleLineStringIsHighlighted() {
        let html = highlight("\"hello world\";")
        #expect(html.contains("<font CLASS=dblquot>"))
        #expect(html.contains("</font>"))
    }

    // MARK: Continuation line coloring

    @Test func continuationLineWithNoQuotesIsColored() {
        // Line 1: "hello \
        // Line 2: no quotes here \
        // Line 3: done";
        let source = """
        "hello \\
        no quotes here \\
        done";
        """
        let html = highlight(source)

        // The string-open tag must appear (from line 1)
        #expect(html.contains("<font CLASS=dblquot>"))
        // The string-close tag must appear (from line 3)
        #expect(html.contains("</font>"))
        // Middle line must be wrapped — confirmed by presence of dblquot
        // tag followed by the literal content on that line
        #expect(html.contains("<font CLASS=dblquot>no quotes here"))
    }

    @Test func continuationLineWithEscapedQuotesIsColored() {
        // Line 1: "hello \
        // Line 2: world \"escaped\" text\
        // Line 3: done";
        let source = """
        "hello \\
        world \\"escaped\\" text\\
        done";
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=dblquot>"))
        // Intermediate line should be opened and closed (balanced)
        #expect(html.contains("<font CLASS=dblquot>world"))
        #expect(html.contains("</font>"))
    }

    @Test func continuationAfterOpeningLineWithHTMLEntities() {
        // Mirrors the endHtml() pattern: the opening line of the string
        // contains < and > (which pre_parse encodes as &lt;/&gt;), followed
        // by a plain-text continuation line that has no quote characters at all.
        // Line 1: s = "<br>\n\
        // Line 2: plain text here \
        // Line 3: end";
        let source = """
        s = "<br>\\n\\
        plain text here \\
        end";
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=dblquot>plain text here"))
    }

    @Test func continuationAfterOpeningLineWithEscapeSequences() {
        // The opening line ends with literal \n\ (escape-sequence characters)
        // before the line-continuation backslash, matching the endHtml pattern.
        // Line 1: x = "abc\n\
        // Line 2: plain\
        // Line 3: done";
        let source = "x = \"abc\\n\\\nplain\\\ndone\";"
        let html = highlight(source)

        #expect(html.contains("<font CLASS=dblquot>plain"))
    }

    // MARK: Other highlighters must not fire inside continuation lines

    @Test func keywordInsideContinuationIsNotHighlighted() {
        // Line 1: "start \
        // Line 2: int return void \
        // Line 3: end";
        let source = """
        "start \\
        int return void \\
        end";
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=keyword>int</font>"))
        #expect(!html.contains("<font CLASS=keyword>return</font>"))
        #expect(!html.contains("<font CLASS=keyword>void</font>"))
    }

    @Test func typeInsideContinuationIsNotHighlighted() {
        let source = """
        "start \\
        bool char double float \\
        end";
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=keytype>bool</font>"))
        #expect(!html.contains("<font CLASS=keytype>char</font>"))
    }

    @Test func numberInsideContinuationIsNotHighlighted() {
        let source = """
        "start \\
        42 3.14 \\
        end";
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=integer>42</font>"))
        #expect(!html.contains("<font CLASS=floatpt>3.14</font>"))
    }

    @Test func commentInsideContinuationIsNotHighlighted() {
        let source = """
        "start \\
        // not a comment \\
        end";
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=comment>// not a comment</font>"))
    }

    @Test func symbolInsideContinuationIsNotHighlighted() {
        let source = """
        "start \\
        + - = \\
        end";
        """
        let html = highlight(source)

        #expect(!html.contains("<font CLASS=symbols>+</font>"))
        #expect(!html.contains("<font CLASS=symbols>-</font>"))
        #expect(!html.contains("<font CLASS=symbols>=</font>"))
    }

    // MARK: Code after string closes is highlighted normally

    @Test func keywordAfterClosingLineIsHighlighted() {
        // Line 1: "hello \
        // Line 2: world";
        // Line 3: return x;
        let source = """
        "hello \\
        world";
        return x;
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=keyword>return</font>"))
    }

    @Test func numberAfterClosingLineIsHighlighted() {
        let source = """
        "hello \\
        world";
        42
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=integer>42</font>"))
    }

    // MARK: Opening line font tag must be closed

    @Test func openingLineHasClosedFontTag() {
        // When a string opens on a line and has no closing quote (backslash
        // continuation), the <font CLASS=dblquot> tag must be closed on that
        // same line so the HTML is well-formed.
        // Line 1: "hello \      ← must have </font> at end
        // Line 2: world";
        let source = "\"hello \\\nworld\";"
        let html = highlight(source)

        let lines = html.components(separatedBy: "\n")
        // Find the line containing the opening quote
        let openingLine = lines.first(where: { $0.contains("<font CLASS=dblquot>") && $0.contains("hello") })
        #expect(openingLine != nil, "Opening line should contain dblquot font tag")
        #expect(openingLine?.contains("</font>") == true,
                "Opening line's font tag must be closed: \(openingLine ?? "")")
    }

    @Test func openingLineWithHTMLEntitiesHasClosedFontTag() {
        // Mirrors the endHtml() pattern exactly: opening line contains < and >
        // (encoded as &lt;/&gt; by pre_parse) and no closing quote.
        // Line 1: made = "<center>\n<br>\n\
        // Line 2: syntax highlighting by<br>\n\
        // Line 3: end";
        let source = "made = \"<center>\\n<br>\\n\\\nsyntax highlighting by<br>\\n\\\nend\";"
        let html = highlight(source)

        let lines = html.components(separatedBy: "\n")

        // Opening line must have a closed font tag
        let openingLine = lines.first(where: { $0.contains("&lt;center&gt;") })
        #expect(openingLine != nil, "Should find line with &lt;center&gt;")
        #expect(openingLine?.contains("<font CLASS=dblquot>") == true,
                "Opening line must start string highlighting")
        #expect(openingLine?.contains("</font>") == true,
                "Opening line's font tag must be closed: \(openingLine ?? "")")

        // First continuation line must be wrapped
        let contLine1 = lines.first(where: { $0.contains("syntax highlighting") })
        #expect(contLine1 != nil, "Should find first continuation line")
        #expect(contLine1?.contains("<font CLASS=dblquot>") == true,
                "First continuation must have dblquot tag: \(contLine1 ?? "")")
        #expect(contLine1?.contains("</font>") == true,
                "First continuation's font tag must be closed: \(contLine1 ?? "")")
    }

    @Test func endHtmlPatternFullFidelity() {
        // Exact reproduction of the endHtml() multi-line string pattern.
        // Each physical line after the opening quote must be string-coloured.
        let source = """
        made = "<center>\\n<hr size=4 width=95%>\\n<br>\\n\\
        syntax highlighting by<br><br>\\n\\
        <table cellpadding=3 cellspacing=3 bgcolor=#000000><tr>\\n\\
        </a></td></tr>\\n</table>\\n<br>\\n</center>";
        """
        let html = highlight(source)

        let lines = html.components(separatedBy: "\n")

        // Opening line: made = "<center>...
        let openingLine = lines.first(where: { $0.contains("&lt;center&gt;") })
        #expect(openingLine?.contains("<font CLASS=dblquot>") == true,
                "Opening line must have dblquot: \(openingLine ?? "NOT FOUND")")
        #expect(openingLine?.contains("</font>") == true,
                "Opening line font must be closed: \(openingLine ?? "NOT FOUND")")

        // First continuation: syntax highlighting by...
        let contLine1 = lines.first(where: { $0.contains("syntax highlighting") })
        #expect(contLine1?.contains("<font CLASS=dblquot>") == true,
                "Cont line 1 must have dblquot: \(contLine1 ?? "NOT FOUND")")

        // Second continuation: <table...
        let contLine2 = lines.first(where: { $0.contains("cellpadding") })
        #expect(contLine2?.contains("<font CLASS=dblquot>") == true,
                "Cont line 2 must have dblquot: \(contLine2 ?? "NOT FOUND")")

        // Closing line: </a>...</center>";
        let closingLine = lines.first(where: { $0.contains("&lt;/center&gt;") })
        #expect(closingLine?.contains("<font CLASS=dblquot>") == true,
                "Closing line must have dblquot: \(closingLine ?? "NOT FOUND")")
    }

    @Test func begHtmlPatternWithEscapedQuotes() {
        // Reproduction of the begHtml() gen = "..." pattern.
        // The continuation line contains escaped quotes (\").
        let source = "gen = \"\\\nPublic \\\"quoted\\\" text\\\nGet webcpp\";"
        let html = highlight(source)

        let lines = html.components(separatedBy: "\n")

        // Opening line: gen = "\
        let openingLine = lines.first(where: { $0.contains("gen") && $0.contains("<font CLASS=dblquot>") })
        #expect(openingLine != nil, "Opening line must have dblquot tag")
        #expect(openingLine?.contains("</font>") == true,
                "Opening line font tag must be closed: \(openingLine ?? "")")

        // First continuation: Public \"quoted\" text\
        let contLine = lines.first(where: { $0.contains("Public") })
        #expect(contLine?.contains("<font CLASS=dblquot>") == true,
                "Continuation with escaped quotes must have dblquot: \(contLine ?? "NOT FOUND")")
    }

    // MARK: Every continuation line in a long chain is coloured

    @Test func fiveContinuationLinesAllColoured() {
        // Five continuation lines, none with quotes — all must be coloured
        let source = "\"line1 \\\nline2 \\\nline3 \\\nline4 \\\nline5 \\\nend\";"
        let html = highlight(source)

        // Line 1 is the opening line: <font CLASS=dblquot>"line1 \</font>
        #expect(html.contains("<font CLASS=dblquot>\"line1"),
                "line1 must be inside dblquot span (opening line includes quote)")
        // Lines 2-5 are continuation lines: <font CLASS=dblquot>lineN \</font>
        for i in 2...5 {
            #expect(html.contains("<font CLASS=dblquot>line\(i)"),
                    "line\(i) must be inside dblquot span")
        }
    }

    @Test func everyLineHasBalancedFontTags() {
        // Each physical line must have balanced <font>...</font> pairs
        // so that the HTML is well-formed per-line.
        let source = "\"aaa \\\nbbb \\\nccc \\\nddd\";"
        let html = highlight(source)

        let lines = html.components(separatedBy: "\n")
        for line in lines {
            let opens = line.components(separatedBy: "<font CLASS=dblquot>").count - 1
            let closes = line.components(separatedBy: "</font>").count - 1
            // Each line that has an opening dblquot tag should have a matching close
            if opens > 0 && line.contains("aaa") || line.contains("bbb") ||
               line.contains("ccc") || line.contains("ddd") {
                #expect(opens <= closes,
                        "Unbalanced font tags on line: \(line)")
            }
        }
    }

    // MARK: Single-quote (char literal) continuation

    @Test func singleQuoteContinuationIsColoured() {
        // Single-quoted strings with backslash continuation
        let source = "'hello \\\nworld';"
        let html = highlight(source)

        let lines = html.components(separatedBy: "\n")
        let openingLine = lines.first(where: { $0.contains("hello") })
        #expect(openingLine?.contains("<font CLASS=sinquot>") == true,
                "Single-quote opening must have sinquot: \(openingLine ?? "")")
        #expect(openingLine?.contains("</font>") == true,
                "Single-quote opening font must be closed: \(openingLine ?? "")")
    }

    // MARK: Opening line content is visually highlighted

    @Test func openingLineContentAfterQuoteIsInsideFontSpan() {
        // The content between the opening " and the end of line must be
        // INSIDE the <font CLASS=dblquot> span, not outside it.
        let source = "x = \"<br>content here\\\nnext\";"
        let html = highlight(source)

        let lines = html.components(separatedBy: "\n")
        let openingLine = lines.first(where: { $0.contains("content here") })!

        // Find the positions of the font tag and the content
        let fontStart = openingLine.range(of: "<font CLASS=dblquot>")
        let contentPos = openingLine.range(of: "content here")
        let fontEnd = openingLine.range(of: "</font>", range: contentPos!.lowerBound..<openingLine.endIndex)

        #expect(fontStart != nil, "Must have opening font tag")
        #expect(contentPos != nil, "Must have content")
        #expect(fontEnd != nil, "Must have closing font tag after content")
        #expect(fontStart!.upperBound <= contentPos!.lowerBound,
                "Font tag must come before content")
        #expect(contentPos!.upperBound <= fontEnd!.lowerBound,
                "Content must come before closing font tag")
    }
}
