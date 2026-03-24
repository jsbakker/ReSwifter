// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#include "langtext.h"

LangText::LangText() {

    initReservedWords();

    doStringsDblQuote = false;
    doNumbers = false;
    doKeywords = false;
    //	doCaseKeys  = false;
    doRemComnt = false;
}

void LangText::initReservedWords() {
    // no keywords
}
