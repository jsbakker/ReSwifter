#include "engine.h"

#ifndef _LANG_DEF_TEXT_H
#define _LANG_DEF_TEXT_H

class LangText :public Engine {
 public:
	LangText();
	~LangText() {IO->close();}
	virtual void fill();
};

#endif // _LANG_DEF_TEXT_H
