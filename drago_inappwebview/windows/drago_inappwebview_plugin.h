#ifndef FLUTTER_PLUGIN_DRAGO_INAPPWEBVIEW_PLUGIN_PLUGIN_H_
#define FLUTTER_PLUGIN_DRAGO_INAPPWEBVIEW_PLUGIN_PLUGIN_H_

#include <flutter/plugin_registrar_windows.h>

namespace drago_inappwebview_plugin
{
  class WebViewEnvironmentManager;
  class InAppWebViewManager;
  class InAppBrowserManager;
  class HeadlessInAppWebViewManager;
  class CookieManager;
  class PlatformUtil;

  class DragoInappwebviewPlugin : public flutter::Plugin {
  public:
    flutter::PluginRegistrarWindows* registrar;
    std::unique_ptr<WebViewEnvironmentManager> webViewEnvironmentManager;
    std::unique_ptr<InAppWebViewManager> inAppWebViewManager;
    std::unique_ptr<InAppBrowserManager> inAppBrowserManager;
    std::unique_ptr<HeadlessInAppWebViewManager> headlessInAppWebViewManager;
    std::unique_ptr<CookieManager> cookieManager;
    std::unique_ptr<PlatformUtil> platformUtil;

    static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

    DragoInappwebviewPlugin(flutter::PluginRegistrarWindows* registrar);

    virtual ~DragoInappwebviewPlugin();

    // Disallow copy and assign.
    DragoInappwebviewPlugin(const DragoInappwebviewPlugin&) = delete;
    DragoInappwebviewPlugin& operator=(const DragoInappwebviewPlugin&) = delete;
  private:
    // The ID of the WindowProc delegate registration.
    int window_proc_id = -1;
    std::optional<LRESULT> HandleWindowProc(
      HWND hWnd,
      UINT message,
      WPARAM wParam,
      LPARAM lParam);
  };
}
#endif  // FLUTTER_PLUGIN_DRAGO_INAPPWEBVIEW_PLUGIN_PLUGIN_H_
