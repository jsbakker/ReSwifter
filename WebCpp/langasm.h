// Author: Jeffrey Bakker  |  Date May14th 2002  |  langasm.h

// the Assembly Language definition file for Web C Plus Plus
// Webcpp Copyright (C) 2002-2026 Jeffrey Bakker
// Updated 2026 for modern x86-64, SSE/AVX/AVX-512, and ARM AArch64/NEON

#ifndef LANG_ASM_DEF_H
#define LANG_ASM_DEF_H

#include "engine.h"

class LangAssembler : public Engine {

  public:
    LangAssembler();
    virtual ~LangAssembler() { IO->close(); }
    virtual void fill();

    virtual void setInline() {
        doCinComnt = true;
        doBigComnt = true;
    }
};

#endif // LANG_ASM_DEF_H
