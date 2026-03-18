// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#include "langtext.h"

LangText::LangText() {

	init_switches();

	doStrings   = No;
	doNumbers   = No;
	doKeywords  = No;
//	doCaseKeys  = No;
	doRemComnt  = No;
}

void LangText::fill() {
	// no keywords
}
