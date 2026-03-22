//
//  HighlightTestHelper.swift
//  ReSwifterTests
//
//  Shared helper for syntax-highlighting tests.
//  Calls the WebCpp C bridge directly so the test target does not
//  need to host the ReSwifter application.
//

import Foundation
import WebCpp

enum HighlightTestHelper {

    /// WebCpp uses fixed temp filenames internally, so all highlight
    /// calls must be serialized across test suites.
    private static let lock = NSLock()

    /// Thread-safe wrapper around webcpp_driver_highlight_string.
    static func highlight(_ source: String, language ext: String) -> String {
        lock.lock()
        defer { lock.unlock() }

        let filename = "snippet.\(ext)"
        guard let cStr = webcpp_driver_highlight_string(source, filename, nil) else {
            return ""
        }
        let result = String(cString: cStr)
        webcpp_free_string(cStr)
        return result
    }
}
