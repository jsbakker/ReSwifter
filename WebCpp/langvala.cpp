// The Vala Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#include "langvala.h"

#include <algorithm>
#include <iterator>
#include <string>

using std::string;

LangVala::LangVala() {

    initReservedWords();

    doStringsSinQuote = true;
    doSymbols = true;
    doUnderscoreNumbers = true;
    doBigComnt = true;  // /* */
    doCinComnt = true;  // //
    doTplString = true; // """...""" triple-quoted strings
    doPreProc = true;   // #if, #elif, #else, #endif, #define
}

void LangVala::initReservedWords() {

    // Vala keywords
    string K[] = {
        "abstract",  "as",        "async",      "base",     "break",
        "case",      "catch",     "class",      "const",    "construct",
        "continue",  "default",   "delegate",   "delete",   "do",
        "dynamic",   "else",      "ensures",    "enum",     "errordomain",
        "extern",    "false",     "finally",    "for",      "foreach",
        "get",       "if",        "implements", "in",       "inline",
        "interface", "internal",  "is",         "lock",     "namespace",
        "new",       "null",      "out",        "override", "owned",
        "private",   "protected", "public",     "ref",      "requires",
        "return",    "sealed",    "set",        "signal",   "sizeof",
        "static",    "struct",    "switch",     "this",     "throw",
        "throws",    "true",      "try",        "typeof",   "unowned",
        "using",     "value",     "var",        "virtual",  "void",
        "weak",      "while",     "yield",
    };
    std::copy(std::cbegin(K), std::cend(K), std::back_inserter(keys));

    // Vala primitive and GLib types
    string T[] = {
        "bool",    "char",   "double", "float",   "int",    "int8",
        "int16",   "int32",  "int64",  "long",    "short",  "size_t",
        "ssize_t", "string", "uchar",  "uint",    "uint8",  "uint16",
        "uint32",  "uint64", "ulong",  "unichar", "ushort",
    };
    std::copy(std::cbegin(T), std::cend(T), std::back_inserter(types));
}
