// The Gherkin Language definition file for Web C Plus Plus
// Gherkin is the BDD plain-language format used by Cucumber et al.
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#include "langgherkin.h"

#include <algorithm>
#include <iterator>
#include <string>

using std::string;

LangGherkin::LangGherkin() {

    initReservedWords();

    doNumbers = false;
    doScalars = true;
    doUnxComnt = true; // # comments
}

void LangGherkin::initReservedWords() {

    // Gherkin step and structural keywords (Cucumber/SpecFlow/Behave)
    string K[] = {
        "Abstract",  "Ability",  "And",   "Background", "But",  "Example",
        "Examples",  "Feature",  "Given", "Outline",    "Rule", "Scenario",
        "Scenarios", "Template", "Then",  "When",
    };
    std::copy(std::cbegin(K), std::cend(K), std::back_inserter(keys));
}
