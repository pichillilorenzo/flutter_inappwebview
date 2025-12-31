#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_LOG_UTIL_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_LOG_UTIL_H_

#include <glib.h>

#include <iostream>
#include <string>
#include <type_traits>

#include "string.h"

namespace flutter_inappwebview_plugin {

template <typename T>
static inline void debugLog(const std::basic_string<T>& msg, const bool& isError = false,
                            const std::string& filename = "", const int& line = 0) {
#ifndef NDEBUG
  std::basic_string<T> debugMsg = msg;
  if (!filename.empty() && line > 0) {
    auto filenameSplit = split(filename, std::string{"/flutter_inappwebview_linux/"});
    std::string reduceFilenamePath =
        filenameSplit.size() > 0 ? "flutter_inappwebview_linux/" + filenameSplit.back() : filename;
    debugMsg = reduceFilenamePath + "(" + std::to_string(line) + "): " + debugMsg;
  }

  // Use g_message for GLib-based logging
  if (isError) {
    g_warning("[flutter_inappwebview] %s", std::string(debugMsg).c_str());
  } else {
    g_message("[flutter_inappwebview] %s", std::string(debugMsg).c_str());
  }
#endif
}

static inline void debugLog(const char* msg, const bool& isError = false,
                            const std::string& filename = "", const int& line = 0) {
  debugLog(std::string(msg), isError, filename, line);
}

static inline void debugLog(const bool& value, const bool& isError = false,
                            const std::string& filename = "", const int& line = 0) {
  debugLog(value ? "true" : "false", isError, filename, line);
}

template <typename T, typename = typename std::enable_if<std::is_arithmetic<T>::value, T>::type>
static inline void debugLog(const T& value, const bool& isError = false,
                            const std::string& filename = "", const int& line = 0) {
  debugLog(std::to_string(value), isError, filename, line);
}

static inline void errorLog(const std::string& msg, const std::string& filename = "",
                            const int& line = 0) {
  debugLog(msg, true, filename, line);
}

// GError logging helper
static inline void logGError(GError* error, const std::string& filename = "", const int& line = 0) {
  if (error != nullptr) {
    std::string msg = "GError: " + std::string(error->message) +
                      " (domain: " + std::to_string(error->domain) +
                      ", code: " + std::to_string(error->code) + ")";
    debugLog(msg, true, filename, line);
  }
}

// Success check with logging for GError - returns true if NO error
static inline bool succeededOrLog(GError** error, const std::string& filename = "",
                                  const int& line = 0) {
  if (error != nullptr && *error != nullptr) {
    logGError(*error, filename, line);
    g_error_free(*error);
    *error = nullptr;
    return false;
  }
  return true;
}

// Failed check with logging for GError - returns true if there IS an error
static inline bool failedAndLog(GError** error, const std::string& filename = "",
                                const int& line = 0) {
  if (error != nullptr && *error != nullptr) {
    logGError(*error, filename, line);
    g_error_free(*error);
    *error = nullptr;
    return true;
  }
  return false;
}

// Log GError without returning status
static inline void failedLog(GError** error, const std::string& filename = "",
                             const int& line = 0) {
  if (error != nullptr && *error != nullptr) {
    logGError(*error, filename, line);
    g_error_free(*error);
    *error = nullptr;
  }
}

}  // namespace flutter_inappwebview_plugin

#ifndef NDEBUG
#define debugLog(value) debugLog(value, false, __FILE__, __LINE__)
#define logGError(error) logGError(error, __FILE__, __LINE__)
#define succeededOrLog(error) succeededOrLog(error, __FILE__, __LINE__)
#define failedAndLog(error) failedAndLog(error, __FILE__, __LINE__)
#define failedLog(error) failedLog(error, __FILE__, __LINE__)
#endif

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_LOG_UTIL_H_
