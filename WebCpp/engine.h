/* webcpp - engine.h
 * Copyright (C)2001-2004, (C)2026 Jeffrey Bakker
   ___________________________________ .. .
 */

#ifndef _ENGINE_H
#define _ENGINE_H

#include "cffile.h"
#include "lang_rules.h"
#include "theme.h"

#include <memory>
#include <string>
#include <vector>

enum class Quote : char {
    Double = 0x22, // '"'
    Single = 0x27, // '''
    Back = 0x60    // '`'
};

class Engine {

  public:
    explicit Engine(std::unique_ptr<LanguageRules> rules);
    virtual ~Engine();

    void init_switches();

    void pre_parse();
    void makeMargin();
    void makeAnchor();

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

    void loadKeys();
    void doParsing();

    void begHtml(const std::string &name);
    void endHtml();

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

    inline void toggleBigtab() { opt_bigtab = !opt_bigtab; }
    inline void toggleWebcpp() { opt_webcpp = !opt_webcpp; }
    inline void toggleHypinc() { opt_hypinc = !opt_hypinc; }
    inline void toggleFollow() { opt_follow = !opt_follow; }
    inline void toggleAnchor() { opt_anchor = !opt_anchor; }
    inline void toggleNumber() { opt_number = !opt_number; }
    inline void toggleExtcss() { opt_extcss = !opt_extcss; }
    inline void toggleHtSnip() { opt_htsnip = !opt_htsnip; }

    void setTabWidth(const std::string &width);

    void setLanguageRules(std::unique_ptr<LanguageRules> rules) {
        this->rules = std::move(rules);
    }

    // String parsing
    inline void parseStringDoubleQuote() {
        parseString(static_cast<char>(Quote::Double), inDblQuotes);
    }
    inline void parseStringSingleQuote() {
        parseString(static_cast<char>(Quote::Single), inSinQuotes);
    }
    inline void parseStringBackQuote() {
        parseString(static_cast<char>(Quote::Back), inBckQuotes);
    }

    // Multiline string parsing
    inline void parseMultilineStrTripleDblQuote() {
        parseMultilineString("\"\"\"", "\"\"\"", inMultiStr, "dblquot");
    }
    inline void parseMultilineStrRaw() {
        parseMultilineString("R\"(", ")\"", inMultiStr, "dblquot");
    }
    inline void parseMultilineStrUpperQBlock() {
        parseMultilineString("%Q{", "}", inMultiStr, "dblquot");
    }
    inline void parseMultilineStrLowerQBlock() {
        parseMultilineString("%q{", "}", inMultiStr, "sinquot");
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
        parseBlockComment("&lt;!-", "--&gt;", inComment);
    }
    inline void parseBlockCommentPascal() {
        parseBlockComment("(*", "*)", inComment);
    }
    inline void parseBlockCommentPLI() {
        parseBlockComment("/*", "*/", inComment);
    }
    inline void parseBlockCommentHaskell() {
        parseBlockComment("{-", "-}", inComment);
    }
    inline void parseHtmlTags() {
        parseBlockComment("&lt;", "&gt;", inHtmTags);
    }

    // Inline language parsing
    inline void colourChildLangAsm() { colourChildLang("asm", "}"); }
    inline void colourChildLangJS() {
        colourChildLang("&lt;script", "/script");
    }
    inline void colourChildLangCSS() { colourChildLang("&lt;style", "/style"); }

    // options
  protected:
    bool opt_bigtab;
    bool opt_webcpp;
    bool opt_hypinc;
    bool opt_follow;
    bool opt_number;
    bool opt_extcss;
    bool opt_anchor;
    bool opt_htsnip;

    // parsing rules
  protected:
    std::unique_ptr<LanguageRules> rules = nullptr;

  public:
    std::shared_ptr<CFfile> IO;
    Theme Scs2;

    // internal data
  protected:
    int langext;
    int lncount;
    int tabwidth;
    std::string tw;
    std::string buffer;

    bool childLang;
    bool inDblQuotes;
    bool inSinQuotes;
    bool inBckQuotes;
    bool inHtmTags;
    bool inComment;
    bool inMultiStr;
    std::string heredocEnd;
    bool endMultiLine;
};

#endif // _ENGINE_H
