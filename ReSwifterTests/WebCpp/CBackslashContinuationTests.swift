//
//  CBackslashContinuationTests.swift
//  ReSwifterTests
//
//  Backslash line-continuation in C string literals.
//  C supports \ at end of a string literal to continue it on the next line.
//

import Testing
import WebCpp

struct CBackslashContinuationTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "c")
    }

    @Test func openingLineHasClosedFontTag() {
        // "hello \       ← must have <font CLASS=dblquot>...</font> on this line
        // world";
        let source = "\"hello \\\nworld\";"
        let html = highlight(source)
        let lines = html.components(separatedBy: "\n")
        let opening = lines.first(where: { $0.contains("hello") })
        #expect(opening?.contains("<font CLASS=dblquot>") == true,
                "Opening line must have dblquot tag: \(opening ?? "NOT FOUND")")
        #expect(opening?.contains("</font>") == true,
                "Opening line font tag must be closed: \(opening ?? "NOT FOUND")")
    }

    @Test func continuationLineIsColoured() {
        let source = "\"hello \\\nworld\";"
        let html = highlight(source)
        let lines = html.components(separatedBy: "\n")
        let cont = lines.first(where: { $0.contains("world") && !$0.contains("\"world\"") })
        #expect(cont?.contains("<font CLASS=dblquot>") == true,
                "Continuation line must have dblquot tag: \(cont ?? "NOT FOUND")")
    }

    @Test func multipleContiguousContinuationLinesAllColoured() {
        // "line1 \
        // line2 \
        // line3";
        let source = "\"line1 \\\nline2 \\\nline3\";"
        let html = highlight(source)
        for label in ["line1", "line2", "line3"] {
            let line = html.components(separatedBy: "\n").first(where: { $0.contains(label) })
            #expect(line?.contains("<font CLASS=dblquot>") == true,
                    "\(label) must be inside dblquot span: \(line ?? "NOT FOUND")")
        }
    }

    @Test func codeAfterStringHighlightsNormally() {
        let source = "\"hello \\\nworld\";\nreturn 0;"
        let html = highlight(source)
        #expect(html.contains("<font CLASS=keyword>return</font>"),
                "Keyword after multi-line string must be highlighted")
    }
}
