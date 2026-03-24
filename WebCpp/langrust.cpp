// The Rust Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#include "langrust.h"

#include <algorithm>
#include <iterator>

LangRust::LangRust() {

    fill();
    init_switches();

    doStringsSinQuote = true;
    doSymbols = Yes;
    doUnderscoreNumbers = Yes;
    doBigComnt = Yes; // /* */
    doCinComnt = Yes; // //
    doPreProc = Yes;  // #[attributes] and #![crate-level attributes]
}

void LangRust::fill() {

    // Rust keywords (Rust 2021 edition)
    string K[] = {
        "Self",     "as",     "async", "await",        "break",  "const",
        "continue", "crate",  "do",    "dyn",          "else",   "enum",
        "extern",   "false",  "fn",    "for",          "if",     "impl",
        "in",       "let",    "loop",  "macro_rules!", "match",  "mod",
        "move",     "mut",    "pub",   "ref",          "return", "self",
        "static",   "struct", "super", "trait",        "true",   "type",
        "union",    "unsafe", "use",   "where",        "while",  "yield",
    };
    std::copy(std::cbegin(K), std::cend(K), std::back_inserter(keys));

    // Rust primitive and standard library types
    string T[] = {
        "Arc",    "Box",  "Cell",    "Cow",    "HashMap", "HashSet",
        "Option", "Rc",   "RefCell", "Result", "String",  "Vec",
        "bool",   "char", "f32",     "f64",    "i8",      "i16",
        "i32",    "i64",  "i128",    "isize",  "str",     "u8",
        "u16",    "u32",  "u64",     "u128",   "usize",
    };
    std::copy(std::cbegin(T), std::cend(T), std::back_inserter(types));
}
