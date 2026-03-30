/* webcpp - theme.cpp
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker
   ___________________________________ .. .
 */

#include "theme.h"
#include "defsys.h"
#include <cctype>

namespace {
constexpr int BgColor = 0;
constexpr int PreProc = 1;
constexpr int NorText = 2;
constexpr int Symbols = 3;
constexpr int KeyWord = 4;
constexpr int KeyType = 5;
constexpr int Integer = 6;
constexpr int FloatPt = 7;
constexpr int DblQuot = 8;
constexpr int SinQuot = 9;
constexpr int Comment = 10;
}

using std::cerr;
using std::string;

// (de)construction -----------------------------------------------------------
Theme::~Theme() { close(); }
Theme::Theme() {

    typical();

    format2 = true;
    snippet = false;
    Picture = "\0";
} //---------------------------------------------------------------------------
// set file -------------------------------------------------------------------
bool Theme::setFile(string filename) {

    SCSfile = filename;

    if (filename.rfind(".Scs2") == string::npos) {

        if (filename.rfind(".scs") != string::npos) {
            format2 = false;
        } else
            filename += ".Scs2";
    }
    if (openR(filename)) {

        return load();
    } else {
        // cerr << "...searching default directory.";
        // search in default webcpp data dir
        if (filename.rfind(DIRECTORY_SLASH) == string::npos) {
            filename = WEBCPP_DATA_DIR + filename;

            if (openR(filename)) {
                return load();
            }
        }
    }
    return false;
}
// set background picture -----------------------------------------------------
void Theme::setPicture(const string &picture) { Picture = picture; }
// get the name of the theme --------------------------------------------------
string Theme::getThemeName() const {

    string justTheName;
    int i_dir, i_ext;

    i_dir = static_cast<int>(SCSfile.rfind(DIRECTORY_SLASH));
    if (i_dir != -1) {
        justTheName = SCSfile.substr(i_dir + 1);
    } else {
        justTheName = SCSfile;
    }
    i_ext = static_cast<int>(justTheName.rfind("."));
    if (i_ext != -1) {
        justTheName = justTheName.substr(0, i_ext);
    }

    return justTheName;
}
// get background picture -----------------------------------------------------
string Theme::getImageFile() const { return Picture; }
// strip pathname from image file for copying ---------------------------------
void Theme::setImageLeaf() {

    string ImgLeaf, Path;

    int dir_idx = static_cast<int>(Picture.rfind(DIRECTORY_SLASH));

    if (dir_idx != -1) {

        Path = Picture.substr(0, dir_idx + 1);
        ImgLeaf = Picture.substr(dir_idx + 1);

        Picture = ImgLeaf;
    }
}
// loading a theme ------------------------------------------------------------
bool Theme::load() {

    // load an Scs2-format file
    if (format2) {

        string Scs2buf;
        CFdatapair ScsXml;

        // check for xml tag
        getline(ifile, Scs2buf);
        if (Scs2buf.find("<?xml version=\"1.0\"") == -1) {
            return false;
        }
        // check for the document type
        getline(ifile, Scs2buf);
        if (Scs2buf.find("<!DOCTYPE SyntaxColourScheme2") == -1) {
            return false;
        }
        // check for Scs2 data section
        getline(ifile, Scs2buf);
        if (Scs2buf.find("<SyntaxColourScheme2>") == -1) {
            return false;
        }

        // load the Scs2 data which may be in random order
        getline(ifile, Scs2buf);
        while (ifile) {

            //			cerr << "\nScs2: " << Scs2buf << endl;

            ScsXml << Scs2buf;
            ScsVec.push_back(Scs2buf);
            getline(ifile, Scs2buf);
        }

        //		for(int j=0; j < ScsVec.size(); j++) {

        //			cerr << endl << ScsVec[j].info_nv() << endl;
        //		}

        // sort the Scs2 data
        Colours2[BgColor] = getColour("bgcolor");
        Colours2[PreProc] = getColour("preproc");
        Colours2[NorText] = getColour("nortext");
        Colours2[Symbols] = getColour("symbols");
        Colours2[KeyWord] = getColour("keyword");
        Colours2[KeyType] = getColour("keytype");
        Colours2[Integer] = getColour("integer");
        Colours2[FloatPt] = getColour("floatpt");
        Colours2[DblQuot] = getColour("dblquot");
        Colours2[SinQuot] = getColour("sinquot");
        Colours2[Comment] = getColour("comment");
        // use a background image, if found
        Picture = getColour("background");

        // check the format of all the colours
        for (int i = BgColor; i <= Comment; i++) {

            if (Colours2[i] == "\0") {
                typical();
                return false;
            }

            if (Colours2[i][0] != '#') {
                Colours2[i].insert(0, "#");
            }

            // verify data is in the right format
            if (!verifyFormat(Colours2[i])) {
                typical();
                return false;
            }
            // if not, use the defulat scheme
        }
        return true;
    }
    // load an original SCS-format file
    for (int i = BgColor; i <= Comment; i++) {

        ifile >> Colours2[i];

        // convert old Scs to Scs2 format
        if (i == NorText) {
            Colours2[Symbols] = Colours2[NorText];
            i++;
        } else if (i == KeyWord) {
            Colours2[KeyType] = Colours2[KeyWord];
            i++;
        } else if (i == Integer) {
            Colours2[FloatPt] = Colours2[Integer];
            i++;
        } else if (i == DblQuot) {
            Colours2[SinQuot] = Colours2[DblQuot];
            i++;
        }
        // they will look exactly the same as the old style

        if (!verifyFormat(Colours2[i])) {
            typical();
            return false;
        }
    }
    return true;
}

string Theme::getColour(const string &Name) const {

    for (int i = 0; i < static_cast<int>(ScsVec.size()); i++) {

        if (ScsVec[i].getname() == Name)
            return ScsVec[i].getvalue();
    }
    //	cerr << "\nScs2: " << Name << " was not found!\n";
    return "\0";
}
// write a stylesheet ---------------------------------------------------------
bool Theme::writeCSS(const string &cssfile) {

    if (!openW(cssfile, true)) {
        return false;
    }
    ofile << getCSSdata();
    closeW();
    return true;
}
// set a colour in the theme --------------------------------------------------
void Theme::setColour(const string &colour, int num) { Colours2[num] = colour; }
// set default theme ----------------------------------------------------------
void Theme::typical() {

    SCSfile = "typical";

    setColour("#ffffff", BgColor);
    setColour("#a900a9", PreProc); // a900a9
    setColour("#000000", NorText);
    setColour("#0077dd", Symbols);
    setColour("#224fff", KeyWord);
    setColour("#ff9933", KeyType); // 224fff  //ff9933
    setColour("#ff0032", Integer);
    setColour("#ff23a6", FloatPt);
    setColour("#00b800", DblQuot);
    setColour("#00b86b", SinQuot);
    setColour("#666666", Comment);
}
// enforces proper colour format ----------------------------------------------
bool Theme::verifyFormat(string hexData) const {

    // make sure string is the right length
    if (hexData.size() != 7) {
        cerr << hexData << "\a is an invalid colour.\n";
        return false;
    }

    // string must start with '#'
    if (hexData[0] != '#') {
        cerr << hexData << "\a is an invalid colour.\n";
        return false;
    }

    // change string to uppercase
    for (int i = 1; i < 7; i++) {
        hexData[i] = toupper(hexData[i]);
    }

    // enforce range from #000000 to #FFFFFF
    for (int j = 1; j < 7; j++) {

        if (hexData[j] < '0' || hexData[j] > 'F') {
            cerr << hexData << "\a is an invalid colour.\n";
            return false;
        }
        if (ispunct(hexData[j]) || isspace(hexData[j])) {
            cerr << hexData << "\a is an invalid colour.\n";
            return false;
        }
    }

    return true;
} //---------------------------------------------------------------------------
string Theme::getCSSdata() const {

    string CSS;

    CSS =

        "/*\nWebcpp v0.8.1 compatible StyleSheet\nhttp://webcpp.sf.net\n"
        "Theme: " +
        getThemeName() + "\n*/\n\n" + +((snippet) ? "div.webcpp" : "body") +
        "\n{\nbackground-color: " + Colours2[BgColor] +
        //";\nalign: center;\n"
        //"color: " + Colours2[COMMENT] + // ";\nborder: solid" +
        ((Picture == "\0") ? "\n}\n\n"
                           : ";\nbackground-image: url(\"" + Picture +
                                 "\");\nbackground-attachment: fixed\n}\n\n") +

        ".webcpp a:link    {color:" + Colours2[DblQuot] +
        "}\n"
        ".webcpp a:visited {color:" +
        Colours2[Comment] +
        "}\n"
        ".webcpp a:active  {color:" +
        Colours2[KeyWord] +
        "}\n"
        ".webcpp a:hover   {color:" +
        Colours2[PreProc] +
        "}\n\n"
        ".webcpp pre\n{\ncolor: " +
        Colours2[NorText] +
        "\n}\n\n"
        ".webcpp font\n{\nfont-size:100%\n}\n\n"
        ".webcpp .symbols\n{\ncolor: " +
        Colours2[Symbols] +
        "\n}\n\n"
        ".webcpp .preproc\n{\ncolor: " +
        Colours2[PreProc] +
        "\n}\n\n"
        ".webcpp .integer\n{\ncolor: " +
        Colours2[Integer] +
        "\n}\n\n"
        ".webcpp .floatpt\n{\ncolor: " +
        Colours2[FloatPt] +
        "\n}\n\n"
        ".webcpp .dblquot\n{\ncolor: " +
        Colours2[DblQuot] +
        "\n}\n\n"
        ".webcpp .sinquot\n{\ncolor: " +
        Colours2[SinQuot] +
        "\n}\n\n"
        ".webcpp .keyword\n{\ncolor: " +
        Colours2[KeyWord] +
        ";\nfont-weight: bold\n}\n\n"
        ".webcpp .keytype\n{\ncolor: " +
        Colours2[KeyType] +
        ";\nfont-weight: bold\n}\n\n"
        ".webcpp .comment\n{\ncolor: " +
        Colours2[Comment] + ";\nfont-style: italic\n}\n\n";

    return CSS;
}
//-----------------------------------------------------------------------------
