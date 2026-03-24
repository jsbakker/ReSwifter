// The Scala Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#ifndef LANG_DEF_SCALA
#define LANG_DEF_SCALA

#include "engine.h"

class LangScala : public Engine {

  public:
    LangScala();
    void fill() override;
};

#endif // LANG_DEF_SCALA
