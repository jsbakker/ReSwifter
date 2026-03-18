/* webcpp - driver.h
 * Copyright (C)2001-2004, (C)2026 Jeffrey Bakker
   ___________________________________ .. .
 */

#ifndef DRIVER_H
#define DRIVER_H

#define HELP_LANGUAGES 'L'
#define HELP_DEFAULT   'D'

#include "defsys.h"
#include "engine.h"

class Driver {
 public:
	Driver();
	~Driver();
	static void help(char mode);
	bool switch_parser(string arg);
	char getExt(string filename);
	string checkExt(string filename);
	static void makeIndex(string prefix);
	bool prep_files(string ifile, string ofile, char over);
	string getTitle();
	void drive();
	void clean();
	void endio();

 protected:
	CFfile *ObjIO;
	Engine *lang;

	string iFile;
	string oFile;
};

#endif //DRIVER_H
