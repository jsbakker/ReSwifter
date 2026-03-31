/* WebCppBridge.cpp
 * C-linkage bridge implementation wrapping the C++ Driver class.
 */

#include "WebCppBridge.h"
#include "driver.h"

#include <cstdlib>
#include <cstring>
#include <vector>

using std::string;
using std::vector;

// Helper: duplicate a std::string as a C-allocated char*.
static char *dup_string(const string &s) {
    char *p = (char *)malloc(s.size() + 1);
    if (p) {
        memcpy(p, s.c_str(), s.size() + 1);
    }
    return p;
}

extern "C" {

WebCppDriverRef webcpp_driver_create(void) { return new Driver(); }

void webcpp_driver_destroy(WebCppDriverRef driver) {
    delete static_cast<Driver *>(driver);
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

bool webcpp_driver_prep_files(WebCppDriverRef driver, const char *ifile,
                              const char *ofile, char over) {
    return static_cast<Driver *>(driver)->prep_files(string(ifile),
                                                     string(ofile), over);
}

char *webcpp_driver_get_title(WebCppDriverRef driver) {
    string result = static_cast<Driver *>(driver)->getTitle();
    return dup_string(result);
}

void webcpp_driver_drive(WebCppDriverRef driver) {
    static_cast<Driver *>(driver)->drive();
}

char *webcpp_driver_highlight_string(const char *source, const char *filename,
                                     const char **options) {
    vector<string> opts;
    if (options) {
        for (int i = 0; options[i] != nullptr; i++)
            opts.emplace_back(options[i]);
    }

    Driver drv;
    string html = drv.highlight_from_string(
        string(source), string(filename), opts);

    return dup_string(html);
}

void webcpp_free_string(char *str) { free(str); }

} // extern "C"
