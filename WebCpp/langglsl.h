// The GLSL Language definition file for Web C Plus Plus

#ifndef LANG_DEF_GLSL
#define LANG_DEF_GLSL

#include "engine.h"

class LangGLSL : public Engine {

 public:
	LangGLSL();
	~LangGLSL() {IO->close();}
	virtual void fill();
};

#endif //LANG_DEF_GLSL
