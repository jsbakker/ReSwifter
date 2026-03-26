/* Cfour (C++ Common Console Classes)
 * Copyright (C) 2001 Jeffrey Bakker
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

class CFdatapair {

  public:
    void operator<<(std::string mldata);  //{translateML(mldata);}
    void operator>>(std::string &mldata); //{mldata = info_ml();}
    //---------------------------------------------------------------------------
    CFdatapair();                   // default constructor
    CFdatapair(std::string mldata);      // create datapair with markup data
    CFdatapair(std::string n, std::string v); // create datapair with name and value
    //---------------------------------------------------------------------------
    std::string getname() const;  // return the name
    std::string getvalue() const; // return the value
    void setname(std::string n);  // change the name
    void setvalue(std::string v); // change the value
    //---------------------------------------------------------------------------
    std::string info_nv() const; // return the name/value in printable format
    std::string info_ml() const; // return the name/value in markup format
    //---------------------------------------------------------------------------
    void translateML(std::string mldata); // change the name/value using markup data
    void swap();                     // swap the name and value
    //---------------------------------------------------------------------------
  protected:
    std::string name;
    std::string value;
    //---------------------------------------------------------------------------
};

#endif // _C4_DATA_PAIR
