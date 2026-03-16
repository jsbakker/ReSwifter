// The Haskell Language definition file for Web C Plus Plus
// Author: Jeffrey Bakker | Date: May 14th 2002 | langhaskell.cpp
// Copyright (C) 2002-2025 Jeffrey Bakker
// Updated 2025 for modern Haskell (GHC 9.x, Haskell 2010)

#include "langhaskell.h"

LangHaskell ::LangHaskell() {

	fill();
	init_switches();

	doAdaComnt  = Yes;  // -- line comments
	doHskComnt  = Yes;  // {- -} block comments
	doSymbols   = Yes;  // Haskell operators
}

void LangHaskell ::fill() {

	// Haskell 2010 reserved words + GHC extension keywords + pragma keywords
	string K[] = {
  "ANN","COLUMN","COMPLETE","CONLIKE","DEPRECATED",
  "INCLUDE","INCOHERENT","INLINE","INLINABLE",
  "LANGUAGE","LINE",
  "MINIMAL",
  "NOINLINE","NOUNPACK",
  "OPAQUE","OPTIONS_GHC","OPTIONS_HADDOCK","OVERLAPPABLE","OVERLAPPING","OVERLAPS",
  "RULES",
  "SOURCE","SPECIALIZE","SPECIALISE",
  "UNPACK",
  "WARNING",
  "anyclass","as",
  "case","class",
  "data","default","deriving","do",
  "else",
  "family","forall","foreign",
  "hiding",
  "if","import","in","infix","infixl","infixr","instance",
  "let",
  "mdo","module",
  "newtype",
  "of",
  "pattern","proc",
  "qualified",
  "rec","role",
  "stock",
  "then","type",
  "via",
  "where"
	};
	for(int k=0;k < 61;k++) {keys.push_back(K[k]);}

	// Common Haskell types, type classes, and data constructors
	string T[] = {
  "Alternative","Any","Applicative","Array",
  "Bool","Bounded","ByteString",
  "Char","Constraint",
  "Double",
  "EQ","Either","Enum","Eq","Exception",
  "False","FilePath","Float","Foldable","Fractional","Functor",
  "GT","Generic",
  "HashMap","HashSet","Hashable",
  "IO","IOError","IORef","Int","Int8","Int16","Int32","Int64",
  "Integer","Integral","IsString",
  "Just",
  "LT","Left",
  "MVar","Map","Maybe","Monad","MonadFail","MonadIO","MonadPlus","Monoid",
  "Nat","Natural","Nothing","Num",
  "Ord","Ordering",
  "Proxy",
  "Ratio","Rational","Read","ReadS","Real","RealFloat","RealFrac","Right",
  "STRef","Semigroup","Seq","Set","Show","ShowS","Storable","String","Symbol",
  "TVar","Text","Traversable","True","Type","Typeable",
  "Vector","Void",
  "Word","Word8","Word16","Word32","Word64"
	};
	for(int t=0;t < 85;t++) {types.push_back(T[t]);}
}
