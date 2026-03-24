// The GLSL Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#include "langglsl.h"

#include <algorithm>
#include <iterator>
#include <string>

using std::string;

LangGLSL::LangGLSL() {

    initReservedWords();

    doSymbols = true;
    doBigComnt = true; // /* */
    doCinComnt = true; // //
    doPreProc = true;  // #version, #extension, #define, #ifdef, #ifndef, #endif
}

void LangGLSL::initReservedWords() {

    // GLSL keywords (GLSL 4.60)
    string K[] = {
        "attribute", "break",     "case",          "centroid",   "coherent",
        "const",     "continue",  "default",       "discard",    "do",
        "else",      "false",     "flat",          "for",        "highp",
        "if",        "in",        "inout",         "invariant",  "layout",
        "lowp",      "mediump",   "noperspective", "out",        "patch",
        "precision", "readonly",  "restrict",      "return",     "sample",
        "shared",    "smooth",    "struct",        "subroutine", "switch",
        "true",      "uniform",   "varying",       "void",       "volatile",
        "while",     "writeonly",
    };
    std::copy(std::cbegin(K), std::cend(K), std::back_inserter(keys));

    // GLSL types
    string T[] = {
        "bool",          "bvec2",        "bvec3",      "bvec4",
        "double",        "dmat2",        "dmat2x2",    "dmat2x3",
        "dmat2x4",       "dmat3",        "dmat3x2",    "dmat3x3",
        "dmat3x4",       "dmat4",        "dmat4x2",    "dmat4x3",
        "dmat4x4",       "dvec2",        "dvec3",      "dvec4",
        "float",         "image1D",      "image2D",    "image3D",
        "imageCube",     "int",          "isampler1D", "isampler2D",
        "isampler3D",    "isamplerCube", "ivec2",      "ivec3",
        "ivec4",         "mat2",         "mat2x2",     "mat2x3",
        "mat2x4",        "mat3",         "mat3x2",     "mat3x3",
        "mat3x4",        "mat4",         "mat4x2",     "mat4x3",
        "mat4x4",        "sampler1D",    "sampler2D",  "sampler3D",
        "samplerBuffer", "samplerCube",  "uint",       "usampler2D",
        "uvec2",         "uvec3",        "uvec4",      "vec2",
        "vec3",          "vec4",
    };
    std::copy(std::cbegin(T), std::cend(T), std::back_inserter(types));
}
