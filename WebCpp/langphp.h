// Author: Jeffrey Bakker  |  Date: May14th 2002  |  langphp.h

// the PHP Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#ifndef LANG_PHP_DEF_H
#define LANG_PHP_DEF_H

#include "engine.h"

class LangPhp : public Engine {
  public:
    LangPhp();
    void fill() override;
};

#endif // LANG_PHP_DEF_H
