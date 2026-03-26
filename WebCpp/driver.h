/* webcpp - driver.h
 * Copyright (C)2001-2004, (C)2026 Jeffrey Bakker
   ___________________________________ .. .
 */

#ifndef DRIVER_H
#define DRIVER_H

#define HELP_LANGUAGES 'L'
#define HELP_DEFAULT 'D'

#include "defsys.h"
#include "engine.h"

#include <memory>
#include <string>

class Driver {
  public:
    Driver();
    ~Driver();
    static void help(char mode);
    bool switch_parser(std::string arg);
    uint8_t getExt(std::string filename);
    std::string checkExt(std::string filename);
    static void makeIndex(std::string prefix);
    bool prep_files(std::string ifile, std::string ofile, char over);
    std::string getTitle();
    void drive();
    void clean();
    void endio();

  private:
    template <typename T>
    inline std::string setLanguage(uint8_t filetype, std::string val) {
        std::unique_ptr<LanguageRules> rules = std::make_unique<T>();
        lang = std::make_unique<Engine>(std::move(rules));
        lang->setLangExt(filetype);
        return val;
    }

  protected:
    std::shared_ptr<CFfile> ObjIO;
    std::unique_ptr<Engine> lang;

    std::string iFile;
    std::string oFile;
};

#endif // DRIVER_H
