// The F# Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#ifndef LANG_DEF_FSHARP
#define LANG_DEF_FSHARP

#include "engine.h"

class LangFSharp : public Engine {

 public:
	LangFSharp();
	~LangFSharp() {IO->close();}
	virtual void fill();

};

#endif //LANG_DEF_FSHARP
