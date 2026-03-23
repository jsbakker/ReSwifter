// Author: Jeffrey Bakker  |  Date: May14th 2002  |  langjava.h

// the Java Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#ifndef LANG_JAVA_DEF_H
#define LANG_JAVA_DEF_H

#include "engine.h"

class LangJava : public Engine {

  public:
    LangJava();
    virtual ~LangJava() { IO->close(); }
    virtual void fill();
};

#endif // LANG_JAVA_DEF_H
