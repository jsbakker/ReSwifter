//
//  HaskellBackslashContinuationTests.swift
//  ReSwifterTests
//
//  Backslash string-gap continuation in Haskell string literals.
//  Haskell 2010 defines a "string gap": \ at end of a line followed by
//  whitespace and then \ at the start of the resumed content are both
//  discarded, allowing a string to span multiple source lines.
//  Single-quoted syntax is character literals; backtick syntax is infix
//  operator notation — neither supports string continuation.
//

import Testing
import WebCpp

struct HaskellBackslashContinuationTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "hs")
    }

    @Test func openingLineHasClosedFontTag() {
        // Haskell gap: "hello \<newline>\world"
        let source = "s = \"hello \\\n\\world\""
        let html = highlight(source)
        let lines = html.components(separatedBy: "\n")
        let opening = lines.first(where: { $0.contains("hello") })
        #expect(opening?.contains("<font CLASS=dblquot>") == true,
                "Haskell opening must have dblquot: \(opening ?? "NOT FOUND")")
        #expect(opening?.contains("</font>") == true,
                "Haskell opening font tag must be closed: \(opening ?? "NOT FOUND")")
    }

    @Test func continuationLineIsColoured() {
        let source = "s = \"hello \\\n\\world\""
        let html = highlight(source)
        let lines = html.components(separatedBy: "\n")
        let cont = lines.first(where: { $0.contains("world") && !$0.contains("s =") })
        #expect(cont?.contains("<font CLASS=dblquot>") == true,
                "Haskell continuation must have dblquot: \(cont ?? "NOT FOUND")")
    }
}
