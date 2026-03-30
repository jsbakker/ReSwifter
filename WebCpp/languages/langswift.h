// The Swift Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#ifndef LANG_DEF_SWIFT
#define LANG_DEF_SWIFT

#include "lang_rules.h"

class LangSwift : public LanguageRules {

  public:
    LangSwift();
    void initReservedWords() override;
};

#endif // LANG_DEF_SWIFT
