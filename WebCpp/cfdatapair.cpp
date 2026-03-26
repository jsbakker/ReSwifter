/* Cfour (C++ Common Console Classes)
 * Copyright (C) 2001 Jeffrey Bakker
 *
 *  Author:              Jeffrey Bakker
 *  Filename:            cfdatapair.cpp
 *  File version:        1.1
 *
 *  ===========================================================================
 *
 *  Created on: Sept 2nd, 2001
 *
 *  Modified on: April 1st, 2002
 *
 *             - Added translateML() which takes data markup format,
 *               and modifies name and value.
 *             - Added info_ml(), changed info() to info_nv().
 *             - Added a constructor which takes a string in markup format.
 *             - Overloaded insertion and extraction operators to convert
 *               data between pairs and maarkup like a stream call.
 *             - Made getName() and getValue() as const methods.
 *
 *  ===========================================================================
 *
 *  Remark:
 *
 *  This is the class implementaion for CFdataPair, a class which provides
 *  methods and data members for storing pairs of data.
 *
 *  ===========================================================================
 * _______. ..
 */

#include "cfdatapair.h"

using std::string;

// overloaded stream operators ------------------------------------------------
void CFdatapair::operator<<(string mldata) { translateML(mldata); }
void CFdatapair::operator>>(string &mldata) { mldata = info_ml(); }
// Constructors ---------------------------------------------------------------
CFdatapair::CFdatapair() {
    name = "name";
    value = "value";
}
CFdatapair::CFdatapair(string mldata) { translateML(mldata); }
CFdatapair::CFdatapair(string n, string v) {
    name = n;
    value = v;
}
// set methods ----------------------------------------------------------------
void CFdatapair::setname(string n) { name = n; }   // changes the name
void CFdatapair::setvalue(string v) { value = v; } // changes the value
// get methods ----------------------------------------------------------------
string CFdatapair::getname() const { return name; }   // returns the name
string CFdatapair::getvalue() const { return value; } // returns the value
//-----------------------------------------------------------------------------
string CFdatapair::info_nv() const { // return the name and value in a string

    return name + ": " + value;
} //---------------------------------------------------------------------------
string CFdatapair::info_ml() const { // return name and value in markup format

    return ("<" + name + ">" + value + "</" + name + ">");
} //---------------------------------------------------------------------------
// swaps the name/value -------------------------------------------------------
void CFdatapair::swap() {
    string temp;
    temp = name;
    name = value;
    value = temp;
} //---------------------------------------------------------------------------
// convert XML-Style string data into name/value pair -------------------------
void CFdatapair::translateML(string mldata) {

    string ntmp, vtmp;
    int open, close;

    open = static_cast<int>(mldata.find("<", 0));
    close = static_cast<int>(mldata.find(">", open));
    ntmp = mldata.substr(open + 1, (close - open) - 1);
    // ntmp  = mldata.substr(open+1,close-1);

    open = static_cast<int>(mldata.find("</", close));
    vtmp = mldata.substr(close + 1, (open - close - 1));

    name = ntmp;
    value = vtmp;
}
//-----------------------------------------------------------------------------
