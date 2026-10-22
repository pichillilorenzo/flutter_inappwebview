#include "include/drago_inappwebview/drago_inappwebview_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "drago_inappwebview_plugin.h"

void DragoInappwebviewPluginCApiRegisterWithRegistrar(
  FlutterDesktopPluginRegistrarRef registrar)
{
  drago_inappwebview_plugin::DragoInappwebviewPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarManager::GetInstance()
    ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
