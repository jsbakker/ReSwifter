/* webcpp - lang_factory.h
 * Copyright (C)2026 Jeffrey Bakker
   ___________________________________ .. .
 */

#pragma once

#include <cstdint>
#include <memory>
#include <string>

class LanguageRules;

struct LanguageInfo {
    std::unique_ptr<LanguageRules> rules;
    uint8_t id;
    std::string name;
};

class LanguageFactory {
  public:
    // Detect language from filename extension and create its rules.
    static LanguageInfo createFromFilename(const std::string &filename);

    // Detect language ID from filename extension (without creating rules).
    static uint8_t getLanguageId(const std::string &filename);
};
