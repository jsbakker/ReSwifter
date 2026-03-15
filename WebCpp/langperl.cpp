// Author: Jeffrey Bakker  |  Date: May14th 2002  |  langperl.cpp

// the PERL 5 Language definition file for Web C Plus Plus
// Webcpp Copyright (C) 2002 Jeffrey Bakker

#include "langperl.h"

LangPerl::LangPerl() {
	
	fill();
	init_switches();

	doSymbols  = Yes;
	doLabels   = Yes;
	doScalars  = Yes;
	doArrays   = Yes;
	doHashes   = Yes;
	doUnxComnt = Yes;
}

void LangPerl::fill() {

	// PERL 5 keywords
	string K[] = {
		"and","bless","chdir","chomp","chop","chr","case","delete",
		"die","do","each","else","elsif","exit","foreach","for",
		"function","if","in","join","keys","last","local","my","next",
		"no","null","or","package","pack","printf","print","push",
		"read","redo","require","return","seek","select","shift",
		"splice","split","sub","tell","tied","then","undef","unless",
		"untie","until","use","vars","warn","while","xor"
	};
	for(int k=0;k < 55;k++) {keys.push_back(K[k]);}

	// filesystem operations
	string T[] = {
		"close","closedir","flock","mkdir","open","opendir","readdir",
		"rewinddir","rmdir","unlink"
	};
	for(int t=0;t < 10;t++) {types.push_back(T[t]);}
}

