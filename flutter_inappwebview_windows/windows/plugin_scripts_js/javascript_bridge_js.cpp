#include <set>

#include "javascript_bridge_js.h"

namespace flutter_inappwebview_plugin
{
  const std::string JAVASCRIPT_BRIDGE_JS_SOURCE = "window." + JAVASCRIPT_BRIDGE_NAME + " = {}; \
  window." + JAVASCRIPT_BRIDGE_NAME + ".callHandler = function() { \
    var _callHandlerID = setTimeout(function() {}); \
    window.chrome.webview.postMessage({ 'internalHandlerName': 'callHandler', 'handlerName': arguments[0], '_callHandlerID' : _callHandlerID, 'args' : JSON.stringify(Array.prototype.slice.call(arguments, 1)) }); \
    return new Promise(function(resolve, reject) { \
      window." + JAVASCRIPT_BRIDGE_NAME + "[_callHandlerID] = { resolve: resolve, reject : reject };\
    });\
  };";

  std::unique_ptr<PluginScript> createJavaScriptBridgePluginScript()
  {
    const std::set<std::string> allowedOriginRules = { "*" };
    return std::make_unique<PluginScript>(
      JAVASCRIPT_BRIDGE_JS_PLUGIN_SCRIPT_GROUP_NAME,
      JAVASCRIPT_BRIDGE_JS_SOURCE,
      UserScriptInjectionTime::atDocumentStart,
      allowedOriginRules
    );
  }
}