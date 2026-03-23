/* webcpp - theme.h
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker
   ___________________________________ .. .
 */

#ifndef _THEME_H_
#define _THEME_H_

#define BGCOLOR 0
#define PREPROC 1
#define NORTEXT 2
#define SYMBOLS 3
#define KEYWORD 4
#define KEYTYPE 5
#define INTEGER 6
#define FLOATPT 7
#define DBLQUOT 8
#define SINQUOT 9
#define COMMENT 10

// use Cfour engines
#include "cfdatapair.h"
#include "cffile.h"

#include <vector>
using namespace std;

class Theme : public CFfile {

  public:
    Theme();
    ~Theme();

    void typical();
    bool setFile(string filename);
    void setPicture(string picture);
    void setColour(string hexcode, int num);
    bool verifyFormat(string data);
    void toggleSnippet() { snippet = !snippet; }

    string getColourByID(int nColour) { return Colours2[nColour]; }
    string getColour(string name);
    string getThemeName();
    string getImageFile();
    string getCSSdata();

    void setImageLeaf();
    bool writeCSS(string cssfile);
    bool load();

  protected:
    vector<CFdatapair> ScsVec;
    string Colours2[11];
    string SCSfile;
    string Picture;
    bool format2;
    bool snippet;
};

#endif // _THEME_H_
