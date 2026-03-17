// Author: Jeffrey Bakker  |  Date: May14th 2002  |  langcpp.h

// the C++ Language definition file for Web C Plus Plus
// Webcpp Copyright (C) 2002 Jeffrey Bakker

#ifndef _LANG_CPP_DEF_H
#define _LANG_CPP_DEF_H

#include "langc.h"

class LangCPlusPlus : public virtual LangC {

 public:
	LangCPlusPlus();
	virtual ~LangCPlusPlus() {IO->close();}
    void fill() override;
};

#endif  // _LANG_CPP_DEF_H
