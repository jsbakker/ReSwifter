// The GLSL Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#ifndef LANG_DEF_GLSL
#define LANG_DEF_GLSL

#include "engine.h"

class LangGLSL : public Engine {

  public:
    LangGLSL();
    void fill() override;
};

#endif // LANG_DEF_GLSL
