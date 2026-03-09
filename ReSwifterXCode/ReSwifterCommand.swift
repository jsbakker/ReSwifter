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
        // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
        
//        completionHandler(nil)
        let text = invocation.buffer.completeBuffer
        let lines = invocation.buffer.lines
        let selections = invocation.buffer.selections

//        try Task.sleep(nanoseconds: 5_000_000_000)
        for selection in selections {
            print("Self: \(selection)\n")
            guard let sel = selection as? XCSourceTextRange else { continue }

//            let lines = text[sel.start.line..<sel.end.line]
            let lStart = sel.start.line
            let lEnd = sel.end.line
            let cStart = sel.start.column
            let cEnd = sel.end.column

//            let startLine = lines[lStart]
//            let endLine = lines[lEnd]

            if lStart == lEnd {
                // column is substring of lStart
            } else {
                var selectedLines = [String]()
                let selectionLineCount = lEnd - lStart
                let selectionLastLine = lStart + selectionLineCount + 1

                print("Begin Selection:\n")
                for i in lStart..<selectionLastLine {

                    if i == lStart {
                        let trimStart = (lines[i] as! String)[String.Index(encodedOffset: cStart)...]
                        selectedLines.append(String(trimStart))
                        print(String(trimStart))
                    }
                    else if i == lEnd {
                        let trimEnd = (lines[i] as! String)[..<String.Index(encodedOffset: cEnd)]
                        selectedLines.append(String(trimEnd))
                        print(String(trimEnd))
                    } else {
                        print(lines[i] as! String)
                        selectedLines.append(lines[i] as! String)
                    }
                }
                print("End of Selection:\n")

                print("Selection:\n\(selectedLines)")

                // works, but just playing around
//                let reversedSelection = Array(selectedLines.reversed())

//                let range: Range = lStart..<selectionLastLine

                // working but just playing around
//                lines.replaceObjects(at: IndexSet(integersIn: range), with: reversedSelection)

                launcher.launchAndProcess(text) { reply, err in
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
                return
//                lines.remove(atOffsets: Range(lStart..<selectionLastLine, in: lines.indicesOfObjects(byEvaluatingObjectSpecifier: "self"))!)
//                lines.removeAllObjects()
//                lines.addObjects(from: updatedText)
//                let trimStart = selectedLines.first?.substring(from: String.Index(cStart))
//                let trimEnd = selectedLines.last?.substring(to: String.Index(cEnd))
            }

              // zero-based indices: e.g. this is on lines 24-27, with 8 spaces indent
//            Self: <XCSourceTextRange: 0xb24c0cd20 {{line: 23, column: 8}, {line: 26, column: 36}}>
//
//            Self: <XCSourceTextRange: 0xb24c0ce10 {{line: 23, column: 8}, {line: 26, column: 36}}>
// why 2 selections though? breakpoint twice?
        }
//_usesTabsForIndentation    bool    false
//_indentationWidth    long long    4
//_tabWidth    long long    4
//_contentUTI    __NSCFConstantString    "public.swift-source"    0x00000001facc81a0
//lines: _lines    XCMutableSourceTextLineArray?    0x0000000b24c0ced0
//selections 1 element
// [0]    XCSourceTextRange?    0x0000000b24c0ce10
//        invocation.buffer.selections.forEach({sel in
//            let selection = sel
//        })
//        print("ReSwifter:\n\(text)")
//        os_log("ReSwifter:\n\(text)")
        completionHandler(nil)
    }
}
