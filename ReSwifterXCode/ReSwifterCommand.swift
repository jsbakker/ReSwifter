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
        let lines = bufferLines(from: buffer)

        guard let xcSelection = buffer.selections.firstObject as? XCSourceTextRange else {
            // No selection info — send entire buffer
            launcher.launchAndProcess(buffer.completeBuffer) { reply, err in
                self.handleReply(reply, error: err, selection: nil, buffer: buffer, completionHandler: completionHandler)
            }
            return
        }

        let sel = TextSelection(
            startLine: xcSelection.start.line,
            startColumn: xcSelection.start.column,
            endLine: xcSelection.end.line,
            endColumn: xcSelection.end.column
        )

        let hasSelection = TextBufferEditor.isNonTrivialSelection(sel, lineCount: lines.count)
        let textToSend = hasSelection
            ? TextBufferEditor.extractSelectedText(from: lines, selection: sel)
            : buffer.completeBuffer

        launcher.launchAndProcess(textToSend) { reply, err in
            self.handleReply(reply, error: err, selection: hasSelection ? xcSelection : nil, buffer: buffer, completionHandler: completionHandler)
        }
    }

    private func handleReply(
        _ reply: String?,
        error: Error?,
        selection: XCSourceTextRange?,
        buffer: XCSourceTextBuffer,
        completionHandler: @escaping (Error?) -> Void
    ) {
        if let error {
            print("Error: \(error)")
            completionHandler(error)
            return
        }

        guard let reply else {
            completionHandler(nil)
            return
        }

        let lines = bufferLines(from: buffer)

        if let sel = selection {
            let textSel = TextSelection(
                startLine: sel.start.line,
                startColumn: sel.start.column,
                endLine: sel.end.line,
                endColumn: sel.end.column
            )
            let result = TextBufferEditor.replaceSelection(in: lines, selection: textSel, with: reply)
            writeLines(result.lines, to: buffer)
            sel.start = XCSourceTextPosition(line: result.updatedSelection.startLine, column: result.updatedSelection.startColumn)
            sel.end = XCSourceTextPosition(line: result.updatedSelection.endLine, column: result.updatedSelection.endColumn)
        } else {
            let result = TextBufferEditor.replaceEntireBuffer(with: reply)
            writeLines(result, to: buffer)
        }

        completionHandler(nil)
    }

    // MARK: - Buffer Conversion Helpers

    private func bufferLines(from buffer: XCSourceTextBuffer) -> [String] {
        (0..<buffer.lines.count).map { buffer.lines[$0] as! String }
    }

    private func writeLines(_ newLines: [String], to buffer: XCSourceTextBuffer) {
        buffer.lines.removeAllObjects()
        for line in newLines {
            buffer.lines.add(line)
        }
    }
}
