// Author: Jeffrey Bakker  |  Date: May14th 2002  |  langc.cpp

// the C Language definition file for Web C Plus Plus
// Webcpp Copyright (C) 2002 Jeffrey Bakker

#include "langc.h"

LangC::LangC() {

	fill();
	init_switches();

	doSymbols   = Yes;
	doLabels    = Yes;
	doPreProc   = Yes;
	doBigComnt  = Yes;
	doCinComnt  = Yes;
}

void LangC::fill() {

	string K[] = {
		"break","case","const","continue","default","do",
		"else","enum","extern","for","if","return","sizeof",
		"struct","switch","typedef","union","while"
	};
	for(int k=0;k < 18;k++) {keys.push_back(K[k]);}

	string T[] = {
		"auto","char","double","float","int","long","register","short",
		"signed","static","unsigned","void","volatile"
	};
	for(int t=0;t < 13;t++) {types.push_back(T[t]);}
}
