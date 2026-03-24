// Author: Jeffrey Bakker  |  Date: May14th 2002  |  langperl.h

// the PERL 5 Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#ifndef LANG_PERL_DEF_H
#define LANG_PERL_DEF_H

#include "engine.h"

class LangPerl : public Engine {

  public:
    LangPerl();
    void fill() override;
};

#endif // LANG_PERL_DEF_H
