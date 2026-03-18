// The Rust Language definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker

#ifndef LANG_DEF_RUST
#define LANG_DEF_RUST

#include "engine.h"

class LangRust : public Engine {

 public:
	LangRust();
	~LangRust() {IO->close();}
	virtual void fill();
};

#endif //LANG_DEF_RUST
