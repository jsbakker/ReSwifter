

/* Cfour (C++ Common Classes Collection)
 * Copyright (C) 2001, (C) 2002 Jeffrey Bakker
 *
 *  Author:              Jeffrey Bakker
 *  Filename:            cffile.cpp
 *  File version:        1.2.3
 *

 *  CHANGELOG =================================================================
 *  ===========================================================================
 *
 *  Created on:  August 21st, 2001
 *
 *
 *  Modified on: September 2nd, 2001
 *
 *             - Added a new read(), rline(), and write() methods for reading
 *               and writing to and from a file.
 *
 *  Modified on: November 7th, 2001
 *
 *             - Added a new isIredir(), and isOredir(), toggleImode(), and
 *               toggleOmode() methods and most cout's were changed to cerr
 *               for I/O redirection.
 *
 *  Modified on: November 8th, 2001
 *
 *             - Added template operaor<< and operator>> overloading.
 *             - The read() and write() methods are now template methods.
 *
 *  Modified on: December 28th, 2001
 *
 *             - Constructor CFfile(string,char) now calls open(string,char).
 *             - Added 'r' and 'w' to the io mode switch statement in open().
 *             - Updated documentation
 *
 *  Modified on: March 30th, 2002
 *
 *             - Extraction and insertion operator now return CFfile&, for
 *               concatenating multiple stream commands into a single call
 *               to the stream object. eg. IO << "this" << that << 2 << 'y';
 *             - Added rfile() method, which reads the contents of the
 *               currently open input file into a string.
 *             - Added an overloaded openW() method, which takes a bool
 *               parameter for overwriting or aborting on existing files.
 *
 *  Modified on: March 31st, 2002
 *
 *             - All templated methods are now implemented in the header
 *               file to fix unresolved symbols when linking with the
 *               microsoft compiler.
 *
 *  Modified on: April 30th, 2002
 *
 *             - Add code in constructors and the openX() methods to interact
 *               with iopen and oopen, to verify open file streams.
 *
 *  ===========================================================================
 *  ===========================================================================
 *
 *  Remark:
 *
 *  This is the implementation of the CFfile class. In here, you will find
 *  the inner workings of the CFfile class. The documentation below will show
 *  how to use the methods.
 *
 *  ===========================================================================
 *  BEGIN METHOD DOCUMENTATION ================================================
 *  ===========================================================================
 *
 *  template <class T> CFfile& operator<<():
 *
 *   Description: overloaded operator allows output stream of many data types.
 *
 *  ===========================================================================
 *
 *  template <class T> CFfile& operator>>():
 *
 *   Description: overloaded operator allows input stream of many data types.
 *
 *  ===========================================================================
 *
 *  CFfile():
 *
 *   Description: default constructor.
 *
 *  ===========================================================================
 *
 *  CFfile(string filename, char io):
 *
 *   Description: Overloaded constructor that takes a filename and anI/O mode.
 *                This constructor calls open(string,char).
 *
 *   Input:
 *
 *    Parameter 1
 *    - Name:        filename
 *    - Type:        string
 *    - Description: the name of the file to open
 *
 *
 *    Parameter 2
 *    - Name:        io
 *    - Type:        char
 *    - Description: the mode in which to open the file ('i/r' or 'o/w').
 *
 *  ===========================================================================
 *
 *  bool open(string filename, char io):
 *
 *   Description: Depending on the mode selected, it passes the filename to
 *                openR(string) or openW(string).
 *
 *   Input:
 *
 *    Parameter 1
 *    - Name:        filename
 *    - Type:        string
 *    - Description: the name of the file to open
 *
 *
 *    Parameter 2
 *    - Name:        io
 *    - Type:        char
 *    - Description: the mode in which to open the file ('i/r' or 'o/w').
 *
 *   Output:
 *    - returns true if file opened correctly, false otherwise.
 *
 *  ===========================================================================
 *
 *  bool openR(string filename):
 *
 *   Description: This opens the specified file for reading and returns true,
 *                if the file exists. If not, it will return false.
 *
 *   Input:
 *
 *    Parameter 1
 *    - Name:        filename
 *    - Type:        string
 *    - Description: the name of the file to open
 *
 *   Output:
 *    - returns true if file opened correctly, false otherwise.
 *
 *  ===========================================================================
 *
 *  bool openW(string filename):
 *
 *   Description: This opens the specified file for writing. If the file
 *                already exists, it asks the user whether to overwrite.
 *
 *   Input:
 *
 *    Parameter 1
 *    - Name:        filename
 *    - Type:        string
 *    - Description: the name of the file to open
 *
 *   Output:
 *    - returns true if file opened correctly, false otherwise.
 *
 *  ===========================================================================
 *
 *  void rline(T &buffer):
 *
 *   Description: reads a whole line from the file into the buffer.
 *
 *   Input:
 *
 *    Parameter 1
 *    - Name:        buffer
 *    - Type:        address of string
 *    - Description: the string in which to store the data
 *
 *  ===========================================================================
 *
 *  void rfile(T &buffer):
 *
 *   Description: reads the currently open input file into the buffer.
 *
 *   Input:
 *
 *    Parameter 1
 *    - Name:        buffer
 *    - Type:        address of string
 *    - Description: the string in which to store the data
 *
 *  ===========================================================================
 *
 *  template <class T> void read(T &buffer):
 *
 *   Description: reads a string from the file into the buffer.
 *
 *   Input:
 *
 *    Parameter 1
 *    - Name:        buffer
 *    - Type:        address of any data type
 *    - Description: the string in which to store the data
 *
 *  ===========================================================================
 *
 *  template <class T> void write(T buffer):
 *
 *   Description: writes from the string buffer to the file.
 *
 *   Input:
 *
 *    Parameter 1
 *    - Name:        buffer
 *    - Type:        any data type
 *    - Description: the string in which to write from
 *
 *  ===========================================================================
 *
 *  void backup(string fname, string bname):
 *
 *   Description: creates a backup of a file.
 *
 *
 *   Input:
 *
 *    Parameter 1
 *    - Name:        fname
 *    - Type:        string
 *    - Description: the name of the file to copy from
 *
 *
 *    Parameter 2
 *    - Name:        bname
 *    - Type:        string
 *    - Description: the name of the backup file
 *
 *  ===========================================================================
 *
 *  bool exists(string fname):
 *
 *   Description: checks whether or not a file exists
 *
 *   Input:
 *
 *    Parameter 1
 *    - Name:        fname
 *    - Type:        string
 *    - Description: the name of the file to check
 *
 *   Output:
 *    - returns true if file exists, false otherwise.
 *
 *  ===========================================================================
 *
 *  void closeR():
 *
 *   Description: closes the input stream _if_ it is open.
 *
 *  ===========================================================================
 *
 *  void closeW():
 *
 *   Description: closes the output stream _if_ it is open.
 *
 *  ===========================================================================
 *
 *  void close():
 *
 *   Description: calls closeR() and closeW().
 *
 *  ===========================================================================
 *  END METHOD DOCUMENTATION ==================================================
 * _______. ..
 */

#include "cffile.h"
#include <cctype>
#include <iostream>

using std::cerr;
using std::cin;
using std::ifstream;
using std::ofstream;
using std::string;

// constructors ---------------------------------------------------------------
CFfile::CFfile() {
    init_switches();
} //---------------------------------------------------------------------------
CFfile::CFfile(const string &filename, char io) {
    init_switches();
    open(filename, io);
} //---------------------------------------------------------------------------
CFfile::CFfile(const string &in, const string &out) {
    init_switches();
    openR(in);
    openW(out);
}
// destructor -----------------------------------------------------------------
CFfile::~CFfile() { close(); }
// bool member initialization -------------------------------------------------
void CFfile::init_switches() {
    iredir = false;
    oredir = false;
    iopen = false;
    oopen = false;
    smode = false;

    str_if = "\0";
    str_of = "\0";
}
// open methods ---------------------------------------------------------------
bool CFfile::open(const string &filename, char io) {

    io = tolower(io);
    switch (io) {
    case 'i':
    case 'r':
        return openR(filename);
    case 'o':
    case 'w':
        return openW(filename);
    case 'f':
        return openW(filename, true);
    case 'k':
        return openW(filename, false);
    default:
        cerr << "\nInvalid I/O mode.\n";
        return false;
    }

    return true;
} // --------------------------------------------------------------------------
bool CFfile::openR(const string &INfile) {

    if (exists(INfile)) {
        ifile.open(INfile.data());
        str_if = INfile;
        iopen = true;
        return true;
    } else {
        cerr << ENDL << INfile << " cannot be opened.\n";
        return false;
    }
} // --------------------------------------------------------------------------
bool CFfile::openW(const string &OUTfile) {

    if (exists(OUTfile)) {
        char write;
        do {
            cerr << ENDL << OUTfile << " already exists. Overwrite? (Y/N) ";
            cin >> write;
            if (write == 'N' || write == 'n') {
                return false;
            }
        } while (!(write == 'Y' || write == 'y'));
    }
    ofile.open(OUTfile.data());
    str_of = OUTfile;
    oopen = true;
    return true;
} // --------------------------------------------------------------------------
bool CFfile::openW(const string &OUTfile, bool overwrite) {

    if (exists(OUTfile)) {
        if (!overwrite) {
            return false;
        }
    }
    ofile.open(OUTfile.data());
    str_of = OUTfile;
    oopen = true;
    return true;
}
// ----------------------------------------------------------------------------
// close methods --------------------------------------------------------------
void CFfile::closeR() { // safely close the stream
    if (ifile) {
        ifile.close();
        iopen = false;
    }
}
void CFfile::closeW() { // safely close the stream
    if (ofile) {
        ofile.close();
        oopen = false;
    }
}
void CFfile::close() { // safely close all streams
    closeR();
    closeW();
}
// ----------------------------------------------------------------------------
// checks if a file exists ----------------------------------------------------
bool CFfile::exists(const string &fname) const {

    ifstream chk;
    chk.open(fname.data());

    if (!chk) {
        chk.close();
        return false;
    }
    chk.close();
    return true;
} //---------------------------------------------------------------------------
// check input/output modes for redirection -----------------------------------
bool CFfile::isIredir() const { return iredir; } // is Input redirected?
bool CFfile::isOredir() const { return oredir; } // is Output redirected?
// toggle input/output modes for redirection ----------------------------------
void CFfile::toggleImode() { iredir = !iredir; }
void CFfile::toggleOmode() { oredir = !oredir; }

// return the location of the pointer in the file -----------------------------
long CFfile::getIFptr() { return ifile.tellg(); }
long CFfile::getOFptr() { return ofile.tellp(); }
// set the location of the ponter in the file ---------------------------------
void CFfile::setIFptr(long location) { ifile.seekg(location); }
void CFfile::setOFptr(long location) { ofile.seekp(location); }

// readline to string ---------------------------------------------------------
void CFfile::rline(string &buffer) {
    if (smode) {
        getline(*istrm, buffer);
    } else if (!iredir) {
        getline(ifile, buffer);
    } else {
        getline(cin, buffer);
    }
}
// in-memory string-stream I/O ------------------------------------------------
void CFfile::openStringR(const string &data) {
    istrm = std::make_unique<std::istringstream>(data);
    smode = true;
}

void CFfile::openStringW() {
    ostrm = std::make_unique<std::ostringstream>();
    smode = true;
}

string CFfile::getStringW() const {
    return ostrm ? ostrm->str() : string{};
}

bool CFfile::isInputGood() const {
    if (smode)  return istrm && static_cast<bool>(*istrm);
    if (iredir) return static_cast<bool>(cin);
    return static_cast<bool>(ifile);
}
// readfile to string ---------------------------------------------------------
void CFfile::rfile(string &buffer) {

    long save_pos = getIFptr(); // save current position in file
    setIFptr(0);                // set position to the start of the file

    string line;
    while (ifile) {
        rline(line);
        buffer += line + ENDL;
    }

    setIFptr(save_pos); // restore previous position in file
} //---------------------------------------------------------------------------
// backup a file --------------------------------------------------------------
void CFfile::backup(const string &fname, const string &bname) {

    ifstream bin;
    ofstream bout;
    string linebuf;

    bin.open(fname.data());
    bout.open(bname.data());

    getline(bin, linebuf);
    while (bin) {
        bout << linebuf;
        getline(bin, linebuf);
        if (bin)
            bout << ENDL;
    }
    bin.close();
    bout.close();
} // --------------------------------------------------------------------------
//-----------------------------------------------------------------------------
