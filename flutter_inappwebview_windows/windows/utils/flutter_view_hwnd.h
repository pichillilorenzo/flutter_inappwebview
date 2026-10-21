#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_FLUTTER_VIEW_HWND_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_FLUTTER_VIEW_HWND_H_

#include <flutter/plugin_registrar_windows.h>

#include <cstdint>
#include <optional>
#include <set>

namespace flutter_inappwebview_plugin
{
  // Pending controllers have no CustomPlatformView yet; preserve their hosts too.
  static inline void ParkPendingWebViewHosts(const std::set<HWND>& hosts,
    HWND flutterViewHwnd, HWND parkingHwnd)
  {
    if (!parkingHwnd) return;
    for (const auto host : hosts) {
      if (GetParent(host) == flutterViewHwnd) {
        SetParent(host, parkingHwnd);
      }
    }
  }

  // HWND of the Flutter view [viewId]; without an id, the implicit view.
  // Never cache the FlutterView: it goes away when its window is destroyed.
  static inline HWND ResolveFlutterViewHwnd(flutter::PluginRegistrarWindows* registrar,
    const std::optional<int64_t>& viewId)
  {
    if (!registrar) {
      return nullptr;
    }
    if (viewId.has_value()) {
      if (const auto view = registrar->GetViewById(viewId.value())) {
        return view->GetNativeWindow();
      }
      // An unknown id other than the implicit view's must not land in view 0.
      if (viewId.value() != 0) {
        return nullptr;
      }
    }
    const auto view = registrar->GetView();
    return view ? view->GetNativeWindow() : nullptr;
  }
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_FLUTTER_VIEW_HWND_H_
