// The Kotlin Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#ifndef LANG_DEF_KOTLIN
#define LANG_DEF_KOTLIN

#include "engine.h"

class LangKotlin : public Engine {

 public:
	LangKotlin();
	~LangKotlin() {IO->close();}
	virtual void fill();
};

#endif //LANG_DEF_KOTLIN
