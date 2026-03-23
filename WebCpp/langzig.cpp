// The Zig Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#include "langzig.h"

#include <algorithm>
#include <iterator>

LangZig::LangZig() {

    fill();
    init_switches();

    doSymbols = Yes;
    doCinComnt = Yes; // // only — Zig has no block comments
}

void LangZig::fill() {

    // Zig keywords
    string K[] = {
        "addrspace",   "align",
        "allowzero",   "and",
        "anyframe",    "anytype",
        "asm",         "async",
        "await",       "break",
        "callconv",    "catch",
        "comptime",    "const",
        "continue",    "defer",
        "else",        "enum",
        "errdefer",    "error",
        "export",      "extern",
        "false",       "fn",
        "for",         "if",
        "inline",      "linksection",
        "noalias",     "noinline",
        "nosuspend",   "null",
        "opaque",      "or",
        "orelse",      "packed",
        "pub",         "resume",
        "return",      "struct",
        "suspend",     "switch",
        "test",        "threadlocal",
        "true",        "try",
        "undefined",   "union",
        "unreachable", "usingnamespace",
        "var",         "volatile",
        "while",
    };
    std::copy(std::cbegin(K), std::cend(K), std::back_inserter(keys));

    // Zig primitive types
    string T[] = {
        "anyerror",     "anyframe",     "anyopaque",
        "bool",         "c_char",       "c_int",
        "c_long",       "c_longdouble", "c_longlong",
        "c_short",      "c_uint",       "c_ulong",
        "c_ulonglong",  "c_ushort",     "comptime_float",
        "comptime_int", "f16",          "f32",
        "f64",          "f80",          "f128",
        "i8",           "i16",          "i32",
        "i64",          "i128",         "isize",
        "noreturn",     "type",         "u8",
        "u16",          "u32",          "u64",
        "u128",         "usize",        "void",
    };
    std::copy(std::cbegin(T), std::cend(T), std::back_inserter(types));
}
