// The Zig Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

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
