// Author: Jeffrey Bakker  |  Date: January 29th 2003  |  languscript.h

// the UnrealScript Language definition file for Web C Plus Plus
// Webcpp Copyright (C) 2002 Jeffrey Bakker

#ifndef _LANG_UNREALSCRIPT_DEF_H
#define _LANG_UNREALSCRIPT_DEF_H

#include "langc.h"

class LangUScript : public LangC {

  public:
    LangUScript();
    void initReservedWords() override;
};

#endif // _LANG_UNREALSCRIPT_DEF_H
