/* webcpp - theme.cpp
 * Copyright (C)2001-2003 Jeffrey Bakker

 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
   ___________________________________ .. .
 */


/*
Finished

Asm
Asp
C
C#
C++
CG
Fortran
HTML
Java
Modula*
Objective C
Pascal
Shell

*/

#include "defsys.h"
#include "theme.h"
#include <cctype>
using namespace std;

// (de)construction -----------------------------------------------------------
Theme::~Theme() {

	close();
}
Theme::Theme()  {

	typical();

	format2 = true;
	snippet = false;
	Picture = "\0";
} //---------------------------------------------------------------------------
// set file -------------------------------------------------------------------
bool Theme::setFile(string filename) {

	SCSfile = filename;

	if(filename.rfind(".Scs2") == -1) {

		if(filename.rfind(".scs") != -1) {
			format2 = false;
		}
		else
		filename += ".Scs2";
	}
	if( openR(filename) ) {

		return load();
	} else {
//		cerr << "...searching default directory.";
		// search in default webcpp data dir
		if(filename.rfind(DIRECTORY_SLASH) == -1)
		{
			filename = WEBCPP_DATA_DIR + filename;

			if(openR(filename))
			{
				return load();
			}
		}
	}
	return false;
}
// set background picture -----------------------------------------------------
void Theme::setPicture(string picture) {

	Picture = picture;
}
// get the name of the theme --------------------------------------------------
string Theme::getThemeName() {

	string justTheName;
	int i_dir, i_ext;

	i_dir = SCSfile.rfind(DIRECTORY_SLASH);
	if(i_dir != -1)
	{
		justTheName = SCSfile.substr(i_dir +1);
	} else {
		justTheName = SCSfile;
	}
	i_ext = justTheName.rfind(".");
	if(i_ext != -1)
	{
		justTheName = justTheName.substr(0,i_ext);
	}

	return justTheName;
}
// get background picture -----------------------------------------------------
string Theme::getImageFile() {

	return Picture;
}
// strip pathname from image file for copying ---------------------------------
void Theme::setImageLeaf() {

	string ImgLeaf, Path;

	int dir_idx = Picture.rfind(DIRECTORY_SLASH);

	if(dir_idx != -1) {

		Path = Picture.substr(0,dir_idx+1);
		ImgLeaf = Picture.substr(dir_idx+1);

		Picture = ImgLeaf;
	}
}
// loading a theme ------------------------------------------------------------
bool Theme::load() {

	// load an Scs2-format file
	if(format2) {

		string     Scs2buf;
		CFdatapair ScsXml;

		// check for xml tag
		getline(ifile,Scs2buf);
		if(Scs2buf.find("<?xml version=\"1.0\"") == -1)
		{return false;}
		// check for the document type
		getline(ifile,Scs2buf);
		if(Scs2buf.find("<!DOCTYPE SyntaxColourScheme2") == -1)
		{return false;}
		// check for Scs2 data section
		getline(ifile,Scs2buf);
		if(Scs2buf.find("<SyntaxColourScheme2>") == -1)
		{return false;}

		// load the Scs2 data which may be in random order
		getline(ifile,Scs2buf);
		while(ifile) {

//			cerr << "\nScs2: " << Scs2buf << endl;

			ScsXml << Scs2buf;
			ScsVec.push_back(Scs2buf);
			getline(ifile,Scs2buf);
		}

//		for(int j=0; j < ScsVec.size(); j++) {

//			cerr << endl << ScsVec[j].info_nv() << endl;
//		}

		// sort the Scs2 data
		Colours2[BGCOLOR] = getColour("bgcolor");
		Colours2[PREPROC] = getColour("preproc");
		Colours2[NORTEXT] = getColour("nortext");
		Colours2[SYMBOLS] = getColour("symbols");
		Colours2[KEYWORD] = getColour("keyword");
		Colours2[KEYTYPE] = getColour("keytype");
		Colours2[INTEGER] = getColour("integer");
		Colours2[FLOATPT] = getColour("floatpt");
		Colours2[DBLQUOT] = getColour("dblquot");
		Colours2[SINQUOT] = getColour("sinquot");
		Colours2[COMMENT] = getColour("comment");
		// use a background image, if found
		Picture = getColour("background");

		// check the format of all the colours
		for(int i=BGCOLOR; i <= COMMENT; i++) {

			if(Colours2[i] == "\0") {
				typical();
				return false;
			}

			if(Colours2[i][0] != '#') {
				Colours2[i].insert(0,"#");
			}

			// verify data is in the right format
			if(!verifyFormat(Colours2[i])) {
				typical();
				return false;
			}
			// if not, use the defulat scheme
		}
		return true;
	}
	// load an original SCS-format file
	for(int i=BGCOLOR; i <= COMMENT; i++) {

		ifile >> Colours2[i];

		// convert old Scs to Scs2 format
		if(i == NORTEXT) {
                	Colours2[SYMBOLS] = Colours2[NORTEXT];
			i++;
		}
		else
		if(i == KEYWORD) {
                	Colours2[KEYTYPE] = Colours2[KEYWORD];
			i++;
		}
		else
		if(i == INTEGER) {
                	Colours2[FLOATPT] = Colours2[INTEGER];
			i++;
		}
		else
		if(i == DBLQUOT) {
                	Colours2[SINQUOT] = Colours2[DBLQUOT];
			i++;
		}
		// they will look exactly the same as the old style

		if(!verifyFormat(Colours2[i])) {
			typical();
			return false;
		}
	}
	return true;
}


string	Theme::getColour(string Name) {

	for(int i=0; i < ScsVec.size(); i++) {

		if(ScsVec[i].getname() == Name)
			return ScsVec[i].getvalue();
	}
//	cerr << "\nScs2: " << Name << " was not found!\n";
	return "\0";
}
// write a stylesheet ---------------------------------------------------------
bool Theme::writeCSS(string cssfile) {

	if(!openW(cssfile,true)) {return false;}
	ofile << getCSSdata();
	closeW();
	return true;
}
// set a colour in the theme --------------------------------------------------
void Theme::setColour(string colour, int num) {

	Colours2[num] = colour;
}
// set default theme ----------------------------------------------------------
void Theme::typical() {

	SCSfile = "typical";

	setColour("#ffffff",BGCOLOR);
	setColour("#a900a9",PREPROC); //a900a9
	setColour("#000000",NORTEXT);
	setColour("#0077dd",SYMBOLS);
	setColour("#224fff",KEYWORD);
	setColour("#ff9933",KEYTYPE); //224fff  //ff9933
	setColour("#ff0032",INTEGER);
	setColour("#ff23a6",FLOATPT);
	setColour("#00b800",DBLQUOT);
	setColour("#00b86b",SINQUOT);
	setColour("#666666",COMMENT);
}
// enforces proper colour format ----------------------------------------------
bool Theme::verifyFormat(string hexData) {

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
	for (int i=1; i < 7; i++) {hexData[i] = toupper(hexData[i]);}

	// enforce range from #000000 to #FFFFFF
	for (int j=1; j < 7; j++) {

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
string Theme::getCSSdata() {

	string CSS;

	CSS =

"/*\nWebcpp v0.8.1 compatible StyleSheet\nhttp://webcpp.sf.net\n"
"Theme: "  +  getThemeName()  + "\n*/\n\n" +
+ ( (snippet) ? "div.webcpp" : "body" ) +
"\n{\nbackground-color: "  + Colours2[BGCOLOR] +
//";\nalign: center;\n"
//"color: " + Colours2[COMMENT] + // ";\nborder: solid" +
( (Picture == "\0")
? "\n}\n\n": ";\nbackground-image: url(\"" + Picture +
"\");\nbackground-attachment: fixed\n}\n\n" ) +

".webcpp a:link    {color:" + Colours2[DBLQUOT] + "}\n"
".webcpp a:visited {color:" + Colours2[COMMENT] + "}\n"
".webcpp a:active  {color:" + Colours2[KEYWORD] + "}\n"
".webcpp a:hover   {color:" + Colours2[PREPROC] + "}\n\n"
".webcpp pre\n{\ncolor: "   + Colours2[NORTEXT] + "\n}\n\n"
".webcpp font\n{\nfont-size:100%\n}\n\n"
".webcpp .symbols\n{\ncolor: " + Colours2[SYMBOLS] + "\n}\n\n"
".webcpp .preproc\n{\ncolor: " + Colours2[PREPROC] + "\n}\n\n"
".webcpp .integer\n{\ncolor: " + Colours2[INTEGER] + "\n}\n\n"
".webcpp .floatpt\n{\ncolor: " + Colours2[FLOATPT] + "\n}\n\n"
".webcpp .dblquot\n{\ncolor: " + Colours2[DBLQUOT] + "\n}\n\n"
".webcpp .sinquot\n{\ncolor: " + Colours2[SINQUOT] + "\n}\n\n"
".webcpp .keyword\n{\ncolor: " + Colours2[KEYWORD] + ";\nfont-weight: bold\n}\n\n"
".webcpp .keytype\n{\ncolor: " + Colours2[KEYTYPE] + ";\nfont-weight: bold\n}\n\n"
".webcpp .comment\n{\ncolor: " + Colours2[COMMENT] + ";\nfont-style: italic\n}\n\n";

	return CSS;
}
//-----------------------------------------------------------------------------
