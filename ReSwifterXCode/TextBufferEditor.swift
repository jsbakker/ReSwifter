//
//  TextBufferEditor.swift
//  ReSwifterXCode
//
//  Created by Jeffrey Bakker on 2026-04-12.
//

import Foundation

struct TextSelection {
    var startLine: Int
    var startColumn: Int
    var endLine: Int
    var endColumn: Int
}

struct TextBufferEditor {

    /// Returns true if the selection represents an actual text selection
    /// (not just a caret position or full-buffer selection).
    static func isNonTrivialSelection(_ sel: TextSelection, lineCount: Int) -> Bool {
        // No actual selection (just a caret)
        if sel.startLine == sel.endLine && sel.startColumn == sel.endColumn {
            return false
        }
        // Entire buffer selected
        if sel.startLine == 0 && sel.endLine == lineCount && sel.startColumn == 0 && sel.endColumn == 0 {
            return false
        }
        return true
    }

    /// Extracts the text covered by the given selection from an array of lines.
    static func extractSelectedText(from lines: [String], selection sel: TextSelection) -> String {
        let lStart = sel.startLine
        let lEnd = sel.endLine
        let cStart = sel.startColumn
        let cEnd = sel.endColumn

        // Single-line selection
        if lStart == lEnd {
            let line = lines[lStart]
            let startIdx = line.index(line.startIndex, offsetBy: min(cStart, line.count))
            let endIdx = line.index(line.startIndex, offsetBy: min(cEnd, line.count))
            return String(line[startIdx..<endIdx])
        }

        // Multi-line selection
        var selectedLines = [String]()
        for i in lStart...lEnd {
            let line = lines[i]
            if i == lStart {
                let startIdx = line.index(line.startIndex, offsetBy: min(cStart, line.count))
                selectedLines.append(String(line[startIdx...]))
            } else if i == lEnd {
                let endIdx = line.index(line.startIndex, offsetBy: min(cEnd, line.count))
                selectedLines.append(String(line[..<endIdx]))
            } else {
                selectedLines.append(line)
            }
        }
        return selectedLines.joined()
    }

    /// Replaces the selected range with new text.
    /// Returns the updated lines array and the new selection covering the replacement.
    static func replaceSelection(
        in lines: [String],
        selection sel: TextSelection,
        with text: String
    ) -> (lines: [String], updatedSelection: TextSelection) {
        var lines = lines
        let lStart = sel.startLine
        let lEnd = sel.endLine
        let cStart = sel.startColumn
        let cEnd = sel.endColumn

        // Get the prefix of the first selected line (before selection)
        let firstLine = lines[lStart]
        let prefixEnd = firstLine.index(firstLine.startIndex, offsetBy: min(cStart, firstLine.count))
        let prefix = String(firstLine[..<prefixEnd])

        // Get the suffix of the last selected line (after selection)
        let lastLine = lines[lEnd]
        let suffixStart = lastLine.index(lastLine.startIndex, offsetBy: min(cEnd, lastLine.count))
        let suffix = String(lastLine[suffixStart...])

        // Remove the old lines covered by the selection
        lines.removeSubrange(lStart...lEnd)

        // Build replacement: prefix + reply text + suffix
        let combined = prefix + text + suffix
        let newLines = combined.components(separatedBy: "\n")

        // Insert replacement lines (each gets a trailing newline except the last)
        var insertLines = [String]()
        for (i, newLine) in newLines.enumerated() {
            let lineToInsert = (i < newLines.count - 1) ? newLine + "\n" : newLine
            insertLines.append(lineToInsert)
        }
        if insertLines.count > 1 && insertLines.last == "" {
            insertLines.removeLast()
        }
        lines.insert(contentsOf: insertLines, at: lStart)

        // Compute updated selection covering the newly inserted text
        let lastInsertedLine = lStart + insertLines.count - 1
        let lastInsertedLineContent = lines[lastInsertedLine]
        let updatedSelection = TextSelection(
            startLine: lStart,
            startColumn: cStart,
            endLine: lastInsertedLine,
            endColumn: lastInsertedLineContent.count
        )

        return (lines, updatedSelection)
    }

    /// Replaces entire buffer content with new text.
    /// Returns the new lines array.
    static func replaceEntireBuffer(with text: String) -> [String] {
        let newLines = text.components(separatedBy: "\n")
        var result = [String]()
        for (i, line) in newLines.enumerated() {
            let lineToInsert = (i < newLines.count - 1) ? line + "\n" : line
            result.append(lineToInsert)
        }
        if result.count > 1 && result.last == "" {
            result.removeLast()
        }
        return result
    }
}
