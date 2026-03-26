/* webcpp - engine.h
 * Copyright (C)2001-2004, (C)2026 Jeffrey Bakker
   ___________________________________ .. .
 */

#ifndef _ENGINE_H
#define _ENGINE_H

#include "cffile.h"
#include "engine_options.h"
#include "theme.h"

class LanguageRules;

#include <memory>
#include <string>

enum class Quote : char {
    Double = 0x22, // '"'
    Single = 0x27, // '''
    Back = 0x60    // '`'
};

struct ParseState {
    bool inDblQuotes  = false;
    bool inSinQuotes  = false;
    bool inBckQuotes  = false;
    bool inHtmTags    = false;
    bool inComment    = false;
    bool inMultiStr   = false;
    bool endMultiLine = false;
    std::string heredocEnd;
};

class Engine {

  public:
    explicit Engine(std::unique_ptr<LanguageRules> rules);
    virtual ~Engine();

    void init_switches();

    void pre_parse();

    bool abortParse() const;
    bool abortColour(int index) const;

    bool isInsideIt(int index, const std::string &start, const std::string &end,
                    bool skipTagged = false) const;
    bool isInsideTag(int index) const;
    bool isNotWord(int index) const;
    void eraseTags(int start, int fin);

    void parsePreProc();

    void parseChildLang();
    void colourChildLang(const std::string &beg, const std::string &end);

    void parseSymbol();
    bool colourSymbol(int start, int end);
    bool isSymbol(char c) const;

    void parseLabel();
    void colourLabel(int start, int end);

    void parseNum();
    bool colourNum(int start, int end);

    void parseString(char quotetype, bool &inside);
    void colourString(int index, bool &inside, const std::string &cssclass);
    void markInterpolations();
    bool isInInterpolation(int index) const;
    bool isInsideSpanOfClass(int index, const std::string &cssClass) const;

    void parseBlockComment(const std::string &start, const std::string &end, bool &inside);
    void parseMultilineString(const std::string &start, const std::string &end, bool &inside,
                              const std::string &css);
    void parseHeredoc(const std::string &marker = "&lt;&lt;");

    void parseKeywordsAndTypes();
    bool colourKeys(int index, const std::string &key, const std::string &cssclass);
    bool isKey(int start, int end) const;
    int noCaseFind(const std::string &search, int index) const;

    void parseVariable(const std::string &var);
    void colourVariable(int index);

    void parseInlineComment(const std::string &cmnt);
    void colourComment(int index);
    void parseCharZeroComment(char zchar);

    void doParsing();

    void hyperTagMe();
    void hyperLinkMe();
    void hyperNameMe();
    void hyperIncludeMe();

    int getLineCount() const { return lncount; }
    std::string getBuffer() const { return buffer; }

    // option setting
    inline void setLangExt(int e) { langext = e; }
    inline void setLineCount(int c) { lncount = c; }
    inline void setChildLang(bool b) { childLang = b; }
    inline void setupIO(std::shared_ptr<CFfile> p) { IO = p; }

    void setLanguageRules(std::unique_ptr<LanguageRules> rules) {
        this->rules = std::move(rules);
    }

    // String parsing
    inline void parseStringDoubleQuote() {
        parseString(static_cast<char>(Quote::Double), state.inDblQuotes);
    }
    inline void parseStringSingleQuote() {
        parseString(static_cast<char>(Quote::Single), state.inSinQuotes);
    }
    inline void parseStringBackQuote() {
        parseString(static_cast<char>(Quote::Back), state.inBckQuotes);
    }

    // Multiline string parsing
    inline void parseMultilineStrTripleDblQuote() {
        parseMultilineString("\"\"\"", "\"\"\"", state.inMultiStr, "dblquot");
    }
    inline void parseMultilineStrRaw() {
        parseMultilineString("R\"(", ")\"", state.inMultiStr, "dblquot");
    }
    inline void parseMultilineStrUpperQBlock() {
        parseMultilineString("%Q{", "}", state.inMultiStr, "dblquot");
    }
    inline void parseMultilineStrLowerQBlock() {
        parseMultilineString("%q{", "}", state.inMultiStr, "sinquot");
    }
    inline void parseMultilineStrHeredocDblLt() { parseHeredoc("&lt;&lt;"); }
    inline void parseMultilineStrHeredocTplLt() {
        parseHeredoc("&lt;&lt;&lt;");
    }

    // Inline comment parsing
    inline void parseInlineCommentSingleQuote() { parseInlineComment("'"); }
    inline void parseInlineCommentDblDash() { parseInlineComment("--"); }
    inline void parseInlineCommentDblSlash() { parseInlineComment("//"); }
    inline void parseInlineCommentHash() { parseInlineComment("#"); }
    inline void parseInlineCommentSemiColon() { parseInlineComment(";"); }
    inline void parseInlineCommentDblColon() { parseInlineComment("::"); }
    inline void parseInlineCommentRem() {
        parseInlineComment("REM");
        parseInlineComment("rem");
    }
    inline void parseInlineCommentExclamation() { parseInlineComment("!"); }

    // First-character line comments
    inline void parseFirstCharCommentHash() { parseCharZeroComment('#'); }
    inline void parseFirstCharCommentFortran() {
        parseCharZeroComment('C');
        parseCharZeroComment('c');
        parseCharZeroComment('*');
    }

    // Block comment parsing
    inline void parseBlockCommentMarkup() {
        parseBlockComment("&lt;!-", "--&gt;", state.inComment);
    }
    inline void parseBlockCommentPascal() {
        parseBlockComment("(*", "*)", state.inComment);
    }
    inline void parseBlockCommentPLI() {
        parseBlockComment("/*", "*/", state.inComment);
    }
    inline void parseBlockCommentHaskell() {
        parseBlockComment("{-", "-}", state.inComment);
    }
    inline void parseHtmlTags() {
        parseBlockComment("&lt;", "&gt;", state.inHtmTags);
    }

    // Inline language parsing
    inline void colourChildLangAsm() { colourChildLang("asm", "}"); }
    inline void colourChildLangJS() {
        colourChildLang("&lt;script", "/script");
    }
    inline void colourChildLangCSS() { colourChildLang("&lt;style", "/style"); }

  public:
    EngineOptions options;

  protected:
    std::unique_ptr<LanguageRules> rules = nullptr;

  public:
    std::shared_ptr<CFfile> IO;
    Theme Scs2;

    // internal data
  protected:
    int langext;
    int lncount;
    std::string buffer;

    bool childLang;
    ParseState state;
};

#endif // _ENGINE_H
