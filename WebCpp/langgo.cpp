// The Go Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#include "langgo.h"

#include <algorithm>
#include <iterator>

LangGo::LangGo() {

	fill();
	init_switches();

	doSymbols  = Yes;
	doBigComnt = Yes;   // /* */
	doCinComnt = Yes;   // //
	// doStrings = true by default; backtick raw strings handled automatically
}

void LangGo::fill() {

	// Go keywords
	string K[] = {
		"break",
		"case",
		"chan",
		"const",
		"continue",
		"default",
		"defer",
		"else",
		"fallthrough",
		"false",
		"for",
		"func",
		"go",
		"goto",
		"if",
		"import",
		"interface",
		"iota",
		"map",
		"nil",
		"package",
		"range",
		"return",
		"select",
		"struct",
		"switch",
		"true",
		"type",
		"var",
	};
    std::copy(std::cbegin(K), std::cend(K), std::back_inserter(keys));

	// Go built-in types
	string T[] = {
		"any",
		"bool",
		"byte",
		"comparable",
		"complex64",
		"complex128",
		"error",
		"float32",
		"float64",
		"int",
		"int8",
		"int16",
		"int32",
		"int64",
		"rune",
		"string",
		"uint",
		"uint8",
		"uint16",
		"uint32",
		"uint64",
		"uintptr",
	};
    std::copy(std::cbegin(T), std::cend(T), std::back_inserter(types));
}
