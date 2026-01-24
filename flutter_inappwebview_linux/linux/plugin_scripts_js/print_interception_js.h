#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_PRINT_INTERCEPTION_JS_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_PRINT_INTERCEPTION_JS_H_

#include <memory>
#include <optional>
#include <string>
#include <vector>

#include "../types/plugin_script.h"
#include "javascript_bridge_js.h"

namespace flutter_inappwebview_plugin {

/**
 * JavaScript for intercepting window.print() calls.
 *
 * WPE WebKit doesn't have a native print signal like WebKitGTK,
 * so we intercept window.print() calls via JavaScript and notify
 * the Dart side via the JavaScript bridge.
 *
 * This allows the app to:
 * - Know when a page tries to print
 * - Optionally implement print-to-PDF functionality
 * - Handle print requests in a platform-appropriate way
 */
class PrintInterceptionJS {
 public:
  inline static const std::string PRINT_INTERCEPTION_JS_PLUGIN_SCRIPT_GROUP_NAME =
      "IN_APP_WEBVIEW_PRINT_INTERCEPTION_JS_PLUGIN_SCRIPT";

  /**
   * JavaScript source code for print interception.
   * This code intercepts window.print() calls and notifies the native side.
   */
  static std::string PRINT_INTERCEPTION_JS_SOURCE() {
    return R"JS(
(function() {
  // Avoid re-registering
  if (window._flutterInAppWebViewPrintInterceptionInit) return;
  window._flutterInAppWebViewPrintInterceptionInit = true;

  // Store the original window.print function
  var originalPrint = window.print;

  // Override window.print
  window.print = function() {
    // Check if the JavaScript bridge is available
    var bridge = window.)JS" + JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() + R"JS(;
    if (bridge && typeof bridge.callHandler === 'function') {
      // Notify the native side about the print request
      bridge.callHandler('_onPrintRequest', {
        url: window.location.href,
        title: document.title
      }).then(function(result) {
        // If the native side returns true, proceed with original print
        // Otherwise, the native side handled the print request
        if (result === true) {
          originalPrint.call(window);
        }
      }).catch(function(error) {
        // On error, fall back to original print behavior
        console.warn('Print interception error:', error);
        originalPrint.call(window);
      });
    } else {
      // No bridge available, use original print
      originalPrint.call(window);
    }
  };
})();
)JS";
  }

  /**
   * Creates a PluginScript for print interception.
   */
  static std::unique_ptr<PluginScript> PRINT_INTERCEPTION_JS_PLUGIN_SCRIPT(
      const std::optional<std::vector<std::string>>& allowedOriginRules,
      bool forMainFrameOnly) {
    return std::make_unique<PluginScript>(
        PRINT_INTERCEPTION_JS_PLUGIN_SCRIPT_GROUP_NAME, PRINT_INTERCEPTION_JS_SOURCE(),
        UserScriptInjectionTime::atDocumentStart, forMainFrameOnly,
        allowedOriginRules,
        nullptr,                    // contentWorld
        true,                       // requiredInAllContentWorlds
        std::vector<std::string>{}  // no additional message handlers needed
    );
  }
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_PRINT_INTERCEPTION_JS_H_
