/* webcpp - driver.h
 * Copyright (C)2001-2004, (C)2026 Jeffrey Bakker
   ___________________________________ .. .
 */

#ifndef DRIVER_H
#define DRIVER_H

#define HELP_LANGUAGES 'L'
#define HELP_DEFAULT 'D'

#include <cstdint>
#include <memory>
#include <string>
#include <vector>

class CFfile;
class Engine;

class Driver {
  public:
    Driver();
    ~Driver();
    bool switch_parser(const std::string &arg);
    uint8_t getExt(const std::string &filename) const;
    std::string checkExt(const std::string &filename);
    static void makeIndex(const std::string &prefix);
    bool prep_files(const std::string &ifile, const std::string &ofile, char over);
    std::string getTitle() const;
    void drive();
    std::string highlight_from_string(const std::string &source,
                                      const std::string &filename,
                                      const std::vector<std::string> &options = {});

  private:
    void clean();
    void endio();

  protected:
    std::shared_ptr<CFfile> ObjIO;
    std::unique_ptr<Engine> lang;

    std::string iFile;
    std::string oFile;
};

#endif // DRIVER_H
