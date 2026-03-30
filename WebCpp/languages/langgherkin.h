// The Gherkin Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#ifndef LANG_DEF_GHERKIN
#define LANG_DEF_GHERKIN

#include "lang_rules.h"

class LangGherkin : public LanguageRules {

  public:
    LangGherkin();
    void initReservedWords() override;
};

#endif // LANG_DEF_GHERKIN
