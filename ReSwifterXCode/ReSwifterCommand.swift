//
//  SourceEditorCommand.swift
//  ReSwifterXCode
//
//  Created by Jeffrey Bakker on 2026-02-27.
//

import Foundation
import XcodeKit
import os.log

class ReSwifterCommand: NSObject, XCSourceEditorCommand {

    private let launcher = AppLauncherIPCService()

    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        let buffer = invocation.buffer
        let selection = getSelection(from: buffer)
        let textToSend = selection != nil
            ? extractSelectedText(from: buffer, selection: selection!)
            : buffer.completeBuffer

        launcher.launchAndProcess(textToSend) { reply, err in
            if let err {
                print("Error: \(err)")
                completionHandler(err)
                return
            }

            guard let reply else {
                completionHandler(nil)
                return
            }

            if let selection {
                self.replaceSelection(in: buffer, selection: selection, with: reply)
            } else {
                self.replaceEntireBuffer(in: buffer, with: reply)
            }

            completionHandler(nil)
        }
    }

    /// Returns the selection range if there is a non-empty selection,
    /// or nil if the cursor is just a caret with nothing selected.
    private func getSelection(from buffer: XCSourceTextBuffer) -> XCSourceTextRange? {
        guard let sel = buffer.selections.firstObject as? XCSourceTextRange else {
            return nil
        }
        // No actual selection (just a caret position)
        if sel.start.line == sel.end.line && sel.start.column == sel.end.column {
            return nil
        }
        return sel
    }

    /// Extracts the text covered by the given selection range.
    private func extractSelectedText(from buffer: XCSourceTextBuffer, selection sel: XCSourceTextRange) -> String {
        let lStart = sel.start.line
        let lEnd = sel.end.line
        let cStart = sel.start.column
        let cEnd = sel.end.column
        let lines = buffer.lines

        // Single-line selection
        if lStart == lEnd {
            let line = lines[lStart] as! String
            let startIdx = line.index(line.startIndex, offsetBy: min(cStart, line.count))
            let endIdx = line.index(line.startIndex, offsetBy: min(cEnd, line.count))
            return String(line[startIdx..<endIdx])
        }

        // Multi-line selection
        var selectedLines = [String]()
        for i in lStart...lEnd {
            let line = lines[i] as! String
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

    /// Replaces the selected range in the buffer with the reply text.
    private func replaceSelection(in buffer: XCSourceTextBuffer, selection sel: XCSourceTextRange, with text: String) {
        let lines = buffer.lines
        let lStart = sel.start.line
        let lEnd = sel.end.line
        let cStart = sel.start.column
        let cEnd = sel.end.column

        // Get the prefix of the first selected line (before selection)
        let firstLine = lines[lStart] as! String
        let prefixEnd = firstLine.index(firstLine.startIndex, offsetBy: min(cStart, firstLine.count))
        let prefix = String(firstLine[..<prefixEnd])

        // Get the suffix of the last selected line (after selection)
        let lastLine = lines[lEnd] as! String
        let suffixStart = lastLine.index(lastLine.startIndex, offsetBy: min(cEnd, lastLine.count))
        let suffix = String(lastLine[suffixStart...])

        // Remove the old lines covered by the selection
        let range = lStart...lEnd
        lines.removeObjects(at: IndexSet(integersIn: range))

        // Build replacement: prefix + reply text + suffix
        let combined = prefix + text + suffix
        let newLines = combined.components(separatedBy: "\n")

        // Insert replacement lines (each needs a trailing newline for XCSourceTextBuffer,
        // except the content is split by \n so we re-add them)
        for (i, newLine) in newLines.enumerated() {
            let lineToInsert = (i < newLines.count - 1) ? newLine + "\n" : newLine
            lines.insert(lineToInsert, at: lStart + i)
        }

        // Update the selection to cover the newly inserted text
        let lastInsertedLine = lStart + newLines.count - 1
        let lastInsertedLineContent = lines[lastInsertedLine] as! String
        let newEnd = XCSourceTextPosition(line: lastInsertedLine, column: lastInsertedLineContent.count)
        sel.start = XCSourceTextPosition(line: lStart, column: cStart)
        sel.end = newEnd
    }

    /// Replaces the entire buffer content with the reply text.
    private func replaceEntireBuffer(in buffer: XCSourceTextBuffer, with text: String) {
        let lines = buffer.lines
        lines.removeAllObjects()

        let newLines = text.components(separatedBy: "\n")
        for (i, line) in newLines.enumerated() {
            let lineToInsert = (i < newLines.count - 1) ? line + "\n" : line
            lines.add(lineToInsert)
        }
    }
}
