#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_LOG_UTIL_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_LOG_UTIL_H_

#include <comdef.h>
#include <iostream>
#include <string>

#include "strconv.h"

namespace flutter_inappwebview_plugin
{
  static inline void debugLog(const std::string& msg, const bool& isError = false)
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

  static inline void debugLog(const std::wstring& msg, const bool& isError = false)
  {
    debugLog(wide_to_ansi(msg), isError);
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