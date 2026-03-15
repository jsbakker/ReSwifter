// Author: Jeffrey Bakker  |  Date: January 29th 2003  |  languscript.cpp

// the UnrealScript Language definition file for Web C Plus Plus
// Webcpp Copyright (C) 2003 Jeffrey Bakker

#include "languscript.h"

LangUScript::LangUScript() {

	fill();
	init_switches();

	doCaseKeys  = No;
	doSymbols   = Yes;
	doLabels    = Yes;
	doPreProc   = Yes;
	doBigComnt  = Yes;
	doCinComnt  = Yes;
}

void LangUScript::fill() {

	string K[] = {
"abstract","class","event","expands","extends","foreach","function","global",
"local","None","Self","state","Super","until","var"
	};
	for(int k=0;k < 15;k++) {keys.push_back(K[k]);}

	string T[] = {
"Vector","Plane","Rotation","Coords","Color","Region","Texture",
"actor","bool","byte","name","string",
"config","native","private","transient",

"sound","shader","combiner","material","texpanner","finalblend",
"SkeletalMesh","StaticMesh","Rotator"
	};
	for(int t=0;t < 25;t++) {types.push_back(T[t]);}
}
