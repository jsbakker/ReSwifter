//
//  SourceEditorCommand.swift
//  ReSwifterXCode
//
//  Created by Jeffrey Bakker on 2026-02-27.
//

import Foundation
@preconcurrency import XcodeKit
import os.log

class ReSwifterCommand: NSObject, XCSourceEditorCommand, @unchecked Sendable {

    private let launcher = AppLauncherIPCService()

    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping @Sendable (Error?) -> Void ) -> Void {
        let buffer = invocation.buffer
        let lines = bufferLines(from: buffer)

        let effectiveSelection: XCSourceTextRange?
        let textToSend: String

        if let xcSel = buffer.selections.firstObject as? XCSourceTextRange {
            let sel = TextSelection(
                startLine: xcSel.start.line,
                startColumn: xcSel.start.column,
                endLine: xcSel.end.line,
                endColumn: xcSel.end.column
            )
            if TextBufferEditor.isNonTrivialSelection(sel, lineCount: lines.count) {
                textToSend = TextBufferEditor.extractSelectedText(from: lines, selection: sel)
                effectiveSelection = xcSel
            } else {
                textToSend = buffer.completeBuffer
                effectiveSelection = nil
            }
        } else {
            textToSend = buffer.completeBuffer
            effectiveSelection = nil
        }

        Task { @MainActor in
            do {
                let reply = try await self.launcher.launchAndProcess(textToSend)
                self.handleReply(reply, error: nil, selection: effectiveSelection, buffer: buffer, completionHandler: completionHandler)
            } catch {
                completionHandler(error)
            }
        }
    }

    @MainActor
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
