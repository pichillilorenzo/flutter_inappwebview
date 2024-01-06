#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_BASE_PLUGIN_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_BASE_PLUGIN_H_

#include <flutter/plugin_registrar_windows.h>

namespace flutter_inappwebview_plugin
{
    class FlutterInappwebviewWindowsBasePlugin : public flutter::Plugin, public std::enable_shared_from_this<FlutterInappwebviewWindowsBasePlugin> {
    public:
        flutter::PluginRegistrarWindows* registrar;

        FlutterInappwebviewWindowsBasePlugin(flutter::PluginRegistrarWindows* registrar);

        virtual ~FlutterInappwebviewWindowsBasePlugin();
    };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_BASE_PLUGIN_H_