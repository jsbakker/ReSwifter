// Author: Jeffrey Bakker  |  Date: May14th 2002  |  langpython.h

// the Python Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#ifndef LANG_PYTHON_DEF_H
#define LANG_PYTHON_DEF_H

#include "lang_rules.h"

class LangPython : public LanguageRules {

  public:
    LangPython();
    void initReservedWords() override;
};

#endif // LANG_PYTHON_DEF_H
