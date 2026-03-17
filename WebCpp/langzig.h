// The Zig Language definition file for Web C Plus Plus

#ifndef LANG_DEF_ZIG
#define LANG_DEF_ZIG

#include "engine.h"

class LangZig : public Engine {

 public:
	LangZig();
	~LangZig() {IO->close();}
	virtual void fill();
};

#endif //LANG_DEF_ZIG
