// The HLSL Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#ifndef LANG_DEF_HLSL
#define LANG_DEF_HLSL

#include "engine.h"

class LangHLSL : public Engine {

 public:
	LangHLSL();
	~LangHLSL() {IO->close();}
	virtual void fill();
};

#endif //LANG_DEF_HLSL
