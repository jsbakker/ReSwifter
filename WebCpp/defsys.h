/* webcpp - defsys.h
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

#ifndef _DEF_SYS_H
#define _DEF_SYS_H

#if     defined(WIN32)
#define COPY "copy /y"
#define LIST_DIRECTORY "dir /s /b "
#define DIRECTORY_SLASH "\\"
#define WEBCPP_DATA_DIR "C:\\Program Files\\Jeffrey Bakker\\Webcpp\\"
#define DELETE "del webcppbatch.txt"
#define CYCLE_SPEED CLK_TCK
#else
#define COPY "cp"
#define LIST_DIRECTORY "ls "
#define DIRECTORY_SLASH "/"
#define WEBCPP_DATA_DIR "/usr/local/share/webcpp/"
#define DELETE "rm -f webcppbatch.txt"
#define CYCLE_SPEED CLOCKS_PER_SEC
#endif  //defined(WIN32/UNIX)

#endif //_DEF_SYS_H
