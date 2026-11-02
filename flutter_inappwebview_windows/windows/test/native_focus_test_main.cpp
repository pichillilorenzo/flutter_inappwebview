// Windows only: real windows, real Win32 focus.
// cl /nologo /std:c++17 /EHsc /W4 native_focus_test_main.cpp user32.lib
#include <iostream>
#include <stdexcept>

#include "../in_app_webview/native_focus.h"

namespace
{
  void require(const bool condition, const char* message)
  {
    if (!condition) {
      throw std::runtime_error(message);
    }
  }

  HWND child(const HWND parent)
  {
    return CreateWindowExW(0, L"STATIC", L"", WS_CHILD, 0, 0, 10, 10, parent,
      nullptr, GetModuleHandleW(nullptr), nullptr);
  }
}

int main()
{
  try {
    using flutter_inappwebview_plugin::focusIsInsideHost;
    const HWND top = CreateWindowExW(WS_EX_NOACTIVATE, L"STATIC", L"", WS_POPUP,
      0, 0, 10, 10, nullptr, nullptr, GetModuleHandleW(nullptr), nullptr);
    const HWND flutterView = child(top);
    const HWND host = child(flutterView);
    const HWND input = child(host);
    const HWND otherHost = child(flutterView);
    const HWND otherInput = child(otherHost);
    require(top && flutterView && host && input && otherHost && otherInput, "CreateWindowEx failed");

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

    DestroyWindow(top);
  }
  catch (const std::exception& error) {
    std::cerr << "native focus tests failed: " << error.what() << '\n';
    return 1;
  }
  std::cout << "native focus tests passed\n";
  return 0;
}
