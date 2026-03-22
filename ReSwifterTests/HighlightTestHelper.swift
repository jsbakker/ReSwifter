//
//  HighlightTestHelper.swift
//  ReSwifterTests
//
//  Shared helper for syntax-highlighting tests.
//  WebCpp uses fixed temp filenames internally, so all highlight calls
//  must be serialized across test suites to avoid file clobbering.
//

import Foundation
@testable import ReSwifter

enum HighlightTestHelper {

    private static let lock = NSLock()

    /// Thread-safe wrapper around WebCppDriver.highlightString.
    static func highlight(_ source: String, language: String) -> String {
        lock.lock()
        defer { lock.unlock() }
        return WebCppDriver.highlightString(source, filename: "snippet.\(language)") ?? ""
    }
}
