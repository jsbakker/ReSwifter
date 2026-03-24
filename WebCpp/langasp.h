// the ASP Language definition file for Web C Plus Plus
// Author: Matt Runion <mrunion@yahoo.com>

#ifndef LANG_DEF_ASP
#define LANG_DEF_ASP

#include "langhtml.h"

class LangAsp : public LangHtml {
  public:
    LangAsp();
    void initReservedWords() override;
};

#endif // LANG_DEF_ASP
