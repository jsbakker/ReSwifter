/* webcpp - driver.cpp
 * Copyright (C)2001-2004, (C)2026 Jeffrey Bakker
   ___________________________________ .. .
 */

#include "driver.h"
#include "cffile.h"
#include "defsys.h"
#include "engine.h"
#include "html_writer.h"
#include "lang_factory.h"
#include "lang_rules.h"
#include "theme.h"

#include <ctime>
#include <iomanip>
#include <vector>

using std::cerr;
using std::cin;
using std::make_shared;
using std::setprecision;
using std::string;
using std::vector;

Driver::Driver() {

    lang = nullptr;
    ObjIO = nullptr;
}
Driver::~Driver() {

    clean();
    endio();
}

// toggle/set an option --------------------------------------------------------
bool Driver::switch_parser(const string &arg) {

    if (arg.starts_with("-x=")) {
        cerr << checkExt("." + arg.substr(3)) << " type forced.\n";
        prep_files(iFile, oFile, 0x66);
    } else if (arg.starts_with("-c=")) {
        lang->Scs2.setFile(arg.substr(3));
    } else if (arg.starts_with("-t=")) {
        lang->options.toggleBigtab();
        lang->options.setTabWidth(arg.substr(3));
    } else if (arg == "--tabs-spaces" || arg == "-t") {
        lang->options.toggleBigtab();
    } else if (arg == "--snippet-only" || arg == "-s") {
        lang->options.toggleHtSnip();
        lang->Scs2.toggleSnippet();
    }

    return true;
}
// determines the filetype for syntax highlighting ----------------------------
uint8_t Driver::getExt(const string &filename) const {

    return LanguageFactory::getLanguageId(filename);
}
// determines the language for syntax highlighting ----------------------------
string Driver::checkExt(const string &filename) {

    clean();

    auto info = LanguageFactory::createFromFilename(filename);
    lang = std::make_unique<Engine>(std::move(info.rules));
    lang->setLangExt(info.id);
    return info.name;
}
//-----------------------------------------------------------------------------
// prepare input and output files ---------------------------------------------
bool Driver::prep_files(const string &ifile, const string &ofile, char over) {

    string resolvedOutput = ofile;
    if (resolvedOutput == "--auto" || resolvedOutput == "-A") {
        resolvedOutput = ifile + ".html";
    }

    iFile = ifile;
    oFile = resolvedOutput;

    endio();
    ObjIO = make_shared<CFfile>();
    //	ObjIO->init_switches();

    if (ifile == "-" || ifile == "--pipe") {
        ObjIO->toggleImode();
    } else if (!ObjIO->openR(ifile)) {
        return false;
    }

    if (resolvedOutput == "-" || resolvedOutput == "--pipe") {
        ObjIO->toggleOmode();
    } else if (!ObjIO->open(resolvedOutput, over)) {
        return false;
    }

    lang->setupIO(ObjIO);

    // over?FORCE_OVERWRITE:MODE_WRITE)
    return true;
}
// returns the filename without the full path ---------------------------------
string Driver::getTitle() const {

    auto slashPos = iFile.rfind(DIRECTORY_SLASH);
    if (slashPos == string::npos) {
        return iFile;
    }
    return iFile.substr(slashPos + 1);
}
// run the webcpp engine ------------------------------------------------------
void Driver::drive() {

    clock_t time_beg, time_end, time_dif;
    time_beg = clock();

    HtmlWriter::writeDocumentStart(lang->IO, lang->Scs2, lang->options, getTitle());
    lang->doParsing();
    while (lang->IO->ifile && cin) {
        lang->doParsing();
    }
    HtmlWriter::writeDocumentEnd(lang->IO, lang->options);

    time_end = clock();
    time_dif = time_end - time_beg;

    cerr << "Parsing took " << setprecision(3) << (double)time_dif / CYCLE_SPEED
         << " seconds.\n";

    lang->IO->close();
}
//-----------------------------------------------------------------------------
void Driver::makeIndex(const string &prefix) {

    CFfile Index;
    if (!Index.openR("webcppbatch.txt")) {
        return;
    }
    if (!Index.openW(prefix + "files.html", true)) {
        return;
    }

    string file;
    Theme theme;

    Index << "<html>\n<head>\n<title>source index</title>\n"
          << "<style type=\"text/css\">\n\n"
          << theme.getCSSdata() << "</style>\n"
          << "</head>\n<body>\n\n";

    getline(Index.ifile, file);
    while (Index.ifile) {

        file = "<a href=\"" + file + ".html\">" + file + "</a>";

        Index << file << "<br>\n";
        getline(Index.ifile, file);
    }

    Index << "\n</body>\n</html>";
}
// highlight source code string in memory, returning HTML -----------------------
string Driver::highlight_from_string(const string &source,
                                     const string &filename,
                                     const vector<string> &options) {
    checkExt(filename);

    // Snippet-only mode by default — no full HTML document wrapper
    switch_parser("-s");

    for (const auto &opt : options) {
        switch_parser(opt);
    }

    auto io = make_shared<CFfile>();
    io->openStringR(source);
    io->openStringW();
    lang->setupIO(io);

    HtmlWriter::writeDocumentStart(lang->IO, lang->Scs2, lang->options, filename);

    // Process all lines until the input stream is exhausted
    lang->doParsing();
    while (lang->IO->isInputGood()) {
        lang->doParsing();
    }

    HtmlWriter::writeDocumentEnd(lang->IO, lang->options);

    return io->getStringW();
}
//-----------------------------------------------------------------------------
void Driver::clean() {
    lang = nullptr;
}
void Driver::endio() {
    ObjIO = nullptr;
}
//-----------------------------------------------------------------------------
