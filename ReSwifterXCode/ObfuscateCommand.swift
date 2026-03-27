//
//  SourceEditorCommand.swift
//  ReSwifterXCode
//
//  Created by Jeffrey Bakker on 2026-02-27.
//

import Foundation
import FoundationModels
import XcodeKit
import os.log

class ObfuscateCommand: NSObject, XCSourceEditorCommand {

    private let launcher = AppLauncherIPCService()

    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
        
//        completionHandler(nil)
        let text = invocation.buffer.completeBuffer
        let lines = invocation.buffer.lines
//        let selections = invocation.buffer.selections

        let model = SystemLanguageModel()//guardrails: .permissiveContentTransformations)
        if model.availability == .available {
            let instructions = """
                Obfuscation Rules:
                1. For all public functions, move their bodies into a private version of said function. Except for public init() when members are declared with let or non-optional vars. Initialization of optional member vars may be moved to a private initializer.
                2. For all private and fileprivate member variables, obfuscate their names
                3. For all private and fileprivate functions, obfuscate their names, bodies including local variables, and update matching call sites.
                4. Do not forget to obfuscate the bodies, locals and arguments of closures
                5. Do not forget to obfuscate references to interpolated variables inside strings
                6. Do not obfuscate the public function signatures, public structs or public class names; we need to keep it API-compatible with the old version.
                """
//            let question = """
//                Obfuscate the following source code using the aforementioned obfuscation rules:
//                ```
//                \(text)
//                ```
//                """

//            let question = """
//                Obfuscation Rules:
//                1. For all public functions, move their bodies into a private version of said function. Except for public init() when members are declared with let or non-optional vars. Initialization of optional member vars may be moved to a private initializer.
//                2. For all private and fileprivate member variables, obfuscate their names
//                3. For all private and fileprivate functions, obfuscate their names, bodies including local variables, and update matching call sites.
//                4. Do not forget to obfuscate the bodies, locals and arguments of closures
//                5. Do not forget to obfuscate references to interpolated variables inside strings
//                6. Do not obfuscate the public function signatures, public structs or public class names; we need to keep it API-compatible with the old version.
//                7. When obfuscating all variables, parameters and functions eligible for obuscating should be assigned cryptic names
//                8. When responding to this request, reply with the code only; no explanation
//                Obfuscate the following source code using the aforementioned obfuscation rules:
//                ```
//                \(text)
//                ```
//                """
            let question = "Based on public or internal functions, create a Swift Protocol from this class/struct and inherit the Protocol. Answer only in code; no comments or explanation.\n\nSource Code:\n\(text)"
            Task {
//                let session = LanguageModelSession(instructions: instructions)
                let session = LanguageModelSession(model: model)
                do {
                    let response = try await session.respond(to: question)
                    print("Obfuscation response: \(response.content)")
                    invocation.buffer.completeBuffer = response.content
                    completionHandler(nil)
                } catch {
                    completionHandler(error)
                }

//                let config = OpenAIConfiguration(
//                    endpoint: .ollama(),
//                    authentication: .none,
//                    ollamaConfig: OllamaConfiguration(
//                        keepAlive: "30m",     // Keep model in memory
//                        pullOnMissing: true,   // Auto-download models
//                        numGPU: 35            // GPU layers to use
//                    )
//                )
//                let provider = OpenAIProvider(configuration: config)
//
//                do {
//                    let response = try await provider.generate(
//                        question,
//                        model: .ollama("gemma3:4b")
////                        model: .ollama("llama3.2")
//                    )
//                    print("Obfuscation response:\n\(response)")
//                    invocation.buffer.completeBuffer = response
//                    completionHandler(nil)
//                } catch {
//                    print("I don't have a local answer for that.")
//                    completionHandler(error)
//                }
            }
        }

//        try Task.sleep(nanoseconds: 5_000_000_000)
//        for selection in selections {
//            print("Self: \(selection)\n")
//            guard let sel = selection as? XCSourceTextRange else { continue }
//
////            let lines = text[sel.start.line..<sel.end.line]
//            let lStart = sel.start.line
//            let lEnd = sel.end.line
//            let cStart = sel.start.column
//            let cEnd = sel.end.column
//
////            let startLine = lines[lStart]
////            let endLine = lines[lEnd]
//
//            if lStart == lEnd {
//                // column is substring of lStart
//            } else {
//                var selectedLines = [String]()
//                let selectionLineCount = lEnd - lStart
//                let selectionLastLine = lStart + selectionLineCount + 1
//
//                print("Begin Selection:\n")
//                for i in lStart..<selectionLastLine {
//
//                    if i == lStart {
//                        let trimStart = (lines[i] as! String)[String.Index(encodedOffset: cStart)...]
//                        selectedLines.append(String(trimStart))
//                        print(String(trimStart))
//                    }
//                    else if i == lEnd {
//                        let trimEnd = (lines[i] as! String)[..<String.Index(encodedOffset: cEnd)]
//                        selectedLines.append(String(trimEnd))
//                        print(String(trimEnd))
//                    } else {
//                        print(lines[i] as! String)
//                        selectedLines.append(lines[i] as! String)
//                    }
//                }
//                print("End of Selection:\n")
//
//                print("Selection:\n\(selectedLines)")
//
//                let reversedSelection = Array(selectedLines.reversed())
//
//                let range: Range = lStart..<selectionLastLine
//
//                // working
////                lines.replaceObjects(at: IndexSet(integersIn: range), with: reversedSelection)
//
//                launcher.launchAndProcess(text) { reply, err in
//                    if let err {
//                        print("Error: \(err)")
//                        completionHandler(err)
//                        return
//                    }
//
//                    if let reply {
//                        print("Replied: \(reply)")
//                    }
//
//                    completionHandler(nil)
//                }
//                return
////                lines.remove(atOffsets: Range(lStart..<selectionLastLine, in: lines.indicesOfObjects(byEvaluatingObjectSpecifier: "self"))!)
////                lines.removeAllObjects()
////                lines.addObjects(from: updatedText)
////                let trimStart = selectedLines.first?.substring(from: String.Index(cStart))
////                let trimEnd = selectedLines.last?.substring(to: String.Index(cEnd))
//            }
//
//              // zero-based indices: e.g. this is on lines 24-27, with 8 spaces indent
////            Self: <XCSourceTextRange: 0xb24c0cd20 {{line: 23, column: 8}, {line: 26, column: 36}}>
////
////            Self: <XCSourceTextRange: 0xb24c0ce10 {{line: 23, column: 8}, {line: 26, column: 36}}>
//// why 2 selections though? breakpoint twice?
//        }
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
//        completionHandler(nil)
    }
}
