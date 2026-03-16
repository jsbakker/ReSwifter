/* webcpp - engine.h
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

#ifndef _ENGINE_H
#define _ENGINE_H

#define DBL_QUOTES   0x22
#define SIN_QUOTES   0x27
#define BCK_QUOTES   0x60

#define Yes          true
#define No           false

#include "cffile.h"
#include "theme.h"
#include <vector>
#include <string>
using namespace std;

class Engine {

 public:
	virtual ~Engine() {IO->close();}

	void init_switches();

	void pre_parse();
	void makeMargin();
	void makeAnchor();

	bool abortParse();
	bool abortColour(int index);

	bool isInsideIt(int index, string start, string end);
	bool isInsideTag(int index);
	bool isNotWord(int index);
	void eraseTags(int start, int fin);

	void parsePreProc();

	void parseChildLang();
	void colourChildLang(string beg, string end);

	void parseSymbol();
	bool colourSymbol(int start, int end);
	bool isSymbol(char c);

	void parseLabel();
	void colourLabel(int start, int end);

	void parseNum();
	bool colourNum(int start, int end);

	void parseString(char quotetype, bool &inside);
	void colourString(int   index, bool &inside, string cssclass);

	void parseBigComment(string start, string end, bool &inside);
	void parseBigComment(string start, string end, bool &inside, string css);

	void parseKeys();
	void colourKeys(int index, string key, string cssclass);
	bool isKey(int start, int end) const;
	int  noCaseFind(string search, int index);
	
	void parseVariable(string var);
	void colourVariable(int index);
	
	void parseComment(string cmnt);
	void colourComment(int index);
	void parseCharZeroComment(char zchar);

	void loadKeys();
	void doParsing();

	void begHtml(string name);
	void endHtml();

	void hyperTagMe();
	void hyperLinkMe();
	void hyperNameMe();
	void hyperIncludeMe();
	
	int	getLineCount()	{return lncount;}
	string	getBuffer()	{return buffer;}

	virtual void setInline() {;}
	virtual void fill() = 0;

	inline void setLangExt(int e)    {langext = e;}
	inline void setupIO(CFfile* p)   {IO = p;}
	inline void setLineCount(int c)  {lncount = c;}
	inline void setChildLang(bool b) {childLang = b;}
	
	inline void toggleBigtab() {opt_bigtab = !opt_bigtab;}
	inline void toggleWebcpp() {opt_webcpp = !opt_webcpp;}
	inline void toggleHypinc() {opt_hypinc = !opt_hypinc;}
	inline void toggleFollow() {opt_follow = !opt_follow;}
	inline void toggleAnchor() {opt_anchor = !opt_anchor;}
	inline void toggleNumber() {opt_number = !opt_number;}
	inline void toggleExtcss() {opt_extcss = !opt_extcss;}
	inline void toggleHtSnip() {opt_htsnip = !opt_htsnip;}

	void setTabWidth(string width);

 //options
 protected:
	bool opt_bigtab;
	bool opt_webcpp;
	bool opt_hypinc;
	bool opt_follow;
	bool opt_number;
	bool opt_extcss;
	bool opt_anchor;
	bool opt_htsnip;
	
 //parsing rules
 protected:
	bool doStrings;
	bool doSymbols;
	bool doNumbers;
	bool doKeywords;
	bool doCaseKeys;
	bool doLabels;
	bool doPreProc;
	bool doScalars;
	bool doArrays;
	bool doHashes;
	bool doHtmlTags;
	bool doCComnt;
	bool doHskComnt;
	bool doHtmComnt;
	bool doPasComnt;
	bool doBigComnt;
	bool doCinComnt;
	bool doAdaComnt;
	bool doUnxComnt;
	bool doAsmComnt;
	bool doRemComnt;
	bool doFtnComnt;
	bool doTclComnt;
	bool doAspComnt;
	bool doBatComnt;
	bool doTplString;

 //theme file I/O engine
 public:
	CFfile *IO;
	Theme  Scs2;
//    vector<string> incref;

 //internal data
 protected:
	int langext;
	int lncount;
	int tabwidth;
	string tw;
	string buffer;
	vector<string> keys;
	vector<string> types;
	bool childLang;
	bool inDblQuotes;
	bool inSinQuotes;
	bool inBckQuotes;
	bool inHtmTags;
	bool inComment;
	bool inTplString;
	bool endComment;
};

#endif  // _ENGINE_H
