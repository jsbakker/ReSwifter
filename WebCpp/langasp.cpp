// the ASP Language definition file for Web C Plus Plus
// Author: Matt Runion <mrunion@yahoo.com>


#include "langasp.h"

LangAsp::LangAsp()  {
	
	fill();
	init_switches();

	//doHtmTags  = Yes;
	//doHtmComnt = Yes;
	doAspComnt = Yes;
	doCaseKeys = No;
}

void LangAsp::fill(){

	// ASP keywords
	string K[] = {
	"and","response","write","case","select","continue","date","dim","server",
	"createobject","do","if","else","end","empty","then","next","set",
	"default","movenext","open","close","activeconnection","false","true","BOF",
	"EOF","each","for","sub","function","len","cstr","include",
	"cdbl","cdate","is","null","object","redirect","request","querystring","exit",
	"clng","redim","session","form","not","nothing","loop","while",

	"public", "let", "boolean", "integer", "property",
	"get", "long", "as", "byval", "byref", "double",
	"event", "private", "enum", "optional", "option",
	"explicit", "on", "error", "goto"

	};
	for(int k=0;k < 71;k++) {keys.push_back(K[k]);}
}
