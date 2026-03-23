// Author: Jeffrey Bakker  |  Date: January 29th 2003  |  languscript.cpp

// the UnrealScript Language definition file for Web C Plus Plus
// Webcpp Copyright (C) 2003 Jeffrey Bakker

#include "languscript.h"

#include <algorithm>
#include <iterator>

LangUScript::LangUScript() {

    fill();
    init_switches();

    doStringsSinQuote = true;
    doCaseKeys = No;
    doSymbols = Yes;
    doLabels = Yes;
    doPreProc = Yes;
    doBigComnt = Yes;
    doCinComnt = Yes;
}

void LangUScript::fill() {

    string K[] = {"abstract", "class",    "event",  "expands", "extends",
                  "foreach",  "function", "global", "local",   "None",
                  "Self",     "state",    "Super",  "until",   "var"};
    std::copy(std::cbegin(K), std::cend(K), std::back_inserter(keys));

    string T[] = {"Vector",    "Plane",      "Rotation",     "Coords",
                  "Color",     "Region",     "Texture",      "actor",
                  "bool",      "byte",       "name",         "string",
                  "config",    "native",     "private",      "transient",

                  "sound",     "shader",     "combiner",     "material",
                  "texpanner", "finalblend", "SkeletalMesh", "StaticMesh",
                  "Rotator"};
    std::copy(std::cbegin(T), std::cend(T), std::back_inserter(types));
}
