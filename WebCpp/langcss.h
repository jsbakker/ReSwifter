// langcss.h

// the CSS Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#ifndef LANG_CSS_DEF_H
#define LANG_CSS_DEF_H

#include "engine.h"

class LangCSS: public Engine {

 public:
	LangCSS();
	virtual ~LangCSS() {IO->close();}

	virtual void fill();
};

#endif  // LANG_CSS_DEF_H
