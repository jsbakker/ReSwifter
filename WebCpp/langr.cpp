// The R Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#include "langr.h"

#include <algorithm>
#include <iterator>
#include <string>

using std::string;

LangR::LangR() {

    initReservedWords();

    doStringsSinQuote = true;
    doStringsBackTick = false;
    doSymbols = true;
    doUnxComnt = true; // # comments
}

void LangR::initReservedWords() {

    // R language keywords and built-in constants
    string K[] = {
        "FALSE",       "Inf",      "NA",     "NA_character_", "NA_complex_",
        "NA_integer_", "NA_real_", "NaN",    "NULL",          "TRUE",
        "break",       "else",     "for",    "function",      "if",
        "in",          "next",     "repeat", "return",        "while",
    };
    std::copy(std::cbegin(K), std::cend(K), std::back_inserter(keys));

    // R built-in types and common type-related names
    string T[] = {
        "array",       "character",  "complex", "data.frame", "double",
        "environment", "expression", "factor",  "formula",    "integer",
        "list",        "logical",    "matrix",  "numeric",    "raw",
        "tibble",      "vector",
    };
    std::copy(std::cbegin(T), std::cend(T), std::back_inserter(types));
}
