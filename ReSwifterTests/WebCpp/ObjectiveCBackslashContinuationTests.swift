//
//  ObjectiveCBackslashContinuationTests.swift
//  ReSwifterTests
//
//  Backslash line-continuation in Objective-C and Objective-C++ string literals.
//  Both use the C preprocessor translation phase 2, so \ at end of a line splices
//  it with the next before any string parsing, covering "..." and @"..." literals.
//

import Testing
import WebCpp

struct ObjectiveCBackslashContinuationTests {

    private func highlight(_ source: String, language: String) -> String {
        HighlightTestHelper.highlight(source, language: language)
    }

    // MARK: Objective-C (.m)

    @Test func objcOpeningLineHasClosedFontTag() {
        let source = "NSString *s = @\"hello \\\nworld\";"
        let html = highlight(source, language: "m")
        let lines = html.components(separatedBy: "\n")
        let opening = lines.first(where: { $0.contains("hello") })
        #expect(opening?.contains("<font CLASS=dblquot>") == true,
                "ObjC opening line must have dblquot: \(opening ?? "NOT FOUND")")
        #expect(opening?.contains("</font>") == true,
                "ObjC opening line font tag must be closed: \(opening ?? "NOT FOUND")")
    }

    @Test func objcContinuationLineIsColoured() {
        let source = "NSString *s = @\"hello \\\nworld\";"
        let html = highlight(source, language: "m")
        let lines = html.components(separatedBy: "\n")
        let cont = lines.first(where: { $0.contains("world") && !$0.contains("@") })
        #expect(cont?.contains("<font CLASS=dblquot>") == true,
                "ObjC continuation line must have dblquot: \(cont ?? "NOT FOUND")")
    }

    // MARK: Objective-C++ (.mm)

    @Test func objcppOpeningLineHasClosedFontTag() {
        let source = "std::string s = \"hello \\\nworld\";"
        let html = highlight(source, language: "mm")
        let lines = html.components(separatedBy: "\n")
        let opening = lines.first(where: { $0.contains("hello") })
        #expect(opening?.contains("<font CLASS=dblquot>") == true,
                "ObjC++ opening line must have dblquot: \(opening ?? "NOT FOUND")")
        #expect(opening?.contains("</font>") == true,
                "ObjC++ opening line font tag must be closed: \(opening ?? "NOT FOUND")")
    }

    @Test func objcppContinuationLineIsColoured() {
        let source = "std::string s = \"hello \\\nworld\";"
        let html = highlight(source, language: "mm")
        let lines = html.components(separatedBy: "\n")
        let cont = lines.first(where: { $0.contains("world") && !$0.contains("std") })
        #expect(cont?.contains("<font CLASS=dblquot>") == true,
                "ObjC++ continuation line must have dblquot: \(cont ?? "NOT FOUND")")
    }
}
