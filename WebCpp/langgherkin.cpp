// The Gherkin Language definition file for Web C Plus Plus
// Gherkin is the BDD plain-language format used by Cucumber et al.
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#include "langgherkin.h"

#include <algorithm>
#include <iterator>

LangGherkin::LangGherkin() {

    fill();
    init_switches();

    doNumbers = No;
    doScalars = Yes;
    doUnxComnt = Yes; // # comments
}

void LangGherkin::fill() {

    // Gherkin step and structural keywords (Cucumber/SpecFlow/Behave)
    string K[] = {
        "Abstract",  "Ability",  "And",   "Background", "But",  "Example",
        "Examples",  "Feature",  "Given", "Outline",    "Rule", "Scenario",
        "Scenarios", "Template", "Then",  "When",
    };
    std::copy(std::cbegin(K), std::cend(K), std::back_inserter(keys));
}
