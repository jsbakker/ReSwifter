// Author: Jeffrey Bakker  |  Date: May14th 2002  |  langshell.h

// the Bourne shell Syntax definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#ifndef LANG_SHELL_DEF_H
#define LANG_SHELL_DEF_H

#include "lang_rules.h"

class LangShell : public LanguageRules {

  public:
    LangShell();
    void initReservedWords() override;
};

#endif // LANG_SHELL_DEF_H
