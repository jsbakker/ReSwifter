/* WebCppBridge.h
 * C-linkage bridge exposing the C++ Driver interface for Swift interop.
 */

#ifndef WEBCPP_BRIDGE_H
#define WEBCPP_BRIDGE_H

#include <stdbool.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

/// Opaque handle to a C++ Driver instance.
typedef void *WebCppDriverRef;

/// Creates a new Driver instance. Caller must call webcpp_driver_destroy when
/// done.
WebCppDriverRef webcpp_driver_create(void);

/// Destroys a Driver instance.
void webcpp_driver_destroy(WebCppDriverRef driver);

/// Prints help text to stderr. mode is 'L' for languages or 'D' for default
/// usage.
void webcpp_driver_help(char mode);

/// Parses a command-line-style option string (e.g. "-l", "--line-numbers",
/// "-c=scheme"). Returns true if the option was valid.
bool webcpp_driver_switch_parser(WebCppDriverRef driver, const char *arg);

/// Returns the language file-type character for the given filename extension.
char webcpp_driver_get_ext(WebCppDriverRef driver, const char *filename);

/// Detects the language for the given filename and returns a description
/// string. The caller must free the returned string with webcpp_free_string.
char *webcpp_driver_check_ext(WebCppDriverRef driver, const char *filename);

/// Generates an index HTML file from a webcppbatch.txt listing.
void webcpp_driver_make_index(const char *prefix);

/// Prepares the input and output files. 'over' controls overwrite behaviour:
///   'f' = force, 'k' = keep/never, 'w' = prompt/write.
/// Returns true on success.
bool webcpp_driver_prep_files(WebCppDriverRef driver, const char *ifile,
                              const char *ofile, char over);

/// Returns the filename portion (without path) of the current input file.
/// The caller must free the returned string with webcpp_free_string.
char *webcpp_driver_get_title(WebCppDriverRef driver);

/// Runs the webcpp syntax-highlighting engine on the prepared files.
void webcpp_driver_drive(WebCppDriverRef driver);

/// Convenience: converts a source code string to syntax-highlighted HTML.
/// The caller must free the returned string with webcpp_free_string.
/// Parameters:
///   source   – the source code text to highlight
///   filename – a representative filename used to detect the language (e.g.
///   "example.py") options  – a null-terminated array of option strings (e.g.
///   {"-l", "-s", NULL}), or NULL
char *webcpp_driver_highlight_string(const char *source, const char *filename,
                                     const char **options);

/// Frees a string that was allocated by the bridge.
void webcpp_free_string(char *str);

#ifdef __cplusplus
}
#endif

#endif /* WEBCPP_BRIDGE_H */
