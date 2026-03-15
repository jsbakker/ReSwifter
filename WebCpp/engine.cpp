/* webcpp - engine.cpp
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

//--build=i386-linux --host=i386-linux --target=i386-linux

#define CHILD( x , y ) Child=new ( x );\
Child->setLangExt( y )

// uncomment to debug
//#include "defdebug.h"

#include "deflangs.h"
#include "defparse.h"
#include "defsys.h"
#include "engine.h"
#include <cstdlib>
#include <cctype>
using namespace std;


// initialize data members ----------------------------------------------------
void Engine::init_switches() {

	childLang   = false;

	// command line options
	opt_bigtab  = false;
	opt_webcpp  = false;
	opt_hypinc  = false;
	opt_follow  = false;
	opt_number  = false;
	opt_extcss  = false;
	opt_anchor  = false;
	opt_htsnip  = false;

	// abort switches
	inHtmTags   = false;
	inDblQuotes = false;
	inSinQuotes = false;
	inBckQuotes = false;
	inComment   = false;
	endComment  = false;

	// common language
	doStrings   = true;
	doNumbers   = true;
	doKeywords  = true;
	doCaseKeys  = true;
	doSymbols   = false;
	doLabels    = false;
	doPreProc   = false;
	doScalars   = false;
	doArrays    = false;
	doHashes    = false;
	doHtmlTags  = false;
	doHtmComnt  = false;
	doHskComnt  = false;
	doPasComnt  = false;
	doBigComnt  = false;
	doCinComnt  = false;
	doUnxComnt  = false;
	doAsmComnt  = false;
	doRemComnt  = false;
	doAdaComnt  = false;
	doFtnComnt  = false;
	doTclComnt  = false;
	doAspComnt  = false;
	doBatComnt  = false;

	lncount  = 1;
	tabwidth = 8;
	tw = "8";
}
// set the width of the tabs --------------------------------------------------
void Engine::setTabWidth(string width) {

	tabwidth = atoi(width.data());
	if(tabwidth == 0) {
        	tabwidth = 8;
		tw = "8";
	}
	tw = width;
}
// format the plain text for proper display in HTML ---------------------------
void Engine::pre_parse() {

	// the virtual Nth character factoring in for escapes
	int i_esc = 0;

	for (int i=0; i < (int)buffer.size(); i++) {

		// escape from HTML escapes
		if (buffer[i] == '&') {buffer.replace(i,1,"&amp;");i_esc+=4;}
		else
		if (buffer[i] == '<') {buffer.replace(i,1, "&lt;");i_esc+=3;}
		else
		if (buffer[i] == '>') {buffer.replace(i,1, "&gt;");i_esc+=3;}
		// escape from accidental HTML tags

		if (opt_bigtab)
		// convert tabs into spaces
		if (buffer[i] == '\t') {

			int j;
			buffer.erase(i,1);

			// factor in the number of escapes
			if((i-i_esc) % tabwidth == 0) {

				for(j=0; j < tabwidth; j++) {

					buffer.insert(i," ");
				}
				i+=tabwidth-1;
			}else{
				int spaces = tabwidth - ((i-i_esc) % tabwidth);

				for(j=0; j < spaces; j++) {

					buffer.insert(i," ");
				}
				i+=spaces-1;
			}
		}
		// for browsers that don't display tabs properly
	}
}
// erases tags (use for inside of inline comments) ----------------------------
void Engine::eraseTags(int start, int fin) {

	if(fin ==  0) {fin = buffer.size();}
	if(fin == -1) {fin = buffer.size();}

	int erase1, erase2;
	int offset1, offset2;
	string srchstr;

	srchstr = "<font CLASS=";
	offset1 = 20;
	offset2 = 7;

	// erase all the colours previously made
	while(buffer.find(srchstr,start) != -1 &&
	      buffer.find(srchstr,start) < fin) {

		//erasing opening font tags
		erase1 = buffer.find(srchstr,start);
		if(erase1 != -1 && erase1 < fin) {
			buffer.erase(erase1,offset1);
		}
		//erasing closing font tags
		erase2 = buffer.find("</font>",start);
		if(erase2 != -1 && erase2 < fin) {
			buffer.erase(erase2,offset2);
		}
	}
	inDblQuotes = false;
	inSinQuotes = false;
	inBckQuotes = false;
}
// anchors the line (for hyperlinking capabilities) ---------------------------
void Engine::makeAnchor() {

	*IO << "<a name=\"line" << lncount << "\"/>";
}
// prints the line number in the margin ---------------------------------------
void Engine::makeMargin() {

	string space = "";

	// setting margin alignment
	if(lncount < 100000)	{space += " ";}
	if(lncount < 10000)	{space += " ";}
	if(lncount < 1000)	{space += " ";}
	if(lncount < 100)	{space += " ";}
	if(lncount < 10)	{space += " ";}

	*IO	<< space	<< "<font CLASS=comment>"
		<< lncount	<< ":</font> ";
}
//-----------------------------------------------------------------------------
// check if parsing needs to be aborted ---------------------------------------
bool Engine::abortParse() {

//	if(doHtmlTags && inHtmTags)
//			{return true;}

	if(endComment)	{return true;}
	if(inDblQuotes)	{return true;}
	if(!doAspComnt)	{
	if(inSinQuotes)	{return true;}
	}
	if(inBckQuotes)	{return true;}
	if(inComment)	{return true;}

	return false;
}
// check if colouring needs to be aborted -------------------------------------
bool Engine::abortColour(int index) {

	if(doHtmComnt
	&& ( isInsideIt(index,"&lt;","&gt;")
	&&   isInsideIt(index,"&gt;","&lt;") ))	{return true;}
	if(isInsideIt(index,"/*","*/"))		{return true;}
	if(isInsideIt(index,"(*","*)"))		{return true;}
	if(isInsideIt(index,"&lt;!","&gt;"))	{return true;}
	if(isInsideIt(index,"\"","\""))		{return true;}
	if(!doAspComnt) {
		if(isInsideIt(index,"'","'"))	{return true;}
	}
	if(isInsideIt(index,"`","`"))		{return true;}

	return false;
}
// check if the index is inside the specified boundaries ----------------------
bool Engine::isInsideIt(int index, string start, string end) {

	// count the number of starts and ends
	// and return true for an odd number
	
	if(buffer.find(start,0) == string::npos) {return false;}

	int l = 0;
	int r = 0;
	int idx;

	idx = buffer.find(end,index);
	while(idx != (int)string::npos && idx < (int)buffer.size()) {
		if(idx > 0 && buffer[idx-1] != '\\'){r++;}
		else if(idx == 0){r++;}
		idx = buffer.find(end,idx+1);
	}

	idx = buffer.rfind(start,index);
	while(idx >= 0 && idx < (int)buffer.size()) {
		if(idx > 0 && buffer[idx-1] != '\\'){l++;}
		else if(idx == 0){l++;}
		if(idx == 0) break;
		idx = buffer.rfind(start,idx-1);
	}

	if(r % 2 == 1 && l % 2 == 1) {return true;}

	return false;
}
// number accuracy ------------------------------------------------------------
bool Engine::isNotWord(int index) {

	if(isalpha(buffer[index+1]))		{return false;}

	while(index > 0) {

		if(isalpha(buffer[index]))	{return false;}
		if(buffer[index] == '_')	{return false;}
		if(buffer[index] == '#')	{return false;}

		if(ispunct(buffer[index]) ||
		   isspace(buffer[index]))	{return true;}
		index--;
	}
	return true;
}
// parse for preprocessor directives ------------------------------------------
void Engine::parsePreProc() {

	if(abortParse())     {return;}
	if(buffer[0] != '#') {return;}

	if(opt_hypinc) {
		hyperIncludeMe();
	}

	buffer += " ";
	buffer.insert(0, "<font CLASS=preproc>");

	int end;
	for(int i=8;i<buffer.size();i++) {
		if(isspace(buffer[i])) {end = i;i=buffer.size();}
	}
	buffer.insert(end, "</font>");
}
// define symbol characters ---------------------------------------------------
bool Engine::isSymbol(char c) {

	// FIXME: make all symbols work
	// without conflicting with the other parsing
	// the current implementaion is also rather slow
	switch(c) {

//			case '*':
			case '!':
			case '|':
//			case '&':
//			case '<':
//			case '>':
//			case '{':
//			case '}':
//			case '[':
//			case ']':
//			case '(':
//			case ')':
//			case ':':
			case '-':
			case '=':
			case '+': return true;
			default : return false;
	}
}
// parse for symbols ----------------------------------------------------------
void Engine::parseSymbol() {

	// FIXME: make all symbols work
	// without conflicting with the other parsing
	// the current implementaion is also rather slow
	if(abortParse()) {return;}

	int	end;
	int	insert = 0;

	for(int i=0; i < buffer.size(); i++) {

		if(isSymbol(buffer[i])) {

			end = i;
			while(isSymbol(buffer[end+1])) {end++;}

			if(colourSymbol(i,end)) {

				insert += 27;
				i = end + insert;
			}
		}
	}
// currently enabled for:
// C,C++,Cg,C#,Objective C,Java,Perl,PHP,Python,UScript
}
// colour the symbols ---------------------------------------------------------
bool Engine::colourSymbol(int s, int f) {

	if(abortColour(s)) {return false;}
	if(!isNotWord(s))  {return false;}

	buffer.insert(s,"<font CLASS=symbols>");
	buffer.insert(f+21,"</font>");

	return true;
}
// parse labels ---------------------------------------------------------------
void Engine::parseLabel() {

	if(abortParse()) {return;}
	if(buffer.empty()) {return;}

	if(buffer.find("/*") != -1) {return;} //prevent comment loop
	if(buffer.find("(*") != -1) {return;}


	int end, beg;
	
	end = buffer.size()-1;
	beg = buffer.rfind(" ",end);

	if(beg == -1) {beg = 0;}
	if(buffer[end] == ':') {
		colourLabel(beg,end);
	}
}
// colourize the labels -------------------------------------------------------
void Engine::colourLabel(int beg, int end) {

	if(abortColour(beg)) {return;}
	buffer.insert(beg,"<font CLASS=preproc>");
	buffer.insert(end+21,"</font>");
}
//-----------------------------------------------------------------------------
// parse the buffer for numbers -----------------------------------------------
void Engine::parseNum()
{
	if(buffer[0] == '#') {return;}
	if(abortParse())     {return;}

	vector<int>	nums;
	vector<int>	ends;
	int  end, insert;

	// grab indexes of all numbers into the vector
	for(int i=0; i < buffer.size(); i++) {

		if(isdigit(buffer[i]) && !isalpha(buffer[i-1])) {
			end = i;

			while(isdigit(buffer[end+1]) ||
				  (buffer[end+1] == '.'  &&
				  isdigit(buffer[end+2])))
			{end++;}

			nums.push_back(i);
			ends.push_back(end);
			i=end;
		}
	}
	// now colour each number
	for(int j=0; j < (int)ends.size(); j++) {

		if(j == 0) {insert = 0;}
		else       {insert += 27;}

		if(!colourNum(nums[j]+insert, ends[j]+insert)) {
			insert -= 27;
		}
	}

}
// insert number highlighting tags --------------------------------------------
bool Engine::colourNum(int s, int f) {

	if(abortColour(s)) {return false;}
	if(!isNotWord(s))  {return false;}

	string cssclass;
	int fpt;

	fpt = buffer.find(".",s);

	if(fpt != -1 && fpt < f) {

 		cssclass = "<font CLASS=floatpt>";
	} else
        	cssclass = "<font CLASS=integer>";


	// insert the font tags
	buffer.insert(s,	cssclass);
	buffer.insert(f+21,	"</font>");
	
	return true;
}
//-----------------------------------------------------------------------------
// parse the buffer for strings -----------------------------------------------
void Engine::parseString(char quotetype, bool &inside) {

	if(doAdaComnt && !doRemComnt && quotetype == SIN_QUOTES) {return;}
	if(doAspComnt && quotetype == SIN_QUOTES) {return;}

	string quote, escap1, escap2, cssclass;
	int index,offset;
	index = 0;

// Support for 3 different string types
	if       (quotetype == DBL_QUOTES) {	
		if(inSinQuotes || inBckQuotes) {return;}

		quote  = "\"";
		
		// Asp uses single ticks for comments and this
		// screws up if a double-quoted line is commented out
		if (!doAspComnt) {
			escap1 = "'";
		} else {
			escap1 = "`";
		}
		escap2 = "`";

		cssclass = "dblquot";

	} else if(quotetype == SIN_QUOTES) {
		if(inDblQuotes || inBckQuotes) {return;}

		quote  = "'";
		escap1 = "\"";
		escap2 = "`";

		cssclass = "sinquot";

	} else if(quotetype == BCK_QUOTES) {
		if(inDblQuotes || inSinQuotes) {return;}

		quote  = "`";
		escap1 = "\"";
		escap2 = "'";

		cssclass = "preproc";
	}
// Double, single, and back quoted ///


	index = buffer.find(quote,index);
	if(index == -1) {return;}

	while (index < string::npos) {

		if(buffer[index -1] == '\\') {
			if(buffer[index -2] == '\'' && buffer[index +1] == '\'') {
				index = buffer.find(quote,index+1);
			}
		}
		if(index == -1) {return;}

		while(isInsideIt(index,escap1,escap1)){
			index = buffer.find(quote,index +1);
			if(index == -1) {return;}
		}
		while(isInsideIt(index,escap2,escap2)){
			index = buffer.find(quote,index +1);
			if(index == -1) {return;}
		}

		while(doHtmComnt && isInsideIt(index,"&gt;","&lt;") ) {
			index = buffer.find(quote,index +1);
			if(index == -1) {return;}
		}

		// keep escape characters in mind
		while	(buffer[index -1] == '\\' &&
			(buffer[index -2] != '\\' ||
			(buffer[index -3] == '\\' &&
			 buffer[index -4] != '\\'))) {

			index = buffer.find(quote,index +1);
			if(index == -1) {return;}
		}

		if(index != -1 	&& !inComment) {

			colourString(index, inside, cssclass);
		}

		if(inside) {offset = index + 21;}
		else       {offset = index +  7;}

		index = buffer.find(quote,offset);
		if(index == -1)          {return;}
		if(index > buffer.size()){return;}
	}
}
// insert string highlighting tags --------------------------------------------
void Engine::colourString(int index, bool &inside, string cssclass) {

	if(index > buffer.size()){return;}

	string fntag = "<font CLASS=" + cssclass + ">";

	// open tag
	if(!inside) {
		buffer.insert(index,   fntag);
	} else {
		buffer.insert(index+1, "</font>");
	}
	// or close tag
	// depending on whether or not inside

	inside = !inside;
}
// parse for multi-line comments ----------------------------------------------
void Engine::parseBigComment(string start, string end, bool &inside) {

	string search, escap, css;
	int index,offset;
	bool erase;

	index = 0;
	erase = true;
	css = "comment";

	if(inside) {search = end;}
	else {search = start;}
	
	index = buffer.find(search,index);
	if(index == -1) {return;}
	if(doCinComnt && start == "/*" && buffer.find("//") < index) {return;}
	if(doUnxComnt && start == "/*" && buffer.find("#")  < index) {return;}

	if(start == "&lt;" && end == "&gt;" && doHtmlTags) {

		if(buffer.find("&lt;!-") == index || inHtmTags)
			if(!inside)
				return;
		erase = false;
        	css = "preproc";
	}

	while (index < string::npos) {

		if(inside) {search = end;}
		else {search = start;}		

		index = buffer.find(search,index);
		if(index == -1) {return;}

		if(buffer[index -1] == '\\') {
			if(buffer[index -2] == '\'' && buffer[index +1] == '\'') {
				index = buffer.find(search,index+1);
			}
		}
		if(index == -1) {return;}
		if(!isInsideIt(index, "\"", "\"") &&
		   !isInsideIt(index, "'", "'")   &&
		   !isInsideIt(index, "`", "`")) {
			if(inside) {
				index += end.size()-1;
		                if(buffer.find(end) == -1) {endComment = true;}
			}
			else if(erase)eraseTags(index,0);
			colourString(index, inside, css);
		}

		if(inside) {
			offset = index + 21;
			search = end;
		}
		else {
			offset = index +  7;
			search = start;
		}

		index = buffer.find(search,offset);
		if(index == -1)          {return;}
		if(index > buffer.size()){return;}
	}
}
// parse for keywords ---------------------------------------------------------
void Engine::parseKeys() {

	if(buffer[0] == '#') {return;}
	if(abortParse())     {return;}

	int i, index, offset = 20;
	string cmpkey;

	for(i=0; i < (int)keys.size(); i++) {

		cmpkey	= keys[i];
		index	= noCaseFind(cmpkey,0);

		while(index < buffer.size() && index != -1) {

			if(isKey(index-1, (index) + keys[i].size())) {
				colourKeys(index, keys[i], "keyword");
			}
			index = noCaseFind(cmpkey,(index+cmpkey.size()+offset));
		}
	}

	for(i=0; i < (int)types.size(); i++) {

		cmpkey	= types[i];
		index	= noCaseFind(cmpkey,0);

		while(index < buffer.size() && index != -1) {

			if(isKey(index-1, (index) + types[i].size())) {
				colourKeys(index, types[i], "keytype");
			}
			index = noCaseFind(cmpkey,(index+cmpkey.size()+offset));
		}
	}
}
// checks for case sensitive keys ---------------------------------------------
int Engine::noCaseFind(string search, int index) {

	if(doCaseKeys) {
		return buffer.find(search,index);
	}
	if(search == "class") {
		return buffer.find(search,index);
	}

	string tmp;
	tmp = buffer;

	for(int i=0; i < tmp.size(); i++) {
		tmp[i] = toupper(tmp[i]);
	}
	for(int j=0; j < search.size(); j++) {
		search[j] = toupper(search[j]);
	}

	return tmp.find(search,index);
}
// asserts word boundaries for keywords ---------------------------------------
bool Engine::isKey(int before, int after) const {

	bool validBefore = (before < 0);
	bool validAfter  = (after < 0 || after >= (int)buffer.size());

	if(!validBefore) {
		if(buffer[before] == '#')   {return false;}
		if(buffer[before] == '_')   {return false;}
		if(isalnum(buffer[before])) {return false;}
	}
	if(!validAfter) {
		if(buffer[after]  == '_')   {return false;}
		if(isalnum(buffer[after]))  {return false;}
	}

	if(validBefore || ispunct(buffer[before]) || isspace(buffer[before])) {
		if(validAfter || ispunct(buffer[after]) || isspace(buffer[after])) {
			return true;
		}
	}
	return true;
}
// check if index is inside an HTML tag (<...>) ------------------------------
bool Engine::isInsideTag(int index) {

	// search backward for '<' or '>' from the index
	for(int i = index - 1; i >= 0; i--) {
		if(buffer[i] == '>') {return false;}
		if(buffer[i] == '<') {return true;}
	}
	return false;
}
// check if index is inside existing <font ...>...</font> content -----------
static bool isInsideFontTag(const string &buffer, int index) {

	// search backward for </font> or <font — if we find <font...> first,
	// we are inside its content and should not wrap again
	int i = index - 1;
	while(i >= 0) {
		if(buffer[i] == '>') {
			// found a closing '>'; check if this is a <font tag
			int tagStart = buffer.rfind('<', i);
			if(tagStart != (int)string::npos && tagStart >= 0) {
				string tag = buffer.substr(tagStart, i - tagStart + 1);
				if(tag.find("<font ") == 0 || tag.find("<font>") == 0) {
					return true;  // we are inside font content
				}
				if(tag.find("</font>") == 0) {
					return false; // we are past a closed font tag
				}
			}
			i = tagStart - 1;
		} else {
			i--;
		}
	}
	return false;
}
// colourize the keywords -----------------------------------------------------
void Engine::colourKeys(int index, string key, string cssclass) {

	if(isInsideTag(index)) {
		return;
	}
	if(isInsideFontTag(buffer, index)) {
		return;
	}
	if(abortColour(index)) {
		return;
	}
	buffer.insert(index, "<font CLASS=" + cssclass + ">");
	buffer.insert(index+key.size()+20, "</font>");
}
//-----------------------------------------------------------------------------
// parse for variables --------------------------------------------------------
void Engine::parseVariable(string var) {

	int index;
	int test;

	index = buffer.find(var,0);
	test  = buffer.find("#",0);
	if(test != -1 && test < index) {return;}

	while(index < string::npos) {

		if(index != -1) {colourVariable(index);}
		index = buffer.find(var,index +22);
	}
}
// colourize the variables ----------------------------------------------------
void Engine::colourVariable(int index) {

	int end = 0;
	buffer.insert(index, "<font CLASS=preproc>");

	int i = index+21;

	// search for a variable name delimiter
	while(!end && i < buffer.size()) {

		if(!isalnum(buffer[i])) {
			if(buffer[i] == '_')   {i++;}
			if(isspace(buffer[i])) {end = i;}
			if(ispunct(buffer[i])) {end = i;}
			if(buffer[i] ==  '=')  {end = i;}
			if(buffer[i] ==  ',')  {end = i;}
			if(buffer[i] ==  '{')  {end = i;}
			if(buffer[i] ==  '[')  {end = i;}
			if(buffer[i] ==  '(')  {end = i;}
			if(buffer[i] == '\'')  {end = i;}
			if(buffer[i] == '\n')  {end = i;}
		}
		if(i == buffer.size() -1)  {end = i+1;}
		else i++;
	}

	if(end > 0 && buffer[end -1] == '\"')     {end--;}
	if(end > 0 && buffer[end -1] == ')')      {end--;}

	buffer.insert(end, "</font>");
}
//-----------------------------------------------------------------------------
// check for comments ---------------------------------------------------------
void Engine::parseComment(string cmnt) {

  if(inComment) {return;}

	int index = buffer.find(cmnt,0);
	if(index == -1) {return;}

// do not misktake HTML attributes for UNIX comments
	if(cmnt == "#" && index != -1 && index > 0 && buffer[index -1] != '\\') {
		if(index != 0) {
			while(buffer[index -1] == '=' && index < string::npos) {
				index = buffer.find("#",index+1);
			}
		}
	}	
//-----------------------------------------------//

	if(index > 0 && buffer[index -1] == '$')  {return;}
	if(index > 0 && buffer[index -1] == '\\') {return;}

	colourComment(index);
}
// colour an inline comment ---------------------------------------------------
void Engine::colourComment(int index) {

	if(abortColour(index)) {
		return;
	}
	if(doCinComnt) {
		if(buffer.rfind("http:",index) == index -5)	{return;}
		if(buffer.rfind("!DOCTYPE", index) != -1)	{return;}
	}

	// no highlighting inside of comments
	eraseTags(index,0);

	// insert the font tags
	buffer.insert(index, "<font CLASS=comment>");
	buffer.insert(buffer.size(), "</font>");
}
//-----------------------------------------------------------------------------
void Engine::parseCharZeroComment(char zchar) {

	if(buffer[0] == zchar) {colourComment(0);}
}
// here is where the parsing rules apply --------------------------------------
void Engine::doParsing() {

	if(opt_anchor) {
		makeAnchor();
	}
	if(opt_number) {
		makeMargin();
	}

	IO->rline(buffer);

	// preformat HTML escapes
	PRE_PARSE_CODE;

	if(doSymbols) parseSymbol();

#ifdef DEBUG_DO_PARSING
PRINT_DEBUG(0);
#endif

	if(doLabels)   PARSE_LABELS;

	if(doStrings)
	{
		PARSE_DBL_QUO_STRING;
		PARSE_SIN_QUO_STRING;
		PARSE_BCK_QUO_STRING;
	}

#ifdef DEBUG_DO_PARSING
PRINT_DEBUG(1);
#endif

	if(doPreProc)  PARSE_PREPROCESSOR;

	if(doPasComnt) PARSE_PAS_MOD2_COMNT;
	if(doHtmComnt) PARSE_A_MARKUP_COMNT;
	if(doBigComnt) PARSE_CLASSICC_COMNT;
	if(doHskComnt) PARSE_HASKL_98_COMNT;
	if(doHtmlTags) PARSE_HTML_TAGS;

	if(doKeywords) PARSE_KEYWORDS;

#ifdef DEBUG_DO_PARSING
PRINT_DEBUG(2);
#endif

	if(doScalars)  PARSE_SCALAR_VARIABL;
	if(doArrays)   PARSE_ARRAYS_VARIABL;
	if(doHashes)   PARSE_HASHED_VARIABL;

#ifdef DEBUG_DO_PARSING
PRINT_DEBUG(3);
#endif

	if(doNumbers)  PARSE_NUMBERS;

#ifdef DEBUG_DO_PARSING
PRINT_DEBUG(4);
#endif

	if(doAdaComnt) {PARSE_A_ADA_95_COMNT;}
	if(doAspComnt) {PARSE_A_MS_ASP_COMNT;}
	if(doCinComnt) {PARSE_C_INLINE_COMNT;}
	if(doUnxComnt) {PARSE_UNIXHASH_COMNT;}
	if(doAsmComnt) {PARSE_ASSEMBLY_COMNT;}
	if(doBatComnt) {PARSE_DBLCOLON_COMNT;}
	if(doRemComnt) {PARSE_REMINDER_COMNT;}
	if(doFtnComnt) {PARSE_ZFORTRAN_COMNT;}
 	if(doTclComnt) {PARSE_ZEROHASH_COMNT;}

#ifdef DEBUG_DO_PARSING
PRINT_DEBUG(5);
#endif

	hyperTagMe();
	hyperNameMe();
	hyperLinkMe();

#ifdef DEBUG_DO_PARSING
PRINT_DEBUG(6);
#endif

	*IO << buffer << "\n";
	if(!childLang) {parseChildLang();}
	endComment = inComment;

	lncount++;
}
//-----------------------------------------------------------------------------
// write the initial HTML tags ------------------------------------------------
void Engine::begHtml(string name) {

	string gen;
	string style;
	string openht;

	string ImgPath;
	string CssFile;
	string Path;
	int dir_idx;


	gen = "\
<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">\
\n\n<!--\nSyntax highlighting generated by Web C Plus Plus software v0.8.4\n\
Webcpp Copyright (C)2001-2004 Jeffrey Bakker under the GNU GPL\n\
Get webcpp at http://webcpp.sf.net\n-->\n\n";


	if(Scs2.getImageFile() != "\0") {

		string CopyCmd = COPY;

		ImgPath = Scs2.getImageFile();
		dir_idx = IO->getStrOf().rfind(DIRECTORY_SLASH);

		if(dir_idx != -1) {

			Path = IO->getStrOf().substr(0,dir_idx+1);

			Scs2.setImageLeaf();
			CopyCmd += " \"" + ImgPath + "\" \"" + Path + Scs2.getImageFile() + "\"";
			system(CopyCmd.data());
//			IO->backup(ImgPath, Path + Scs2.getImageFile(), true);
		}
	}

	// external or embedded stylesheet
	if(opt_extcss) {

		CssFile = Scs2.getThemeName() + ".css";

		dir_idx = IO->getStrOf().rfind(DIRECTORY_SLASH);

		if(dir_idx != -1) {

			Path = IO->getStrOf().substr(0,dir_idx+1);
			CssFile = Path + CssFile;
		}

		Scs2.writeCSS(CssFile);
//		cerr << endl << CssFile << endl;

		style =
		"<link rel=\"stylesheet\" type=\"text/css\" href=\""
		+ Scs2.getThemeName() + ".css\"/>\n";
	} else {
		style =
		"<style type=\"text/css\">\n\n"
		+ Scs2.getCSSdata() + "</style>\n";
	}

	// html snippet or complete html tags
	if(opt_htsnip) {

		openht = style;
	} else {
		openht =
		"<html>\n<head>\n<title>" + name + "</title>\n"
		+ style + "</head>\n<body>\n\n"; // bgcolor="
//		+ Scs2.getColourByID(BGCOLOR) + ">\n\n";
	}

	if(IO->isOredir()) {

		*IO << "Content-Type: text/html\n\n";  // cgi-ready
	}
	*IO << gen << openht << "<div class=\"webcpp\">\n<pre>\n\n";
}
// write the closing HTML tags ------------------------------------------------
void Engine::endHtml() {

	*IO << "\n\n</pre>\n";
	if(opt_webcpp) {

		string made;
		made = "<center>\n<hr size=4 width=95%>\n<br>\n\
syntax highlighting by<br><br>\n\
<table cellpadding=3 cellspacing=3 bgcolor=#000000><tr>\n\
<td bgcolor=#ff0000><tt><font size=+2 color=#000000>w</font></tt></td>\n\
<td bgcolor=#ffbb00><tt><font size=+2 color=#000000>e</font></tt></td>\n\
<td bgcolor=#ffff00><tt><font size=+2 color=#000000>b</font></tt></td>\n\
<td bgcolor=#00ff00><tt><font size=+2 color=#000000>c</font></tt></td>\n\
<td bgcolor=#0000ff><tt><font size=+2 color=#000000>p</font></tt></td>\n\
<td bgcolor=#bb00ff><tt><font size=+2 color=#000000>p</font></tt></td>\n\
</tr><tr><td colspan=6>\n\
<a href=\"http://webcpp.sf.net\"><center><b>\
<font color=#ffffff>web c plus plus</font></b></center>\n\
</a></td></tr>\n\</table>\n<br>\n</center>";

		*IO << made;
	}
	*IO << "\n</div>\n";
	if(!opt_htsnip) {*IO << "\n\n</body>\n</html>\n";}
}
// place HTML tags without being stripped -------------------------------------
void Engine::hyperTagMe() {

	int index;
	index = buffer.find("TagMe:",0);
	if(index == -1) {return;}
	if(abortColour(index)) {
		return;
	}
	buffer.erase(index,6);

	for(int i=index; i < buffer.size(); i++) {
		if	(buffer.substr(i,4) == "&lt;") buffer.replace(i,4, "<");
		else if	(buffer.substr(i,4) == "&gt;") buffer.replace(i,4, ">");
	}
}
// hyperlink a line of code ---------------------------------------------------
void Engine::hyperLinkMe() {

	int index;
	index = buffer.find("LinkMe:",0);
	if(index == -1) {return;}
	if(abortColour(index)) {
		return;
	}
	string link;
	link = buffer.substr(index+7);
	buffer.erase(index, buffer.size() - index);

	buffer.insert(0, "<a href=\"" + link + "\">");
	buffer += "</a>";
}
// anchor a line of code ------------------------------------------------------
void Engine::hyperNameMe() {

	int index;
	index = buffer.find("NameMe:",0);
	if(index == -1) {return;}
	if(abortColour(index)) {
		return;
	}
	string name;
	name = buffer.substr(index+7);
	buffer.erase(index, buffer.size() - index);

	buffer.insert(0, "<a name=\"" + name + "\">");
	buffer += "</a>";
}
// automatically hyperlink included C/C++ files -------------------------------
void Engine::hyperIncludeMe() {

	int incl, insr;

	incl = buffer.find("#include",0);
	if(incl == -1) {return;}

	insr = buffer.find("\"",incl+1);
	if(insr == -1) {return;}

	string cmd;
	string link;
	link = buffer.substr(insr);
	link = link.substr(0,link.find("\"</font>"));

	if(opt_follow) {
		// follow and process the include file

		string path;

		int dir_idx = IO->getStrIf().rfind(DIRECTORY_SLASH);

		if(dir_idx != -1) {

			path = IO->getStrIf().substr(0,dir_idx+1);
			path = path + link.substr(1);
		} else {
			path = link.substr(1);
		}

		cmd = "webcpp " + path + " -A:f -H";
		// retain switches from the current file
		if(opt_bigtab) {
			cmd += " -t";
			if(tabwidth != 8) {
				cmd += "=";
				cmd += tw;
			}
		}
		if(opt_webcpp) cmd += " -m";
		if(opt_number) cmd += " -l";
		if(opt_anchor) cmd += " -a";
		if(opt_htsnip) cmd += " -s";
		if(opt_extcss) cmd += " -X";

		if(Scs2.getThemeName() != "typical") {
			cmd += " -c=" + Scs2.getThemeName();
		}
		if(Scs2.getImageFile() != "") {
			cmd += " -i=" + Scs2.getImageFile();
		}
		cerr << "\nSuperInclude found " + path + "\n";
		cerr << cmd << "\n";
		system(cmd.data());
	}
	// make the hyperlink
	link = "<a href=" + link + ".html\">";
	buffer.insert(insr, link);
	buffer.insert(buffer.size(),"</a>");
}
//-----------------------------------------------------------------------------
// parse for inline languages -------------------------------------------------
void Engine::parseChildLang() {

//	if(abortParse())     {return;}
//	cerr << "\nNow in parseChildLang()\n";

	switch(langext)
	{
		case CPP_FILE	: PARSE_INLINE_ASM;	break;
		case HTM_FILE	: PARSE_INLINE_JS;	break;
		default		: return;
	}
}
// process an inline child language -------------------------------------------
void Engine::colourChildLang(string beg, string end) {

//	cerr << "\nNow in colourChildLang()\n";

	if(buffer.find(beg) != -1) {

//		cerr << "\nNow in if of colourChildLang()\n";

		Engine *Child;

		switch(langext)
		{
			case CPP_FILE : CHILD(LangAssembler, ASM_FILE); break;
			case HTM_FILE : CHILD(LangJScript,   JSC_FILE); break;
		}
		Child->setupIO(IO);
		Child->setChildLang(true);
		Child->setLineCount(lncount +1);
		if(opt_anchor) {Child->toggleAnchor();}
		if(opt_number) {Child->toggleNumber();}	

		if(langext == CPP_FILE)
			{Child->setInline();}
		if(langext == HTM_FILE && inComment)
			{*IO << "</font>";}

		do {
			Child->doParsing();
//			cerr << endl << Child->getBuffer() << endl;
		} while(Child->getBuffer().find(end) == -1 &&
			(Child->IO->ifile && cin));

		if(langext == HTM_FILE && inComment)
			{*IO << "<font CLASS=comment>";}

		setLineCount(Child->getLineCount() -1);	
	}
}
//-----------------------------------------------------------------------------
