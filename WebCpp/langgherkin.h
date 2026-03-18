// The Gherkin Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#ifndef LANG_DEF_GHERKIN
#define LANG_DEF_GHERKIN

#include "engine.h"

class LangGherkin : public Engine {

 public:
	LangGherkin();
	~LangGherkin() {IO->close();}
	virtual void fill();

};

#endif //LANG_DEF_GHERKIN
