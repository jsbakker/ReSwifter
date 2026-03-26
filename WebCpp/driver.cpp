/* webcpp - driver.cpp
 * Copyright (C)2001-2004, (C)2026 Jeffrey Bakker
   ___________________________________ .. .
 */

#include "driver.h"
#include "deflangs.h"

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
        lang->toggleExtcss();
        lang->Scs2.setFile(arg.substr(3));
    } else if (arg.substr(0, 3) == "-i=") {
        lang->Scs2.setPicture(arg.substr(3));
    } else if (arg.substr(0, 3) == "-t=") {
        lang->toggleBigtab();
        lang->setTabWidth(arg.substr(3));
    } else if (arg.substr(0, 3) == "-w=") {
        lang->toggleNumber();
        lang->toggleAnchor();
        lang->toggleHypinc();
        lang->toggleWebcpp();
        lang->Scs2.setFile(arg.substr(3));
    } else if (arg.substr(0, 3) == "-W=") {
        lang->toggleNumber();
        lang->toggleAnchor();
        lang->toggleHypinc();
        lang->toggleWebcpp();
        lang->toggleExtcss();
        lang->Scs2.setFile(arg.substr(3));
    } else if (arg == "--external-css" || arg == "-X") {
        lang->toggleExtcss();
    } else if (arg == "--superinclude" || arg == "-H") {
        lang->toggleHypinc();
        lang->toggleFollow();
    } else if (arg == "--hyperinclude" || arg == "-h") {
        lang->toggleHypinc();
    } else if (arg == "--anchor-lines" || arg == "-a") {
        lang->toggleAnchor();
    } else if (arg == "--line-numbers" || arg == "-l") {
        lang->toggleNumber();
    } else if (arg == "--tabs-spaces" || arg == "-t") {
        lang->toggleBigtab();
    } else if (arg == "--made-with" || arg == "-m") {
        lang->toggleWebcpp();
    } else if (arg == "--snippet-only" || arg == "-s") {
        lang->toggleHtSnip();
        lang->Scs2.toggleSnippet();
    } else if (arg == "--the-works" || arg == "-w") {
        lang->toggleNumber();
        lang->toggleAnchor();
        lang->toggleHypinc();
        lang->toggleWebcpp();
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

    static const std::unordered_map<std::string, uint8_t> extensionMap = {
        {"adb", lang::ADA_FILE},     {"ads", lang::ADA_FILE},
        {"ali", lang::ADA_FILE},     {"asm", lang::ASM_FILE},
        {"s", lang::ASM_FILE},       {"asp", lang::ASP_FILE},
        {"asa", lang::ASP_FILE},     {"bas", lang::BAS_FILE},
        {"bat", lang::DOS_FILE},     {"cmd", lang::DOS_FILE},
        {"c", lang::C99_FILE},       {"rc", lang::C99_FILE},
        {"cc", lang::CPP_FILE},      {"cpp", lang::CPP_FILE},
        {"coo", lang::CPP_FILE},     {"c++", lang::CPP_FILE},
        {"cxx", lang::CPP_FILE},     {"h", lang::CPP_FILE},
        {"hh", lang::CPP_FILE},      {"hpp", lang::CPP_FILE},
        {"hxx", lang::CPP_FILE},     {"cg", lang::C4G_FILE},
        {"clp", lang::CLP_FILE},     {"cs", lang::CSP_FILE},
        {"m", lang::OBC_FILE},       {"mm", lang::OCP_FILE},
        {"emf", lang::EMF_FILE},     {"e", lang::EU4_FILE},
        {"eu", lang::EU4_FILE},      {"ex", lang::EU4_FILE},
        {"f", lang::FTN_FILE},       {"for", lang::FTN_FILE},
        {"ftn", lang::FTN_FILE},     {"f77", lang::FTN_FILE},
        {"f90", lang::FTN_FILE},     {"hs", lang::HSK_FILE},
        {"lhs", lang::HSK_FILE},     {"shtm", lang::HTM_FILE},
        {"html", lang::HTM_FILE},    {"htm", lang::HTM_FILE},
        {"sgml", lang::HTM_FILE},    {"xml", lang::XML_FILE},
        {"java", lang::JAV_FILE},    {"js", lang::JSC_FILE},
        {"def", lang::MOD_FILE},     {"mod", lang::MOD_FILE},
        {"pas", lang::PAS_FILE},     {"cgi", lang::PRL_FILE},
        {"plex", lang::PRL_FILE},    {"plx", lang::PRL_FILE},
        {"pl", lang::PRL_FILE},      {"pm", lang::PRL_FILE},
        {"inc", lang::PHP_FILE},     {"php4", lang::PHP_FILE},
        {"php3", lang::PHP_FILE},    {"php", lang::PHP_FILE},
        {"pbl", lang::PB6_FILE},     {"pbr", lang::PB6_FILE},
        {"pyw", lang::PYT_FILE},     {"py", lang::PYT_FILE},
        {"sl", lang::RND_FILE},      {"rib", lang::RND_FILE},
        {"rb", lang::RUB_FILE},      {"sql", lang::SQL_FILE},
        {"sh", lang::UNX_FILE},      {"swift", lang::SWF_FILE},
        {"tcl", lang::TCL_FILE},     {"tk", lang::TCL_FILE},
        {"uc", lang::UNR_FILE},      {"v", lang::VHD_FILE},
        {"vhdl", lang::VHD_FILE},    {"vhd", lang::VHD_FILE},
        {"css", lang::CSS_FILE},     {"rs", lang::RST_FILE},
        {"go", lang::GOL_FILE},      {"ts", lang::TSC_FILE},
        {"tsx", lang::TSC_FILE},     {"kt", lang::KOT_FILE},
        {"kts", lang::KOT_FILE},     {"vala", lang::VLA_FILE},
        {"vapi", lang::VLA_FILE},    {"zig", lang::ZIG_FILE},
        {"glsl", lang::GLS_FILE},    {"vert", lang::GLS_FILE},
        {"frag", lang::GLS_FILE},    {"geom", lang::GLS_FILE},
        {"tesc", lang::GLS_FILE},    {"tese", lang::GLS_FILE},
        {"comp", lang::GLS_FILE},    {"hlsl", lang::HLS_FILE},
        {"hlsli", lang::HLS_FILE},   {"r", lang::R_FILE},
        {"feature", lang::GHK_FILE}, {"fs", lang::FSH_FILE},
        {"fsi", lang::FSH_FILE},     {"fsx", lang::FSH_FILE},
        {"scala", lang::SCA_FILE},   {"sc", lang::SCA_FILE},
        {"ml", lang::OML_FILE},      {"mli", lang::OML_FILE}};

    // Extract extension
    size_t dotPos = filename.find_last_of('.');
    if (dotPos == std::string::npos)
        return lang::TXT_FILE;

    std::string extension = filename.substr(dotPos + 1);

    // Convert to lowercase
    std::transform(extension.begin(), extension.end(), extension.begin(),
                   [](unsigned char c) { return std::tolower(c); });

    // Lookup
    auto it = extensionMap.find(extension);
    return (it != extensionMap.end()) ? it->second : lang::TXT_FILE;
}
// determines the language for syntax highlighting ----------------------------
string Driver::checkExt(const string &filename) {

    clean();

    char filetype = getExt(filename);

    switch (filetype) {
    case (lang::ADA_FILE):
        return setLanguage<LangAda>(filetype, "Ada file");
    case (lang::ASM_FILE):
        return setLanguage<LangAssembler>(filetype, "Assembly file");
    case (lang::ASP_FILE):
        return setLanguage<LangAsp>(filetype, "ASP file");
    case (lang::BAS_FILE):
        return setLanguage<LangBasic>(filetype, "Basic file");
    case (lang::DOS_FILE):
        return setLanguage<LangBatch>(filetype, "DOS Batch file");
    case (lang::C99_FILE):
        return setLanguage<LangC>(filetype, "'C' file");
    case (lang::CPP_FILE):
        return setLanguage<LangCPlusPlus>(filetype, "C++ file");
    case (lang::C4G_FILE):
        return setLanguage<LangCg>(filetype, "NVIDIA Cg file");
    case (lang::CLP_FILE):
        return setLanguage<LangClips>(filetype, "NASA CLIPS file");
    case (lang::CSS_FILE):
        return setLanguage<LangCSS>(filetype, "CSS file");
    case (lang::CSP_FILE):
        return setLanguage<LangCSharp>(filetype, "C-Sharp file");
    case (lang::OBC_FILE):
        return setLanguage<LangObjectiveC>(filetype, "Objective-C file");
    case (lang::OCP_FILE):
        return setLanguage<LangObjectiveCpp>(filetype, "Objective-C++ file");
    case (lang::EMF_FILE):
        return setLanguage<LangEmf>(filetype, "MicroEmacs macro file");
    case (lang::EU4_FILE):
        return setLanguage<LangEuphoria>(filetype, "Euphoria file");
    case (lang::FTN_FILE):
        return setLanguage<LangFortran>(filetype, "Fortran file");
    case (lang::HSK_FILE):
        return setLanguage<LangHaskell>(filetype, "Haskell file");
    case (lang::HTM_FILE):
        return setLanguage<LangHtml>(filetype, "Markup file");
    case (lang::JAV_FILE):
        return setLanguage<LangJava>(filetype, "Java file");
    case (lang::JSC_FILE):
        return setLanguage<LangJScript>(filetype, "JavaScript file");
    case (lang::MOD_FILE):
        return setLanguage<LangModula2>(filetype, "Modula file");
    case (lang::PAS_FILE):
        return setLanguage<LangPascal>(filetype, "Pascal file");
    case (lang::PRL_FILE):
        return setLanguage<LangPerl>(filetype, "Perl script");
    case (lang::PHP_FILE):
        return setLanguage<LangPhp>(filetype, "PHP script");
    case (lang::PB6_FILE):
        return setLanguage<LangPBuilder>(filetype, "Power Builder file");
    case (lang::PYT_FILE):
        return setLanguage<LangPython>(filetype, "Python script");
    case (lang::RUB_FILE):
        return setLanguage<LangRuby>(filetype, "Ruby script");
    case (lang::RND_FILE):
        return setLanguage<LangRenderMan>(filetype, "RenderMan file");
    case (lang::SQL_FILE):
        return setLanguage<LangSQL>(filetype, "SQL script");
    case (lang::SWF_FILE):
        return setLanguage<LangSwift>(filetype, "Swift file");
    case (lang::UNX_FILE):
        return setLanguage<LangShell>(filetype, "UNIX shell script");
    case (lang::TCL_FILE):
        return setLanguage<LangTcl>(filetype, "Tcl script");
    case (lang::UNR_FILE):
        return setLanguage<LangUScript>(filetype, "UnrealScript file");
    case (lang::VHD_FILE):
        return setLanguage<LangVHDL>(filetype, "VHDL file");
    case (lang::XML_FILE):
        return setLanguage<LangXML>(filetype, "XML file");
    case (lang::RST_FILE):
        return setLanguage<LangRust>(filetype, "Rust file");
    case (lang::GOL_FILE):
        return setLanguage<LangGo>(filetype, "Go file");
    case (lang::TSC_FILE):
        return setLanguage<LangTypeScript>(filetype, "TypeScript file");
    case (lang::KOT_FILE):
        return setLanguage<LangKotlin>(filetype, "Kotlin file");
    case (lang::VLA_FILE):
        return setLanguage<LangVala>(filetype, "Vala file");
    case (lang::ZIG_FILE):
        return setLanguage<LangZig>(filetype, "Zig file");
    case (lang::GLS_FILE):
        return setLanguage<LangGLSL>(filetype, "GLSL file");
    case (lang::HLS_FILE):
        return setLanguage<LangHLSL>(filetype, "HLSL file");
    case (lang::R_FILE):
        return setLanguage<LangR>(filetype, "R file");
    case (lang::GHK_FILE):
        return setLanguage<LangGherkin>(filetype, "Gherkin feature file");
    case (lang::FSH_FILE):
        return setLanguage<LangFSharp>(filetype, "F# file");
    case (lang::SCA_FILE):
        return setLanguage<LangScala>(filetype, "Scala file");
    case (lang::OML_FILE):
        return setLanguage<LangOCaml>(filetype, "OCaml file");
    default:
        return setLanguage<LangText>(filetype, "Text file");
    }
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

    lang->begHtml(getTitle());
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
    lang->endHtml();

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
