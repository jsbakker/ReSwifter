// langxml.cpp

// the XML Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#include "langxml.h"

#include <algorithm>
#include <iterator>

LangXML::LangXML() {

    fill();
    init_switches();

    doNumbers = Yes;
    doCaseKeys = Yes;
    doHtmlTags = Yes;
    doHtmComnt = Yes;
}

void LangXML::fill() {

    // XML declarations and processing instructions
    string K[] = {
        "?xml",      "!DOCTYPE", "!ELEMENT",   "!ATTLIST",  "!ENTITY",
        "!NOTATION", "![CDATA[", "![INCLUDE[", "![IGNORE[",
    };
    std::copy(std::cbegin(K), std::cend(K), std::back_inserter(keys));

    // XML common attributes
    string T[] = {
        "encoding", "standalone", "version", "xml:lang", "xml:space", "xmlns",
    };
    std::copy(std::cbegin(T), std::cend(T), std::back_inserter(types));
}
