// Author: Jeffrey Bakker  |  Date: May14th 2002  |  langshell.h

// the Bourne shell Syntax definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#ifndef LANG_SHELL_DEF_H
#define LANG_SHELL_DEF_H

#include "engine.h"

class LangShell : public Engine {

  public:
    LangShell();
    virtual ~LangShell() { IO->close(); }
    virtual void fill();
};

#endif // LANG_SHELL_DEF_H
