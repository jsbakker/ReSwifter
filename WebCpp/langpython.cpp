// Author: Jeffrey Bakker  |  Date: May14th 2002  |  langpython.cpp

// the Python Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker
// Updated 2026 for Python 3.14

#include "langpython.h"

#include <algorithm>
#include <iterator>

LangPython::LangPython() {

    fill();
    init_switches();

    doStringsSinQuote = true;
    doSymbols = Yes;
    doUnderscoreNumbers = Yes;
    doUnxComnt = Yes;
    doTplString = Yes;
    // Python f-strings: f"text {expr}" — applied to all "..." strings
    doInterpolate = true;
    interpolStart = "{";
    interpolEnd = '}';
}

void LangPython::fill() {

    // Python 3.14 keywords
    string K[] = {
        "@abstractmethod",
        "@cache",
        "@cached_property",
        "@classmethod",
        "@dataclass",
        "@final",
        "@overload",
        "@override",
        "@property",
        "@staticmethod",
        "and",
        "as",
        "assert",
        "async",
        "await",
        "break",
        "case",
        "class",
        "continue",
        "def",
        "del",
        "elif",
        "else",
        "except",
        "False",
        "finally",
        "for",
        "from",
        "global",
        "if",
        "import",
        "in",
        "is",
        "lambda",
        "match",
        "None",
        "nonlocal",
        "not",
        "or",
        "pass",
        "raise",
        "return",
        "True",
        "try",
        "type",
        "while",
        "with",
        "yield",
    };
    std::copy(std::cbegin(K), std::cend(K), std::back_inserter(keys));

    // Python 3.14 built-in types and typing module types
    string T[] = {
        "Any",      "Callable",  "ClassVar",  "Final",    "Generator",
        "Generic",  "Iterable",  "Iterator",  "Literal",  "Mapping",
        "Never",    "NoReturn",  "Optional",  "Protocol", "Self",
        "Sequence", "TypeAlias", "TypeGuard", "TypeVar",  "Union",
        "bool",     "bytearray", "bytes",     "complex",  "dict",
        "float",    "frozenset", "int",       "list",     "memoryview",
        "object",   "range",     "set",       "str",      "tuple",
    };
    std::copy(std::cbegin(T), std::cend(T), std::back_inserter(types));
}
