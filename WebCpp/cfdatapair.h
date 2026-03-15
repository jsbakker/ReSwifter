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
 *  Filename:            cfdatapair.h
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
 *  This is the class defintion for CFdataPair, a class which provides methods
 *  and data members for storing pairs of data.
 *
 *  ===========================================================================
 * _______. ..
 */


#ifndef _C4_DATA_PAIR 
#define _C4_DATA_PAIR 

#include <string> 
using namespace std;

class CFdatapair {

 public:

  void operator<<(string  mldata);//{translateML(mldata);}
  void operator>>(string& mldata);//{mldata = info_ml();}
  //---------------------------------------------------------------------------
  CFdatapair();                   // default constructor
  CFdatapair(string mldata);      // create datapair with markup data
  CFdatapair(string n, string v); // create datapair with name and value
  //---------------------------------------------------------------------------
  string getname()  const;        // return the name
  string getvalue() const;        // return the value
  void setname (string n);        // change the name
  void setvalue(string v);        // change the value
  //---------------------------------------------------------------------------
  string info_nv()  const;        // return the name/value in printable format
  string info_ml()  const;        // return the name/value in markup format
  //---------------------------------------------------------------------------
  void translateML(string mldata);// change the name/value using markup data
  void swap();                    // swap the name and value
  //---------------------------------------------------------------------------
 protected:

  string name;
  string value;
  //---------------------------------------------------------------------------
};

#endif  // _C4_DATA_PAIR 

