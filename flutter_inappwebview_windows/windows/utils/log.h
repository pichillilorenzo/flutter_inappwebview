#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_LOG_UTIL_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_LOG_UTIL_H_

#include <comdef.h>
#include <iostream>
#include <string>
#include <type_traits>

#include "strconv.h"

namespace flutter_inappwebview_plugin
{
  template <typename T>
  static inline void debugLog(const std::basic_string<T>& msg, const bool& isError = false)
  {
#ifndef NDEBUG
    if (isError) {
      std::cerr << msg << std::endl;
    }
    else {
      std::cout << msg << std::endl;
    }
    OutputDebugString(ansi_to_wide(msg + "\n").c_str());
#endif
  }

  static inline void debugLog(const char* msg, const bool& isError = false)
  {
    debugLog(std::string(msg), isError);
  }

  static inline void debugLog(const std::wstring& msg, const bool& isError = false)
  {
    debugLog(wide_to_ansi(msg), isError);
  }

  static inline void debugLog(const bool& value, const bool& isError = false)
  {
    debugLog(value ? "true" : "false", isError);
  }

  template<
    typename T,
    typename = typename std::enable_if<std::is_arithmetic<T>::value, T>::type
  >
  static inline void debugLog(const T& value, const bool& isError = false)
  {
    debugLog(std::to_string(value), isError);
  }

  static inline std::string getHRMessage(const HRESULT& error)
  {
    return wide_to_ansi(_com_error(error).ErrorMessage());
  }

  static inline void debugLog(const HRESULT& hr)
  {
    auto isError = hr != S_OK;
    debugLog((isError ? "Error: " : "Message: ") + getHRMessage(hr), isError);
  }

  static inline bool succeededOrLog(const HRESULT& hr)
  {
    if (SUCCEEDED(hr)) {
      return true;
    }
    debugLog(hr);
    return false;
  }

  static inline bool failedAndLog(const HRESULT& hr)
  {
    if (FAILED(hr)) {
      debugLog(hr);
      return true;
    }
    return false;
  }

  static inline void failedLog(const HRESULT& hr)
  {
    if (FAILED(hr)) {
      debugLog(hr);
    }
  }
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_LOG_UTIL_H_