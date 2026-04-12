//
//  TextBufferEditorTests.swift
//  ReSwifterTests
//
//  Created by Jeffrey Bakker on 2026-04-12.
//

import XCTest

final class TextBufferEditorTests: XCTestCase {

    // MARK: - isNonTrivialSelection

    func test_isNonTrivialSelection_caret_returnsFalse() {
        let sel = TextSelection(startLine: 2, startColumn: 5, endLine: 2, endColumn: 5)
        XCTAssertFalse(TextBufferEditor.isNonTrivialSelection(sel, lineCount: 10))
    }

    func test_isNonTrivialSelection_fullBuffer_returnsFalse() {
        let sel = TextSelection(startLine: 0, startColumn: 0, endLine: 10, endColumn: 0)
        XCTAssertFalse(TextBufferEditor.isNonTrivialSelection(sel, lineCount: 10))
    }

    func test_isNonTrivialSelection_partialSingleLine_returnsTrue() {
        let sel = TextSelection(startLine: 1, startColumn: 2, endLine: 1, endColumn: 8)
        XCTAssertTrue(TextBufferEditor.isNonTrivialSelection(sel, lineCount: 10))
    }

    func test_isNonTrivialSelection_multiLine_returnsTrue() {
        let sel = TextSelection(startLine: 0, startColumn: 3, endLine: 2, endColumn: 5)
        XCTAssertTrue(TextBufferEditor.isNonTrivialSelection(sel, lineCount: 10))
    }

    // MARK: - extractSelectedText

    func test_extractSelectedText_singleLine() {
        let lines = ["Hello, world!\n", "Second line\n"]
        let sel = TextSelection(startLine: 0, startColumn: 7, endLine: 0, endColumn: 12)
        let result = TextBufferEditor.extractSelectedText(from: lines, selection: sel)
        XCTAssertEqual(result, "world")
    }

    func test_extractSelectedText_multiLine() {
        let lines = ["First line\n", "Second line\n", "Third line\n"]
        let sel = TextSelection(startLine: 0, startColumn: 6, endLine: 2, endColumn: 5)
        let result = TextBufferEditor.extractSelectedText(from: lines, selection: sel)
        XCTAssertEqual(result, "line\nSecond line\nThird")
    }

    func test_extractSelectedText_columnZeroFirstLine() {
        let lines = ["Hello\n", "World\n"]
        let sel = TextSelection(startLine: 0, startColumn: 0, endLine: 0, endColumn: 5)
        let result = TextBufferEditor.extractSelectedText(from: lines, selection: sel)
        XCTAssertEqual(result, "Hello")
    }

    func test_extractSelectedText_columnBeyondLineLength() {
        let lines = ["Hi\n", "There\n"]
        let sel = TextSelection(startLine: 0, startColumn: 0, endLine: 0, endColumn: 100)
        let result = TextBufferEditor.extractSelectedText(from: lines, selection: sel)
        XCTAssertEqual(result, "Hi\n")
    }

    func test_extractSelectedText_adjacentLines() {
        let lines = ["AAA\n", "BBB\n", "CCC\n"]
        let sel = TextSelection(startLine: 0, startColumn: 1, endLine: 1, endColumn: 2)
        let result = TextBufferEditor.extractSelectedText(from: lines, selection: sel)
        XCTAssertEqual(result, "AA\nBB")
    }

    func test_extractSelectedText_entireSingleLine() {
        let lines = ["Hello\n", "World\n"]
        let sel = TextSelection(startLine: 1, startColumn: 0, endLine: 1, endColumn: 6)
        let result = TextBufferEditor.extractSelectedText(from: lines, selection: sel)
        XCTAssertEqual(result, "World\n")
    }

    // MARK: - replaceSelection

    func test_replaceSelection_singleLineWithShorterText() {
        // Lines without trailing newlines (like the last line in a buffer)
        let lines = ["Hello, world!"]
        let sel = TextSelection(startLine: 0, startColumn: 7, endLine: 0, endColumn: 12)
        let (newLines, _) = TextBufferEditor.replaceSelection(in: lines, selection: sel, with: "there")
        XCTAssertEqual(newLines, ["Hello, there!"])
    }

    func test_replaceSelection_singleLineWithLongerText() {
        let lines = ["Hello, world!"]
        let sel = TextSelection(startLine: 0, startColumn: 7, endLine: 0, endColumn: 12)
        let (newLines, _) = TextBufferEditor.replaceSelection(in: lines, selection: sel, with: "beautiful world")
        XCTAssertEqual(newLines, ["Hello, beautiful world!"])
    }

    func test_replaceSelection_multiLineWithSingleLine() {
        // Lines with trailing newlines (typical XCSourceTextBuffer format)
        let lines = ["First\n", "Second\n", "Third\n"]
        let sel = TextSelection(startLine: 0, startColumn: 0, endLine: 1, endColumn: 7)
        // Selecting "First\n" + "Second\n" — suffix is "" (after col 7 in "Second\n")
        let (newLines, _) = TextBufferEditor.replaceSelection(in: lines, selection: sel, with: "Replaced")
        XCTAssertEqual(newLines, ["Replaced", "Third\n"])
    }

    func test_replaceSelection_singleLineWithMultiLineText() {
        let lines = ["Hello world"]
        let sel = TextSelection(startLine: 0, startColumn: 5, endLine: 0, endColumn: 5)
        let (newLines, _) = TextBufferEditor.replaceSelection(in: lines, selection: sel, with: ",\nbeautiful")
        XCTAssertEqual(newLines, ["Hello,\n", "beautiful world"])
    }

    func test_replaceSelection_preservesPrefix() {
        let lines = ["    let x = 42;"]
        let sel = TextSelection(startLine: 0, startColumn: 12, endLine: 0, endColumn: 14)
        let (newLines, _) = TextBufferEditor.replaceSelection(in: lines, selection: sel, with: "99")
        XCTAssertEqual(newLines, ["    let x = 99;"])
    }

    func test_replaceSelection_multiLineReplacementWithTrailingNewline() {
        let lines = ["First\n", "Second\n", "Third\n"]
        let sel = TextSelection(startLine: 0, startColumn: 0, endLine: 2, endColumn: 6)
        let (newLines, _) = TextBufferEditor.replaceSelection(in: lines, selection: sel, with: "Alpha\nBeta\n")
        XCTAssertEqual(newLines, ["Alpha\n", "Beta\n"])
    }

    func test_replaceSelection_preservesSuffix() {
        let lines = ["prefix SELECTED suffix"]
        let sel = TextSelection(startLine: 0, startColumn: 7, endLine: 0, endColumn: 15)
        let (newLines, _) = TextBufferEditor.replaceSelection(in: lines, selection: sel, with: "NEW")
        XCTAssertEqual(newLines, ["prefix NEW suffix"])
    }

    func test_replaceSelection_updatedSelectionCoversNewText() {
        let lines = ["Hello, world!"]
        let sel = TextSelection(startLine: 0, startColumn: 7, endLine: 0, endColumn: 12)
        let (_, updated) = TextBufferEditor.replaceSelection(in: lines, selection: sel, with: "there")
        XCTAssertEqual(updated.startLine, 0)
        XCTAssertEqual(updated.startColumn, 7)
        XCTAssertEqual(updated.endLine, 0)
        XCTAssertEqual(updated.endColumn, "Hello, there!".count)
    }

    func test_replaceSelection_columnBeyondLineLengthClamped() {
        let lines = ["Hi"]
        let sel = TextSelection(startLine: 0, startColumn: 1, endLine: 0, endColumn: 100)
        let (newLines, _) = TextBufferEditor.replaceSelection(in: lines, selection: sel, with: "ello")
        XCTAssertEqual(newLines, ["Hello"])
    }

    // MARK: - replaceEntireBuffer

    func test_replaceEntireBuffer_singleLine() {
        let result = TextBufferEditor.replaceEntireBuffer(with: "Hello")
        XCTAssertEqual(result, ["Hello"])
    }

    func test_replaceEntireBuffer_multiLine() {
        let result = TextBufferEditor.replaceEntireBuffer(with: "Line1\nLine2\nLine3")
        XCTAssertEqual(result, ["Line1\n", "Line2\n", "Line3"])
    }

    func test_replaceEntireBuffer_singleLineWithTrailingNewline() {
        let result = TextBufferEditor.replaceEntireBuffer(with: "Hello\n")
        XCTAssertEqual(result, ["Hello\n"])
    }

    func test_replaceEntireBuffer_multiLineWithTrailingNewline() {
        let result = TextBufferEditor.replaceEntireBuffer(with: "Line1\nLine2\nLine3\n")
        XCTAssertEqual(result, ["Line1\n", "Line2\n", "Line3\n"])
    }

    func test_replaceEntireBuffer_emptyString() {
        let result = TextBufferEditor.replaceEntireBuffer(with: "")
        XCTAssertEqual(result, [""])
    }
}
