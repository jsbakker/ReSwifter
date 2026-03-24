// Author: Jeffrey Bakker  |  Date: May14th 2002  |  langc.cpp

// the C Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#include "langc.h"

#include <algorithm>
#include <iterator>
#include <string>

using std::string;

LangC::LangC() {

    initReservedWords();

    doStringsSinQuote = true;
    doSymbols = true;
    doLabels = true;
    doPreProc = true;
    doBigComnt = true;
    doCinComnt = true;
}

void LangC::initReservedWords() {

    string K[] = {"break",  "case",   "const",  "continue", "default", "do",
                  "else",   "enum",   "extern", "for",      "if",      "return",
                  "sizeof", "struct", "switch", "typedef",  "union",   "while"};
    std::copy(std::cbegin(K), std::cend(K), std::back_inserter(keys));

    string T[] = {
        "auto",     "char",     "double",    "float",     "int",
        "int8_t",   "int16_t",  "int32_t",   "int64_t",   "intmax_t",
        "intptr_t", "long",     "ptrdiff_t", "register",  "short",
        "signed",   "size_t",   "ssize_t",   "static",    "uint8_t",
        "uint16_t", "uint32_t", "uint64_t",  "uintmax_t", "uintptr_t",
        "unsigned", "void",     "volatile",
    };
    std::copy(std::cbegin(T), std::cend(T), std::back_inserter(types));
}
