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
    case ada        = "adb"
    case assembly   = "asm"
    case asp        = "asp"
    case basic      = "bas"
    case batch      = "bat"
    case c          = "c"
    case cpp        = "cpp"
    case cSharp     = "cs"
    case cg         = "cg"
    case clips      = "clp"
    case emf        = "emf"
    case euphoria   = "eu"
    case fortran    = "f90"
    case haskell    = "hs"
    case html       = "html"
    case java       = "java"
    case javaScript = "js"
    case modula2    = "mod"
    case objectiveC = "m"
    case pascal     = "pas"
    case perl       = "pl"
    case php        = "php"
    case powerBuilder = "pbl"
    case python     = "py"
    case renderMan  = "sl"
    case ruby       = "rb"
    case sql        = "sql"
    case swift      = "swift"
    case tcl        = "tcl"
    case shell      = "sh"
    case unrealScript = "uc"
    case vhdl       = "vhd"
    case text       = "txt"

    var id: String { rawValue }

    /// Human-readable display name for the picker.
    var displayName: String {
        switch self {
        case .ada:           return "Ada95"
        case .assembly:      return "Assembly"
        case .asp:           return "ASP"
        case .basic:         return "Basic"
        case .batch:         return "DOS Batch"
        case .c:             return "C"
        case .cpp:           return "C++"
        case .cSharp:        return "C#"
        case .cg:            return "NVidia Cg"
        case .clips:         return "NASA CLIPS"
        case .emf:           return "EMF"
        case .euphoria:      return "Euphoria"
        case .fortran:       return "Fortran"
        case .haskell:       return "Haskell"
        case .html:          return "Markup"
        case .java:          return "Java"
        case .javaScript:    return "JavaScript"
        case .modula2:       return "Modula2"
        case .objectiveC:    return "Objective-C"
        case .pascal:        return "Pascal"
        case .perl:          return "Perl"
        case .php:           return "PHP"
        case .powerBuilder:  return "Power Builder"
        case .python:        return "Python"
        case .renderMan:     return "RenderMan"
        case .ruby:          return "Ruby"
        case .sql:           return "SQL"
        case .swift:         return "Swift"
        case .tcl:           return "Tcl"
        case .shell:         return "Unix Shell"
        case .unrealScript:  return "UnrealScript"
        case .vhdl:          return "VHDL"
        case .text:          return "Plain Text"
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
