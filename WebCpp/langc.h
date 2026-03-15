// Author: Jeffrey Bakker  |  Date: May14th 2002  |  langc.h

// the C Language definition file for Web C Plus Plus
// Webcpp Copyright (C) 2002 Jeffrey Bakker


#ifndef _LANG_C_DEF_H
#define _LANG_C_DEF_H

#include "engine.h"

class LangC : public Engine {

 public:
	LangC();
	virtual ~LangC() {IO->close();}
	virtual void fill();
};

#endif  // _LANG_C_DEF_H
