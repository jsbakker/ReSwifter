// The R Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#ifndef LANG_DEF_R
#define LANG_DEF_R

#include "lang_rules.h"

class LangR : public LanguageRules {

  public:
    LangR();
    void initReservedWords() override;
};

#endif // LANG_DEF_R
