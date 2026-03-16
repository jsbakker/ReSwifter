// langxml.h

// the XML Language definition file for Web C Plus Plus
// Webcpp Copyright (C) 2002 Jeffrey Bakker

#ifndef LANG_XML_DEF_H
#define LANG_XML_DEF_H

#include "engine.h"

class LangXML: public Engine {

 public:
	LangXML();
	virtual ~LangXML() {IO->close();}

	virtual void fill();
};

#endif  // LANG_XML_DEF_H
