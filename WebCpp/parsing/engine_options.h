/* webcpp - engine_options.h
 * Copyright (C)2026 Jeffrey Bakker
   ___________________________________ .. .
 */

#pragma once

#include <string>

struct EngineOptions {
    bool bigtab  = false;
    bool htsnip  = false;
    int  tabwidth = 8;
    std::string tw = "8";

    void setTabWidth(const std::string &width);

    void toggleBigtab() { bigtab = !bigtab; }
    void toggleHtSnip() { htsnip = !htsnip; }
};
