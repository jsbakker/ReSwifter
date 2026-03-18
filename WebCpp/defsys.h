/* webcpp - defsys.h
 * Copyright (C)2001-2004, (C)2026 Jeffrey Bakker
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
