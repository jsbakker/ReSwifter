// The Go Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#ifndef LANG_DEF_GO
#define LANG_DEF_GO

#include "lang_rules.h"

class LangGo : public LanguageRules {

  public:
    LangGo();
    void initReservedWords() override;
};

#endif // LANG_DEF_GO
