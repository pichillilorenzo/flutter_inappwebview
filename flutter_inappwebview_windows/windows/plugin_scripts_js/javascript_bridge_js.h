#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_JAVASCRIPT_BRIDGE_JS_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_JAVASCRIPT_BRIDGE_JS_H_

#include <memory>
#include <string>

#include "../types/plugin_script.h"

namespace flutter_inappwebview_plugin
{
  const std::string JAVASCRIPT_BRIDGE_NAME = "flutter_inappwebview";
  const std::string JAVASCRIPT_BRIDGE_JS_PLUGIN_SCRIPT_GROUP_NAME = "IN_APP_WEBVIEW_JAVASCRIPT_BRIDGE_JS_PLUGIN_SCRIPT";

  std::unique_ptr<PluginScript> createJavaScriptBridgePluginScript();
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_JAVASCRIPT_BRIDGE_JS_H_