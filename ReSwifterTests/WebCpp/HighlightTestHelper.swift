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

    /// Wrapper around webcpp_driver_highlight_string.
    /// Each call uses a unique temp file (via an atomic counter in the
    /// C bridge), so concurrent calls from parallel tests are safe.
    static func highlight(_ source: String, language ext: String) -> String {
        let filename = "snippet.\(ext)"
        guard let cStr = webcpp_driver_highlight_string(source, filename, nil) else {
            return ""
        }
        let result = String(cString: cStr)
        webcpp_free_string(cStr)
        return result
    }
}
