// Author: Jeffrey Bakker  |  Date: May14th 2002  |  langasm.cpp

// the Assembler Language definition file for Web C Plus Plus
// Webcpp Copyright (C) 2002 Jeffrey Bakker

#include "langasm.h"

LangAssembler::LangAssembler() {

	fill();
	init_switches();

	doCaseKeys  = No;
	doLabels    = Yes;
	doPreProc   = Yes;
	doBigComnt  = Yes;
	doAsmComnt  = Yes;
}

void LangAssembler::fill() {

	string K[] = {
"aam","aas","adc","add","and","align","assume","bne","bpl","br","call","cmp",
"cbw","clc","cwd","daa","das","db","dd","dec","dq","dt","dup","dw","endp",
"ends","end","equ","far","global","idiv","div","in","inc","int","jae","ja",
"jb","jcxz","jmp","jne","jns","jle","je","jl","jg","jng","jnl","jns","jnz",
"jz","lodsb","local","loop","leave","lea","main","mov","imul","mul","near",
"neg","not","or","org","out","pusha","push","popa","pop","proc","iret","rep",
"ret","rol","seg","section","segment","shld","shl","shr","stosd","stosw",
"sbb","sub","test","xchg","xor",
"addps","movps","mulps","shufps","movss","movaps","movups","xorps"
	};

	for(int k=0;k < 96;k++) {keys.push_back(K[k]);}

	string T[] = {
"ah","al","ax",
"bh","bl","bx",
"ch","cl","cx",
"dh","dl","dx",
"eax","ebx","ecx","edx",
"di","si","esi","edi",
"ss","ds","cs","es",
"mm0","mm1","mm2","mm3",
"mm4","mm5","mm6","mm7",
"xmm0","xmm1","xmm2","xmm3",
"xmm4","xmm5","xmm6","xmm7"
	};
	for(int t=0;t < 40;t++) {types.push_back(T[t]);}
}
