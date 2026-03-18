// Author: Jeffrey Bakker  |  Date: May14th 2002  |  langcpp.cpp

// the C++ Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#include "langcpp.h"

#include <algorithm>
#include <iterator>

LangCPlusPlus::LangCPlusPlus() {

	fill();
	init_switches();

	doSymbols   = Yes;
	doLabels    = Yes;
	doPreProc   = Yes;
	doBigComnt  = Yes;
	doCinComnt  = Yes;
	doRawString = Yes;
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
    std::copy(std::cbegin(K), std::cend(K), std::back_inserter(keys));

	// C++ types (C++98 through C++23)
	string T[] = {
		"bool",
		"char8_t",
		"char16_t",
		"char32_t",
		"mutable",
		"wchar_t",
	};
    std::copy(std::cbegin(T), std::cend(T), std::back_inserter(types));
}
