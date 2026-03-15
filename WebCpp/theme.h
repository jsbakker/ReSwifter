/* webcpp - theme.h
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


#ifndef _THEME_H_
#define _THEME_H_

#define BGCOLOR  0
#define PREPROC  1
#define NORTEXT  2
#define SYMBOLS  3
#define KEYWORD  4
#define KEYTYPE  5
#define INTEGER  6
#define FLOATPT  7
#define DBLQUOT  8
#define SINQUOT  9
#define COMMENT 10

// use Cfour engines
#include "cffile.h"
#include "cfdatapair.h"

#include <vector>
using namespace std;

class Theme : public CFfile {

 public:
	Theme();
	~Theme();

	void	typical();
	bool	setFile(string filename);
	void	setPicture(string picture);
	void	setColour(string hexcode,int num);
	bool	verifyFormat(string data);
	void	toggleSnippet() {snippet = !snippet;}

	string	getColourByID(int nColour) {return Colours2[nColour];}
	string	getColour(string name);
	string	getThemeName();
	string	getImageFile();
	string	getCSSdata();

	void	setImageLeaf();
	bool	writeCSS(string cssfile);
	bool	load();

 protected:
	vector<CFdatapair> ScsVec;
	string	Colours2[11];
	string	SCSfile;
	string	Picture;
	bool	format2;	
	bool	snippet;
};

#endif  // _THEME_H_
