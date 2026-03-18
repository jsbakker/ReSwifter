// The Go Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#ifndef LANG_DEF_GO
#define LANG_DEF_GO

#include "engine.h"

class LangGo : public Engine {

 public:
	LangGo();
	~LangGo() {IO->close();}
	virtual void fill();
};

#endif //LANG_DEF_GO
