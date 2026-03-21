//
//  WebCppTheme.swift
//  ReSwifter
//
//  Maps WebCpp CSS token class names to NSColor values.
//  Each color is adaptive: it resolves to a light or dark variant
//  automatically based on the current NSAppearance.
//

import AppKit

enum WebCppTheme {

    // MARK: - Background

    /// The background color of the code view. Adapts to light/dark mode.
    static let backgroundColor = NSColor.adaptive(light: "#fafafa", dark: "#18181C")

    // MARK: - Token Colors

    /// Returns the adaptive foreground `NSColor` for a given WebCpp CSS class name.
    /// Falls back to `nortext` for unrecognised class names.
    static func color(for tokenClass: String) -> NSColor {
        switch tokenClass {
        case "bgcolor":  return .adaptive(light: "#fafafa",  dark: "#18181C")
        case "preproc":  return .adaptive(light: "#6E200D",  dark: "#FD8F3F")
        case "nortext":  return .adaptive(light: "#000000",  dark: "#FFFFFF")
        case "symbols":  return .adaptive(light: "#0077DD",  dark: "#0077DD")
        case "keyword":  return .adaptive(light: "#B40062",  dark: "#E4529A")
        case "keytype":  return .adaptive(light: "#AA0D91",  dark: "#AB64FF")
        case "integer":  return .adaptive(light: "#000BFF",  dark: "#FFE76D")
        case "floatpt":  return .adaptive(light: "#2211AA",  dark: "#FFE76D")
        case "dblquot":  return .adaptive(light: "#BA0011",  dark: "#FC4651")
        case "sinquot":  return .adaptive(light: "#000BFF",  dark: "#FFE76D")
        case "comment":  return .adaptive(light: "#5E5E5E",  dark: "#6C7987")
        default:         return .adaptive(light: "#000000",  dark: "#FFFFFF")
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

// MARK: - NSColor adaptive + hex factory

private extension NSColor {
    /// Creates an adaptive `NSColor` that resolves to `light` in light mode
    /// and `dark` in dark mode, using the current `NSAppearance`.
    static func adaptive(light lightHex: String, dark darkHex: String) -> NSColor {
        NSColor(name: nil) { appearance in
            let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            return isDark ? .fromHex(darkHex) : .fromHex(lightHex)
        }
    }

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
