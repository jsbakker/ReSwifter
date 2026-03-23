// The TypeScript Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#include "langts.h"

#include <algorithm>
#include <iterator>

LangTypeScript::LangTypeScript() {

    fill();
    init_switches();

    doSymbols = Yes;
    doBigComnt = Yes; // /* */
    doCinComnt = Yes; // //
    // doStrings = true by default; backtick template literals handled
    // automatically
}

void LangTypeScript::fill() {

    // TypeScript keywords (TypeScript 5.x)
    string K[] = {
        "abstract",  "as",         "async",     "await",     "break",
        "case",      "catch",      "class",     "const",     "continue",
        "debugger",  "declare",    "default",   "delete",    "do",
        "else",      "enum",       "export",    "extends",   "false",
        "finally",   "for",        "from",      "function",  "get",
        "if",        "implements", "import",    "in",        "instanceof",
        "interface", "is",         "keyof",     "let",       "module",
        "namespace", "new",        "null",      "of",        "override",
        "package",   "private",    "protected", "public",    "readonly",
        "require",   "return",     "satisfies", "set",       "static",
        "super",     "switch",     "this",      "throw",     "true",
        "try",       "type",       "typeof",    "undefined", "using",
        "var",       "void",       "while",     "with",      "yield",
    };
    std::copy(std::cbegin(K), std::cend(K), std::back_inserter(keys));

    // TypeScript built-in and utility types
    string T[] = {
        "Array",       "ArrayBuffer", "BigInt",       "Boolean",
        "Date",        "Error",       "Float32Array", "Float64Array",
        "Function",    "Int8Array",   "Int16Array",   "Int32Array",
        "Map",         "Number",      "Object",       "Promise",
        "Proxy",       "Record",      "RegExp",       "Set",
        "String",      "Symbol",      "TypeError",    "Uint8Array",
        "Uint16Array", "Uint32Array", "WeakMap",      "WeakRef",
        "WeakSet",     "any",         "bigint",       "boolean",
        "never",       "number",      "object",       "string",
        "symbol",      "unknown",
    };
    std::copy(std::cbegin(T), std::cend(T), std::back_inserter(types));
}
