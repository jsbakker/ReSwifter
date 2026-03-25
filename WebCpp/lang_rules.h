//
//  lang_rules.h
//  ReSwifter
//
//  Created by Jeffrey Bakker on 2026-03-24.
//

#pragma once

#include <string>
#include <vector>

class Engine;

class LanguageRules {

  public:
    LanguageRules() {
        // Default rules (most common)
        doStringsDblQuote = true;
        doStringsSinQuote = false;
        doStringsBackTick = false;
        doNumbers = true;
        doUnderscoreNumbers = false;
        doKeywords = true;
        doCaseKeys = true;
        doSymbols = false;
        doLabels = false;
        doPreProc = false;
        doScalars = false;
        doArrays = false;
        doHashes = false;
        doHtmlTags = false;
        doHtmComnt = false;
        doHskComnt = false;
        doPasComnt = false;
        doBigComnt = false;
        doCinComnt = false;
        doUnxComnt = false;
        doAsmComnt = false;
        doRemComnt = false;
        doAdaComnt = false;
        doFtnComnt = false;
        doTclComnt = false;
        doAspComnt = false;
        doBatComnt = false;
        doTplString = false;
        doRawString = false;
        doHeredoc = false;
        doPercentQ = false;
        doPhpHeredoc = false;
        doInterpolate = false;
        // Most languages treat an unclosed " or ' at end of line as a syntax
        // error unless a \ immediately precedes the newline.  Set false only
        // for languages where string literals may span lines without any
        // continuation marker (e.g. Ruby, Perl, Shell, PHP, Tcl).
        doRequireBackslashContinuation = true;
        interpolStart = "";
        interpolEnd = '\0';
        interpolCssClass = "dblquot";
    }

    virtual ~LanguageRules() = default;
    virtual void setInline() { }
    virtual void initReservedWords() = 0;

  protected:
    // Rules for highlighting the language
    bool doStringsDblQuote;
    bool doStringsSinQuote;
    bool doStringsBackTick;
    bool doSymbols;
    bool doNumbers;
    bool doUnderscoreNumbers;
    bool doKeywords;
    bool doCaseKeys;
    bool doLabels;
    bool doPreProc;
    bool doScalars;
    bool doArrays;
    bool doHashes;
    bool doHtmlTags;
    bool doCComnt;
    bool doHskComnt;
    bool doHtmComnt;
    bool doPasComnt;
    bool doBigComnt;
    bool doCinComnt;
    bool doAdaComnt;
    bool doUnxComnt;
    bool doAsmComnt;
    bool doRemComnt;
    bool doFtnComnt;
    bool doTclComnt;
    bool doAspComnt;
    bool doBatComnt;
    bool doTplString;
    bool doRawString;
    bool doHeredoc;
    bool doPercentQ;
    bool doPhpHeredoc;
    bool doInterpolate;
    // Most languages treat an unclosed " or ' at end of line as a syntax
    // error unless a \ immediately precedes the newline.  Set false only
    // for languages where string literals may span lines without any
    // continuation marker (e.g. Ruby, Perl, Shell, PHP, Tcl).
    bool doRequireBackslashContinuation;

    std::string interpolCssClass; // CSS class of the string type that interpolates
    std::string interpolStart;    // e.g. "#{" for Ruby, "${" for JS, "\\(" for Swift
    char interpolEnd;             // e.g. '}' or ')'

    std::vector<std::string> keys;
    std::vector<std::string> types;

    friend class Engine;
};
