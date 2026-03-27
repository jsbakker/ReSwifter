// The Scala Language definition file for Web C Plus Plus
// Covers Scala 2 and Scala 3 keywords
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#include "langscala.h"

#include <algorithm>
#include <iterator>
#include <string>

using std::string;

LangScala::LangScala() {

    initReservedWords();

    doStringsSinQuote = true;
    doStringsBackTick = true;
    doSymbols = true;
    doUnderscoreNumbers = true;
    doBlockCommentPLI = true;  // /* */
    doInlineCommentDblSlash = true;  // //
    doMultilineStrTripleDblQuote = true; // """..."""
    // Scala string interpolation: s"text ${expr}" or s"text $name"
    doInterpolate = true;
    interpolStart = "${";
    interpolEnd = '}';
}

void LangScala::initReservedWords() {

    // Scala 2 + Scala 3 keywords
    string K[] = {
        "abstract", "case",        "catch",     "class",     "def",
        "derives",  "do",          "else",      "end",       "enum",
        "export",   "extends",     "extension", "false",     "final",
        "finally",  "for",         "forSome",   "given",     "if",
        "implicit", "import",      "inline",    "lazy",      "match",
        "new",      "null",        "object",    "opaque",    "open",
        "override", "package",     "private",   "protected", "return",
        "sealed",   "super",       "then",      "this",      "throw",
        "trait",    "transparent", "true",      "try",       "type",
        "using",    "val",         "var",       "while",     "with",
        "yield",
    };
    std::copy(std::cbegin(K), std::cend(K), std::back_inserter(keys));

    // Scala built-in and standard library types
    string T[] = {
        "Any",  "AnyRef",   "AnyVal",   "Array",   "Boolean", "Byte",
        "Char", "Double",   "Either",   "Failure", "Float",   "Future",
        "Int",  "Iterable", "Iterator", "Left",    "List",    "Long",
        "Map",  "None",     "Nothing",  "Null",    "Option",  "Right",
        "Seq",  "Set",      "Short",    "Some",    "String",  "Success",
        "Try",  "Tuple2",   "Unit",     "Vector",
    };
    std::copy(std::cbegin(T), std::cend(T), std::back_inserter(types));
}
