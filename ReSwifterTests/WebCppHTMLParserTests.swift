//
//  WebCppHTMLParserTests.swift
//  ReSwifterTests
//
//  Tests for parseWebCppHTML() and rebaseTokenRanges(), which translate
//  WebCpp's HTML font tags into NSRange-based token ranges for the live
//  code editor's syntax highlighting.
//
//  These functions live in the ReSwifter app target. Since the test target
//  runs standalone (no TEST_HOST), we import them via @testable.
//

import Foundation
import Testing
import WebCpp
@testable import ReSwifter

struct WebCppHTMLParserTests {

    // MARK: - parseWebCppHTML basics

    @Test func parsesKeywordToken() {
        let html = "<pre>\n\n<font CLASS=keyword>return</font>\n\n</pre>"
        let result = parseWebCppHTML(html)
        #expect(result.plainText == "return")
        #expect(result.tokenRanges.count == 1)
        #expect(result.tokenRanges[0].tokenClass == "keyword")
        #expect(result.tokenRanges[0].range == NSRange(location: 0, length: 6))
    }

    @Test func parsesMultipleTokens() {
        let html = "<pre>\n\n<font CLASS=keytype>int</font> x <font CLASS=symbols>=</font> <font CLASS=integer>42</font>;\n\n</pre>"
        let result = parseWebCppHTML(html)
        #expect(result.plainText == "int x = 42;")
        #expect(result.tokenRanges.count == 3)
        #expect(result.tokenRanges[0].tokenClass == "keytype")
        #expect(result.tokenRanges[0].range == NSRange(location: 0, length: 3))
        #expect(result.tokenRanges[1].tokenClass == "symbols")
        #expect(result.tokenRanges[1].range == NSRange(location: 6, length: 1))
        #expect(result.tokenRanges[2].tokenClass == "integer")
        #expect(result.tokenRanges[2].range == NSRange(location: 8, length: 2))
    }

    @Test func decodesHTMLEntities() {
        let html = "<pre>\n\nx &lt; y &amp;&amp; z &gt; w\n\n</pre>"
        let result = parseWebCppHTML(html)
        #expect(result.plainText == "x < y && z > w")
    }

    @Test func handlesEmptyPreBlock() {
        let html = "<pre>\n\n\n\n</pre>"
        let result = parseWebCppHTML(html)
        #expect(result.plainText == "")
        #expect(result.tokenRanges.isEmpty)
    }

    @Test func handlesMalformedHTMLGracefully() {
        let html = "no pre tags here"
        let result = parseWebCppHTML(html)
        #expect(result.tokenRanges.isEmpty)
    }

    // MARK: - Leading blank line regression

    /// Bug: if the snippet started with an empty line, all syntax highlighting
    /// would break because the old trimming logic (trimmingCharacters(in: .newlines))
    /// consumed the user's blank line along with WebCpp's fixed newlines,
    /// shifting every subsequent token range.
    @Test func leadingBlankLinePreservesTokenRanges() {
        // Simulate WebCpp output for "\nint x = 42;"
        // WebCpp wraps in <pre>\n\n...\n\n</pre>, so with a source blank line
        // the content has 3 leading newlines (2 WebCpp + 1 user)
        let html = "<pre>\n\n\n<font CLASS=keytype>int</font> x <font CLASS=symbols>=</font> <font CLASS=integer>42</font>;\n\n</pre>"
        let result = parseWebCppHTML(html)

        // The leading blank line must be preserved in the plain text
        #expect(result.plainText.hasPrefix("\n"))

        // "int" should start at position 1 (after the user's newline)
        let intToken = result.tokenRanges.first { $0.tokenClass == "keytype" }
        #expect(intToken != nil)
        #expect(intToken?.range.location == 1)

        // "42" should also be at the correct offset
        let numToken = result.tokenRanges.first { $0.tokenClass == "integer" }
        #expect(numToken != nil)
        let expectedLoc = (result.plainText as NSString).range(of: "42").location
        #expect(numToken?.range.location == expectedLoc)
    }

    /// The parser must trim exactly 2 leading and 2 trailing newlines
    /// (WebCpp's fixed <pre>\n\n...\n\n</pre>) and no more.
    @Test func trimsExactlyTwoLeadingAndTrailingNewlines() {
        // Standard WebCpp: 2 leading + 2 trailing
        let html = "<pre>\n\nfoo\n\n</pre>"
        let result = parseWebCppHTML(html)
        #expect(result.plainText == "foo")

        // User has one blank line at start: 3 leading
        let html2 = "<pre>\n\n\nfoo\n\n</pre>"
        let result2 = parseWebCppHTML(html2)
        #expect(result2.plainText == "\nfoo")

        // User has two blank lines at start: 4 leading
        let html3 = "<pre>\n\n\n\nfoo\n\n</pre>"
        let result3 = parseWebCppHTML(html3)
        #expect(result3.plainText == "\n\nfoo")
    }

    @Test func multipleLeadingBlankLinesPreserveTokenPositions() {
        // Source: "\n\nreturn 0;" — two user blank lines
        let html = "<pre>\n\n\n\n<font CLASS=keyword>return</font> <font CLASS=integer>0</font>;\n\n</pre>"
        let result = parseWebCppHTML(html)

        #expect(result.plainText == "\n\nreturn 0;")

        let kwToken = result.tokenRanges.first { $0.tokenClass == "keyword" }
        #expect(kwToken?.range.location == 2) // after 2 user newlines
        #expect(kwToken?.range.length == 6)   // "return"
    }

    // MARK: - Preprocessor trailing space regression (rebaseTokenRanges)

    /// Bug: WebCpp's parsePreProc appends a trailing space to each preprocessor
    /// line. Without rebaseTokenRanges, each #include shifts all subsequent
    /// token ranges by +1, compounding with each additional directive.
    @Test func rebaseCorrectsSinglePreprocessorOffset() {
        let source = "#include <stdio.h>\nint x = 42;"

        // WebCpp adds trailing space on preprocessor line
        let parsedText = "#include <stdio.h> \nint x = 42;"
        let tokens = [
            WebCppTokenRange(range: NSRange(location: 0, length: 8), tokenClass: "preproc"),
            WebCppTokenRange(range: NSRange(location: 20, length: 3), tokenClass: "keytype"),
            WebCppTokenRange(range: NSRange(location: 28, length: 2), tokenClass: "integer"),
        ]
        let parsed = WebCppParseResult(plainText: parsedText, tokenRanges: tokens)
        let rebased = rebaseTokenRanges(parsed, to: source)

        // "int" should be at offset 19 in the original (not 20)
        let intToken = rebased.tokenRanges.first { $0.tokenClass == "keytype" }
        #expect(intToken?.range.location == 19)
        #expect(intToken?.range.length == 3)

        // "42" at correct position
        let numToken = rebased.tokenRanges.first { $0.tokenClass == "integer" }
        #expect(numToken?.range.location == (source as NSString).range(of: "42").location)
    }

    @Test func rebaseCorrectsMultiplePreprocessorOffsets() {
        let source = "#include <stdio.h>\n#include <stdlib.h>\nint x = 42;"

        // Two extra trailing spaces
        let parsedText = "#include <stdio.h> \n#include <stdlib.h> \nint x = 42;"
        let tokens = [
            WebCppTokenRange(range: NSRange(location: 0, length: 8), tokenClass: "preproc"),
            WebCppTokenRange(range: NSRange(location: 20, length: 8), tokenClass: "preproc"),
            WebCppTokenRange(range: NSRange(location: 41, length: 3), tokenClass: "keytype"),
            WebCppTokenRange(range: NSRange(location: 49, length: 2), tokenClass: "integer"),
        ]
        let parsed = WebCppParseResult(plainText: parsedText, tokenRanges: tokens)
        let rebased = rebaseTokenRanges(parsed, to: source)

        let intToken = rebased.tokenRanges.first { $0.tokenClass == "keytype" }
        #expect(intToken?.range.location == (source as NSString).range(of: "int").location)

        let numToken = rebased.tokenRanges.first { $0.tokenClass == "integer" }
        #expect(numToken?.range.location == (source as NSString).range(of: "42").location)
    }

    @Test func rebaseWithThreePreprocessorDirectives() {
        let source = "#include <stdio.h>\n#include <stdlib.h>\n#include <string.h>\nint x = 42;"

        let parsedText = "#include <stdio.h> \n#include <stdlib.h> \n#include <string.h> \nint x = 42;"
        let tokens = [
            WebCppTokenRange(range: NSRange(location: 0, length: 8), tokenClass: "preproc"),
            WebCppTokenRange(range: NSRange(location: 20, length: 8), tokenClass: "preproc"),
            WebCppTokenRange(range: NSRange(location: 41, length: 8), tokenClass: "preproc"),
            WebCppTokenRange(range: NSRange(location: 62, length: 3), tokenClass: "keytype"),
            WebCppTokenRange(range: NSRange(location: 70, length: 2), tokenClass: "integer"),
        ]
        let parsed = WebCppParseResult(plainText: parsedText, tokenRanges: tokens)
        let rebased = rebaseTokenRanges(parsed, to: source)

        let intToken = rebased.tokenRanges.first { $0.tokenClass == "keytype" }
        #expect(intToken?.range.location == (source as NSString).range(of: "int").location)
        #expect(intToken?.range.length == 3)

        let numToken = rebased.tokenRanges.first { $0.tokenClass == "integer" }
        #expect(numToken?.range.location == (source as NSString).range(of: "42").location)
        #expect(numToken?.range.length == 2)
    }

    // MARK: - rebaseTokenRanges edge cases

    @Test func rebaseIsNoOpWhenTextsMatch() {
        let text = "int x = 42;"
        let tokens = [
            WebCppTokenRange(range: NSRange(location: 0, length: 3), tokenClass: "keytype"),
            WebCppTokenRange(range: NSRange(location: 8, length: 2), tokenClass: "integer"),
        ]
        let parsed = WebCppParseResult(plainText: text, tokenRanges: tokens)
        let rebased = rebaseTokenRanges(parsed, to: text)

        #expect(rebased.tokenRanges[0].range == NSRange(location: 0, length: 3))
        #expect(rebased.tokenRanges[1].range == NSRange(location: 8, length: 2))
    }

    // MARK: - End-to-end with real WebCpp output

    /// Integration test: feed real C++ source through WebCpp, parse the HTML,
    /// rebase the ranges, and verify they land on the correct substrings.
    @Test func endToEndPreprocessorHighlighting() {
        let source = "#include <stdio.h>\nint main() { return 42; }"
        let html = HighlightTestHelper.highlight(source, language: "cpp")

        var result = parseWebCppHTML(html)
        if result.plainText != source {
            result = rebaseTokenRanges(result, to: source)
        }

        let nsSource = source as NSString
        for token in result.tokenRanges {
            guard token.range.location + token.range.length <= nsSource.length else {
                Issue.record("Token range \(token.range) out of bounds")
                continue
            }
            let substring = nsSource.substring(with: token.range)
            switch token.tokenClass {
            case "preproc":  #expect(substring == "#include")
            case "keytype":  #expect(substring == "int")
            case "keyword":  #expect(substring == "return")
            case "integer":  #expect(substring == "42")
            default: break
            }
        }
    }

    @Test func endToEndLeadingBlankLine() {
        let source = "\nint x = 42;"
        let html = HighlightTestHelper.highlight(source, language: "cpp")

        var result = parseWebCppHTML(html)
        if result.plainText != source {
            result = rebaseTokenRanges(result, to: source)
        }

        // "int" must start at position 1 (after the blank line)
        let intToken = result.tokenRanges.first { $0.tokenClass == "keytype" }
        #expect(intToken != nil)
        #expect(intToken?.range.location == 1)
        #expect(intToken?.range.length == 3)

        let substring = (source as NSString).substring(with: intToken!.range)
        #expect(substring == "int")
    }

    @Test func endToEndMultiplePreprocessorLines() {
        let source = "#include <stdio.h>\n#include <stdlib.h>\n#include <string.h>\nint x = 42;"
        let html = HighlightTestHelper.highlight(source, language: "cpp")

        var result = parseWebCppHTML(html)
        if result.plainText != source {
            result = rebaseTokenRanges(result, to: source)
        }

        let nsSource = source as NSString
        for token in result.tokenRanges {
            guard token.range.location + token.range.length <= nsSource.length else {
                Issue.record("Token \(token.tokenClass) range \(token.range) out of bounds")
                continue
            }
            let substring = nsSource.substring(with: token.range)
            switch token.tokenClass {
            case "preproc":  #expect(substring == "#include")
            case "keytype":  #expect(substring == "int")
            case "integer":  #expect(substring == "42")
            default: break
            }
        }
    }
}
