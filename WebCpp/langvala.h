// The Vala Language definition file for Web C Plus Plus

#ifndef LANG_DEF_VALA
#define LANG_DEF_VALA

#include "engine.h"

class LangVala : public Engine {

 public:
	LangVala();
	~LangVala() {IO->close();}
	virtual void fill();
};

#endif //LANG_DEF_VALA
