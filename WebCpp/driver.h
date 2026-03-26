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
    bool switch_parser(const std::string &arg);
    uint8_t getExt(const std::string &filename) const;
    std::string checkExt(const std::string &filename);
    static void makeIndex(const std::string &prefix);
    bool prep_files(const std::string &ifile, const std::string &ofile, char over);
    std::string getTitle() const;
    void drive();
    void clean();
    void endio();

  private:
    template <typename T>
    inline std::string setLanguage(uint8_t filetype, const std::string &val) {
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
