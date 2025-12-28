#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_JAVASCRIPT_BRIDGE_JS_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_JAVASCRIPT_BRIDGE_JS_H_

#include <memory>
#include <optional>
#include <string>
#include <vector>

#include "../types/plugin_script.h"
#include "../utils/string.h"

namespace flutter_inappwebview_plugin {

/**
 * JavaScript bridge for communication between web content and native code.
 * 
 * WebKitGTK uses a different approach than WKWebView:
 * - We inject JavaScript that captures calls
 * - JavaScript calls are sent via webkit.messageHandlers (using WKUserScript)
 * - Or we can use webkit_web_view_run_javascript_in_world with custom URI schemes
 * 
 * For WebKitGTK, we use webkit_user_content_manager to register script message handlers
 * and inject JavaScript that sends messages to these handlers.
 */
class JavaScriptBridgeJS {
 public:
  static void set_JAVASCRIPT_BRIDGE_NAME(const std::string& bridgeName) {
    _JAVASCRIPT_BRIDGE_NAME = bridgeName;
  }

  static std::string get_JAVASCRIPT_BRIDGE_NAME() {
    return _JAVASCRIPT_BRIDGE_NAME;
  }

  inline static const std::string JAVASCRIPT_BRIDGE_JS_PLUGIN_SCRIPT_GROUP_NAME =
      "IN_APP_WEBVIEW_JAVASCRIPT_BRIDGE_JS_PLUGIN_SCRIPT";

  inline static const std::string VAR_JAVASCRIPT_BRIDGE_BRIDGE_SECRET =
      "$IN_APP_WEBVIEW_JAVASCRIPT_BRIDGE_BRIDGE_SECRET";

  /**
   * JavaScript source code for the bridge.
   * This code sets up window.flutter_inappwebview.callHandler() function
   * which communicates with native code via webkit.messageHandlers.
   */
  static std::string JAVASCRIPT_BRIDGE_JS_SOURCE() {
    return R"JS(
window.)JS" + get_JAVASCRIPT_BRIDGE_NAME() + R"JS( = {};
(function(window) {
  var bridgeSecret = ')JS" + VAR_JAVASCRIPT_BRIDGE_BRIDGE_SECRET + R"JS(';
  var origin = '';
  var requestUrl = '';
  var isMainFrame = false;
  var _JSON_stringify;
  var _Array_slice;
  var _setTimeout;
  var _Promise;
  var _postMessage;
  
  try {
    origin = window.location.origin;
  } catch (_) {}
  try {
    requestUrl = window.location.href;
  } catch (_) {}
  try {
    isMainFrame = window === window.top;
  } catch (_) {}
  
  try {
    _JSON_stringify = window.JSON.stringify;
    _Array_slice = window.Array.prototype.slice;
    _Array_slice.call = window.Function.prototype.call;
    _setTimeout = window.setTimeout;
    _Promise = window.Promise;
    _postMessage = window.webkit.messageHandlers.callHandler.postMessage;
  } catch (_) { return; }
  
  window.)JS" + get_JAVASCRIPT_BRIDGE_NAME() + R"JS(.callHandler = function() {
    try {
      requestUrl = window.location.href;
    } catch (_) {}
    
    var _callHandlerID = _setTimeout(function() {});
    _postMessage({
      'handlerName': arguments[0],
      '_callHandlerID': _callHandlerID,
      '_bridgeSecret': bridgeSecret,
      'origin': origin,
      'requestUrl': requestUrl,
      'isMainFrame': isMainFrame,
      'args': _JSON_stringify(_Array_slice.call(arguments, 1))
    });
    
    return new _Promise(function(resolve, reject) {
      try {
        (isMainFrame ? window : window.top).)JS" + get_JAVASCRIPT_BRIDGE_NAME() + R"JS([_callHandlerID] = { resolve: resolve, reject: reject };
      } catch(e) { resolve(); }
    });
  };
})(window);
)JS";
  }

  /**
   * JavaScript to dispatch the platform ready event.
   */
  static std::string PLATFORM_READY_JS_SOURCE() {
    return R"JS(
(function() {
  if ((window.top == null || window.top === window) && 
      window.)JS" + get_JAVASCRIPT_BRIDGE_NAME() + R"JS( != null && 
      window.)JS" + get_JAVASCRIPT_BRIDGE_NAME() + R"JS(._platformReady == null) {
    window.dispatchEvent(new Event('flutterInAppWebViewPlatformReady'));
    window.)JS" + get_JAVASCRIPT_BRIDGE_NAME() + R"JS(._platformReady = true;
  }
})();
)JS";
  }

  /**
   * Creates a PluginScript for the JavaScript bridge.
   */
  static std::unique_ptr<PluginScript> JAVASCRIPT_BRIDGE_JS_PLUGIN_SCRIPT(
      const std::string& expectedBridgeSecret,
      const std::optional<std::vector<std::string>>& allowedOriginRules,
      bool forMainFrameOnly) {
    std::string source = JAVASCRIPT_BRIDGE_JS_SOURCE();
    // Replace the placeholder with the actual secret
    size_t pos = source.find(VAR_JAVASCRIPT_BRIDGE_BRIDGE_SECRET);
    if (pos != std::string::npos) {
      source.replace(pos, VAR_JAVASCRIPT_BRIDGE_BRIDGE_SECRET.length(), expectedBridgeSecret);
    }
    
    return std::make_unique<PluginScript>(
        JAVASCRIPT_BRIDGE_JS_PLUGIN_SCRIPT_GROUP_NAME,
        source,
        UserScriptInjectionTime::atDocumentStart,
        forMainFrameOnly,
        allowedOriginRules,
        nullptr,  // contentWorld
        true,     // requiredInAllContentWorlds
        std::vector<std::string>{"callHandler"}  // messageHandlerNames
    );
  }

 private:
  inline static std::string _JAVASCRIPT_BRIDGE_NAME = "flutter_inappwebview";
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_JAVASCRIPT_BRIDGE_JS_H_
