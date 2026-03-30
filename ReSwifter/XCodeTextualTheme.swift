//
//  XCodeTextualTheme.swift
//  Emulate Xcode colour scheme for Light and Dark

import SwiftUI
import Textual

extension DynamicColor {
  static let codePlain = DynamicColor(
    light: Color(red: 0, green: 0, blue: 0, opacity: 1),
    dark: Color(red: 1, green: 1, blue: 1, opacity: 1)
  )

  static let codeBackground = DynamicColor(
    light: Color(red: 0.9804, green: 0.9804, blue: 0.9804),
    dark: Color(red: 0.094, green: 0.094, blue: 0.110)
  )
}

extension StructuredText.HighlighterTheme {
  /// The default syntax-highlighting theme used by Textual.
  public static let `xcode` = Self(
    foregroundColor: .codePlain,
    backgroundColor: .codeBackground,
    tokenProperties: [
      // Keywords
      .keyword: AnyTextProperty(
        .foregroundColor(.codeKeyword),
        .fontWeight(.semibold)
      ),
      .builtin: AnyTextProperty(.foregroundColor(.codeBuiltin)),
      .literal: AnyTextProperty(
        .foregroundColor(.codeKeyword),
        .fontWeight(.semibold)
      ),
      // Strings and characters
      .string: AnyTextProperty(.foregroundColor(.codeString)),
      .char: AnyTextProperty(.foregroundColor(.codeChar)),
      .regex: AnyTextProperty(.foregroundColor(.codeString)),
      .url: AnyTextProperty(.foregroundColor(.codeURL)),
      // Numbers and symbols
      .number: AnyTextProperty(.foregroundColor(.codeNumber)),
      .symbol: AnyTextProperty(.foregroundColor(.codePlain)),
      .boolean: AnyTextProperty(
        .foregroundColor(.codeKeyword),
        .fontWeight(.semibold)
      ),
      // Types and classes
      .className: AnyTextProperty(.foregroundColor(.codeClass)),
      // Functions
      .function: AnyTextProperty(.foregroundColor(.codeFunction)),
      .functionName: AnyTextProperty(.foregroundColor(.codeFunction)),
      // Variables and properties
      .variable: AnyTextProperty(.foregroundColor(.codeVariable)),
      .constant: AnyTextProperty(.foregroundColor(.codeConstant)),
      .property: AnyTextProperty(.foregroundColor(.codeVariable)),
      // Comments
      .comment: AnyTextProperty(.foregroundColor(.codeComment)),
      .blockComment: AnyTextProperty(.foregroundColor(.codeComment)),
      .docComment: AnyTextProperty(.foregroundColor(.codeComment)),
      .mark: AnyTextProperty(
        .foregroundColor(.codeMark),
        .fontWeight(.bold)
      ),
      // Preprocessor
      .preprocessor: AnyTextProperty(.foregroundColor(.codePreprocessor)),
      // Swift
      .directive: AnyTextProperty(.foregroundColor(.codePreprocessor)),
      .attribute: AnyTextProperty(.foregroundColor(.codeAttribute)),
      // Markup
      .tag: AnyTextProperty(.foregroundColor(.codeChar)),
      .attributeName: AnyTextProperty(.foregroundColor(.codeAttribute)),
      // Diff
      .inserted: AnyTextProperty(.foregroundColor(.codeInserted)),
      .deleted: AnyTextProperty(.foregroundColor(.codeDeleted)),
    ]
  )
}

extension DynamicColor {
  fileprivate static let codeKeyword = DynamicColor(
    light: Color(red: 0.706, green: 0.0, blue: 0.384),
    dark: Color(red: 0.894, green: 0.322, blue: 0.604)
  )

  fileprivate static let codeBuiltin = DynamicColor(
    light: Color(red: 0.361, green: 0.149, blue: 0.600),
    dark: Color(red: 0.671, green: 0.392, blue: 1.0)
  )

  fileprivate static let codeString = DynamicColor(
    light: Color(red: 0.7294, green: 0.0, blue: 0.0667),
    dark: Color(red: 0.988, green: 0.275, blue: 0.318)
  )

  fileprivate static let codeChar = DynamicColor(
    light: Color(red: 0.0, green: 0.0431, blue: 1.0),
    dark: Color(red: 1.0, green: 0.9059, blue: 0.4275)
  )

  fileprivate static let codeURL = DynamicColor(
    light: Color(red: 0.0549, green: 0.0549, blue: 1.0),
    dark: Color(red: 0.3098, green: 0.6471, blue: 1.0)
  )

  fileprivate static let codeNumber = DynamicColor(
    light: Color(red: 0.0, green: 0.0431, blue: 1.0),
    dark: Color(red: 1.0, green: 0.9059, blue: 0.4275)
  )

  fileprivate static let codeClass = DynamicColor(
    light: Color(red: 0.157, green: 0.294, blue: 0.310),
    dark: Color(red: 0.6627, green: 1.0, blue: 0.9176)
  )

  fileprivate static let codeFunction = DynamicColor(
    light: Color(red: 0.231, green: 0.498, blue: 0.537),
    dark: Color(red: 0.337255, green: 0.815686, blue: 0.701961)
  )

  fileprivate static let codeVariable = DynamicColor(
    light: Color(red: 0.157, green: 0.294, blue: 0.310),
    dark: Color(red: 0.6627, green: 1.0, blue: 0.9176)
  )

  fileprivate static let codeConstant = DynamicColor(
    light: Color(red: 0.231, green: 0.498, blue: 0.537),
    dark: Color(red: 0.337, green: 0.816, blue: 0.702)
  )

  fileprivate static let codeComment = DynamicColor(
    light: Color(red: 0.37, green: 0.37, blue: 0.37),
    dark: Color(red: 0.47, green: 0.47, blue: 0.47)
  )

  fileprivate static let codeMark = DynamicColor(
    light: Color(red: 0.37, green: 0.37, blue: 0.37),
    dark: Color(red: 0.47, green: 0.47, blue: 0.47)
  )

  fileprivate static let codePreprocessor = DynamicColor(
    light: Color(red: 0.431, green: 0.125, blue: 0.051),
    dark: Color(red: 0.992, green: 0.561, blue: 0.247)
  )

  fileprivate static let codeAttribute = DynamicColor(
    light: Color(red: 0.514, green: 0.424, blue: 0.157),
    dark: Color(red: 0.878, green: 0.616, blue: 0.396)
  )

  fileprivate static let codeInserted = DynamicColor(
    light: Color(red: 0.203922, green: 0.780392, blue: 0.349020),
    dark: Color(red: 0.188235, green: 0.819608, blue: 0.345098)
  )  // TODO

  fileprivate static let codeDeleted = DynamicColor(
    light: Color(red: 1, green: 0.219608, blue: 0.235294),
    dark: Color(red: 1, green: 0.258824, blue: 0.270588)
  )  // TODO
}
