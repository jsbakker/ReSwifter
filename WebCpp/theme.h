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

    void typical();
    bool setFile(std::string filename);
    void setPicture(std::string picture);
    void setColour(std::string hexcode, int num);
    bool verifyFormat(std::string data);
    void toggleSnippet() { snippet = !snippet; }

    std::string getColourByID(int nColour) { return Colours2[nColour]; }
    std::string getColour(std::string name);
    std::string getThemeName();
    std::string getImageFile();
    std::string getCSSdata();

    void setImageLeaf();
    bool writeCSS(std::string cssfile);
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
