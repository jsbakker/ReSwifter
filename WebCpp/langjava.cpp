// Author: Jeffrey Bakker  |  Date: May14th 2002  |  langjava.cpp

// the Java Language definition file for Web C Plus Plus
// Webcpp Copyright (C) 2002 Jeffrey Bakker
// Updated 2025 for modern Java (Java 23)

#include "langjava.h"

LangJava::LangJava() {
	
	fill();
	init_switches();

	doSymbols   = Yes;
	doLabels    = Yes;
	doBigComnt  = Yes;
	doCinComnt  = Yes;
}

void LangJava::fill() {

	// Java keywords (Java SE 23)
	string K[] = {
		"@Deprecated",
		"@FunctionalInterface",
		"@Override",
		"@SafeVarargs",
		"@SuppressWarnings",
		"abstract",
		"assert",
		"break",
		"case",
		"catch",
		"class",
		"const",
		"continue",
		"default",
		"do",
		"else",
		"enum",
		"exports",
		"extends",
		"false",
		"final",
		"finally",
		"for",
		"goto",
		"if",
		"implements",
		"import",
		"instanceof",
		"interface",
		"module",
		"native",
		"new",
		"non-sealed",
		"null",
		"open",
		"opens",
		"package",
		"permits",
		"private",
		"protected",
		"provides",
		"public",
		"record",
		"requires",
		"return",
		"sealed",
		"strictfp",
		"super",
		"switch",
		"synchronized",
		"this",
		"throw",
		"throws",
		"to",
		"transient",
		"transitive",
		"true",
		"try",
		"uses",
		"var",
		"void",
		"when",
		"while",
		"with",
		"yield",
	};
	for(int k=0;k < 65;k++) {keys.push_back(K[k]);}

	// Java built-in types (Java SE 23)
	string T[] = {
		"Boolean",
		"Byte",
		"Character",
		"Class",
		"Comparable",
		"Double",
		"Enum",
		"Error",
		"Exception",
		"Float",
		"Integer",
		"Iterable",
		"Long",
		"Number",
		"Object",
		"Optional",
		"Record",
		"Runnable",
		"Short",
		"String",
		"Thread",
		"Throwable",
		"Void",
		"boolean",
		"byte",
		"char",
		"double",
		"float",
		"int",
		"long",
		"short",
		"static",
		"volatile",
	};
	for(int t=0;t < 33;t++) {types.push_back(T[t]);}
}

