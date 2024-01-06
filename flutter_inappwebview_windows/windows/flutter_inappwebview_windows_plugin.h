#ifndef FLUTTER_PLUGIN_FLUTTER_INAPPWEBVIEW_PLUGIN_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUTTER_INAPPWEBVIEW_PLUGIN_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

#include "flutter_inappwebview_windows_base_plugin.h"

#include "in_app_browser/in_app_browser_manager.h"

namespace flutter_inappwebview_plugin
{
    class FlutterInappwebviewWindowsPlugin : public FlutterInappwebviewWindowsBasePlugin {
    public:
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
