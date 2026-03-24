// The Objective-C++ Language definition file for Web C Plus Plus
// Copyright (C) 2026 Jeffrey Bakker

#include "langobjcpp.h"
#include <string>

using std::string;

LangObjectiveCpp::LangObjectiveCpp() {

    // Base class constructors (LangC, LangCPlusPlus, LangObjectiveC) each call
    // their own initReservedWords() and init_switches() during construction, accumulating
    // all keywords and types into the shared vectors. We only need to set the
    // flags.
    doStringsSinQuote = true;
    doSymbols = true;
    doLabels = true;
    doPreProc = true;
    doBigComnt = true;
    doCinComnt = true;
    doRawString = true;
}

void LangObjectiveCpp::initReservedWords() {

    // Resolve the multiple-inheritance ambiguity: both LangCPlusPlus and
    // LangObjectiveC override initReservedWords(). This explicit delegation ensures all
    // keywords and types from the full C / C++ / Objective-C hierarchy are
    // present when initReservedWords() is called directly on this class.
    LangC::initReservedWords();
    LangCPlusPlus::initReservedWords();
    LangObjectiveC::initReservedWords();
}
