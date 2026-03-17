// The Rust Language definition file for Web C Plus Plus

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
