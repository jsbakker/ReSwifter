// Author: Jeffrey Bakker  |  Date: May14th 2002  |  langshell.cpp

// the Shell Syntax definition file for Web C Plus Plus
// Webcpp Copyright (C)2001-2004, (C)2026 Jeffrey Bakker
// Updated 2026 for modern Bash 5 and Zsh 5

#include "langshell.h"

#include <algorithm>
#include <iterator>

LangShell::LangShell() {

    fill();
    init_switches();

    doScalars = Yes;
    doUnxComnt = Yes;
    doHeredoc = Yes;
}

void LangShell::fill() {

    // Bash and Zsh keywords
    string K[] = {
        "break",  "case",   "coproc",  "continue", "declare",   "do",
        "done",   "elif",   "else",    "esac",     "eval",      "exec",
        "exit",   "export", "fi",      "for",      "function",  "if",
        "in",     "local",  "mapfile", "read",     "readarray", "readonly",
        "return", "select", "set",     "shift",    "source",    "then",
        "time",   "trap",   "typeset", "unset",    "until",     "while",
    };
    std::copy(std::cbegin(K), std::cend(K), std::back_inserter(keys));

    // Common shell commands and utilities
    string T[] = {
        "apt",    "ar",    "awk",      "basename", "brew",   "cat",
        "cd",     "chgrp", "chmod",    "chown",    "clear",  "cmp",
        "column", "cp",    "curl",     "cut",      "date",   "df",
        "diff",   "dig",   "dirname",  "docker",   "du",     "echo",
        "env",    "false", "find",     "fmt",      "git",    "grep",
        "gunzip", "gzip",  "head",     "hostname", "id",     "install",
        "jq",     "kill",  "killall",  "less",     "ln",     "ls",
        "lsof",   "make",  "man",      "mkdir",    "mktemp", "more",
        "mount",  "mv",    "nohup",    "paste",    "patch",  "pgrep",
        "ping",   "pip",   "pkill",    "printf",   "ps",     "pushd",
        "popd",   "pwd",   "realpath", "rev",      "rm",     "rmdir",
        "rsync",  "scp",   "sed",      "seq",      "sleep",  "sort",
        "split",  "ssh",   "stat",     "sudo",     "tail",   "tar",
        "tee",    "test",  "top",      "touch",    "tr",     "true",
        "umount", "uname", "uniq",     "unzip",    "wc",     "wget",
        "which",  "who",   "whoami",   "xargs",    "yes",    "zip",
    };
    std::copy(std::cbegin(T), std::cend(T), std::back_inserter(types));
}
