// The Kotlin Language definition file for Web C Plus Plus

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
