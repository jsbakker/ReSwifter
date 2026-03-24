// The OCaml Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#include "langocaml.h"

#include <algorithm>
#include <iterator>

LangOCaml::LangOCaml() {

    fill();
    init_switches();

    doStringsSinQuote = true;
    doSymbols = Yes;
    doUnderscoreNumbers = Yes;
    doPasComnt =
        Yes; // (* *) block comments (best approximation; OCaml allows nesting)
}

void LangOCaml::fill() {

    // OCaml reserved keywords (OCaml 5.x)
    string K[] = {
        "and",        "as",       "assert", "asr",     "begin",   "class",
        "constraint", "do",       "done",   "downto",  "else",    "end",
        "exception",  "external", "false",  "for",     "fun",     "function",
        "functor",    "if",       "in",     "include", "inherit", "initializer",
        "land",       "lazy",     "let",    "lor",     "lsl",     "lsr",
        "lxor",       "match",    "method", "mod",     "module",  "mutable",
        "new",        "nonrec",   "object", "of",      "open",    "or",
        "private",    "rec",      "sig",    "struct",  "then",    "to",
        "true",       "try",      "type",   "val",     "virtual", "when",
        "while",      "with",
    };
    std::copy(std::cbegin(K), std::cend(K), std::back_inserter(keys));

    // OCaml built-in types
    string T[] = {
        "bool",      "bytes",  "char",   "exn",    "float",  "format",
        "format6",   "int",    "int32",  "int64",  "lazy_t", "list",
        "nativeint", "option", "result", "string", "unit",
    };
    std::copy(std::cbegin(T), std::cend(T), std::back_inserter(types));
}
