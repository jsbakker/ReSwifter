//
//  WebCppTheme.swift
//  ReSwifter
//
//  Maps WebCpp CSS token class names to NSColor values.
//  Colors mirror the "typical" theme defined in WebCpp/theme.cpp: Theme::typical().
//

import AppKit

enum WebCppTheme {

    // MARK: - Background

    /// The background color of the code view (WebCpp's BGCOLOR).
    static let backgroundColor = NSColor.fromHex("#fafafa")

    // MARK: - Token Colors

    /// Returns the foreground `NSColor` for a given WebCpp CSS class name.
    /// Falls back to `nortext` (black) for unrecognised class names.
    static func color(for tokenClass: String) -> NSColor {
        switch tokenClass {
        case "bgcolor":  return .fromHex("#fafafa")
        case "preproc":  return .fromHex("#a900a9")
        case "nortext":  return .fromHex("#000000")
        case "symbols":  return .fromHex("#0077dd")
        case "keyword":  return .fromHex("#224fff")
        case "keytype":  return .fromHex("#ff9933")
        case "integer":  return .fromHex("#ff0032")
        case "floatpt":  return .fromHex("#ff23a6")
        case "dblquot":  return .fromHex("#00b800")
        case "sinquot":  return .fromHex("#00b86b")
        case "comment":  return .fromHex("#666666")
        default:         return .fromHex("#000000")
        }
    }

    // MARK: - Font Traits

    /// Returns `true` if the token class should be rendered bold (keywords, keytypes).
    static func isBold(for tokenClass: String) -> Bool {
        tokenClass == "keyword" || tokenClass == "keytype"
    }

    /// Returns `true` if the token class should be rendered italic (comments).
    static func isItalic(for tokenClass: String) -> Bool {
        tokenClass == "comment"
    }
}

// MARK: - NSColor hex factory

private extension NSColor {
    /// Creates an `NSColor` from a 6-digit hex string such as `"#224fff"` or `"224fff"`.
    static func fromHex(_ hex: String) -> NSColor {
        let hex = hex.trimmingCharacters(in: .init(charactersIn: "#"))
        let value = UInt64(hex, radix: 16) ?? 0
        let r = CGFloat((value >> 16) & 0xFF) / 255
        let g = CGFloat((value >> 8)  & 0xFF) / 255
        let b = CGFloat( value        & 0xFF) / 255
        return NSColor(srgbRed: r, green: g, blue: b, alpha: 1)
    }
}
