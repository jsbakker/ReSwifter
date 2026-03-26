/* webcpp - engine_options.cpp
 * Copyright (C)2026 Jeffrey Bakker
   ___________________________________ .. .
 */

#include "engine_options.h"

#include <cstdlib>

void EngineOptions::setTabWidth(const std::string &width) {

    tabwidth = atoi(width.data());
    if (tabwidth == 0) {
        tabwidth = 8;
        tw = "8";
    }
    tw = width;
}
