/* webcpp - defparse.h
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

#ifndef _DEF_PARSE_H
#define _DEF_PARSE_H

/* macros for the parsing engine */

// linline parsing
#define PARSE_INLINE_ASM     colourChildLang("asm", "}")
#define PARSE_INLINE_JS      colourChildLang("text/javascript", "/script")
// string parsing
#define PARSE_DBL_QUO_STRING parseString(DBL_QUOTES,inDblQuotes)
#define PARSE_SIN_QUO_STRING parseString(SIN_QUOTES,inSinQuotes)
#define PARSE_BCK_QUO_STRING parseString(BCK_QUOTES,inBckQuotes)
// multiline comment parsing
#define PARSE_A_MARKUP_COMNT parseBigComment("&lt;!-", "--&gt;", inComment)
#define PARSE_PAS_MOD2_COMNT parseBigComment("(*", "*)", inComment)
#define PARSE_CLASSICC_COMNT parseBigComment("/*", "*/", inComment)
#define PARSE_HASKL_98_COMNT parseBigComment("{-", "-", inComment)
#define PARSE_HTML_TAGS      parseBigComment("&lt;", "&gt;", inHtmTags)
// single line comment parsing
#define PARSE_A_MS_ASP_COMNT parseComment("'")
#define PARSE_A_ADA_95_COMNT parseComment("--")
#define PARSE_C_INLINE_COMNT parseComment("//")
#define PARSE_UNIXHASH_COMNT parseComment("#")
#define PARSE_ASSEMBLY_COMNT parseComment(";")
#define PARSE_DBLCOLON_COMNT parseComment("::")
#define PARSE_REMINDER_COMNT \
parseComment("REM"); \
parseComment("rem")
// 1st character comment parsing (fortran)
#define PARSE_ZEROHASH_COMNT parseCharZeroComment('#')
#define PARSE_ZFORTRAN_COMNT \
parseCharZeroComment('C'); \
parseCharZeroComment('c'); \
parseCharZeroComment('*'); \
parseCharZeroComment('!')
// variable parsing
#define PARSE_ASSEMBLY_MACRO parseVariable("%")
#define PARSE_SCALAR_VARIABL parseVariable("$")
#define PARSE_ARRAYS_VARIABL parseVariable("@")
#define PARSE_HASHED_VARIABL parseVariable("%")
// misc parsing
#define PRE_PARSE_CODE       pre_parse()
#define PARSE_PREPROCESSOR   parsePreProc()
#define PARSE_LABELS         parseLabel()
#define PARSE_KEYWORDS       parseKeys()
#define PARSE_NUMBERS        parseNum()


#endif //_DEF_PARSE_H
