// The Kotlin Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#include "langkotlin.h"

#include <algorithm>
#include <iterator>

LangKotlin::LangKotlin() {

    fill();
    init_switches();

    doStringsSinQuote = true;
    doStringsBackTick = true;
    doSymbols = Yes;
    doBigComnt = Yes;  // /* */
    doCinComnt = Yes;  // //
    doTplString = Yes; // """...""" triple-quoted strings
}

void LangKotlin::fill() {

    // Kotlin keywords
    string K[] = {
        "abstract",  "actual",      "as",        "break",    "by",
        "catch",     "class",       "companion", "const",    "constructor",
        "continue",  "crossinline", "data",      "delegate", "do",
        "dynamic",   "else",        "enum",      "expect",   "external",
        "false",     "field",       "file",      "final",    "finally",
        "for",       "fun",         "get",       "if",       "import",
        "in",        "infix",       "init",      "inline",   "inner",
        "interface", "internal",    "is",        "lateinit", "noinline",
        "null",      "object",      "open",      "operator", "out",
        "override",  "package",     "private",   "property", "protected",
        "public",    "reified",     "return",    "sealed",   "set",
        "super",     "suspend",     "tailrec",   "this",     "throw",
        "true",      "try",         "typealias", "val",      "value",
        "var",       "vararg",      "when",      "where",    "while",
    };
    std::copy(std::cbegin(K), std::cend(K), std::back_inserter(keys));

    // Kotlin built-in types
    string T[] = {
        "Any",
        "Array",
        "Boolean",
        "BooleanArray",
        "Byte",
        "ByteArray",
        "Char",
        "CharArray",
        "Collection",
        "Comparable",
        "Double",
        "DoubleArray",
        "Float",
        "FloatArray",
        "Int",
        "IntArray",
        "Iterable",
        "Iterator",
        "List",
        "Long",
        "LongArray",
        "Map",
        "MutableCollection",
        "MutableIterable",
        "MutableIterator",
        "MutableList",
        "MutableMap",
        "MutableSet",
        "Nothing",
        "Number",
        "Pair",
        "Sequence",
        "Set",
        "Short",
        "ShortArray",
        "String",
        "Triple",
        "Unit",
    };
    std::copy(std::cbegin(T), std::cend(T), std::back_inserter(types));
}
