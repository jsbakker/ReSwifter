// The Scala Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#ifndef LANG_DEF_SCALA
#define LANG_DEF_SCALA

#include "lang_rules.h"

class LangScala : public LanguageRules {

  public:
    LangScala();
    void initReservedWords() override;
};

#endif // LANG_DEF_SCALA
