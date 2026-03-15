// Author: Jeffrey Bakker  |  Date: May14th 2002  |  langjava.cpp

// the Java Language definition file for Web C Plus Plus
// Webcpp Copyright (C) 2002 Jeffrey Bakker


#include "langjava.h"

LangJava::LangJava() {
	
	fill();
	init_switches();

	doSymbols   = Yes;
	doLabels    = Yes;
	doBigComnt  = Yes;
	doCinComnt  = Yes;
}

void LangJava::fill() {

	// add Java keywords --------------------------------------------------
	string K[] = {
		"abstract","break","case","catch","class","const",
		"continue","default","do","else","extends","final","false",
		"for","if","implements","import","instanceof","interface",
		"native","new","null","package","private","protected","public",
		"register","return","super","switch","synchronized","this",
		"true","throws","throw","transient","try","while"
	};
	for(int k=0;k < 38;k++) {keys.push_back(K[k]);}

	string T[] = {
		"boolean","byte","char","double","float","int","long","short",
		"static","void","volatile"
	};
	for(int t=0;t < 11;t++) {types.push_back(T[t]);}
}

