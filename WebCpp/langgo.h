// The Go Language definition file for Web C Plus Plus

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
