#pragma once

#include <stdexcept>

#include "../in_app_webview/native_focus.h"

namespace flutter_inappwebview_plugin::test::native_focus_test {

inline void require(const bool condition, const char* message) {
  if (!condition) throw std::runtime_error(message);
}

inline HWND child(const HWND parent) {
  return CreateWindowExW(0, L"STATIC", L"", WS_CHILD, 0, 0, 10, 10, parent,
    nullptr, GetModuleHandleW(nullptr), nullptr);
}

// Real windows, real Win32 focus: FlutterView -> two WebView hosts -> their
// input windows, the shape a split tab leaves under the Flutter view.
inline void focusInsideHostOnly() {
  const HWND top = CreateWindowExW(WS_EX_NOACTIVATE, L"STATIC", L"", WS_POPUP,
    0, 0, 10, 10, nullptr, nullptr, GetModuleHandleW(nullptr), nullptr);
  const HWND flutterView = child(top);
  const HWND host = child(flutterView);
  const HWND input = child(host);
  const HWND otherHost = child(flutterView);
  const HWND otherInput = child(otherHost);
  try {
    require(top && flutterView && host && input && otherHost && otherInput,
      "CreateWindowEx failed");

    SetFocus(input);
    require(GetFocus() == input, "setup: input window did not take the focus");
    require(focusIsInsideHost(host, GetFocus()), "focus on the input window counts");

    // What put_IsVisible(FALSE) leaves behind.
    SetFocus(host);
    require(GetFocus() == host, "setup: host did not take the focus");
    require(!focusIsInsideHost(host, GetFocus()), "focus on the host itself does not count");

    SetFocus(otherInput);
    require(!focusIsInsideHost(host, GetFocus()), "another instance's focus does not count");
    require(focusIsInsideHost(otherHost, GetFocus()), "and is that instance's own");

    SetFocus(flutterView);
    require(!focusIsInsideHost(host, GetFocus()), "focus on the Flutter view does not count");

    require(!focusIsInsideHost(nullptr, input), "no host");
    require(!focusIsInsideHost(host, nullptr), "no focus");
  }
  catch (...) {
    if (top) DestroyWindow(top);
    throw;
  }
  DestroyWindow(top);
}

}  // namespace flutter_inappwebview_plugin::test::native_focus_test
