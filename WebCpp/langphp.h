// Author: Jeffrey Bakker  |  Date: May14th 2002  |  langphp.h

// the PHP Language definition file for Web C Plus Plus
// Webcpp Copyright (C) 2002 Jeffrey Bakker

#ifndef LANG_PHP_DEF_H
#define LANG_PHP_DEF_H

#include "engine.h"

class LangPhp :public Engine {
 public:
	LangPhp();
	~LangPhp() {IO->close();}
	virtual void fill();
};

#endif  // LANG_PHP_DEF_H
