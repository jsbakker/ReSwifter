// The OCaml Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#ifndef LANG_DEF_OCAML
#define LANG_DEF_OCAML

#include "engine.h"

class LangOCaml : public Engine {

  public:
    LangOCaml();
    ~LangOCaml() { IO->close(); }
    virtual void fill();
};

#endif // LANG_DEF_OCAML
