//
//  WebCppLanguage.swift
//  ReSwifter
//
//  Supported languages for WebCpp syntax highlighting.
//

import Foundation

/// Languages supported by the WebCpp syntax-highlighting engine.
/// Each case carries a representative file extension used by the driver.
enum WebCppLanguage: String, CaseIterable, Identifiable {
    case ada          = "adb"
    case assembly     = "asm"
    case asp          = "asp"
    case basic        = "bas"
    case batch        = "bat"
    case c            = "c"
    case cg           = "cg"
    case clips        = "clp"
    case cpp          = "cpp"
    case cSharp       = "cs"
    case css          = "css"
    case emf          = "emf"
    case euphoria     = "eu"
    case fortran      = "f90"
    case fSharp       = "fs"
    case gherkin      = "feature"
    case glsl         = "glsl"
    case go           = "go"
    case haskell      = "hs"
    case hlsl         = "hlsl"
    case html         = "html"
    case java         = "java"
    case javaScript   = "js"
    case kotlin       = "kt"
    case modula2      = "mod"
    case oCaml        = "ml"
    case objectiveC   = "m"
    case objectiveCpp = "mm"
    case pascal       = "pas"
    case perl         = "pl"
    case php          = "php"
    case powerBuilder = "pbl"
    case python       = "py"
    case r            = "r"
    case renderMan    = "sl"
    case ruby         = "rb"
    case rust         = "rs"
    case scala        = "scala"
    case shell        = "sh"
    case sql          = "sql"
    case swift        = "swift"
    case tcl          = "tcl"
    case typeScript   = "ts"
    case unrealScript = "uc"
    case vala         = "vala"
    case vhdl         = "vhd"
    case xml          = "xml"
    case zig          = "zig"
    case text         = "txt"

    var id: String { rawValue }

    /// Human-readable display name for the picker.
    var displayName: String {
        switch self {
        case .ada:           return "Ada"
        case .assembly:      return "Assembly"
        case .asp:           return "ASP"
        case .basic:         return "Basic"
        case .batch:         return "DOS Batch"
        case .c:             return "C"
        case .cg:            return "NVidia Cg"
        case .clips:         return "NASA CLIPS"
        case .cpp:           return "C++"
        case .cSharp:        return "C#"
        case .css:           return "Cascading StyleSheet"
        case .emf:           return "EMF"
        case .euphoria:      return "Euphoria"
        case .fortran:       return "Fortran"
        case .fSharp:        return "F#"
        case .gherkin:       return "Gherkin"
        case .glsl:          return "GLSL"
        case .go:            return "Go"
        case .haskell:       return "Haskell"
        case .hlsl:          return "HLSL"
        case .html:          return "HTML"
        case .java:          return "Java"
        case .javaScript:    return "JavaScript"
        case .kotlin:        return "Kotlin"
        case .modula2:       return "Modula2"
        case .oCaml:         return "OCaml"
        case .objectiveC:    return "Objective-C"
        case .objectiveCpp:  return "Objective-C++"
        case .pascal:        return "Pascal"
        case .perl:          return "Perl"
        case .php:           return "PHP"
        case .powerBuilder:  return "Power Builder"
        case .python:        return "Python"
        case .r:             return "R"
        case .renderMan:     return "RenderMan"
        case .ruby:          return "Ruby"
        case .rust:          return "Rust"
        case .scala:         return "Scala"
        case .shell:         return "Unix Shell"
        case .sql:           return "SQL"
        case .swift:         return "Swift"
        case .tcl:           return "Tcl"
        case .typeScript:    return "TypeScript"
        case .unrealScript:  return "UnrealScript"
        case .vala:          return "Vala"
        case .vhdl:          return "VHDL"
        case .xml:           return "XML"
        case .zig:           return "Zig"
        case .text:          return "Text"
        }
    }

    /// The dummy filename passed to WebCppDriver so it selects the right language engine.
    var dummyFilename: String {
        "snippet.\(rawValue)"
    }

    /// Finds the language matching a raw extension string, falling back to `.swift`.
    static func from(rawValue: String) -> WebCppLanguage {
        WebCppLanguage(rawValue: rawValue) ?? .swift
    }
}
