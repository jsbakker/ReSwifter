// Author: Jeffrey Bakker  |  Date: May14th 2002  |  langc.h

// the C Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#ifndef _LANG_C_DEF_H
#define _LANG_C_DEF_H

#include "lang_rules.h"

class LangC : public virtual LanguageRules {

  public:
    LangC();
    void initReservedWords() override;
};

#endif // _LANG_C_DEF_H
