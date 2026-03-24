// Author: Jeffrey Bakker  |  Date: May14th 2002  |  langphp.cpp

// the PHP Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker
// Updated 2026 for modern PHP (PHP 8.4)

#include "langphp.h"

#include <algorithm>
#include <iterator>
#include <string>

using std::string;

LangPhp::LangPhp() {

    initReservedWords();

    doStringsSinQuote = true;
    doStringsBackTick = true;
    doSymbols = true;
    doUnderscoreNumbers = true;
    doScalars = true;
    doBigComnt = true;
    doCinComnt = true;
    doUnxComnt = true;
    doPhpHeredoc = true;
}

void LangPhp::initReservedWords() {

    // PHP 8.4 keywords
    string K[] = {
        "abstract",   "and",       "as",           "break",        "case",
        "catch",      "class",     "clone",        "const",        "continue",
        "declare",    "default",   "do",           "echo",         "else",
        "elseif",     "empty",     "enddeclare",   "endfor",       "endforeach",
        "endif",      "endswitch", "endwhile",     "enum",         "extends",
        "false",      "final",     "finally",      "fn",           "for",
        "foreach",    "function",  "global",       "goto",         "if",
        "implements", "include",   "include_once", "instanceof",   "insteadof",
        "interface",  "list",      "match",        "namespace",    "new",
        "null",       "or",        "print",        "private",      "protected",
        "public",     "readonly",  "require",      "require_once", "return",
        "static",     "switch",    "throw",        "trait",        "true",
        "try",        "unset",     "use",          "var",          "while",
        "xor",        "yield",
    };
    std::copy(std::cbegin(K), std::cend(K), std::back_inserter(keys));

    // PHP 8.4 built-in types
    string T[] = {
        "array", "bool", "callable", "float", "int",    "iterable", "mixed",
        "never", "null", "object",   "self",  "string", "void",
    };
    std::copy(std::cbegin(T), std::cend(T), std::back_inserter(types));
}
