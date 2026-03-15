// Author: Jeffrey Bakker  |  Date: May14th 2002  |  langphp.cpp

// the PHP Language definition file for Web C Plus Plus
// Webcpp Copyright (C) 2002 Jeffrey Bakker

#include "langphp.h"

LangPhp::LangPhp()  {
	
	fill();
	init_switches();

	doSymbols  = Yes;
	doScalars  = Yes;
	doBigComnt = Yes;
	doCinComnt = Yes;
	doUnxComnt = Yes;
}

void LangPhp::fill(){

	// PHP keywords
	string K[] = {
	"and","array","break","case","class","continue","date","declare","die",
	"double","do","if","elseif","else","empty","endif","endfor","endforeach",
	"endswitch","endwhile","echo","exit","extends","false","fclose","fgets",
	"fopen","foreach","for","fputs","function","global","header","include",
	"int","list","new","NULL","object","print","require","return","static",
	"string","switch","this","ticks","true","unset","var","while"
	};
	for(int k=0;k < 51;k++) {keys.push_back(K[k]);}
}
