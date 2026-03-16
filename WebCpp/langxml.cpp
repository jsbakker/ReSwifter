// langxml.cpp

// the XML Language definition file for Web C Plus Plus
// Webcpp Copyright (C) 2002 Jeffrey Bakker

#include "langxml.h"

LangXML::LangXML() {

	fill();
	init_switches();

	doNumbers   = Yes;
	doCaseKeys  = Yes;
	doHtmlTags  = Yes;
	doHtmComnt  = Yes;
}

void LangXML::fill() {

	// XML declarations and processing instructions
	string K[] = {
		"?xml",
		"!DOCTYPE",
		"!ELEMENT",
		"!ATTLIST",
		"!ENTITY",
		"!NOTATION",
		"![CDATA[",
		"![INCLUDE[",
		"![IGNORE[",
	};
	for(int k=0;k < 9;k++) {keys.push_back(K[k]);}

	// XML common attributes
	string T[] = {
		"encoding",
		"standalone",
		"version",
		"xml:lang",
		"xml:space",
		"xmlns",
	};
	for(int t=0;t < 6;t++) {types.push_back(T[t]);}
}
