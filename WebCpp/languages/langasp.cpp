// the ASP Language definition file for Web C Plus Plus
// Author: Matt Runion <mrunion@yahoo.com>

#include "langasp.h"

#include <algorithm>
#include <iterator>
#include <string>

using std::string;

LangAsp::LangAsp() {

    initReservedWords();

    // doHtmTags  = true;
    // doBlockCommentMarkup = true;
    doInlineCommentSingleQuote = true;
    doCaseKeys = false;
}

void LangAsp::initReservedWords() {

    // ASP keywords
    string K[] = {"and",
                  "response",
                  "write",
                  "case",
                  "select",
                  "continue",
                  "date",
                  "dim",
                  "server",
                  "createobject",
                  "do",
                  "if",
                  "else",
                  "end",
                  "empty",
                  "then",
                  "next",
                  "set",
                  "default",
                  "movenext",
                  "open",
                  "close",
                  "activeconnection",
                  "false",
                  "true",
                  "BOF",
                  "EOF",
                  "each",
                  "for",
                  "sub",
                  "function",
                  "len",
                  "cstr",
                  "include",
                  "cdbl",
                  "cdate",
                  "is",
                  "null",
                  "object",
                  "redirect",
                  "request",
                  "querystring",
                  "exit",
                  "clng",
                  "redim",
                  "session",
                  "form",
                  "not",
                  "nothing",
                  "loop",
                  "while",

                  "public",
                  "let",
                  "boolean",
                  "integer",
                  "property",
                  "get",
                  "long",
                  "as",
                  "byval",
                  "byref",
                  "double",
                  "event",
                  "private",
                  "enum",
                  "optional",
                  "option",
                  "explicit",
                  "on",
                  "error",
                  "goto"

    };
    std::copy(std::cbegin(K), std::cend(K), std::back_inserter(keys));
}
