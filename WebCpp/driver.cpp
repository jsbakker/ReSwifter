/* webcpp - driver.cpp
 * Copyright (C)2001-2004, (C)2026 Jeffrey Bakker
   ___________________________________ .. .
 */

#define LANG(x, y)                                                             \
    lang = new (x);                                                            \
    lang->setLangExt(filetype);                                                \
    return (y)

#include "driver.h"
#include "deflangs.h"

#include <ctime>
#include <iomanip>
using namespace std;

Driver::Driver() {

    lang = NULL;
    ObjIO = NULL;
}
Driver::~Driver() {

    clean();
    endio();
}

// toggle/set an option --------------------------------------------------------
bool Driver::switch_parser(string arg) {

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
char Driver::getExt(string filename) {
    int dot;
    char ext;

    string extension = "";
    dot = filename.rfind(".");

    if (dot != -1) {
        extension = filename.substr(dot + 1, filename.size() - dot);
    }
    for (int i = 0; i < extension.size(); i++) {
        extension[i] = tolower(extension[i]);
    }

    if (extension == "adb") {
        ext = ADA_FILE;
    } else if (extension == "ads") {
        ext = ADA_FILE;
    } else if (extension == "ali") {
        ext = ADA_FILE;
    } else if (extension == "asm") {
        ext = ASM_FILE;
    } else if (extension == "asp") {
        ext = ASP_FILE;
    } else if (extension == "asa") {
        ext = ASP_FILE;
    } else if (extension == "s") {
        ext = ASM_FILE;
    } else if (extension == "bas") {
        ext = BAS_FILE;
    } else if (extension == "bat") {
        ext = DOS_FILE;
    } else if (extension == "cmd") {
        ext = DOS_FILE;
    } else if (extension == "c") {
        ext = C99_FILE;
    } else if (extension == "rc") {
        ext = C99_FILE;
    } else if (extension == "cc") {
        ext = CPP_FILE;
    } else if (extension == "cpp") {
        ext = CPP_FILE;
    } else if (extension == "coo") {
        ext = CPP_FILE;
    } else if (extension == "c++") {
        ext = CPP_FILE;
    } else if (extension == "cxx") {
        ext = CPP_FILE;
    } else if (extension == "h") {
        ext = CPP_FILE;
    } else if (extension == "hh") {
        ext = CPP_FILE;
    } else if (extension == "hpp") {
        ext = CPP_FILE;
    } else if (extension == "hxx") {
        ext = CPP_FILE;
    } else if (extension == "cg") {
        ext = C4G_FILE;
    } else if (extension == "clp") {
        ext = CLP_FILE;
    } else if (extension == "cs") {
        ext = CSP_FILE;
    } else if (extension == "m") {
        ext = OBC_FILE;
    } else if (extension == "mm") {
        ext = OCP_FILE;
    } else if (extension == "emf") {
        ext = EMF_FILE;
    } else if (extension == "e") {
        ext = EU4_FILE;
    } else if (extension == "eu") {
        ext = EU4_FILE;
    } else if (extension == "ex") {
        ext = EU4_FILE;
    } else if (extension == "f") {
        ext = FTN_FILE;
    } else if (extension == "for") {
        ext = FTN_FILE;
    } else if (extension == "ftn") {
        ext = FTN_FILE;
    } else if (extension == "f77") {
        ext = FTN_FILE;
    } else if (extension == "f90") {
        ext = FTN_FILE;
    } else if (extension == "hs") {
        ext = HSK_FILE;
    } else if (extension == "lhs") {
        ext = HSK_FILE;
    } else if (extension == "shtm") {
        ext = HTM_FILE;
    } else if (extension == "html") {
        ext = HTM_FILE;
    } else if (extension == "htm") {
        ext = HTM_FILE;
    } else if (extension == "xml") {
        ext = XML_FILE;
    } else if (extension == "sgml") {
        ext = HTM_FILE;
    } else if (extension == "java") {
        ext = JAV_FILE;
    } else if (extension == "js") {
        ext = JSC_FILE;
    } else if (extension == "def") {
        ext = MOD_FILE;
    } else if (extension == "mod") {
        ext = MOD_FILE;
    } else if (extension == "pas") {
        ext = PAS_FILE;
    } else if (extension == "cgi") {
        ext = PRL_FILE;
    } else if (extension == "plex") {
        ext = PRL_FILE;
    } else if (extension == "plx") {
        ext = PRL_FILE;
    } else if (extension == "pl") {
        ext = PRL_FILE;
    } else if (extension == "pm") {
        ext = PRL_FILE;
    } else if (extension == "inc") {
        ext = PHP_FILE;
    } else if (extension == "php4") {
        ext = PHP_FILE;
    } else if (extension == "php3") {
        ext = PHP_FILE;
    } else if (extension == "php") {
        ext = PHP_FILE;
    } else if (extension == "pbl") {
        ext = PB6_FILE;
    } else if (extension == "pbr") {
        ext = PB6_FILE;
    } else if (extension == "pyw") {
        ext = PYT_FILE;
    } else if (extension == "py") {
        ext = PYT_FILE;
    } else if (extension == "sl") {
        ext = RND_FILE;
    } else if (extension == "rib") {
        ext = RND_FILE;
    } else if (extension == "rb") {
        ext = RUB_FILE;
    } else if (extension == "sql") {
        ext = SQL_FILE;
    } else if (extension == "sh") {
        ext = UNX_FILE;
    } else if (extension == "swift") {
        ext = SWF_FILE;
    } else if (extension == "tcl") {
        ext = TCL_FILE;
    } else if (extension == "tk") {
        ext = TCL_FILE;
    } else if (extension == "uc") {
        ext = UNR_FILE;
    } else if (extension == "v") {
        ext = VHD_FILE;
    } else if (extension == "vhdl") {
        ext = VHD_FILE;
    } else if (extension == "vhd") {
        ext = VHD_FILE;
    } else if (extension == "css") {
        ext = CSS_FILE;
    } else if (extension == "rs") {
        ext = RST_FILE;
    } else if (extension == "go") {
        ext = GOL_FILE;
    } else if (extension == "ts") {
        ext = TSC_FILE;
    } else if (extension == "tsx") {
        ext = TSC_FILE;
    } else if (extension == "kt") {
        ext = KOT_FILE;
    } else if (extension == "kts") {
        ext = KOT_FILE;
    } else if (extension == "vala") {
        ext = VLA_FILE;
    } else if (extension == "vapi") {
        ext = VLA_FILE;
    } else if (extension == "zig") {
        ext = ZIG_FILE;
    } else if (extension == "glsl") {
        ext = GLS_FILE;
    } else if (extension == "vert") {
        ext = GLS_FILE;
    } else if (extension == "frag") {
        ext = GLS_FILE;
    } else if (extension == "geom") {
        ext = GLS_FILE;
    } else if (extension == "tesc") {
        ext = GLS_FILE;
    } else if (extension == "tese") {
        ext = GLS_FILE;
    } else if (extension == "comp") {
        ext = GLS_FILE;
    } else if (extension == "hlsl") {
        ext = HLS_FILE;
    } else if (extension == "hlsli") {
        ext = HLS_FILE;
    } else if (extension == "r") {
        ext = R_FILE;
    } else if (extension == "feature") {
        ext = GHK_FILE;
    } else if (extension == "fs") {
        ext = FSH_FILE;
    } else if (extension == "fsi") {
        ext = FSH_FILE;
    } else if (extension == "fsx") {
        ext = FSH_FILE;
    } else if (extension == "scala") {
        ext = SCA_FILE;
    } else if (extension == "sc") {
        ext = SCA_FILE;
    } else if (extension == "ml") {
        ext = OML_FILE;
    } else if (extension == "mli") {
        ext = OML_FILE;
    }

    else
        ext = TXT_FILE;
    return ext;
}
// determines the language for syntax highlighting ----------------------------
string Driver::checkExt(string filename) {

    clean();

    char filetype = getExt(filename);

    switch (filetype) {
    case (ADA_FILE):
        LANG(LangAda, "Ada file");
    case (ASM_FILE):
        LANG(LangAssembler, "Assembly file");
    case (ASP_FILE):
        LANG(LangAsp, "ASP file");
    case (BAS_FILE):
        LANG(LangBasic, "Basic file");
    case (DOS_FILE):
        LANG(LangBatch, "DOS Batch file");
    case (C99_FILE):
        LANG(LangC, "'C' file");
    case (CPP_FILE):
        LANG(LangCPlusPlus, "C++ file");
    case (C4G_FILE):
        LANG(LangCg, "NVIDIA Cg file");
    case (CLP_FILE):
        LANG(LangClips, "NASA CLIPS file");
    case (CSS_FILE):
        LANG(LangCSS, "CSS file");
    case (CSP_FILE):
        LANG(LangCSharp, "C-Sharp file");
    case (OBC_FILE):
        LANG(LangObjectiveC, "Objective-C file");
    case (OCP_FILE):
        LANG(LangObjectiveCpp, "Objective-C++ file");
    case (EMF_FILE):
        LANG(LangEmf, "MicroEmacs macro file");
    case (EU4_FILE):
        LANG(LangEuphoria, "Euphoria file");
    case (FTN_FILE):
        LANG(LangFortran, "Fortran file");
    case (HSK_FILE):
        LANG(LangHaskell, "Haskell file");
    case (HTM_FILE):
        LANG(LangHtml, "Markup file");
    case (JAV_FILE):
        LANG(LangJava, "Java file");
    case (JSC_FILE):
        LANG(LangJScript, "Java script");
    case (MOD_FILE):
        LANG(LangModula2, "Modula file");
    case (PAS_FILE):
        LANG(LangPascal, "Pascal file");
    case (PRL_FILE):
        LANG(LangPerl, "Perl script");
    case (PHP_FILE):
        LANG(LangPhp, "PHP script");
    case (PB6_FILE):
        LANG(LangPBuilder, "Power Builder file");
    case (PYT_FILE):
        LANG(LangPython, "Python script");
    case (RUB_FILE):
        LANG(LangRuby, "Ruby script");
    case (RND_FILE):
        LANG(LangRenderMan, "RenderMan file");
    case (SQL_FILE):
        LANG(LangSQL, "SQL script");
    case (SWF_FILE):
        LANG(LangSwift, "Swift file");
    case (UNX_FILE):
        LANG(LangShell, "UNIX shell script");
    case (TCL_FILE):
        LANG(LangTcl, "Tcl script");
    case (UNR_FILE):
        LANG(LangUScript, "UnrealScript");
    case (VHD_FILE):
        LANG(LangVHDL, "VHDL file");
    case (XML_FILE):
        LANG(LangXML, "XML file");
    case (RST_FILE):
        LANG(LangRust, "Rust file");
    case (GOL_FILE):
        LANG(LangGo, "Go file");
    case (TSC_FILE):
        LANG(LangTypeScript, "TypeScript file");
    case (KOT_FILE):
        LANG(LangKotlin, "Kotlin file");
    case (VLA_FILE):
        LANG(LangVala, "Vala file");
    case (ZIG_FILE):
        LANG(LangZig, "Zig file");
    case (GLS_FILE):
        LANG(LangGLSL, "GLSL file");
    case (HLS_FILE):
        LANG(LangHLSL, "HLSL file");
    case (R_FILE):
        LANG(LangR, "R file");
    case (GHK_FILE):
        LANG(LangGherkin, "Gherkin feature file");
    case (FSH_FILE):
        LANG(LangFSharp, "F# file");
    case (SCA_FILE):
        LANG(LangScala, "Scala file");
    case (OML_FILE):
        LANG(LangOCaml, "OCaml file");
    default:
        LANG(LangText, "Text file");
    }
}
//-----------------------------------------------------------------------------
// prepare input and output files ---------------------------------------------
bool Driver::prep_files(string ifile, string ofile, char over) {

    if (ofile == "--auto" || ofile == "-A") {
        ofile = ifile + ".html";
    }

    iFile = ifile;
    oFile = ofile;

    endio();
    ObjIO = new CFfile;
    //	ObjIO->init_switches();

    if (ifile == "-" || ifile == "--pipe") {
        ObjIO->toggleImode();
    } else if (!ObjIO->openR(ifile)) {
        return false;
    }

    if (ofile == "-" || ofile == "--pipe") {
        ObjIO->toggleOmode();
    } else if (!ObjIO->open(ofile, over)) {
        return false;
    }

    lang->setupIO(ObjIO);

    // over?FORCE_OVERWRITE:MODE_WRITE)
    return true;
}
// returns the filename without the full path ---------------------------------
string Driver::getTitle() {

    int slash = iFile.rfind(DIRECTORY_SLASH);
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
void Driver::makeIndex(string prefix) {

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

    if (lang != NULL) {
        delete lang;
        lang = NULL;
    }
}
void Driver::endio() {

    if (ObjIO != NULL) {
        delete ObjIO;
        ObjIO = NULL;
    }
}
//-----------------------------------------------------------------------------
