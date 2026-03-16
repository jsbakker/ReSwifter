// Author: Jeffrey Bakker  |  Date: May14th 2002  |  langphp.cpp

// the PHP Language definition file for Web C Plus Plus
// Webcpp Copyright (C) 2002 Jeffrey Bakker
// Updated 2025 for modern PHP (PHP 8.4)

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

	// PHP 8.4 keywords
	string K[] = {
		"abstract",
		"and",
		"as",
		"break",
		"case",
		"catch",
		"class",
		"clone",
		"const",
		"continue",
		"declare",
		"default",
		"do",
		"echo",
		"else",
		"elseif",
		"empty",
		"enddeclare",
		"endfor",
		"endforeach",
		"endif",
		"endswitch",
		"endwhile",
		"enum",
		"extends",
		"false",
		"final",
		"finally",
		"fn",
		"for",
		"foreach",
		"function",
		"global",
		"goto",
		"if",
		"implements",
		"include",
		"include_once",
		"instanceof",
		"insteadof",
		"interface",
		"list",
		"match",
		"namespace",
		"new",
		"null",
		"or",
		"print",
		"private",
		"protected",
		"public",
		"readonly",
		"require",
		"require_once",
		"return",
		"static",
		"switch",
		"throw",
		"trait",
		"true",
		"try",
		"unset",
		"use",
		"var",
		"while",
		"xor",
		"yield",
	};
	for(int k=0;k < 67;k++) {keys.push_back(K[k]);}

	// PHP 8.4 built-in types
	string T[] = {
		"array",
		"bool",
		"callable",
		"float",
		"int",
		"iterable",
		"mixed",
		"never",
		"null",
		"object",
		"self",
		"string",
		"void",
	};
	for(int t=0;t < 13;t++) {types.push_back(T[t]);}
}
