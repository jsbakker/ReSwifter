/* webcpp - deflangs.h
 * Copyright (C)2001-2004, (C)2026 Jeffrey Bakker
   ___________________________________ .. .
 */

#ifndef _DEF_LANGS_H
#define _DEF_LANGS_H

#include "langada.h"
#include "langasm.h"
#include "langasp.h"
#include "langbasic.h"
#include "langbatch.h"
#include "langc.h"
#include "langcg.h"
#include "langclips.h"
#include "langcpp.h"
#include "langcsharp.h"
#include "langcss.h"
#include "langemf.h"
#include "langeuphoria.h"
#include "langfortran.h"
#include "langfsharp.h"
#include "langgherkin.h"
#include "langglsl.h"
#include "langgo.h"
#include "langhaskell.h"
#include "langhlsl.h"
#include "langhtml.h"
#include "langjava.h"
#include "langjscript.h"
#include "langkotlin.h"
#include "langmodula.h"
#include "langobjc.h"
#include "langobjcpp.h"
#include "langocaml.h"
#include "langpascal.h"
#include "langpbuilder.h"
#include "langperl.h"
#include "langphp.h"
#include "langpython.h"
#include "langr.h"
#include "langrenderman.h"
#include "langruby.h"
#include "langrust.h"
#include "langscala.h"
#include "langshell.h"
#include "langsql.h"
#include "langswift.h"
#include "langtcl.h"
#include "langtext.h"
#include "langts.h"
#include "languscript.h"
#include "langvala.h"
#include "langvhdl.h"
#include "langxml.h"
#include "langzig.h"

#include <cstdint>

namespace lang {
inline constexpr std::uint8_t ADA_FILE = 0x64;
inline constexpr std::uint8_t ASM_FILE = 0x61;
inline constexpr std::uint8_t ASP_FILE = 0x41;
inline constexpr std::uint8_t BAS_FILE = 0x62;
inline constexpr std::uint8_t DOS_FILE = 0x75;
inline constexpr std::uint8_t C99_FILE = 0x63;
inline constexpr std::uint8_t C4G_FILE = 0x67;
inline constexpr std::uint8_t CLP_FILE = 0x6E;
inline constexpr std::uint8_t CPP_FILE = 0x2B;
inline constexpr std::uint8_t CSP_FILE = 0x23;
inline constexpr std::uint8_t EMF_FILE = 0x4D;
inline constexpr std::uint8_t EU4_FILE = 0x45;
inline constexpr std::uint8_t FTN_FILE = 0x66;
inline constexpr std::uint8_t HSK_FILE = 0x6B;
inline constexpr std::uint8_t HTM_FILE = 0x68;
inline constexpr std::uint8_t JAV_FILE = 0x6A;
inline constexpr std::uint8_t JSC_FILE = 0x78;
inline constexpr std::uint8_t MOD_FILE = 0x6D;
inline constexpr std::uint8_t OBC_FILE = 0x6F;
inline constexpr std::uint8_t PAS_FILE = 0x6C;
inline constexpr std::uint8_t PRL_FILE = 0x65;
inline constexpr std::uint8_t PHP_FILE = 0x70;
inline constexpr std::uint8_t PB6_FILE = 0x77;
inline constexpr std::uint8_t PYT_FILE = 0x79;
inline constexpr std::uint8_t RND_FILE = 0x52;
inline constexpr std::uint8_t RUB_FILE = 0x55;
inline constexpr std::uint8_t UNX_FILE = 0x73;
inline constexpr std::uint8_t SQL_FILE = 0x71;
inline constexpr std::uint8_t TCL_FILE = 0x72;
inline constexpr std::uint8_t TXT_FILE = 0x74;
inline constexpr std::uint8_t UNR_FILE = 0x54;
inline constexpr std::uint8_t SWF_FILE = 0x53;
inline constexpr std::uint8_t VHD_FILE = 0x76;
inline constexpr std::uint8_t CSS_FILE = 0x43;
inline constexpr std::uint8_t XML_FILE = 0x58;
inline constexpr std::uint8_t RST_FILE = 0x30;
inline constexpr std::uint8_t GOL_FILE = 0x31;
inline constexpr std::uint8_t TSC_FILE = 0x32;
inline constexpr std::uint8_t KOT_FILE = 0x33;
inline constexpr std::uint8_t VLA_FILE = 0x34;
inline constexpr std::uint8_t ZIG_FILE = 0x35;
inline constexpr std::uint8_t GLS_FILE = 0x36;
inline constexpr std::uint8_t HLS_FILE = 0x37;
inline constexpr std::uint8_t OCP_FILE = 0x38;
inline constexpr std::uint8_t R_FILE = 0x39;
inline constexpr std::uint8_t GHK_FILE = 0x3A;
inline constexpr std::uint8_t FSH_FILE = 0x3B;
inline constexpr std::uint8_t SCA_FILE = 0x3C;
inline constexpr std::uint8_t OML_FILE = 0x3D;
} // namespace lang

#endif //_DEF_LANGS_H
