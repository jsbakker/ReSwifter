/* webcpp - main.cpp
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


#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include "driver.h"
#include <fstream>
using namespace std;

int main(int argc, char **argv) {

	if(argc == 2) {
		string tHelp = argv[1];
		if(tHelp == "--languages") {
			Driver::help(HELP_LANGUAGES);
			return -1;
		}
	}

	if(argc < 3) {
		Driver::help(HELP_DEFAULT);
		return -1;
	}

	string Arg1, Arg2, opt;
	Arg1 = argv[1];
	Arg2 = argv[2];

	// file overwriting : (f)orce, (k)eep, ()ask
	char over;
	over = (Arg1=="-"||Arg1=="--pipe")?0x66:0x77;

	int fileflag = Arg2.rfind(":");
	if(fileflag != -1 && fileflag != 1) {
		over = Arg2[fileflag + 1];
		Arg2.erase(fileflag,2);
		if(over == 'i' || over == 'r') {
			over = 0x77;
		}
	}
	/* process wildcards in filenames */
	if(Arg1.find("*") != -1) {

		cerr << "multiple input files...\n";

		ifstream batch;
		string wildcard = LIST_DIRECTORY;
		wildcard += Arg1;
		wildcard += " >webcppbatch.txt";
		system(wildcard.data());

		//load wildcard file, then for-loop through
		//and run the engine each time
		batch.open("webcppbatch.txt");
		if(!batch) {
			cerr << "cannot create a list of files.\n";
			return -1;
		}
		string file;
		getline(batch,file);
		while(batch) {

			Driver Webcpp;
			cerr << "\nProcessing " << file << "...";
			cerr << Webcpp.checkExt(file) << " detected.\n";

			if(Webcpp.prep_files(file, file + ".html",over)) {

				for(int i = 3;i < argc;i++) {
					opt = argv[i];
					if(!Webcpp.switch_parser(opt)) {
						cerr << opt << " is an invalid option\n";
						return -1;
					}
				}
				Webcpp.drive();
			} else return -1;
			getline(batch,file);
		}
		batch.close();
		Driver::makeIndex("");
		system(DELETE);
	}
	else {
		Driver Webcpp;
		cerr << Webcpp.checkExt(Arg1) << " detected.\n";

		if(Webcpp.prep_files(Arg1,Arg2,over)) {

			for(int i = 3;i < argc;i++) {
				opt = argv[i];
				if(!Webcpp.switch_parser(opt)) {
					cerr << opt << " is an invalid option\n";
					return -1;
				}
			}
			Webcpp.drive();
		} else return -1;
	}
	return 0;
}
