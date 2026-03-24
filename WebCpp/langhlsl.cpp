// The HLSL Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#include "langhlsl.h"

#include <algorithm>
#include <iterator>
#include <string>

using std::string;

LangHLSL::LangHLSL() {

    initReservedWords();

    doSymbols = true;
    doBigComnt = true; // /* */
    doCinComnt = true; // //
    doPreProc =
        true; // #define, #if, #ifdef, #ifndef, #else, #elif, #endif, #include
}

void LangHLSL::initReservedWords() {

    // HLSL keywords (Shader Model 6.x)
    string K[] = {
        "break",
        "case",
        "cbuffer",
        "class",
        "compile",
        "const",
        "continue",
        "default",
        "discard",
        "do",
        "else",
        "export",
        "extern",
        "false",
        "for",
        "groupshared",
        "if",
        "in",
        "inline",
        "inout",
        "interface",
        "linear",
        "namespace",
        "nointerpolation",
        "noperspective",
        "NULL",
        "out",
        "packoffset",
        "pass",
        "precise",
        "register",
        "return",
        "row_major",
        "sample",
        "sampler",
        "shared",
        "snorm",
        "static",
        "struct",
        "switch",
        "tbuffer",
        "technique",
        "technique10",
        "technique11",
        "true",
        "typedef",
        "uniform",
        "unorm",
        "volatile",
        "while",
    };
    std::copy(std::cbegin(K), std::cend(K), std::back_inserter(keys));

    // HLSL types
    string T[] = {
        "AppendStructuredBuffer",
        "BlendState",
        "Buffer",
        "ByteAddressBuffer",
        "ConsumedStructuredBuffer",
        "DepthStencilState",
        "RasterizerState",
        "RasterizerOrderedBuffer",
        "RasterizerOrderedByteAddressBuffer",
        "RasterizerOrderedStructuredBuffer",
        "RasterizerOrderedTexture1D",
        "RasterizerOrderedTexture1DArray",
        "RasterizerOrderedTexture2D",
        "RasterizerOrderedTexture2DArray",
        "RasterizerOrderedTexture3D",
        "RWBuffer",
        "RWByteAddressBuffer",
        "RWStructuredBuffer",
        "RWTexture1D",
        "RWTexture1DArray",
        "RWTexture2D",
        "RWTexture2DArray",
        "RWTexture3D",
        "SamplerComparisonState",
        "SamplerState",
        "StructuredBuffer",
        "Texture1D",
        "Texture1DArray",
        "Texture2D",
        "Texture2DArray",
        "Texture2DMS",
        "Texture2DMSArray",
        "Texture3D",
        "TextureCube",
        "TextureCubeArray",
        "bool",
        "bool1",
        "bool2",
        "bool3",
        "bool4",
        "bool1x1",
        "bool2x2",
        "bool3x3",
        "bool4x4",
        "double",
        "float",
        "float1",
        "float2",
        "float3",
        "float4",
        "float1x1",
        "float2x2",
        "float3x3",
        "float4x4",
        "half",
        "int",
        "int1",
        "int2",
        "int3",
        "int4",
        "matrix",
        "min10float",
        "min12int",
        "min16float",
        "min16int",
        "min16uint",
        "string",
        "uint",
        "uint1",
        "uint2",
        "uint3",
        "uint4",
        "vector",
        "void",
    };
    std::copy(std::cbegin(T), std::cend(T), std::back_inserter(types));
}
