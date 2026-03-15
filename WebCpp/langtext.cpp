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
