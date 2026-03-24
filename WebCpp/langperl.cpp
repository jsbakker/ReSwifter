// Author: Jeffrey Bakker  |  Date: May14th 2002  |  langperl.cpp

// the Perl Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker
// Updated 2026 for modern Perl (Perl 5.40)

#include "langperl.h"

#include <algorithm>
#include <iterator>
#include <string>

using std::string;

LangPerl::LangPerl() {

    initReservedWords();

    doStringsSinQuote = true;
    doStringsBackTick = true;
    doSymbols = true;
    doUnderscoreNumbers = true;
    doLabels = true;
    doScalars = true;
    doArrays = true;
    doHashes = true;
    doUnxComnt = true;
    doHeredoc = true;
}

void LangPerl::initReservedWords() {

    // Perl 5.40 keywords
    string K[] = {
        "and",     "bless",   "caller",   "chomp",  "chop",   "chr",
        "class",   "cmp",     "constant", "CORE",   "croak",  "defer",
        "defined", "delete",  "die",      "do",     "dump",   "each",
        "else",    "elsif",   "eq",       "eval",   "exists", "field",
        "for",     "foreach", "ge",       "goto",   "grep",   "gt",
        "if",      "isa",     "join",     "keys",   "last",   "le",
        "local",   "lt",      "map",      "method", "my",     "ne",
        "next",    "no",      "not",      "or",     "our",    "package",
        "pop",     "print",   "printf",   "push",   "redo",   "ref",
        "require", "return",  "reverse",  "say",    "shift",  "sort",
        "splice",  "split",   "state",    "sub",    "try",    "undef",
        "unless",  "unshift", "until",    "use",    "values", "wantarray",
        "warn",    "while",   "xor",
    };
    std::copy(std::cbegin(K), std::cend(K), std::back_inserter(keys));

    // Perl 5.40 built-in functions (filesystem, I/O, system)
    string T[] = {
        "binmode",  "catch",   "chdir",  "chmod",   "chown",    "close",
        "closedir", "connect", "exit",   "flock",   "mkdir",    "open",
        "opendir",  "pack",    "read",   "readdir", "rename",   "rewinddir",
        "rmdir",    "seek",    "select", "socket",  "stat",     "sysread",
        "syswrite", "tell",    "tied",   "tie",     "truncate", "unlink",
        "untie",
    };
    std::copy(std::cbegin(T), std::cend(T), std::back_inserter(types));
}
