// Author: Jeffrey Bakker  |  Date: May14th 2002  |  langpython.cpp

// the Python Language definition file for Web C Plus Plus
// Webcpp Copyright (C) 2002 Jeffrey Bakker
// Updated 2025 for Python 3.14

#include "langpython.h"

LangPython::LangPython() {
	
	fill();
	init_switches();

	doSymbols  = Yes;
	doUnxComnt = Yes;
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
	for(int k=0;k < 48;k++) {keys.push_back(K[k]);}

	// Python 3.14 built-in types and typing module types
	string T[] = {
		"Any",
		"Callable",
		"ClassVar",
		"Final",
		"Generator",
		"Generic",
		"Iterable",
		"Iterator",
		"Literal",
		"Mapping",
		"Never",
		"NoReturn",
		"Optional",
		"Protocol",
		"Self",
		"Sequence",
		"TypeAlias",
		"TypeGuard",
		"TypeVar",
		"Union",
		"bool",
		"bytearray",
		"bytes",
		"complex",
		"dict",
		"float",
		"frozenset",
		"int",
		"list",
		"memoryview",
		"object",
		"range",
		"set",
		"str",
		"tuple",
	};
	for(int t=0;t < 35;t++) {types.push_back(T[t]);}
}
