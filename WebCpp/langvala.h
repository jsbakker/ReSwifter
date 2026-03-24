// The Vala Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#ifndef LANG_DEF_VALA
#define LANG_DEF_VALA

#include "lang_rules.h"

class LangVala : public LanguageRules {

  public:
    LangVala();
    void initReservedWords() override;
};

#endif // LANG_DEF_VALA
