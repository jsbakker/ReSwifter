// Author: Jeffrey Bakker  |  Date: May14th 2002  |  langshell.cpp

// the Bourne shell Syntax definition file for Web C Plus Plus
// Webcpp Copyright (C) 2002 Jeffrey Bakker

#include "langshell.h"

LangShell::LangShell() {
	
	fill();
	init_switches();

	doScalars  = Yes;
	doUnxComnt = Yes;
}

void LangShell::fill() {

	string K[] = {
	// add shell keywords -------------------------------------------------
		"case","done","do","elif","else","esac","exit","for","fi",
		"function","if","in","then","until","while"
	};
	for(int k=0;k < 15;k++) {keys.push_back(K[k]);}

	string T[] = {
	// add UNIX commands --------------------------------------------------
	"alias","ar","awk","bg","cat","cc","cd","chgrp","chmod","clear","cmp",
	"compress","cp","date","dialog","diff","echo","export","fg","find","finger",
	"ftp","g++","gcc","grep","gunzip","gzip","jobs","killall","kill","ln","ls",
	"less","make","merge","mkdir","more","mv","ping","ps","pwd","read","rm",
	"rmdir","sed","set","sort","sleep","tail","tar","test","time","touch",
	"uncompress","wc","which","whoami","who"
	};
	for(int t=0;t < 58;t++) {types.push_back(T[t]);}
}
