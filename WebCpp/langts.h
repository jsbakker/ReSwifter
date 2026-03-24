// The TypeScript Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#ifndef LANG_DEF_TS
#define LANG_DEF_TS

#include "lang_rules.h"

class LangTypeScript : public LanguageRules {

  public:
    LangTypeScript();
    void initReservedWords() override;
};

#endif // LANG_DEF_TS
