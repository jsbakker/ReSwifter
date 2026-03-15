// Author: Jeffrey Bakker  |  Date May14th 2002  |  langasm.h

// the Assembly Language definition file for Web C Plus Plus
// Webcpp Copyright (C) 2002 Jeffrey Bakker


#ifndef LANG_ASM_DEF_H
#define LANG_ASM_DEF_H

#include "engine.h"

class LangAssembler: public Engine {

 public:
	LangAssembler();
	virtual ~LangAssembler() {IO->close();}
	virtual void fill();

	virtual void setInline() {doCinComnt = true; doBigComnt = true;}
};

#endif // LANG_ASM_DEF_H
