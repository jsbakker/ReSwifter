/* webcpp - engine.cpp
 * Copyright (C)2001-2004, (C)2026 Jeffrey Bakker
   ___________________________________ .. .
 */

// uncomment for debug output
// #include "defdebug.h"

#include "engine.h"
#include "deflangs.h"
#include "defsys.h"
#include "html_writer.h"
#include "lang_rules.h"

#include <algorithm>
#include <cctype>
#include <cstdlib>

using std::cerr;
using std::cin;
using std::make_unique;
using std::string;
using std::unique_ptr;
using std::vector;

// forward declaration (defined near colourKeys)
static bool isInsideFontTag(const string &buffer, int index);

Engine::Engine(unique_ptr<LanguageRules> rules) {
    this->rules = std::move(rules);
    init_switches();
}

Engine::~Engine() {
    if (!childLang)
        IO->close();
}

// initialize data members ----------------------------------------------------
void Engine::init_switches() {

    childLang = false;
    options = EngineOptions{};
    state = ParseState{};

    lncount = 1;
}
// format the plain text for proper display in HTML ---------------------------
void Engine::pre_parse() {

    string out;
    out.reserve(buffer.size() + buffer.size() / 4);

    int col = 0; // visual column for tab-stop arithmetic

    for (unsigned char c : buffer) {
        if (c == '&') {
            out += "&amp;";
            col++;
        } else if (c == '<') {
            out += "&lt;";
            col++;
        } else if (c == '>') {
            out += "&gt;";
            col++;
        } else if (options.bigtab && c == '\t') {
            int spaces = options.tabwidth - (col % options.tabwidth);
            out.append(spaces, ' ');
            col += spaces;
        } else {
            out += c;
            col++;
        }
    }

    buffer = std::move(out);
}
// erases tags (use for inside of inline comments) ----------------------------
void Engine::eraseTags(int start, int fin) {

    if (fin == 0) {
        fin = static_cast<int>(buffer.size());
    }
    if (fin == -1) {
        fin = static_cast<int>(buffer.size());
    }

    int erase1, erase2;
    int offset1, offset2;
    string srchstr;

    srchstr = "<font CLASS=";
    offset1 = 20;
    offset2 = 7;

    // erase all the colours previously made
    while (buffer.find(srchstr, start) != string::npos &&
           static_cast<int>(buffer.find(srchstr, start)) < fin) {

        // erasing opening font tags
        erase1 = static_cast<int>(buffer.find(srchstr, start));
        if (erase1 != -1 && erase1 < fin) {
            buffer.erase(erase1, offset1);
        }
        // erasing closing font tags
        erase2 = static_cast<int>(buffer.find("</font>", start));
        if (erase2 != -1 && erase2 < fin) {
            buffer.erase(erase2, offset2);
        }
    }
    state.inDblQuotes = false;
    state.inSinQuotes = false;
    state.inBckQuotes = false;
}
// anchors the line (for hyperlinking capabilities) ---------------------------
//-----------------------------------------------------------------------------
// check if parsing needs to be aborted ---------------------------------------
bool Engine::abortParse() const {

    //	if(doHtmlTags && state.inHtmTags)
    //			{return true;}

    // If interpolation blocks are present on this line, allow content parsing.
    // Individual colour functions use isInInterpolation() to gate access.
    if (buffer.contains('\x01')) {
        return false;
    }

    if (state.endMultiLine) {
        return true;
    }
    if (state.inDblQuotes) {
        return true;
    }
    if (!rules->doInlineCommentSingleQuote) {
        if (state.inSinQuotes) {
            return true;
        }
    }
    if (state.inBckQuotes) {
        return true;
    }
    if (state.inComment) {
        return true;
    }
    if (state.inMultiStr) {
        return true;
    }

    return false;
}
// check if colouring needs to be aborted -------------------------------------
bool Engine::abortColour(int index) const {

    // Content inside an interpolation block is always highlightable
    if (isInInterpolation(index))
        return false;

    // If the position is inside a string/comment font tag (including the
    // opening tag inserted at position 0 for continuation lines), don't
    // highlight it — the content is part of a string literal.
    if (isInsideFontTag(buffer, index))
        return true;

    // On multi-line string continuation lines where no font tag was inserted
    // (e.g. triple-quoted strings, comment continuations), block coloring
    // outside interpolation zones.
    if (state.endMultiLine || state.inMultiStr)
        return true;

    if (rules->doBlockCommentMarkup && (isInsideIt(index, "&lt;", "&gt;") &&
                              isInsideIt(index, "&gt;", "&lt;"))) {
        return true;
    }
    if (isInsideIt(index, "/*", "*/", true)) {
        return true;
    }
    if (isInsideIt(index, "(*", "*)", true)) {
        return true;
    }
    if (isInsideIt(index, "&lt;!", "&gt;")) {
        return true;
    }
    if (isInsideIt(index, "\"", "\"")) {
        return true;
    }
    if (!rules->doInlineCommentSingleQuote) {
        if (isInsideIt(index, "'", "'")) {
            return true;
        }
    }
    if (isInsideIt(index, "`", "`")) {
        return true;
    }

    return false;
}
// check if the index is inside the specified boundaries ----------------------
bool Engine::isInsideIt(int index, const string &start, const string &end, bool skipTagged) const {

    // count the number of starts and ends
    // and return true for an odd number

    if (!buffer.contains(start)) {
        return false;
    }

    int l = 0;
    int r = 0;
    int idx;

    idx = static_cast<int>(buffer.find(end, index));
    while (idx != (int)string::npos && idx < (int)buffer.size()) {
        if (idx > 0 && buffer[idx - 1] != '\\') {
            if (!skipTagged || !isInsideFontTag(buffer, idx))
                r++;
        } else if (idx == 0) {
            r++;
        }
        idx = static_cast<int>(buffer.find(end, idx + 1));
    }

    idx = static_cast<int>(buffer.rfind(start, index));
    while (idx >= 0 && idx < (int)buffer.size()) {
        if (idx > 0 && buffer[idx - 1] != '\\') {
            if (!skipTagged || !isInsideFontTag(buffer, idx))
                l++;
        } else if (idx == 0) {
            l++;
        }
        if (idx == 0)
            break;
        idx = static_cast<int>(buffer.rfind(start, idx - 1));
    }

    if (r % 2 == 1 && l % 2 == 1) {
        return true;
    }

    return false;
}
// number accuracy ------------------------------------------------------------
bool Engine::isNotWord(int index) const {

    if (isalpha(buffer[index + 1])) {
        return false;
    }

    while (index > 0) {

        if (isalpha(buffer[index])) {
            return false;
        }
        if (buffer[index] == '_') {
            return false;
        }
        if (buffer[index] == '#') {
            return false;
        }

        if (ispunct(buffer[index]) || isspace(buffer[index])) {
            return true;
        }
        index--;
    }
    return true;
}
// parse for preprocessor directives ------------------------------------------
void Engine::parsePreProc() {

    if (abortParse()) {
        return;
    }
    if (buffer[0] != '#') {
        return;
    }

    if (options.hypinc) {
        hyperIncludeMe();
    }

    buffer += " ";
    buffer.insert(0, "<font CLASS=preproc>");

    int end = 0;
    for (int i = 8; i < static_cast<int>(buffer.size()); i++) {
        if (isspace(buffer[i])) {
            end = i;
            i = static_cast<int>(buffer.size());
        }
    }
    buffer.insert(end, "</font>");
}
// define symbol characters ---------------------------------------------------
bool Engine::isSymbol(char c) const {

    // FIXME: make all symbols work
    // without conflicting with the other parsing
    // the current implementaion is also rather slow
    switch (c) {

        //    case '*':
    case '!':
    case '|':
        //    case '&':
        //    case '<':
        //    case '>':
        //    case '{':
        //    case '}':
        //    case '[':
        //    case ']':
        //    case '(':
        //    case ')':
        //    case ':':
    case '-':
    case '=':
    case '+':
        return true;
    default:
        return false;
    }
}
// parse for symbols ----------------------------------------------------------
void Engine::parseSymbol() {

    // FIXME: make all symbols work
    // without conflicting with the other parsing
    // the current implementaion is also rather slow
    if (abortParse()) {
        return;
    }

    int end;
    int insert = 0;

    for (int i = 0; i < static_cast<int>(buffer.size()); i++) {

        if (isSymbol(buffer[i])) {

            end = i;
            while (isSymbol(buffer[end + 1])) {
                end++;
            }

            // skip symbol spans that form comment markers
            if (buffer[i] == '-') {
                string span = buffer.substr(i, end - i + 1);
                if (rules->doInlineCommentDblDash && span.contains("--")) {
                    i = end;
                    continue;
                }
                if (rules->doBlockCommentHaskell) {
                    if (i > 0 && buffer[i - 1] == '{') {
                        i = end;
                        continue;
                    }
                    if (end + 1 < (int)buffer.size() &&
                        buffer[end + 1] == '}') {
                        i = end;
                        continue;
                    }
                }
            }

            if (colourSymbol(i, end)) {

                insert += 27;
                i = end + insert;
            }
        }
    }
    // currently enabled for:
    // C,C++,Cg,C#,Objective C,Java,Perl,PHP,Python,UScript
}
// colour the symbols ---------------------------------------------------------
bool Engine::colourSymbol(int s, int f) {

    if (abortColour(s)) {
        return false;
    }
    if (!isNotWord(s)) {
        return false;
    }

    buffer.insert(s, "<font CLASS=symbols>");
    buffer.insert(f + 21, "</font>");

    return true;
}
// parse labels ---------------------------------------------------------------
void Engine::parseLabel() {

    if (abortParse()) {
        return;
    }
    if (buffer.empty()) {
        return;
    }

    if (buffer.contains("/*")) {
        return;
    } // prevent comment loop
    if (buffer.contains("(*")) {
        return;
    }

    int end, beg;

    end = static_cast<int>(buffer.size()) - 1;
    beg = static_cast<int>(buffer.rfind(" ", end));

    if (beg == -1) {
        beg = 0;
    }
    if (buffer[end] == ':') {
        colourLabel(beg, end);
    }
}
// colourize the labels -------------------------------------------------------
void Engine::colourLabel(int beg, int end) {

    if (abortColour(beg)) {
        return;
    }
    buffer.insert(beg, "<font CLASS=preproc>");
    buffer.insert(end + 21, "</font>");
}
//-----------------------------------------------------------------------------
// parse the buffer for numbers -----------------------------------------------
void Engine::parseNum() {
    if (buffer.starts_with('#')) {
        return;
    }
    if (abortParse()) {
        return;
    }

    vector<int> nums;
    vector<int> ends;
    int end;
    int insert = 0;

    // grab indexes of all numbers into the vector
    for (int i = 0; i < static_cast<int>(buffer.size()); i++) {

        if (isdigit(buffer[i]) && (i == 0 || !isalpha(buffer[i - 1]))) {
            end = i;

            while (isdigit(buffer[end + 1]) ||
                   (buffer[end + 1] == '.' && isdigit(buffer[end + 2])) ||
                   (rules->doUnderscoreNumbers && buffer[end + 1] == '_' &&
                    isdigit(buffer[end + 2]))) {
                end++;
            }

            nums.push_back(i);
            ends.push_back(end);
            i = end;
        }
    }
    // now colour each number
    for (int j = 0; j < (int)ends.size(); j++) {

        if (j > 0) {
            insert += 27;
        }

        if (!colourNum(nums[j] + insert, ends[j] + insert)) {
            insert -= 27;
        }
    }
}
// insert number highlighting tags --------------------------------------------
bool Engine::colourNum(int s, int f) {

    if (abortColour(s)) {
        return false;
    }
    if (!isNotWord(s)) {
        return false;
    }

    string cssclass;
    int fpt;

    fpt = static_cast<int>(buffer.find(".", s));

    if (fpt != -1 && fpt < f) {

        cssclass = "<font CLASS=floatpt>";
    } else
        cssclass = "<font CLASS=integer>";

    // insert the font tags
    buffer.insert(s, cssclass);
    buffer.insert(f + 21, "</font>");

    return true;
}
//-----------------------------------------------------------------------------
// parse the buffer for strings -----------------------------------------------
void Engine::parseString(char quotetype, bool &inside) {

    if (state.endMultiLine) {
        return;
    }
    if (state.inMultiStr) {
        return;
    }
    if (rules->doInlineCommentSingleQuote && quotetype == static_cast<char>(Quote::Single)) {
        return;
    }

    string quote, escap1, escap2, cssclass;
    int index, offset;
    index = 0;

    // Support for 3 different string types
    if (quotetype == static_cast<char>(Quote::Double)) {
        if (state.inSinQuotes || state.inBckQuotes) {
            return;
        }

        quote = "\"";

        // Asp uses single ticks for comments and this
        // screws up if a double-quoted line is commented out
        if (!rules->doInlineCommentSingleQuote) {
            escap1 = "'";
        } else {
            escap1 = "`";
        }
        escap2 = "`";

        cssclass = "dblquot";

    } else if (quotetype == static_cast<char>(Quote::Single)) {
        if (state.inDblQuotes || state.inBckQuotes) {
            return;
        }

        quote = "'";
        escap1 = "\"";
        escap2 = "`";

        cssclass = "sinquot";

    } else if (quotetype == static_cast<char>(Quote::Back)) {
        if (state.inDblQuotes || state.inSinQuotes) {
            return;
        }

        quote = "`";
        escap1 = "\"";
        escap2 = "'";

        cssclass = "preproc";
    }
    // Double, single, and back quoted ///

    // On a string-continuation line (inside=true), always insert the opening
    // font tag at position 0 so that isInsideSpanOfClass and isInsideFontTag
    // can correctly identify the string body and gate interpolation detection
    // and content highlighting.  If no unescaped closing delimiter is found,
    // close the tag at end of buffer so that the line is fully coloured and
    // the HTML stays balanced.
    bool insertedContinuationTag = false;
    if (inside) {
        buffer.insert(0, "<font CLASS=" + cssclass + ">");
        insertedContinuationTag = true;
    }

    index = static_cast<int>(buffer.find(quote, index));
    if (index == -1) {
        if (insertedContinuationTag && inside)
            buffer += "</font>";
        return;
    }

    while (index >= 0) {

        if (index > 0 && buffer[index - 1] == '\\') {
            if (index > 1 && buffer[index - 2] == '\'' &&
                buffer[index + 1] == '\'') {
                index = static_cast<int>(buffer.find(quote, index + 1));
            }
        }
        if (index == -1) {
            if (insertedContinuationTag && inside)
                buffer += "</font>";
            return;
        }

        while (isInsideIt(index, escap1, escap1)) {
            index = static_cast<int>(buffer.find(quote, index + 1));
            if (index == -1) {
                if (insertedContinuationTag && inside)
                    buffer += "</font>";
                return;
            }
        }
        while (isInsideIt(index, escap2, escap2)) {
            index = static_cast<int>(buffer.find(quote, index + 1));
            if (index == -1) {
                if (insertedContinuationTag && inside)
                    buffer += "</font>";
                return;
            }
        }

        while (rules->doInlineCommentDblDash && isInsideIt(index, "--", "\n")) {
            index = static_cast<int>(buffer.find(quote, index + 1));
            if (index == -1) {
                if (insertedContinuationTag && inside)
                    buffer += "</font>";
                return;
            }
        }

        while (rules->doBlockCommentMarkup && isInsideIt(index, "&gt;", "&lt;")) {
            index = static_cast<int>(buffer.find(quote, index + 1));
            if (index == -1) {
                if (insertedContinuationTag && inside)
                    buffer += "</font>";
                return;
            }
        }

        // keep escape characters in mind
        while (index > 3 && buffer[index - 1] == '\\' &&
               (buffer[index - 2] != '\\' ||
                (buffer[index - 3] == '\\' && buffer[index - 4] != '\\'))) {

            index = static_cast<int>(buffer.find(quote, index + 1));
            if (index == -1) {
                if (insertedContinuationTag && inside)
                    buffer += "</font>";
                return;
            }
        }

        if (index != -1 && !state.inComment) {

            colourString(index, inside, cssclass);
        }

        if (inside) {
            offset = index + 21;
        } else {
            offset = index + 7;
        }

        index = static_cast<int>(buffer.find(quote, offset));
        if (index == -1) {
            if (inside)
                buffer += "</font>";
            return;
        }
        if (index > static_cast<int>(buffer.size())) {
            if (inside)
                buffer += "</font>";
            return;
        }
    }
}
// insert string highlighting tags --------------------------------------------
void Engine::colourString(int index, bool &inside, const string &cssclass) {

    if (index > static_cast<int>(buffer.size())) {
        return;
    }

    string fntag = "<font CLASS=" + cssclass + ">";

    // open tag
    if (!inside) {
        buffer.insert(index, fntag);
    } else {
        buffer.insert(index + 1, "</font>");
    }
    // or close tag
    // depending on whether or not inside

    inside = !inside;
}
//-----------------------------------------------------------------------------
// returns true if buffer[index] is inside a <font CLASS=cssClass>...</font>
// span
bool Engine::isInsideSpanOfClass(int index, const string &cssClass) const {

    string openTag = "<font CLASS=" + cssClass + ">";
    int i = index - 1;
    while (i >= 0) {
        if (buffer[i] == '>') {
            int ts = static_cast<int>(buffer.rfind('<', i));
            if (ts != (int)string::npos) {
                string tag = buffer.substr(ts, i - ts + 1);
                if (tag == "</font>")
                    return false;
                if (tag == openTag)
                    return true;
                if (tag.size() >= 6 && tag.substr(0, 6) == "<font ")
                    return false; // inside a different class — not this one
                i = ts - 1;
                continue;
            }
        }
        i--;
    }
    return false;
}
//-----------------------------------------------------------------------------
// returns true if buffer[index] is between interpolation boundary markers
// \x01 = interpolation open, \x02 = interpolation close
bool Engine::isInInterpolation(int index) const {

    for (int i = index - 1; i >= 0; i--) {
        if (buffer[i] == '\x01')
            return true;
        if (buffer[i] == '\x02')
            return false;
    }
    return false;
}
//-----------------------------------------------------------------------------
// insert \x01/\x02 interpolation boundary markers around each interpolation
// block found inside string-highlighted spans. Runs as a post-pass after
// parseString, before other highlight passes.
void Engine::markInterpolations() {

    if (!rules->doInterpolate || rules->interpolStart.empty() ||
        rules->interpolEnd == '\0')
        return;

    const string openMark = "</font>\x01"; // close string tag, open interp
    const string closeMark = "\x02<font CLASS=" + rules->interpolCssClass + ">";
    int pos = 0;

    // When inside a multi-line string continuation the whole buffer is
    // implicitly inside the string, even though this line has no opening
    // font tag of its own.
    bool wholeLineIsString = state.inMultiStr && rules->interpolCssClass == "dblquot";

    while (pos < (int)buffer.size()) {
        int ipos = static_cast<int>(buffer.find(rules->interpolStart, pos));
        if (ipos == (int)string::npos)
            break;

        // Must be inside the appropriate string span, or on a multi-line
        // string continuation line where the whole buffer is implicitly
        // string-coloured.
        if (!isInsideSpanOfClass(ipos, rules->interpolCssClass) &&
            !wholeLineIsString) {
            pos = ipos + 1;
            continue;
        }

        // Skip escaped interpolation markers.
        // Count consecutive backslashes immediately before ipos;
        // an odd count means the # is escaped.
        int bsCount = 0;
        int bsPos = ipos - 1;
        while (bsPos >= 0 && buffer[bsPos] == '\\') {
            bsCount++;
            bsPos--;
        }
        if (bsCount % 2 != 0) {
            pos = ipos + 1;
            continue;
        }

        // Insert </font>\x01 before the interpolation marker
        buffer.insert(ipos, openMark);
        int shift1 = (int)openMark.size(); // 8

        // Depth-track from just after interpolStart to find the matching end
        int scanPos = ipos + shift1 + (int)rules->interpolStart.size();
        int depth = 1;

        while (scanPos < (int)buffer.size() && depth > 0) {
            char c = buffer[scanPos];
            // Skip over any HTML tags inserted by earlier passes
            if (c == '<' && scanPos + 1 < (int)buffer.size() &&
                buffer[scanPos + 1] == 'f') {
                int gt = static_cast<int>(buffer.find('>', scanPos));
                if (gt != (int)string::npos) {
                    scanPos = gt + 1;
                    continue;
                }
            }
            if (rules->interpolEnd == '}' && c == '{')
                depth++;
            else if (rules->interpolEnd == ')' && c == '(')
                depth++;
            if (c == rules->interpolEnd) {
                depth--;
                if (depth == 0)
                    break;
            }
            scanPos++;
        }

        if (depth != 0) {
            // Unbalanced — revert and skip past this marker
            buffer.erase(ipos, shift1);
            pos = ipos + 1;
            continue;
        }

        // Insert \x02<font CLASS=dblquot> after the closing marker
        buffer.insert(scanPos + 1, closeMark);
        pos = scanPos + 1 + (int)closeMark.size();
    }
}
// parse for multi-line strings -----------------------------------------------
void Engine::parseMultilineString(const string &start, const string &end, bool &inside,
                                  const string &css) {

    // don't interfere when a heredoc owns the state.inMultiStr state
    if (!state.heredocEnd.empty()) {
        return;
    }

    string search;
    int index, offset;

    index = 0;

    if (inside) {
        search = end;
    } else {
        search = start;
    }

    index = static_cast<int>(buffer.find(search, index));
    if (index == -1) {
        return;
    }

    while (index >= 0) {

        if (inside) {
            search = end;
        } else {
            search = start;
        }

        index = static_cast<int>(buffer.find(search, index));
        if (index == -1) {
            return;
        }

        if (index > 0 && buffer[index - 1] == '\\') {
            if (index > 1 && buffer[index - 2] == '\'' &&
                buffer[index + 1] == '\'') {
                index = static_cast<int>(buffer.find(search, index + 1));
            }
        }
        if (index == -1) {
            return;
        }

        // For brace-delimited strings (%Q{}, %q{}, etc.), skip nested
        // braces so that interpolation like #{var} doesn't end the
        // string prematurely.
        if (inside && end == "}") {
            int depth = 0;
            // Find where the string content begins. If the opening
            // delimiter (%Q{ or %q{) is on this line, start scanning
            // after its {. Otherwise (continuation line), start at 0.
            int scanStart = 0;
            string startNoBrace =
                start.substr(0, start.size() - 1); // "%Q" or "%q"
            int delimPos = static_cast<int>(buffer.rfind(startNoBrace, index));
            if (delimPos != (int)string::npos) {
                // Skip past the opening { of the delimiter
                scanStart = delimPos + static_cast<int>(start.size());
            }
            for (int i = scanStart; i < index; i++) {
                if (buffer[i] == '{' && !isInsideTag(i))
                    depth++;
                if (buffer[i] == '}' && !isInsideTag(i))
                    depth--;
            }
            // If depth > 0, there are unclosed braces before this },
            // so this } is a nested one — skip it.
            if (depth > 0) {
                index = static_cast<int>(buffer.find(search, index + 1));
                continue;
            }
        }

        if (inside) {
            index += static_cast<int>(end.size()) - 1;
        } else
            eraseTags(index, 0);
        colourString(index, inside, css);

        if (inside) {
            offset = index + 21;
            search = end;
        } else {
            offset = index + 7;
            search = start;
        }

        index = static_cast<int>(buffer.find(search, offset));
        if (index == -1) {
            if (inside) {
                state.endMultiLine = true;
            }
            return;
        }
        if (index > buffer.size()) {
            if (inside) {
                state.endMultiLine = true;
            }
            return;
        }
    }
}
// parse for Ruby-style heredoc strings (<<TAG, <<-TAG, <<~TAG) ---------------
void Engine::parseHeredoc(const string &marker) {

    if (state.inMultiStr && !state.heredocEnd.empty()) {
        // we are inside a heredoc — check if this line is the end marker
        // the end marker must appear at the start of the line (after optional
        // whitespace)
        string trimmed = buffer;
        int pos = 0;
        while (pos < (int)trimmed.size() &&
               (trimmed[pos] == ' ' || trimmed[pos] == '\t')) {
            pos++;
        }
        string lineContent = trimmed.substr(pos);

        // strip trailing semicolon for languages like PHP where EOT; is valid
        if (!lineContent.empty() && lineContent.back() == ';') {
            lineContent = lineContent.substr(0, lineContent.size() - 1);
        }

        if (lineContent == state.heredocEnd) {
            // this line closes the heredoc — colour it and end
            // position index at end of the marker so </font> closes after it
            int endIdx = pos + (int)state.heredocEnd.size() - 1;
            eraseTags(0, 0);
            colourString(endIdx, state.inMultiStr, "dblquot");
            // state.inMultiStr is now false after colourString toggles it
            state.heredocEnd = "";
            return;
        }
        // still inside heredoc — line is already coloured by state.endMultiLine
        // mechanism
        return;
    }

    // don't start a heredoc when a %Q{} string owns the state.inMultiStr state
    if (state.inMultiStr) {
        return;
    }

    // not inside a heredoc — look for a heredoc start on this line
    // after pre_parse, << becomes &lt;&lt; (or <<< becomes &lt;&lt;&lt; for
    // PHP)
    int index = static_cast<int>(buffer.find(marker, 0));
    if (index == -1) {
        return;
    }

    while (index != -1 && index < (int)buffer.size()) {
        int tagStart = index;

        // skip if the marker is inside a string literal
        if (abortColour(tagStart)) {
            index =
                static_cast<int>(buffer.find(marker, tagStart + marker.size()));
            continue;
        }

        // skip if the marker appears after a single-line comment start
        // (single-line comments haven't been parsed yet at this point in
        // doParsing)
        if (rules->doInlineCommentHash) {
            int hashPos = static_cast<int>(buffer.find("#", 0));
            if (hashPos != -1 && hashPos < tagStart) {
                if (!isInsideIt(hashPos, "\"", "\"") &&
                    !isInsideIt(hashPos, "'", "'")) {
                    return;
                }
            }
        }
        if (rules->doInlineCommentDblSlash) {
            int slashPos = static_cast<int>(buffer.find("//", 0));
            if (slashPos != -1 && slashPos < tagStart) {
                if (!isInsideIt(slashPos, "\"", "\"") &&
                    !isInsideIt(slashPos, "'", "'")) {
                    return;
                }
            }
        }

        int pos = index + static_cast<int>(marker.size()); // past "&lt;&lt;"

        // optional - or ~
        if (pos < (int)buffer.size() &&
            (buffer[pos] == '-' || buffer[pos] == '~')) {
            pos++;
        }

        // optional quote character around the tag name
        char quoteChar = 0;
        if (pos < (int)buffer.size() &&
            (buffer[pos] == '\'' || buffer[pos] == '"')) {
            quoteChar = buffer[pos];
            pos++;
        }

        // extract the tag name (must be a word: letters, digits, underscore)
        int nameStart = pos;
        while (pos < (int)buffer.size() &&
               (isalnum(buffer[pos]) || buffer[pos] == '_')) {
            pos++;
        }

        if (pos == nameStart) {
            // no valid tag name found, skip this match
            index =
                static_cast<int>(buffer.find(marker, tagStart + marker.size()));
            continue;
        }

        string tagName = buffer.substr(nameStart, pos - nameStart);

        // skip closing quote if present
        if (quoteChar && pos < (int)buffer.size() && buffer[pos] == quoteChar) {
            pos++;
        }

        // store the end marker and start the heredoc
        state.heredocEnd = tagName;
        eraseTags(tagStart, 0);
        colourString(tagStart, state.inMultiStr, "dblquot");
        // state.inMultiStr is now true after colourString toggles it
        return;
    }
}
// parse for multi-line comments ----------------------------------------------
void Engine::parseBlockComment(const string &start, const string &end, bool &inside) {

    if (state.inMultiStr) {
        return;
    }

    string search, escap, css;
    int index, offset;
    bool erase;

    index = 0;
    erase = true;
    css = "comment";

    if (inside) {
        search = end;
    } else {
        search = start;
    }

    index = static_cast<int>(buffer.find(search, index));
    if (index == -1) {
        return;
    }
    if (rules->doInlineCommentDblSlash && start == "/*" && buffer.find("//") < index) {
        return;
    }
    if (rules->doInlineCommentHash && start == "/*" && buffer.find("#") < index) {
        return;
    }

    if (start == "&lt;" && end == "&gt;" && rules->doHtmlTags) {

        if (buffer.find("&lt;!-") == index || state.inHtmTags)
            if (!inside)
                return;
        erase = false;
        css = "preproc";
    }

    while (index >= 0) {

        if (inside) {
            search = end;
        } else {
            search = start;
        }

        index = static_cast<int>(buffer.find(search, index));
        if (index == -1) {
            return;
        }

        if (index > 0 && buffer[index - 1] == '\\') {
            if (index > 1 && buffer[index - 2] == '\'' &&
                buffer[index + 1] == '\'') {
                index = static_cast<int>(buffer.find(search, index + 1));
            }
        }
        if (index == -1) {
            return;
        }
        if (!isInsideIt(index, "\"", "\"") && !isInsideIt(index, "'", "'") &&
            !isInsideIt(index, "`", "`")) {
            if (inside) {
                index += end.size() - 1;
                if (!buffer.contains(end)) {
                    state.endMultiLine = true;
                }
            } else if (erase)
                eraseTags(index, 0);
            colourString(index, inside, css);
        }

        if (inside) {
            offset = index + 21;
            search = end;
        } else {
            offset = index + 7;
            search = start;
        }

        index = static_cast<int>(buffer.find(search, offset));
        if (index == -1) {
            return;
        }
        if (index > static_cast<int>(buffer.size())) {
            return;
        }
    }
}
// parse for keywords ---------------------------------------------------------
void Engine::parseKeywordsAndTypes() {

    if (buffer.starts_with('#')) {
        return;
    }
    if (abortParse()) {
        return;
    }

    int i, index, offset = 20;
    string cmpkey;

    for (i = 0; i < (int)rules->keys.size(); i++) {

        cmpkey = rules->keys[i];
        index = noCaseFind(cmpkey, 0);

        while (index < static_cast<int>(buffer.size()) && index != -1) {

            bool inserted = false;
            if (isKey(index - 1,
                      index + static_cast<int>(rules->keys[i].size()))) {
                inserted = colourKeys(index, rules->keys[i], "keyword");
            }
            int skip = inserted ? offset : 0;
            index = noCaseFind(cmpkey,
                               index + static_cast<int>(cmpkey.size()) + skip);
        }
    }

    for (i = 0; i < (int)rules->types.size(); i++) {

        cmpkey = rules->types[i];
        index = noCaseFind(cmpkey, 0);

        while (index < static_cast<int>(buffer.size()) && index != -1) {

            bool inserted = false;
            if (isKey(index - 1,
                      index + static_cast<int>(rules->types[i].size()))) {
                inserted = colourKeys(index, rules->types[i], "keytype");
            }
            int skip = inserted ? offset : 0;
            index = noCaseFind(cmpkey,
                               index + static_cast<int>(cmpkey.size()) + skip);
        }
    }
}
// checks for case sensitive keys ---------------------------------------------
int Engine::noCaseFind(const string &search, int index) const {

    if (rules->doCaseKeys) {
        return static_cast<int>(buffer.find(search, index));
    }
    if (search == "class") {
        return static_cast<int>(buffer.find(search, index));
    }

    string tmp = buffer;

    for (int i = 0; i < static_cast<int>(tmp.size()); i++) {
        tmp[i] = toupper(tmp[i]);
    }

    string searchUpper = search;
    for (int j = 0; j < static_cast<int>(searchUpper.size()); j++) {
        searchUpper[j] = toupper(searchUpper[j]);
    }

    return static_cast<int>(tmp.find(searchUpper, index));
}
// asserts word boundaries for keywords ---------------------------------------
bool Engine::isKey(int before, int after) const {

    bool validBefore = (before < 0);
    bool validAfter = (after < 0 || after >= (int)buffer.size());

    if (!validBefore) {
        if (buffer[before] == '#') {
            return false;
        }
        if (buffer[before] == '_') {
            return false;
        }
        if (isalnum(buffer[before])) {
            return false;
        }
    }
    if (!validAfter) {
        if (buffer[after] == '_') {
            return false;
        }
        if (isalnum(buffer[after])) {
            return false;
        }
    }

    if (validBefore || ispunct(buffer[before]) || isspace(buffer[before])) {
        if (validAfter || ispunct(buffer[after]) || isspace(buffer[after])) {
            return true;
        }
    }
    return true;
}
// check if index is inside an HTML tag (<...>) ------------------------------
bool Engine::isInsideTag(int index) const {

    // search backward for '<' or '>' from the index
    for (int i = index - 1; i >= 0; i--) {
        if (buffer[i] == '>') {
            return false;
        }
        if (buffer[i] == '<') {
            return true;
        }
    }
    return false;
}
// check if index is inside existing <font ...>...</font> content -----------
static bool isInsideFontTag(const string &buffer, int index) {

    // search backward for </font> or <font — if we find <font...> first,
    // we are inside its content and should not wrap again
    int i = index - 1;
    while (i >= 0) {
        if (buffer[i] == '>') {
            // found a closing '>'; check if this is a <font tag
            int tagStart = static_cast<int>(buffer.rfind('<', i));
            if (tagStart != (int)string::npos && tagStart >= 0) {
                string tag = buffer.substr(tagStart, i - tagStart + 1);
                if (tag.starts_with("<font ") || tag.starts_with("<font>")) {
                    return true; // we are inside font content
                }
                if (tag.starts_with("</font>")) {
                    return false; // we are past a closed font tag
                }
            }
            i = tagStart - 1;
        } else {
            i--;
        }
    }
    return false;
}
// colourize the keywords -----------------------------------------------------
bool Engine::colourKeys(int index, const string &key, const string &cssclass) {

    if (isInsideTag(index)) {
        return false;
    }
    if (isInsideFontTag(buffer, index)) {
        return false;
    }
    if (abortColour(index)) {
        return false;
    }
    buffer.insert(index, "<font CLASS=" + cssclass + ">");
    buffer.insert(index + key.size() + 20, "</font>");
    return true;
}
//-----------------------------------------------------------------------------
// parse for variables --------------------------------------------------------
void Engine::parseVariable(const string &var) {

    if (state.endMultiLine) {
        return;
    }
    if (state.inMultiStr) {
        return;
    }
    if (state.inComment) {
        return;
    }

    int index;
    int test;

    index = static_cast<int>(buffer.find(var, 0));
    test = static_cast<int>(buffer.find("#", 0));
    if (test != -1 && test < index) {
        return;
    }

    while (index >= 0) {

        if (index != -1) {
            colourVariable(index);
        }
        index = static_cast<int>(buffer.find(var, index + 22));
    }
}
// colourize the variables ----------------------------------------------------
void Engine::colourVariable(int index) {

    int end = 0;
    buffer.insert(index, "<font CLASS=preproc>");

    int i = index + 21;

    // search for a variable name delimiter
    while (!end && i < buffer.size()) {

        if (!isalnum(buffer[i])) {
            if (buffer[i] == '_') {
                i++;
            }
            if (isspace(buffer[i])) {
                end = i;
            }
            if (ispunct(buffer[i])) {
                end = i;
            }
            if (buffer[i] == '=') {
                end = i;
            }
            if (buffer[i] == ',') {
                end = i;
            }
            if (buffer[i] == '{') {
                end = i;
            }
            if (buffer[i] == '[') {
                end = i;
            }
            if (buffer[i] == '(') {
                end = i;
            }
            if (buffer[i] == '\'') {
                end = i;
            }
            if (buffer[i] == '\n') {
                end = i;
            }
        }
        if (i == buffer.size() - 1) {
            end = i + 1;
        } else
            i++;
    }

    // if the variable prefix is at the end of the buffer (no delimiter
    // found because the search started at or past buffer.size()),
    // close the tag at the end instead of at position 0
    if (!end) {
        end = static_cast<int>(buffer.size());
    }

    if (end > 0 && buffer[end - 1] == '\"') {
        end--;
    }
    if (end > 0 && buffer[end - 1] == ')') {
        end--;
    }

    buffer.insert(end, "</font>");
}
//-----------------------------------------------------------------------------
// check for comments ---------------------------------------------------------
void Engine::parseInlineComment(const string &cmnt) {

    if (state.inComment) {
        return;
    }
    if (state.endMultiLine) {
        return;
    }

    int index = static_cast<int>(buffer.find(cmnt, 0));
    if (index == -1) {
        return;
    }

    // do not misktake HTML attributes for UNIX comments
    if (cmnt == "#" && index != -1 && index > 0 && buffer[index - 1] != '\\') {
        if (index != 0) {
            while (index > 0 && index < (int)buffer.size() &&
                   buffer[index - 1] == '=') {
                index = static_cast<int>(buffer.find("#", index + 1));
                if (index == -1) {
                    return;
                }
            }
        }
    }
    //-----------------------------------------------//

    // do not mistake HTML entity terminators for assembly comments
    // (pre_parse converts > to &gt; and & to &amp; — the trailing ;
    //  of these entities is not a real semicolon in the source)
    if (cmnt == ";") {
        while (index != -1 && index > 0) {
            bool isEntity = false;
            // check if ; is the end of &gt; &lt; or &amp;
            if (index >= 3 && buffer.substr(index - 3, 4) == "&gt;")
                isEntity = true;
            if (index >= 3 && buffer.substr(index - 3, 4) == "&lt;")
                isEntity = true;
            if (index >= 4 && buffer.substr(index - 4, 5) == "&amp;")
                isEntity = true;
            if (isEntity) {
                index = static_cast<int>(buffer.find(cmnt, index + 1));
                continue;
            }
            break;
        }
        if (index == -1) {
            return;
        }
    }
    //-----------------------------------------------//

    if (index > 0 && buffer[index - 1] == '$') {
        return;
    }
    if (index > 0 && buffer[index - 1] == '\\') {
        return;
    }

    colourComment(index);
}
// colour an inline comment ---------------------------------------------------
void Engine::colourComment(int index) {

    // Never colour a comment that starts inside an existing highlighted span
    // or inside an interpolation block (comments don't parse there, and
    // eraseTags would damage the interpolation markers).
    if (isInsideFontTag(buffer, index))
        return;
    if (isInInterpolation(index))
        return;
    if (abortColour(index)) {
        return;
    }
    if (rules->doInlineCommentDblSlash) {
        if (index >= 5 && buffer.rfind("http:", index) == index - 5) {
            return;
        }
        if (buffer.rfind("!DOCTYPE", index) != -1) {
            return;
        }
    }

    // no highlighting inside of comments
    eraseTags(index, 0);

    // insert the font tags
    buffer.insert(index, "<font CLASS=comment>");
    buffer.insert(buffer.size(), "</font>");
}
//-----------------------------------------------------------------------------
void Engine::parseCharZeroComment(char zchar) {

    if (!buffer.empty() && buffer.front() == zchar) {
        colourComment(0);
    }
}
// here is where the parsing rules apply --------------------------------------
void Engine::doParsing() {

    if (options.anchor) {
        HtmlWriter::writeAnchor(IO, lncount);
    }
    if (options.number) {
        HtmlWriter::writeMargin(IO, lncount);
    }

    IO->rline(buffer);
    if (!IO->isInputGood()) {
        return;
    }

    // Count trailing backslashes on the raw line before any modification.
    // An odd count means the final \ is a genuine line-continuation marker;
    // an even count means the trailing backslashes are all escaped pairs.
    int trailingBackslashes = 0;
    for (int i = (int)buffer.size() - 1; i >= 0 && buffer[i] == '\\'; i--)
        trailingBackslashes++;
    const bool lineHasContinuation = (trailingBackslashes % 2 == 1);

    // preformat HTML escapes
    pre_parse();

#ifdef DEBUG_DO_PARSING
    PRINT_DEBUG(0);
#endif

    if (rules->doLabels)
        parseLabel();

    if (rules->doMultilineStrTripleDblQuote)
        parseMultilineStrTripleDblQuote();
    if (rules->doMultilineStrRaw)
        parseMultilineStrRaw();
    if (rules->doMultilineStrHeredoc)
        parseMultilineStrHeredocDblLt();
    if (rules->doMultilineStrHeredocTpl)
        parseMultilineStrHeredocTplLt();
    if (rules->doMultilineStrPercentQ) {
        parseMultilineStrUpperQBlock();
        parseMultilineStrLowerQBlock();
    }

    if (rules->doStringsDblQuote) {
        parseStringDoubleQuote();
    }

    if (rules->doStringsSinQuote) {
        parseStringSingleQuote();
    }

    if (rules->doStringsBackTick) {
        parseStringBackQuote();
    }

    // Post-pass: insert interpolation boundary markers inside string spans.
    // Symbols are also parsed here so they can see the interpolation
    // boundaries.
    markInterpolations();
    if (rules->doSymbols)
        parseSymbol();

#ifdef DEBUG_DO_PARSING
    PRINT_DEBUG(1);
#endif

    if (rules->doPreProc)
        parsePreProc();

    if (rules->doBlockCommentPascal)
        parseBlockCommentPascal();
    if (rules->doBlockCommentMarkup)
        parseBlockCommentMarkup();
    if (rules->doBlockCommentPLI)
        parseBlockCommentPLI();
    if (rules->doBlockCommentHaskell)
        parseBlockCommentHaskell();
    if (rules->doHtmlTags)
        parseHtmlTags();

    if (rules->doKeywords)
        parseKeywordsAndTypes();

#ifdef DEBUG_DO_PARSING
    PRINT_DEBUG(2);
#endif

    // Scripting variables parsing
    if (rules->doScalars)
        parseVariable("$");
    if (rules->doArrays)
        parseVariable("@");
    if (rules->doHashes)
        parseVariable("%");

#ifdef DEBUG_DO_PARSING
    PRINT_DEBUG(3);
#endif

    if (rules->doNumbers)
        parseNum();

#ifdef DEBUG_DO_PARSING
    PRINT_DEBUG(4);
#endif

    if (rules->doInlineCommentDblDash) {
        parseInlineCommentDblDash();
    }
    if (rules->doInlineCommentSingleQuote) {
        parseInlineCommentSingleQuote();
    }
    if (rules->doInlineCommentDblSlash) {
        parseInlineCommentDblSlash();
    }
    if (rules->doInlineCommentHash) {
        parseInlineCommentHash();
    }
    if (rules->doInlineCommentSemiColon) {
        parseInlineCommentSemiColon();
    }
    if (rules->doInlineCommentDblColon) {
        parseInlineCommentDblColon();
    }
    if (rules->doInlineCommentRem) {
        parseInlineCommentRem();
    }
    if (rules->doFirstCharCommentFortran) {
        parseFirstCharCommentFortran();
        parseInlineCommentExclamation();
    }
    if (rules->doFirstCharCommentHash) {
        parseFirstCharCommentHash();
    }

#ifdef DEBUG_DO_PARSING
    PRINT_DEBUG(5);
#endif

    hyperTagMe();
    hyperNameMe();
    hyperLinkMe();

#ifdef DEBUG_DO_PARSING
    PRINT_DEBUG(6);
#endif

    // Strip internal interpolation boundary markers before output
    std::erase(buffer, '\x01');
    std::erase(buffer, '\x02');

    *IO << buffer << "\n";
    if (!childLang) {
        parseChildLang();
    }
    state.endMultiLine = state.inComment || state.inMultiStr;

    // A regular "..." or '...' string opened on this line can only continue
    // onto the next line if the line ends with an odd number of backslashes
    // (i.e. a genuine continuation marker).  Without it the string is either
    // complete or a syntax error and must not bleed into subsequent lines.
    //
    // Backtick strings are intentionally excluded: template literals in
    // JavaScript/TypeScript and similar languages span lines naturally
    // without any backslash, so state.inBckQuotes must persist across newlines.
    if (!lineHasContinuation && rules->doRequireBackslashContinuation) {
        state.inDblQuotes = false;
        state.inSinQuotes = false;
    }

    lncount++;
}
//-----------------------------------------------------------------------------
// write the initial HTML tags ------------------------------------------------
// place HTML tags without being stripped -------------------------------------
void Engine::hyperTagMe() {

    int index;
    index = static_cast<int>(buffer.find("TagMe:", 0));
    if (index == -1) {
        return;
    }
    if (abortColour(index)) {
        return;
    }
    buffer.erase(index, 6);

    for (int i = index; i < static_cast<int>(buffer.size()); i++) {
        if (buffer.substr(i, 4) == "&lt;")
            buffer.replace(i, 4, "<");
        else if (buffer.substr(i, 4) == "&gt;")
            buffer.replace(i, 4, ">");
    }
}
// hyperlink a line of code ---------------------------------------------------
void Engine::hyperLinkMe() {

    int index;
    index = static_cast<int>(buffer.find("LinkMe:", 0));
    if (index == -1) {
        return;
    }
    if (abortColour(index)) {
        return;
    }
    string link;
    link = buffer.substr(index + 7);
    buffer.erase(index, buffer.size() - index);

    buffer.insert(0, "<a href=\"" + link + "\">");
    buffer += "</a>";
}
// anchor a line of code ------------------------------------------------------
void Engine::hyperNameMe() {

    int index;
    index = static_cast<int>(buffer.find("NameMe:", 0));
    if (index == -1) {
        return;
    }
    if (abortColour(index)) {
        return;
    }
    string name;
    name = buffer.substr(index + 7);
    buffer.erase(index, buffer.size() - index);

    buffer.insert(0, "<a name=\"" + name + "\">");
    buffer += "</a>";
}
// automatically hyperlink included C/C++ files -------------------------------
void Engine::hyperIncludeMe() {

    int incl, insr;

    incl = static_cast<int>(buffer.find("#include", 0));
    if (incl == -1) {
        return;
    }

    insr = static_cast<int>(buffer.find("\"", incl + 1));
    if (insr == -1) {
        return;
    }

    string cmd;
    string link;
    link = buffer.substr(insr);
    link = link.substr(0, link.find("\"</font>"));

    if (options.follow) {
        // follow and process the include file

        string path;

        int dir_idx = static_cast<int>(IO->getStrIf().rfind(DIRECTORY_SLASH));

        if (dir_idx != -1) {

            path = IO->getStrIf().substr(0, dir_idx + 1);
            path = path + link.substr(1);
        } else {
            path = link.substr(1);
        }

        cmd = "webcpp " + path + " -A:f -H";
        // retain switches from the current file
        if (options.bigtab) {
            cmd += " -t";
            if (options.tabwidth != 8) {
                cmd += "=";
                cmd += options.tw;
            }
        }
        if (options.webcpp)
            cmd += " -m";
        if (options.number)
            cmd += " -l";
        if (options.anchor)
            cmd += " -a";
        if (options.htsnip)
            cmd += " -s";
        if (options.extcss)
            cmd += " -X";

        if (Scs2.getThemeName() != "typical") {
            cmd += " -c=" + Scs2.getThemeName();
        }
        if (Scs2.getImageFile() != "") {
            cmd += " -i=" + Scs2.getImageFile();
        }
        cerr << "\nSuperInclude found " + path + "\n";
        cerr << cmd << "\n";
        system(cmd.data());
    }
    // make the hyperlink
    link = "<a href=" + link + ".html\">";
    buffer.insert(insr, link);
    buffer.insert(buffer.size(), "</a>");
}
//-----------------------------------------------------------------------------
// parse for inline languages -------------------------------------------------
void Engine::parseChildLang() {

    // if(abortParse())     {return;}
    // cerr << "\nNow in parseChildLang()\n";

    switch (langext) {
    case lang::CPP_FILE:
        colourChildLangAsm();
        break;
    case lang::HTM_FILE:
        colourChildLangJS();
        colourChildLangCSS();
        break;
    default:
        return;
    }
}
// process an inline child language -------------------------------------------
void Engine::colourChildLang(const string &beg, const string &end) {

    // cerr << "\nNow in colourChildLang()\n";

    if (buffer.contains(beg)) {

        // cerr << "\nNow in if of colourChildLang()\n";

        std::unique_ptr<Engine> childEngine = nullptr;
        std::unique_ptr<LanguageRules> childRules = nullptr;

        switch (langext) {
        case lang::CPP_FILE:
            childRules = make_unique<LangAssembler>();
            childRules->setInline();
            childEngine = make_unique<Engine>(std::move(childRules));
            childEngine->setLangExt(lang::ASM_FILE);
            break;
        case lang::HTM_FILE:
            if (end == "/style") {
                childRules = make_unique<LangCSS>();
                childEngine = make_unique<Engine>(std::move(childRules));
                childEngine->setLangExt(lang::CSS_FILE);
            } else {
                childRules = make_unique<LangJScript>();
                childEngine = make_unique<Engine>(std::move(childRules));
                childEngine->setLangExt(lang::JSC_FILE);
            }
            break;
        }
        childEngine->setupIO(IO);
        childEngine->setChildLang(true);
        childEngine->setLineCount(lncount + 1);
        childEngine->options.anchor = options.anchor;
        childEngine->options.number = options.number;

        if (langext == lang::HTM_FILE && state.inComment) {
            *IO << "</font>";
        }

        do {
            childEngine->doParsing();
            // cerr << endl << Child->getBuffer() << endl;
        } while (!childEngine->getBuffer().contains(end) &&
                 (childEngine->IO->ifile && cin));

        if (langext == lang::HTM_FILE && state.inComment) {
            *IO << "<font CLASS=comment>";
        }

        setLineCount(childEngine->getLineCount() - 1);
    }
}
//-----------------------------------------------------------------------------
