// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#include "lang_rules.h"

#ifndef _LANG_DEF_TEXT_H
#define _LANG_DEF_TEXT_H

class LangText : public LanguageRules {
  public:
    LangText();
    void initReservedWords() override;
};

#endif // _LANG_DEF_TEXT_H
