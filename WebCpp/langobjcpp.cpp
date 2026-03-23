// The Objective-C++ Language definition file for Web C Plus Plus
// Copyright (C) 2026 Jeffrey Bakker

#include "langobjcpp.h"

LangObjectiveCpp::LangObjectiveCpp() {

    // Base class constructors (LangC, LangCPlusPlus, LangObjectiveC) each call
    // their own fill() and init_switches() during construction, accumulating
    // all keywords and types into the shared vectors. We only need to set the
    // flags.
    doStringsSinQuote = true;
    doSymbols = Yes;
    doLabels = Yes;
    doPreProc = Yes;
    doBigComnt = Yes;
    doCinComnt = Yes;
    doRawString = Yes;
}

void LangObjectiveCpp::fill() {

    // Resolve the multiple-inheritance ambiguity: both LangCPlusPlus and
    // LangObjectiveC override fill(). This explicit delegation ensures all
    // keywords and types from the full C / C++ / Objective-C hierarchy are
    // present when fill() is called directly on this class.
    LangC::fill();
    LangCPlusPlus::fill();
    LangObjectiveC::fill();
}
