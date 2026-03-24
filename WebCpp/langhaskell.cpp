// The Haskell Language definition file for Web C Plus Plus
// Author: Jeffrey Bakker | Date: May 14th 2002 | langhaskell.cpp
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker
// Updated 2026 for modern Haskell (GHC 9.x, Haskell 2010)

#include "langhaskell.h"

#include <algorithm>
#include <iterator>
#include <string>

using std::string;

LangHaskell ::LangHaskell() {

    initReservedWords();

    doStringsSinQuote = true;
    doStringsBackTick = true;
    doAdaComnt = true; // -- line comments
    doHskComnt = true; // {- -} block comments
    doSymbols = true;  // Haskell operators
    doUnderscoreNumbers = true;
}

void LangHaskell ::initReservedWords() {

    // Haskell 2010 reserved words + GHC extension keywords + pragma keywords
    string K[] = {"ANN",
                  "COLUMN",
                  "COMPLETE",
                  "CONLIKE",
                  "DEPRECATED",
                  "INCLUDE",
                  "INCOHERENT",
                  "INLINE",
                  "INLINABLE",
                  "LANGUAGE",
                  "LINE",
                  "MINIMAL",
                  "NOINLINE",
                  "NOUNPACK",
                  "OPAQUE",
                  "OPTIONS_GHC",
                  "OPTIONS_HADDOCK",
                  "OVERLAPPABLE",
                  "OVERLAPPING",
                  "OVERLAPS",
                  "RULES",
                  "SOURCE",
                  "SPECIALIZE",
                  "SPECIALISE",
                  "UNPACK",
                  "WARNING",
                  "anyclass",
                  "as",
                  "case",
                  "class",
                  "data",
                  "default",
                  "deriving",
                  "do",
                  "else",
                  "family",
                  "forall",
                  "foreign",
                  "hiding",
                  "if",
                  "import",
                  "in",
                  "infix",
                  "infixl",
                  "infixr",
                  "instance",
                  "let",
                  "mdo",
                  "module",
                  "newtype",
                  "of",
                  "pattern",
                  "proc",
                  "qualified",
                  "rec",
                  "role",
                  "stock",
                  "then",
                  "type",
                  "via",
                  "where"};
    std::copy(std::cbegin(K), std::cend(K), std::back_inserter(keys));

    // Common Haskell types, type classes, and data constructors
    string T[] = {
        "Alternative", "Any",        "Applicative", "Array",      "Bool",
        "Bounded",     "ByteString", "Char",        "Constraint", "Double",
        "EQ",          "Either",     "Enum",        "Eq",         "Exception",
        "False",       "FilePath",   "Float",       "Foldable",   "Fractional",
        "Functor",     "GT",         "Generic",     "HashMap",    "HashSet",
        "Hashable",    "IO",         "IOError",     "IORef",      "Int",
        "Int8",        "Int16",      "Int32",       "Int64",      "Integer",
        "Integral",    "IsString",   "Just",        "LT",         "Left",
        "MVar",        "Map",        "Maybe",       "Monad",      "MonadFail",
        "MonadIO",     "MonadPlus",  "Monoid",      "Nat",        "Natural",
        "Nothing",     "Num",        "Ord",         "Ordering",   "Proxy",
        "Ratio",       "Rational",   "Read",        "ReadS",      "Real",
        "RealFloat",   "RealFrac",   "Right",       "STRef",      "Semigroup",
        "Seq",         "Set",        "Show",        "ShowS",      "Storable",
        "String",      "Symbol",     "TVar",        "Text",       "Traversable",
        "True",        "Type",       "Typeable",    "Vector",     "Void",
        "Word",        "Word8",      "Word16",      "Word32",     "Word64"};
    std::copy(std::cbegin(T), std::cend(T), std::back_inserter(types));
}
