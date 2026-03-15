// Author: Jeffrey Bakker  |  Date: May14th 2002  |  langcpp.cpp

// the C++ Language definition file for Web C Plus Plus
// Webcpp Copyright (C) 2002 Jeffrey Bakker

#include "langcpp.h"

LangCPlusPlus::LangCPlusPlus() {

	fill();
	init_switches();

	doSymbols   = Yes;
	doLabels    = Yes;
	doPreProc   = Yes;
	doBigComnt  = Yes;
	doCinComnt  = Yes;
}

void LangCPlusPlus::fill() {

	// C++ keywords (C++98 through C++23)
	// Note: C keywords are inherited from LangC
	string K[] = {
		"alignas",
		"alignof",
		"asm",
		"catch",
		"class",
		"co_await",
		"co_return",
		"co_yield",
		"concept",
		"const_cast",
		"consteval",
		"constexpr",
		"constinit",
		"decltype",
		"delete",
		"dynamic_cast",
		"explicit",
		"export",
		"false",
		"friend",
		"inline",
		"namespace",
		"new",
		"noexcept",
		"nullptr",
		"operator",
		"private",
		"protected",
		"public",
		"reinterpret_cast",
		"requires",
		"static_assert",
		"static_cast",
		"template",
		"this",
		"thread_local",
		"throw",
		"true",
		"try",
		"typeid",
		"typename",
		"using",
		"virtual",
	};
	for(int k=0;k < 44;k++) {keys.push_back(K[k]);}

	// C++ types (C++98 through C++23)
	string T[] = {
		"bool",
		"char8_t",
		"char16_t",
		"char32_t",
		"mutable",
		"wchar_t",
	};
	for(int t=0;t < 6;t++) {types.push_back(T[t]);}
}
