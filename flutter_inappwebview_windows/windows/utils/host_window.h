#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_UTILS_HOST_WINDOW_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_UTILS_HOST_WINDOW_H_

#include <flutter/plugin_registrar_windows.h>
#include <windows.h>

#include <cstdint>
#include <optional>

namespace flutter_inappwebview_plugin {

// Resolve a Flutter viewId to its top-level HWND via the engine's internal
// FFI symbol — the same one Flutter's WindowControllerWin32.windowHandle
// uses on the Dart side.
//
// Returns nullptr if flutter_windows.dll isn't loaded yet or the symbol
// isn't exported (older engines without multi-window support).
inline HWND ResolveFlutterViewHwnd(int64_t engineId, int64_t viewId) {
  using GetHandleFn = HWND(__cdecl*)(int64_t, int64_t);
  static auto* fn = []() -> GetHandleFn {
    HMODULE m = ::GetModuleHandleW(L"flutter_windows.dll");
    if (!m) return nullptr;
    return reinterpret_cast<GetHandleFn>(::GetProcAddress(
        m, "InternalFlutterWindows_WindowManager_GetTopLevelWindowHandle"));
  }();
  return fn ? fn(engineId, viewId) : nullptr;
}

// Pick the right parent HWND for webview hosting.
//
//  1. If Dart supplied a `flutterViewId`, resolve it to the corresponding
//     RegularWindow's HWND (multi-window case).
//  2. Otherwise fall back to the registrar's view (classic single-window
//     case where the C++ runner created a FlutterViewController).
//  3. Final fallback: nullptr — Win32 accepts this for top-level windows,
//     and the actual rendering goes through CustomPlatformView's texture
//     anyway, so the parent HWND is just an attachment anchor for WebView2.
inline HWND PickHostHwnd(flutter::PluginRegistrarWindows* registrar,
                         std::optional<int64_t> engineId,
                         std::optional<int64_t> flutterViewId) {
  if (engineId.has_value() && flutterViewId.has_value()) {
    if (HWND h = ResolveFlutterViewHwnd(*engineId, *flutterViewId)) {
      return h;
    }
  }
  if (auto* view = registrar->GetView()) {
    return view->GetNativeWindow();
  }
  return nullptr;
}

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_UTILS_HOST_WINDOW_H_
