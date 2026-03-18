// The Haskell Language definition file for Web C Plus Plus
// Author: Jeffrey Bakker | Date: May 14th 2002 | langhaskell.h
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker
// Updated 2026 for modern Haskell (GHC 9.x, Haskell 2010)

#ifndef LANG_DEF_Haskell
#define LANG_DEF_Haskell

#include "engine.h"

class LangHaskell : public Engine {

 public:
	LangHaskell();
	~LangHaskell() {IO->close();}
	virtual void fill();

};

#endif //LANG_DEF_Haskell

