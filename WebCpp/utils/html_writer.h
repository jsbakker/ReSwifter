/* webcpp - html_writer.h
 * Copyright (C)2026 Jeffrey Bakker
   ___________________________________ .. .
 */

#pragma once

#include <memory>
#include <string>

class CFfile;
class Theme;
struct EngineOptions;

class HtmlWriter {
  public:
    static void writeDocumentStart(std::shared_ptr<CFfile> io, Theme &theme,
                                   const EngineOptions &options,
                                   const std::string &name);
    static void writeDocumentEnd(std::shared_ptr<CFfile> io,
                                 const EngineOptions &options);
    static void writeMargin(std::shared_ptr<CFfile> io, int lineCount);
    static void writeAnchor(std::shared_ptr<CFfile> io, int lineCount);
};
