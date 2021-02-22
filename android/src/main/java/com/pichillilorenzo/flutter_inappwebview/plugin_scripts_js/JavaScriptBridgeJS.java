package com.pichillilorenzo.flutter_inappwebview.plugin_scripts_js;

import com.pichillilorenzo.flutter_inappwebview.types.PluginScript;
import com.pichillilorenzo.flutter_inappwebview.types.UserScriptInjectionTime;

public class JavaScriptBridgeJS {
  public static final String JAVASCRIPT_BRIDGE_NAME = "flutter_inappwebview";
  public static final String JAVASCRIPT_BRIDGE_JS_PLUGIN_SCRIPT_GROUP_NAME = "IN_APP_WEBVIEW_JAVASCRIPT_BRIDGE_JS_PLUGIN_SCRIPT";
  public static final PluginScript JAVASCRIPT_BRIDGE_JS_PLUGIN_SCRIPT = new PluginScript(
          JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_JS_PLUGIN_SCRIPT_GROUP_NAME,
          JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_JS_SOURCE,
          UserScriptInjectionTime.AT_DOCUMENT_START,
          null,
          true
  );

  public static final String JAVASCRIPT_BRIDGE_JS_SOURCE = "if (window.top == null || window.top === window) {" +
          "  window." + JAVASCRIPT_BRIDGE_NAME + ".callHandler = function() {" +
          "    var _callHandlerID = setTimeout(function(){});" +
          "    window." + JAVASCRIPT_BRIDGE_NAME + "._callHandler(arguments[0], _callHandlerID, JSON.stringify(Array.prototype.slice.call(arguments, 1)));" +
          "    return new Promise(function(resolve, reject) {" +
          "      window." + JAVASCRIPT_BRIDGE_NAME + "[_callHandlerID] = resolve;" +
          "    });" +
          "  };"+
          "} else {" +
          "  window." + JAVASCRIPT_BRIDGE_NAME + " = {};" +
          "  window." + JAVASCRIPT_BRIDGE_NAME + ".callHandler = function() {" +
          "    var _callHandlerID = setTimeout(function(){});" +
          "    window.top." + JAVASCRIPT_BRIDGE_NAME + "._callHandler(arguments[0], _callHandlerID, JSON.stringify(Array.prototype.slice.call(arguments, 1)));" +
          "    return new Promise(function(resolve, reject) {" +
          "      window.top." + JAVASCRIPT_BRIDGE_NAME + "[_callHandlerID] = resolve;" +
          "    });" +
          "  };"+
          "}";

  public static final String PLATFORM_READY_JS_SOURCE = "(function() {" +
          "  if ((window.top == null || window.top === window) && window." + JAVASCRIPT_BRIDGE_NAME + "._platformReady == null) {" +
          "    window.dispatchEvent(new Event('flutterInAppWebViewPlatformReady'));" +
          "    window." + JAVASCRIPT_BRIDGE_NAME + "._platformReady = true;" +
          "  }" +
          "})();";
}
