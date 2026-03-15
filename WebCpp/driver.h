/* webcpp - driver.h
 * Copyright (C)2001-2003 Jeffrey Bakker

 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
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
