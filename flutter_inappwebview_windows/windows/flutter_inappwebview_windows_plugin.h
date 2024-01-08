#ifndef FLUTTER_PLUGIN_FLUTTER_INAPPWEBVIEW_PLUGIN_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUTTER_INAPPWEBVIEW_PLUGIN_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

namespace flutter_inappwebview_plugin
{
  class InAppBrowserManager;

  class FlutterInappwebviewWindowsPlugin : public flutter::Plugin {
  public:
    flutter::PluginRegistrarWindows* registrar;
    std::unique_ptr<InAppBrowserManager> inAppBrowserManager;

    static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

    FlutterInappwebviewWindowsPlugin(flutter::PluginRegistrarWindows* registrar);

    virtual ~FlutterInappwebviewWindowsPlugin();

    // Disallow copy and assign.
    FlutterInappwebviewWindowsPlugin(const FlutterInappwebviewWindowsPlugin&) = delete;
    FlutterInappwebviewWindowsPlugin& operator=(const FlutterInappwebviewWindowsPlugin&) = delete;
  };
}
#endif  // FLUTTER_PLUGIN_FLUTTER_INAPPWEBVIEW_PLUGIN_PLUGIN_H_
