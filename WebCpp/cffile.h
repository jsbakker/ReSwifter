

/* Cfour (C++ Common Classes Collection)
 * Copyright (C) 2001, (C) 2002 Jeffrey Bakker
 *
 *  Author:              Jeffrey Bakker
 *  Filename:            cffile.h
 *  File version:        1.2.3
 *
 *  CHANGELOG ==================================================================
 *  ============================================================================
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
 *               toggleOmode() methods and booleans data iredir & oredir for
 *               I/O redirection.
 *
 *  Modified on: November 8th, 2001
 *
 *             - Overloaded the insertion and extraction operators.
 *             - The read() and write() methods are now template methods.
 *
 *  Modified on: December 30th, 2001
 *
 *             - Added void setIFptr(long), void setOFptr (long),
 *               long getIFptr(), and long getOFptr() methods for
 *               get/setting the location of the in/out file pointers.
 *             - Added CFfile::READ and CFfile::WRITE constants to send
 *               as file modes to the constructor and open method.
 *
 *  Modified on: March 30th, 2002
 *
 *             - Extraction and insertion operator now return CFfile&, for
 *               concatenating multiple stream commands into a single call
 *               to the stream object. eg. IO << "this" << that << 2 << 'y';
 *             - Added rfile() method, which reads the contents of the
 *               currently open input file into a string.
 *             - Defined ENDL and DOSENDL as "\n" and "\r\n".
 *
 *  Modified on: March 31st, 2002
 *
 *             - Added an overloaded openW() method, which takes a bool
 *               parameter for overwriting or aborting on existing files.
 *             - Redone read() and write() using the conditional operator
 *               rather than using if/else.
 *             - Replaced read/write mode constants with #defines, and
 *               added more modes.
 *             - All templated methods are now implemented in the header
 *               file to fix unresolved symbols when linking with the
 *               microsoft compiler.
 *
 *  Modified on: April 12th, 2002
 *
 *             - Improved and added more whitespace defines, and set the file
 *               open method defines to Hex format.
 *             - The read() and write() methods now use positive logic.
 *
 *  Modified on: April 30th, 2002
 *
 *             - Added members bool oopen, iopen, bool isOopen(), and
 *               bool isIopen() to check if the file streams are in use.
 *
 *  ============================================================================
 *  ============================================================================
 *
 *  Remark:
 *
 *  This is the definition of the CFfile class. The CFfile class contains file
 *  I/O methods which automates file checking while opening I/O streams. You
 *  can now safely open and close files, error free.
 *
 *  The extraction and insertion operators have been overloaded, in an attempt
 *  to turn this class into a stream class which wraps the fstream and the
 *  iostream classes nicely and conveniently together.
 *
 *  The class has also been designed to easily switch between file I/O to
 *  STDIN/STDOUT, enabling the ability to write programs which provide the
 *  "piping" functionality from the command line.
 *
 *  For specific details on the methods, see the documentation at the top of
 *  the file "cffile.cpp".
 *
 *  ============================================================================
 * _______. ..
 */

#ifndef _C4_FILE_H
#define _C4_FILE_H

#define C4_FILE_VER "1.2.3"

// whitespace defines ----------------------------------------------------------
#if defined(WIN32)
#define ENDL "\r\n"
#elif defined(UNIX)
#define ENDL "\n"
#else // other OS
#define ENDL "\n"
#endif // defined(WIN32/UNIX)

#define NIXENDL "\n"
#define DOSENDL "\r\n"
#define BIG_TAB "\t\t"
#define SPACE_4 "    "
#define SPACE_8 "        "

// file open modes ----------
#define MODE_READ 0x72
#define MODE_WRITE 0x77
#define PROMPT_OVERWRITE 0x77
#define FORCE_OVERWRITE 0x66
#define NEVER_OVERWRITE 0x6B
//--------------------------..

#include <fstream>
#include <iostream>
#include <string>
using namespace std;

class CFfile {

  public:
    // (Con/De)structors
    // ---------------------------------------------------------
    CFfile();
    CFfile(string filename, char io);
    CFfile(string filein, string fileout);
    ~CFfile();
    // Initialize bool data members
    // ----------------------------------------------
    void init_switches();
    //----------------------------------------------------------------------------
    // Operator overloading
    // ------------------------------------------------------
    template <class T> CFfile &operator<<(T var) {
        write(var);
        return *this;
    }
    template <class T> CFfile &operator>>(T &var) {
        read(var);
        return *this;
    }
    //----------------------------------------------------------------------------
    // File open methods
    // ---------------------------------------------------------
    bool exists(string fname);      // check if a file exists
    bool openR(string INfile);      // opens file for reading
    bool openW(string OUTfile);     // opens file for writing
    bool openW(string fn, bool ow); // open, specify overwrite
    bool open(string fn, char io);  // open, specify mode

    bool isIopen() { return iopen; } // is infile open?
    bool isOopen() { return oopen; } // is outfile open?
    //----------------------------------------------------------------------------
    // File pointer location methods
    // ---------------------------------------------
    void setIFptr(long location); // set the infile pointer location
    void setOFptr(long location); // set the outfile pointer location
    long getIFptr();              // get the infile pointer location
    long getOFptr();              // get the outfile pointer location
    // get the filenames
    // ---------------------------------------------------------
    inline string getStrIf() { return str_if; }
    inline string getStrOf() { return str_of; }
    //----------------------------------------------------------------------------
    // I/O redirection methods
    // ---------------------------------------------------
    bool isIredir() const; // returns the input mode
    bool isOredir() const; // returns the output mode
    void toggleImode();    // toggles input mode (FILE or STDIN)
    void toggleOmode();    // toggles output mode (FILE or STDIN)
    //----------------------------------------------------------------------------
    // Read/Write methods
    // --------------------------------------------------------
    template <class T> void read(T &buffer) {
        (iredir ? cin : ifile) >> buffer;
    }
    template <class T> void write(T buffer) {
        (oredir ? cout : ofile) << buffer;
    }
    // Special purpose read methods
    // ----------------------------------------------
    void rline(string &buffer);              // read a line to the string
    void rfile(string &buffer);              // read a file to the string
    void backup(string fname, string bname); // copy a file
    // File close methods
    // --------------------------------------------------------
    void closeR(); // close the input file
    void closeW(); // close the output file
    void close();  // close all
    //----------------------------------------------------------------------------
    // These are public, so you can still use them raw
    // ---------------------------
    ifstream ifile; // input file stream
    ofstream ofile; // output file stream
    //----------------------------------------------------------------------------
  protected:
    // I/O redirection switches
    // --------------------------------------------------
    bool iredir;
    bool oredir;
    bool iopen;
    bool oopen;
    // filenames
    // -----------------------------------------------------------------
    string str_if;
    string str_of;
};

#endif // _C4_FILE_H
