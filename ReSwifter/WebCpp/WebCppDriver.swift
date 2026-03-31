//
//  WebCppDriver.swift
//  ReSwifter
//
//  Swift wrapper around the WebCpp framework's C bridge.
//

import Foundation
import WebCpp

/// Swift-friendly wrapper around the WebCpp syntax-highlighting engine.
final class WebCppDriver {

    private let ref: WebCppDriverRef

    init() {
        ref = webcpp_driver_create()
    }

    deinit {
        webcpp_driver_destroy(ref)
    }

    // MARK: - Static

    /// Generates an index HTML file from a webcppbatch.txt listing.
    static func makeIndex(prefix: String = "") {
        webcpp_driver_make_index(prefix)
    }

    // MARK: - Instance

    /// Parses a command-line-style option (e.g. `"-l"`, `"--line-numbers"`, `"-c=scheme"`).
    /// - Returns: `true` if the option was recognised and applied.
    @discardableResult
    func parseSwitch(_ arg: String) -> Bool {
        webcpp_driver_switch_parser(ref, arg)
    }

    /// Returns the internal language file-type code for the given filename.
    func getExtension(for filename: String) -> CChar {
        webcpp_driver_get_ext(ref, filename)
    }

    /// Detects the language for the given filename and returns a human-readable description
    /// (e.g. `"C++ file"`, `"Python script"`).
    func checkExtension(for filename: String) -> String {
        guard let cStr = webcpp_driver_check_ext(ref, filename) else { return "" }
        let result = String(cString: cStr)
        webcpp_free_string(cStr)
        return result
    }

    /// Prepares input/output files for processing.
    /// - Parameters:
    ///   - inputFile: Path to the source file.
    ///   - outputFile: Path for the HTML output.
    ///   - overwrite: Overwrite behaviour — `.force`, `.never`, or `.prompt`.
    /// - Returns: `true` on success.
    @discardableResult
    func prepareFiles(input inputFile: String,
                      output outputFile: String,
                      overwrite: OverwriteMode = .force) -> Bool {
        webcpp_driver_prep_files(ref, inputFile, outputFile, overwrite.rawValue)
    }

    /// Returns the filename portion (without directory path) of the current input file.
    func getTitle() -> String {
        guard let cStr = webcpp_driver_get_title(ref) else { return "" }
        let result = String(cString: cStr)
        webcpp_free_string(cStr)
        return result
    }

    /// Runs the syntax-highlighting engine on the prepared files.
    func drive() {
        webcpp_driver_drive(ref)
    }

    // MARK: - Convenience

    /// Converts a source code string to syntax-highlighted HTML.
    /// - Parameters:
    ///   - source: The source code text.
    ///   - filename: A representative filename used for language detection (e.g. `"example.swift"`).
    ///   - options: Optional command-line-style flags (e.g. `["-l", "-c=scheme"]`).
    /// - Returns: The highlighted HTML string, or `nil` on failure.
    static func highlightString(_ source: String,
                                filename: String,
                                options: [String] = []) -> String? {
        // Build a null-terminated C array of option strings
        var cOptions = options.map { strdup($0) as UnsafeMutablePointer<CChar>? }
        cOptions.append(nil)

        let result: String? = cOptions.withUnsafeMutableBufferPointer { buf in
            // Reinterpret [UnsafeMutablePointer<CChar>?] as [UnsafePointer<CChar>?]
            buf.baseAddress!.withMemoryRebound(
                to: UnsafePointer<CChar>?.self,
                capacity: buf.count
            ) { ptr in
                guard let cStr = webcpp_driver_highlight_string(source, filename, ptr) else {
                    return nil
                }
                let s = String(cString: cStr)
                webcpp_free_string(cStr)
                return s
            }
        }

        // Free the strdup'd option strings
        for ptr in cOptions {
            free(ptr)
        }

        return result
    }

    // MARK: - Supporting Types

    enum HelpMode: CChar {
        case languages = 0x4C  // 'L'
        case `default` = 0x44  // 'D'
    }

    enum OverwriteMode: CChar {
        case force  = 0x66  // 'f'
        case never  = 0x6B  // 'k'
        case prompt = 0x77  // 'w'
    }
}
