// The Objective-C++ Language definition file for Web C Plus Plus
// Copyright (C) 2026 Jeffrey Bakker

#ifndef LANG_DEF_ObjectiveCPP
#define LANG_DEF_ObjectiveCPP

#include "langcpp.h"
#include "langobjc.h"

class LangObjectiveCpp : public LangCPlusPlus, public LangObjectiveC {

  public:
    LangObjectiveCpp();
    virtual ~LangObjectiveCpp() { IO->close(); }
    void fill() override;
};

#endif // LANG_DEF_ObjectiveCPP
