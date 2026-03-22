/* webcpp - defparse.h
 * Copyright (C)2001-2004, (C)2026 Jeffrey Bakker
   ___________________________________ .. .
 */

#ifndef _DEF_PARSE_H
#define _DEF_PARSE_H

/* macros for the parsing engine */

// linline parsing
#define PARSE_INLINE_ASM     colourChildLang("asm", "}")
#define PARSE_INLINE_JS      colourChildLang("&lt;script", "/script")
#define PARSE_INLINE_CSS     colourChildLang("&lt;style", "/style")
// string parsing
#define PARSE_DBL_QUO_STRING parseString(DBL_QUOTES,inDblQuotes)
#define PARSE_SIN_QUO_STRING parseString(SIN_QUOTES,inSinQuotes)
#define PARSE_BCK_QUO_STRING parseString(BCK_QUOTES,inBckQuotes)
// multiline string parsing

#define PARSE_TPL_DBL_STRING parseMultiStr("\"\"\"", "\"\"\"", inMultiStr, "dblquot")

#define PARSE_RAW_CPP_STRING parseMultiStr("R\"(", ")\"", inMultiStr, "dblquot")

#define PARSE_PERCENT_QU_STR parseMultiStr("%Q{", "}", inMultiStr, "dblquot")

#define PARSE_PERCENT_QL_STR parseMultiStr("%q{", "}", inMultiStr, "sinquot")

#define PARSE_HEREDOC_STRING parseHeredoc("&lt;&lt;")

#define PARSE_PHP_HEREDOC    parseHeredoc("&lt;&lt;&lt;")

// multiline comment parsing
#define PARSE_A_MARKUP_COMNT parseBigComment("&lt;!-", "--&gt;", inComment)
#define PARSE_PAS_MOD2_COMNT parseBigComment("(*", "*)", inComment)
#define PARSE_CLASSICC_COMNT parseBigComment("/*", "*/", inComment)
#define PARSE_HASKL_98_COMNT parseBigComment("{-", "-}", inComment)
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
