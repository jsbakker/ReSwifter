/* webcpp - theme.h
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker
   ___________________________________ .. .
 */

#ifndef _THEME_H_
#define _THEME_H_

// use Cfour engines
#include "cfdatapair.h"
#include "cffile.h"

#include <string>
#include <vector>

class Theme : public CFfile {

  public:
    Theme();
    ~Theme();

    bool setFile(std::string filename);
    void toggleSnippet() { snippet = !snippet; }

    std::string getImageFile() const;
    std::string getCSSdata() const;

    void setImageLeaf();

  private:
    void typical();
    void setPicture(const std::string &picture);
    void setColour(const std::string &hexcode, int num);
    bool verifyFormat(std::string data) const;
    std::string getColour(const std::string &name) const;
    std::string getThemeName() const;
    std::string getColourByID(int nColour) const { return Colours2[nColour]; }
    bool writeCSS(const std::string &cssfile);
    bool load();

  protected:
    std::vector<CFdatapair> ScsVec;
    std::string Colours2[11];
    std::string SCSfile;
    std::string Picture;
    bool format2;
    bool snippet;
};

#endif // _THEME_H_
