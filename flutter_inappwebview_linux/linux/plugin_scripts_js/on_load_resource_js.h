#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_ON_LOAD_RESOURCE_JS_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_ON_LOAD_RESOURCE_JS_H_

#include <memory>
#include <optional>
#include <string>
#include <vector>

#include "../types/plugin_script.h"
#include "javascript_bridge_js.h"

namespace flutter_inappwebview_plugin {

/**
 * JavaScript for capturing resource load events.
 *
 * This script uses the PerformanceObserver API to monitor resource loading
 * and sends the data to the native side via the JavaScript bridge.
 *
 * Matches iOS implementation: OnLoadResourceJS.swift
 */
class OnLoadResourceJS {
 public:
  inline static const std::string ON_LOAD_RESOURCE_JS_PLUGIN_SCRIPT_GROUP_NAME =
      "IN_APP_WEBVIEW_ON_LOAD_RESOURCE_JS_PLUGIN_SCRIPT";

  /**
   * Flag variable name used to enable/disable the observer at runtime.
   */
  static std::string FLAG_VARIABLE_FOR_ON_LOAD_RESOURCE_JS_SOURCE() {
    return "window." + JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() +
           "._useOnLoadResource";
  }

  /**
   * JavaScript source code for resource loading observation.
   * Uses PerformanceObserver API to track all resource loads.
   *
   * Matches iOS OnLoadResourceJS.swift implementation.
   */
  static std::string ON_LOAD_RESOURCE_JS_SOURCE() {
    const std::string flagVariable = FLAG_VARIABLE_FOR_ON_LOAD_RESOURCE_JS_SOURCE();
    const std::string bridgeName = JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME();

    return flagVariable + R"JS( = true;
(function() {
    var observer = new PerformanceObserver(function(list) {
        list.getEntries().forEach(function(entry) {
            if ()JS" + flagVariable + R"JS( == null || )JS" + flagVariable + R"JS( == true) {
                var resource = {
                    "url": entry.name,
                    "initiatorType": entry.initiatorType,
                    "startTime": entry.startTime,
                    "duration": entry.duration
                };
                window.)JS" + bridgeName + R"JS(.callHandler("onLoadResource", resource);
            }
        });
    });
    observer.observe({entryTypes: ['resource']});
})();
)JS";
  }

  /**
   * Creates a PluginScript for resource load observation.
   *
   * @param allowedOriginRules Optional list of origin rules to restrict script injection.
   * @param forMainFrameOnly Whether to inject only in main frame.
   */
  static std::unique_ptr<PluginScript> ON_LOAD_RESOURCE_JS_PLUGIN_SCRIPT(
      const std::optional<std::vector<std::string>>& allowedOriginRules,
      bool forMainFrameOnly) {
    return std::make_unique<PluginScript>(
        ON_LOAD_RESOURCE_JS_PLUGIN_SCRIPT_GROUP_NAME,
        ON_LOAD_RESOURCE_JS_SOURCE(),
        UserScriptInjectionTime::atDocumentStart,
        forMainFrameOnly,
        allowedOriginRules,
        nullptr,                    // contentWorld
        false,                      // requiredInAllContentWorlds
        std::vector<std::string>{}  // no additional message handlers needed
    );
  }
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_ON_LOAD_RESOURCE_JS_H_
