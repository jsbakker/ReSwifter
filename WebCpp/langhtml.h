// Author: Jeffrey Bakker  |  Date: May14th 2002  |  langhtml.h

// the HyperText Markup Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#ifndef LANG_HTML_DEF_H
#define LANG_HTML_DEF_H

#include "lang_rules.h"

class LangHtml : public LanguageRules {

  public:
    LangHtml();
    void initReservedWords() override;
};

#endif // LANG_HTML_DEF_H
