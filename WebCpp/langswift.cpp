// The Swift Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#include "langswift.h"

#include <algorithm>
#include <iterator>

LangSwift::LangSwift() {

    fill();
    init_switches();

    doStringsBackTick = true;
    doSymbols = Yes;
    doBigComnt = Yes;
    doCinComnt = Yes;
    doTplString = Yes;
    // Swift string interpolation: "text \(expr)"
    doInterpolate = true;
    interpolStart = "\\(";
    interpolEnd = ')';
}

void LangSwift::fill() {

    // Swift keywords
    string K[] = {
        "@AppStorage",
        "@Attribute",
        "@Bindable",
        "@Binding",
        "@DiscardableResult",
        "@Entry",
        "@Environment",
        "@EnvironmentObject",
        "@FetchRequest",
        "@FocusState",
        "@FocusedBinding",
        "@FocusedValue",
        "@GestureState",
        "@MainActor",
        "@Model",
        "@Namespace",
        "@Observable",
        "@ObservedObject",
        "@Published",
        "@Query",
        "@ScaledMetric",
        "@SceneStorage",
        "@Sendable",
        "@State",
        "@StateObject",
        "@UIApplicationDelegateAdaptor",
        "@ViewBuilder",
        "@autoclosure",
        "@available",
        "@convention",
        "@discardableResult",
        "@dynamicCallable",
        "@dynamicMemberLookup",
        "@escaping",
        "@frozen",
        "@inlinable",
        "@main",
        "@objc",
        "@objcMembers",
        "@preconcurrency",
        "@propertyWrapper",
        "@resultBuilder",
        "@retroactive",
        "@testable",
        "@unchecked",
        "@unknown",
        "@usableFromInline",
        "actor",
        "as",
        "associatedtype",
        "associativity",
        "async",
        "await",
        "break",
        "case",
        "catch",
        "class",
        "consume",
        "consuming",
        "continue",
        "convenience",
        "default",
        "defer",
        "deinit",
        "didSet",
        "do",
        "dynamic",
        "else",
        "enum",
        "extension",
        "fallthrough",
        "false",
        "fileprivate",
        "final",
        "for",
        "func",
        "get",
        "guard",
        "if",
        "import",
        "in",
        "indirect",
        "infix",
        "init",
        "inout",
        "internal",
        "is",
        "isolated",
        "lazy",
        "left",
        "let",
        "macro",
        "mutating",
        "nil",
        "nonisolated",
        "nonmutating",
        "open",
        "operator",
        "optional",
        "override",
        "postfix",
        "precedence",
        "precedencegroup",
        "prefix",
        "private",
        "protocol",
        "public",
        "repeat",
        "required",
        "rethrows",
        "return",
        "right",
        "self",
        "set",
        "some",
        "static",
        "struct",
        "subscript",
        "super",
        "switch",
        "throw",
        "throws",
        "true",
        "try",
        "typealias",
        "unowned",
        "var",
        "weak",
        "where",
        "while",
        "willSet",
    };
    std::copy(std::cbegin(K), std::cend(K), std::back_inserter(keys));

    // Swift built-in types
    string T[] = {
        "Any",    "AnyObject", "Array", "Bool",     "Character", "Dictionary",
        "Double", "Error",     "Float", "Int",      "Int8",      "Int16",
        "Int32",  "Int64",     "Never", "Optional", "Result",    "Self",
        "Set",    "String",    "UInt",  "UInt8",    "UInt16",    "UInt32",
        "UInt64", "Void",
    };
    std::copy(std::cbegin(T), std::cend(T), std::back_inserter(types));
}
