// Author: Jeffrey Bakker  |  Date: May14th 2002  |  langpython.cpp

// the Python Language definition file for Web C Plus Plus
// Webcpp Copyright (C) 2002 Jeffrey Bakker

#include "langpython.h"

LangPython::LangPython() {
	
	fill();
	init_switches();

	doSymbols  = Yes;
	doUnxComnt = Yes;
}

void LangPython::fill() {

	string K[] = {
	"and","assert","break","class","continue","def","del","elif","else","except",
	"exec","finally","for","from","global","if","import","input","in","is",
	"lambda","not","or","pass","print","raise","range","return","try","while"
	};
	for(int k=0;k < 30;k++) {keys.push_back(K[k]);}
}
