// The Swift Language definition file for Web C Plus Plus

#ifndef LANG_DEF_SWIFT
#define LANG_DEF_SWIFT

#include "engine.h"

class LangSwift : public Engine {

 public:
	LangSwift();
	~LangSwift() {IO->close();}
	virtual void fill();
};

#endif //LANG_DEF_SWIFT
