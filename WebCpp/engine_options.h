/* webcpp - engine_options.h
 * Copyright (C)2026 Jeffrey Bakker
   ___________________________________ .. .
 */

#pragma once

#include <string>

struct EngineOptions {
    bool bigtab  = false;
    bool webcpp  = false;
    bool hypinc  = false;
    bool follow  = false;
    bool number  = false;
    bool extcss  = false;
    bool anchor  = false;
    bool htsnip  = false;
    int  tabwidth = 8;
    std::string tw = "8";

    void setTabWidth(const std::string &width);

    void toggleBigtab() { bigtab = !bigtab; }
    void toggleWebcpp() { webcpp = !webcpp; }
    void toggleHypinc() { hypinc = !hypinc; }
    void toggleFollow() { follow = !follow; }
    void toggleAnchor() { anchor = !anchor; }
    void toggleNumber() { number = !number; }
    void toggleExtcss() { extcss = !extcss; }
    void toggleHtSnip() { htsnip = !htsnip; }
};
