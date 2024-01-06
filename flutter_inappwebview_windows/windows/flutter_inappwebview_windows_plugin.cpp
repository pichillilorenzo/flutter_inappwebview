#include "flutter_inappwebview_windows_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>

namespace flutter_inappwebview_plugin
{
    // static
    void FlutterInappwebviewWindowsPlugin::RegisterWithRegistrar(
        flutter::PluginRegistrarWindows* registrar) {
        auto plugin = std::make_unique<FlutterInappwebviewWindowsPlugin>(registrar);
        registrar->AddPlugin(std::move(plugin));
    }

    FlutterInappwebviewWindowsPlugin::FlutterInappwebviewWindowsPlugin(flutter::PluginRegistrarWindows* registrar)
        : FlutterInappwebviewWindowsBasePlugin(registrar)
    {
        inAppBrowserManager = std::make_unique<InAppBrowserManager>(this);
    }

    FlutterInappwebviewWindowsPlugin::~FlutterInappwebviewWindowsPlugin()
    {
        inAppBrowserManager.release();
    }
}