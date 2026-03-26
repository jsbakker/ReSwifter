/* webcpp - lang_factory.cpp
 * Copyright (C)2026 Jeffrey Bakker
   ___________________________________ .. .
 */

#include "lang_factory.h"
#include "deflangs.h"

#include <algorithm>
#include <cctype>
#include <unordered_map>

using std::make_unique;
using std::string;

uint8_t LanguageFactory::getLanguageId(const string &filename) {

    static const std::unordered_map<string, uint8_t> extensionMap = {
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
    if (dotPos == string::npos)
        return lang::TXT_FILE;

    string extension = filename.substr(dotPos + 1);

    // Convert to lowercase
    std::transform(extension.begin(), extension.end(), extension.begin(),
                   [](unsigned char c) { return std::tolower(c); });

    // Lookup
    auto it = extensionMap.find(extension);
    return (it != extensionMap.end()) ? it->second : lang::TXT_FILE;
}

LanguageInfo LanguageFactory::createFromFilename(const string &filename) {

    uint8_t id = getLanguageId(filename);

    switch (id) {
    case (lang::ADA_FILE):
        return {make_unique<LangAda>(), id, "Ada file"};
    case (lang::ASM_FILE):
        return {make_unique<LangAssembler>(), id, "Assembly file"};
    case (lang::ASP_FILE):
        return {make_unique<LangAsp>(), id, "ASP file"};
    case (lang::BAS_FILE):
        return {make_unique<LangBasic>(), id, "Basic file"};
    case (lang::DOS_FILE):
        return {make_unique<LangBatch>(), id, "DOS Batch file"};
    case (lang::C99_FILE):
        return {make_unique<LangC>(), id, "'C' file"};
    case (lang::CPP_FILE):
        return {make_unique<LangCPlusPlus>(), id, "C++ file"};
    case (lang::C4G_FILE):
        return {make_unique<LangCg>(), id, "NVIDIA Cg file"};
    case (lang::CLP_FILE):
        return {make_unique<LangClips>(), id, "NASA CLIPS file"};
    case (lang::CSS_FILE):
        return {make_unique<LangCSS>(), id, "CSS file"};
    case (lang::CSP_FILE):
        return {make_unique<LangCSharp>(), id, "C-Sharp file"};
    case (lang::OBC_FILE):
        return {make_unique<LangObjectiveC>(), id, "Objective-C file"};
    case (lang::OCP_FILE):
        return {make_unique<LangObjectiveCpp>(), id, "Objective-C++ file"};
    case (lang::EMF_FILE):
        return {make_unique<LangEmf>(), id, "MicroEmacs macro file"};
    case (lang::EU4_FILE):
        return {make_unique<LangEuphoria>(), id, "Euphoria file"};
    case (lang::FTN_FILE):
        return {make_unique<LangFortran>(), id, "Fortran file"};
    case (lang::HSK_FILE):
        return {make_unique<LangHaskell>(), id, "Haskell file"};
    case (lang::HTM_FILE):
        return {make_unique<LangHtml>(), id, "Markup file"};
    case (lang::JAV_FILE):
        return {make_unique<LangJava>(), id, "Java file"};
    case (lang::JSC_FILE):
        return {make_unique<LangJScript>(), id, "JavaScript file"};
    case (lang::MOD_FILE):
        return {make_unique<LangModula2>(), id, "Modula file"};
    case (lang::PAS_FILE):
        return {make_unique<LangPascal>(), id, "Pascal file"};
    case (lang::PRL_FILE):
        return {make_unique<LangPerl>(), id, "Perl script"};
    case (lang::PHP_FILE):
        return {make_unique<LangPhp>(), id, "PHP script"};
    case (lang::PB6_FILE):
        return {make_unique<LangPBuilder>(), id, "Power Builder file"};
    case (lang::PYT_FILE):
        return {make_unique<LangPython>(), id, "Python script"};
    case (lang::RUB_FILE):
        return {make_unique<LangRuby>(), id, "Ruby script"};
    case (lang::RND_FILE):
        return {make_unique<LangRenderMan>(), id, "RenderMan file"};
    case (lang::SQL_FILE):
        return {make_unique<LangSQL>(), id, "SQL script"};
    case (lang::SWF_FILE):
        return {make_unique<LangSwift>(), id, "Swift file"};
    case (lang::UNX_FILE):
        return {make_unique<LangShell>(), id, "UNIX shell script"};
    case (lang::TCL_FILE):
        return {make_unique<LangTcl>(), id, "Tcl script"};
    case (lang::UNR_FILE):
        return {make_unique<LangUScript>(), id, "UnrealScript file"};
    case (lang::VHD_FILE):
        return {make_unique<LangVHDL>(), id, "VHDL file"};
    case (lang::XML_FILE):
        return {make_unique<LangXML>(), id, "XML file"};
    case (lang::RST_FILE):
        return {make_unique<LangRust>(), id, "Rust file"};
    case (lang::GOL_FILE):
        return {make_unique<LangGo>(), id, "Go file"};
    case (lang::TSC_FILE):
        return {make_unique<LangTypeScript>(), id, "TypeScript file"};
    case (lang::KOT_FILE):
        return {make_unique<LangKotlin>(), id, "Kotlin file"};
    case (lang::VLA_FILE):
        return {make_unique<LangVala>(), id, "Vala file"};
    case (lang::ZIG_FILE):
        return {make_unique<LangZig>(), id, "Zig file"};
    case (lang::GLS_FILE):
        return {make_unique<LangGLSL>(), id, "GLSL file"};
    case (lang::HLS_FILE):
        return {make_unique<LangHLSL>(), id, "HLSL file"};
    case (lang::R_FILE):
        return {make_unique<LangR>(), id, "R file"};
    case (lang::GHK_FILE):
        return {make_unique<LangGherkin>(), id, "Gherkin feature file"};
    case (lang::FSH_FILE):
        return {make_unique<LangFSharp>(), id, "F# file"};
    case (lang::SCA_FILE):
        return {make_unique<LangScala>(), id, "Scala file"};
    case (lang::OML_FILE):
        return {make_unique<LangOCaml>(), id, "OCaml file"};
    default:
        return {make_unique<LangText>(), id, "Text file"};
    }
}
