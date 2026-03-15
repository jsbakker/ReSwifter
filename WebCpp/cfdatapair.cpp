/* Cfour (C++ Common Console Classes)
 * Copyright (C) 2001 Jeffrey Bakker
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *
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

// overloaded stream operators ------------------------------------------------
void CFdatapair::operator<<(string  mldata) {translateML(mldata);}
void CFdatapair::operator>>(string& mldata) {mldata = info_ml();}
// Constructors ---------------------------------------------------------------
CFdatapair::CFdatapair()                   {name = "name"; value = "value";}
CFdatapair::CFdatapair(string mldata)      {translateML(mldata);}
CFdatapair::CFdatapair(string n, string v) {name = n; value = v;}
// set methods ----------------------------------------------------------------
void CFdatapair::setname(string n)  {name  = n;} // changes the name
void CFdatapair::setvalue(string v) {value = v;} // changes the value
// get methods ----------------------------------------------------------------
string CFdatapair::getname()  const {return name;}  // returns the name
string CFdatapair::getvalue() const {return value;} // returns the value
//-----------------------------------------------------------------------------
string CFdatapair::info_nv()  const { // return the name and value in a string

 return name + ": " + value;
} //---------------------------------------------------------------------------
string CFdatapair::info_ml()  const { // return name and value in markup format

 return ("<" + name + ">" + value + "</" + name + ">");
} //---------------------------------------------------------------------------
// swaps the name/value -------------------------------------------------------
void CFdatapair::swap() {
 string temp;
 temp  = name;
 name  = value;
 value = temp;
} //---------------------------------------------------------------------------
// convert XML-Style string data into name/value pair ------------------------- 
void CFdatapair::translateML(string mldata) {

 string ntmp, vtmp;
 int    open, close;
 
 open  = mldata.find("<",0);
 close = mldata.find(">",open);
 ntmp  = mldata.substr(open+1,(close - open) -1);
// ntmp  = mldata.substr(open+1,close-1);

 open  = mldata.find("</",close);
 vtmp  = mldata.substr(close+1,(open - close -1));

 name  = ntmp;
 value = vtmp;
}
//-----------------------------------------------------------------------------

