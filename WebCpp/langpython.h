// Author: Jeffrey Bakker  |  Date: May14th 2002  |  langpython.h

// the Python Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#ifndef LANG_PYTHON_DEF_H
#define LANG_PYTHON_DEF_H

#include "engine.h"

class LangPython : public Engine {

 public:
	LangPython();
	~LangPython() {IO->close();}

	virtual void fill();
};

#endif  // LANG_PYTHON_DEF_H
