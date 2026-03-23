/* WebCppBridge.cpp
 * C-linkage bridge implementation wrapping the C++ Driver class.
 */

#include "WebCppBridge.h"
#include "driver.h"
#include <cstdlib>
#include <cstring>
#include <sstream>
#include <fstream>
#include <iostream>
using namespace std;

// Helper: duplicate a std::string as a C-allocated char*.
static char *dup_string(const string &s) {
    char *p = (char *)malloc(s.size() + 1);
    if (p) {
        memcpy(p, s.c_str(), s.size() + 1);
    }
    return p;
}

extern "C" {

WebCppDriverRef webcpp_driver_create(void) {
    return new Driver();
}

void webcpp_driver_destroy(WebCppDriverRef driver) {
    delete static_cast<Driver *>(driver);
}

void webcpp_driver_help(char mode) {
    Driver::help(mode);
}

bool webcpp_driver_switch_parser(WebCppDriverRef driver, const char *arg) {
    return static_cast<Driver *>(driver)->switch_parser(string(arg));
}

char webcpp_driver_get_ext(WebCppDriverRef driver, const char *filename) {
    return static_cast<Driver *>(driver)->getExt(string(filename));
}

char *webcpp_driver_check_ext(WebCppDriverRef driver, const char *filename) {
    string result = static_cast<Driver *>(driver)->checkExt(string(filename));
    return dup_string(result);
}

void webcpp_driver_make_index(const char *prefix) {
    Driver::makeIndex(string(prefix ? prefix : ""));
}

bool webcpp_driver_prep_files(WebCppDriverRef driver,
                              const char *ifile,
                              const char *ofile,
                              char over) {
    return static_cast<Driver *>(driver)->prep_files(
        string(ifile), string(ofile), over);
}

char *webcpp_driver_get_title(WebCppDriverRef driver) {
    string result = static_cast<Driver *>(driver)->getTitle();
    return dup_string(result);
}

void webcpp_driver_drive(WebCppDriverRef driver) {
    static_cast<Driver *>(driver)->drive();
}

char *webcpp_driver_highlight_string(const char *source,
                                     const char *filename,
                                     const char **options) {
    // Write source to a uniquely-named temporary file so that
    // concurrent callers (e.g. parallel unit tests) don't collide.
    const char *tmpDir = getenv("TMPDIR");
    if (!tmpDir) tmpDir = "/tmp";

    // Build a per-call suffix from the thread ID and a counter
    static _Atomic unsigned long long counter = 0;
    unsigned long long seq = counter++;
    string suffix = to_string(seq);
    string tmpIn  = string(tmpDir) + "/webcpp_in_"  + suffix + ".tmp";
    string tmpOut = string(tmpDir) + "/webcpp_out_" + suffix + ".tmp";

    {
        ofstream ofs(tmpIn.c_str());
        if (!ofs) return nullptr;
        ofs << source;
    }

    Driver drv;
    // Detect the language based on the given filename
    drv.checkExt(string(filename));

    if (!drv.prep_files(tmpIn, tmpOut, 'f')) {
        return nullptr;
    }

    // Apply snippet-only mode by default so we get just the highlighted HTML
    drv.switch_parser(string("-s"));

    // Apply any caller-supplied options
    if (options) {
        for (int i = 0; options[i] != nullptr; i++) {
            drv.switch_parser(string(options[i]));
        }
    }

    drv.drive();

    // Read the output file into a string
    ifstream ifs(tmpOut.c_str());
    if (!ifs) return nullptr;

    ostringstream oss;
    oss << ifs.rdbuf();
    string html = oss.str();

    // Clean up temp files
    remove(tmpIn.c_str());
    remove(tmpOut.c_str());

    return dup_string(html);
}

void webcpp_free_string(char *str) {
    free(str);
}

} // extern "C"
