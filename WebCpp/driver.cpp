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

using std::cerr;
using std::cin;
using std::ifstream;
using std::make_shared;
using std::setprecision;
using std::string;

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

    if (arg.substr(0, 3) == "-x=") {
        cerr << checkExt("." + arg.substr(3)) << " type forced.\n";
        prep_files(iFile, oFile, 0x66);
    } else if (arg.substr(0, 3) == "-c=") {
        lang->Scs2.setFile(arg.substr(3));
    } else if (arg.substr(0, 3) == "-C=") {
        lang->options.toggleExtcss();
        lang->Scs2.setFile(arg.substr(3));
    } else if (arg.substr(0, 3) == "-i=") {
        lang->Scs2.setPicture(arg.substr(3));
    } else if (arg.substr(0, 3) == "-t=") {
        lang->options.toggleBigtab();
        lang->options.setTabWidth(arg.substr(3));
    } else if (arg.substr(0, 3) == "-w=") {
        lang->options.toggleNumber();
        lang->options.toggleAnchor();
        lang->options.toggleHypinc();
        lang->options.toggleWebcpp();
        lang->Scs2.setFile(arg.substr(3));
    } else if (arg.substr(0, 3) == "-W=") {
        lang->options.toggleNumber();
        lang->options.toggleAnchor();
        lang->options.toggleHypinc();
        lang->options.toggleWebcpp();
        lang->options.toggleExtcss();
        lang->Scs2.setFile(arg.substr(3));
    } else if (arg == "--external-css" || arg == "-X") {
        lang->options.toggleExtcss();
    } else if (arg == "--superinclude" || arg == "-H") {
        lang->options.toggleHypinc();
        lang->options.toggleFollow();
    } else if (arg == "--hyperinclude" || arg == "-h") {
        lang->options.toggleHypinc();
    } else if (arg == "--anchor-lines" || arg == "-a") {
        lang->options.toggleAnchor();
    } else if (arg == "--line-numbers" || arg == "-l") {
        lang->options.toggleNumber();
    } else if (arg == "--tabs-spaces" || arg == "-t") {
        lang->options.toggleBigtab();
    } else if (arg == "--made-with" || arg == "-m") {
        lang->options.toggleWebcpp();
    } else if (arg == "--snippet-only" || arg == "-s") {
        lang->options.toggleHtSnip();
        lang->Scs2.toggleSnippet();
    } else if (arg == "--the-works" || arg == "-w") {
        lang->options.toggleNumber();
        lang->options.toggleAnchor();
        lang->options.toggleHypinc();
        lang->options.toggleWebcpp();
    } else {
        help(HELP_DEFAULT);
        return false;
    }

    return true;
}
// print help ----------------------------------------------------------------
void Driver::help(char mode) {

    string Usage;

    Usage = "\
Usage: $ webcpp <infile> <outfile> [options...]\n\
\n\
Options:\n\
  -c=<scheme>        Use a webcpp colour scheme.\n\
  -w=<scheme>        The works, same as -m -l -a -h -c=<scheme>.\n\
  -i=<filename>      Use an image for the background.\n\
  -t=<width>         Convert tabs to spaces using the specified width.\n\
  -x=<extension>     Force the filetype for syntax highlighting.\n\
  -X,--external-css  Generate an external stylesheet.\n\
  -s,--snippet-only  Don't generate HTML and BODY tags.\n\
  -l,--line-numbers  Print the line numbers in the left margin.\n\
  -a,--anchor-lines  Create anchors to line numbers.\n\
  -h,--hyperinclude  Create hyperlinks to #include statements.\n\
  -H,--superinclude  Hyperinclude that recursively genera.tes files.\n\
  -t,--tabs-spaces   Convert tabs to spaces, default width is 8.\n\
  -m,--made-with     Show made with webcpp footer.\n\
  -A,--auto          Automatic naming in place of the output file.\n\
  - ,--pipe          Use STDIN or STDOUT in place of the filename.\n\
\n\
 Type `webcpp --languages` to see supported languages and filetypes.\n";

    string Langs = "\
Ada\t\t*.adb,*.ads,*.ali\n\
Assembly\t*.asm,*.s\n\
Asp\t\t*.asp,*.asa\n\
Basic\t\t*.bas\n\
C#\t\t*.cs\n\
C Source\t*.c,*.rc\n\
C++ Source\t*.cc,*.cpp,*.cxx\n\
C/C++ Header\t*.h,*.hh,*.hpp,*.hxx\n\
CSS\t\t*.css\n\
DOS Batch\t*.bat,*.cmd\n\
EMF\t\t*.emf\n\
Euphoria\t*.e,*.eu,*.ex\n\
F#\t\t*.fs,*.fsi,*.fsx\n\
Fortran\t\t*.f,*.f77,*.f90,*.for,*.ftn\n\
Gherkin\t\t*.feature\n\
GLSL\t\t*.glsl,*.vert,*.frag,*.geom,*.tesc,*.tese,*.comp\n\
Go\t\t*.go\n\
Haskell\t\t*.hs,*.lhs\n\
HLSL\t\t*.hlsl,*.hlsli\n\
Java\t\t*.java\n\
JavaScript\t*.js\n\
Kotlin\t\t*.kt,*.kts\n\
Markup\t\t*.htm,*.html,*.shtml,*.sgml\n\
Modula2\t\t*.def,*.mod\n\
Nasa CLIPS\t*.clp\n\
NVidia Cg\t*.cg\n\
Objective-C\t*.m\n\
Objective-C++\t*.mm\n\
OCaml\t\t*.ml,*.mli\n\
Pascal\t\t*.pas\n\
Perl\t\t*.cgi,*.pl,*.plx,*.plex,*.pm\n\
PHP\t\t*.inc,*.php,*.php3,*.php4\n\
Power Builder\t*.pbl,*.pbr\n\
Python\t\t*.py,*.pyw\n\
R\t\t*.r\n\
RenderMan\t*.rib,*.sl\n\
Ruby\t\t*.rb\n\
Rust\t\t*.rs\n\
Scala\t\t*.scala,*.sc\n\
SQL\t\t*.sql\n\
Swift\t\t*.swift\n\
Tcl\t\t*.tcl,*.tk\n\
TypeScript\t*.ts,*.tsx\n\
Unix shell\t*.sh\n\
UnrealScript\t*.uc\n\
Vala\t\t*.vala,*.vapi\n\
VHDL\t\t*.v,*.vhd,*.vhdl\n\
XML\t\t*.xml\n\
Zig\t\t*.zig\n";

    cerr << "Web C Plus Plus v0.9.0  "
         << "Copyright (C)2001-2026 Jeffrey Bakker\n"
         << "Compiled " << __DATE__ << " at " << __TIME__ << "\n\n"
         << ((mode == HELP_LANGUAGES) ? Langs : Usage);
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

    int slash = static_cast<int>(iFile.rfind(DIRECTORY_SLASH));
    if (slash == -1) {
        return iFile;
    }
    return iFile.substr(slash + 1);
}
// run the webcpp engine ------------------------------------------------------
void Driver::drive() {

    clock_t time_beg, time_end, time_dif;
    time_beg = clock();

    // get the filesize
    ifstream Count;
    string tmp;
    int percent = 0;

    Count.open(iFile.data());
    while (Count) {
        getline(Count, tmp);
        percent++;
    }
    percent--;
    Count.close();
    // to compare against progress

    HtmlWriter::writeDocumentStart(lang->IO, lang->Scs2, lang->options, getTitle());
    lang->doParsing();
    while (lang->IO->ifile && cin) {
        lang->doParsing();

//        if( ((lang->getLineCount()*100)/percent) < 101 ) {
//
//            cerr << '\r';
//
//            if(!lang->IO->isIredir()) {
//
//                cerr	<< ((lang->getLineCount() * 100) / percent)
//                    << "% Complete ";
//            }
//            cerr << "@ line " << lang->getLineCount()-1;
//        }
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
//-----------------------------------------------------------------------------
void Driver::clean() {

    if (lang != nullptr) {
        lang = nullptr;
    }
}
void Driver::endio() {

    if (ObjIO != nullptr) {
        ObjIO = nullptr;
    }
}
//-----------------------------------------------------------------------------
