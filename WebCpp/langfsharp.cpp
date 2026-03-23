// The F# Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#include "langfsharp.h"

#include <algorithm>
#include <iterator>

LangFSharp::LangFSharp() {

    fill();
    init_switches();

    doStringsSinQuote = true;
    doStringsBackTick = true;
    doSymbols = Yes;
    doCinComnt = Yes;  // // line comments
    doPasComnt = Yes;  // (* *) block comments
    doTplString = Yes; // """...""" triple-quoted strings
}

void LangFSharp::fill() {

    // F# reserved keywords
    string K[] = {
        "abstract",  "and",      "as",       "assert", "base",      "begin",
        "class",     "default",  "delegate", "do",     "done",      "downcast",
        "downto",    "elif",     "else",     "end",    "exception", "extern",
        "false",     "finally",  "for",      "fun",    "function",  "global",
        "if",        "in",       "inherit",  "inline", "interface", "internal",
        "lazy",      "let",      "match",    "member", "module",    "mutable",
        "namespace", "new",      "not",      "null",   "of",        "open",
        "or",        "override", "private",  "public", "rec",       "return",
        "seq",       "static",   "struct",   "then",   "to",        "true",
        "try",       "type",     "upcast",   "use",    "val",       "void",
        "when",      "while",    "with",     "yield",
    };
    std::copy(std::cbegin(K), std::cend(K), std::back_inserter(keys));

    // F# primitive and built-in types
    string T[] = {
        "bool",   "byte",    "char",       "decimal", "double", "exn",
        "float",  "float32", "int",        "int8",    "int16",  "int32",
        "int64",  "list",    "nativeint",  "obj",     "option", "sbyte",
        "seq",    "single",  "string",     "uint",    "uint8",  "uint16",
        "uint32", "uint64",  "unativeint", "unit",
    };
    std::copy(std::cbegin(T), std::cend(T), std::back_inserter(types));
}
