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

	string K[] = {
		"asm","catch","class","const_cast","delete","dynamic_cast",
		"explicit","false","friend","inline","namespace","new",
		"operator","private","protected","public","reinterpret_cast",
		"static_cast","template","this","throw","true","try","typeid",
		"typename","using","virtual","wchar_t"
	};
	for(int k=0;k < 28;k++) {keys.push_back(K[k]);}

	string T[] = {
		"bool","mutable"
	};
	for(int t=0;t < 2;t++) {types.push_back(T[t]);}
}
