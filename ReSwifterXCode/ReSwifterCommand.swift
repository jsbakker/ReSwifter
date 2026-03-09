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

    private let launcher = AppLauncherXPCService()

    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        let textToSend = extractSelectedText(from: invocation.buffer)
            ?? invocation.buffer.completeBuffer

        launcher.launchAndProcess(textToSend) { reply, err in
            if let err {
                print("Error: \(err)")
                completionHandler(err)
                return
            }

            if let reply {
                print("Replied: \(reply)")
            }

            completionHandler(nil)
        }
    }

    /// Returns the selected text if there is a non-empty selection,
    /// or nil if the cursor is just a caret with nothing selected.
    private func extractSelectedText(from buffer: XCSourceTextBuffer) -> String? {
        guard let sel = buffer.selections.firstObject as? XCSourceTextRange else {
            return nil
        }

        let lStart = sel.start.line
        let lEnd = sel.end.line
        let cStart = sel.start.column
        let cEnd = sel.end.column

        // No actual selection (just a caret position)
        if lStart == lEnd && cStart == cEnd {
            return nil
        }

        let lines = buffer.lines

        // Single-line selection
        if lStart == lEnd {
            guard let line = lines[lStart] as? String else { return nil }
            let startIdx = line.index(line.startIndex, offsetBy: min(cStart, line.count))
            let endIdx = line.index(line.startIndex, offsetBy: min(cEnd, line.count))
            return String(line[startIdx..<endIdx])
        }

        // Multi-line selection
        var selectedLines = [String]()
        for i in lStart...lEnd {
            guard let line = lines[i] as? String else { continue }

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

        let result = selectedLines.joined()
        return result.isEmpty ? nil : result
    }
}
