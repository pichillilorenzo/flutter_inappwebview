package com.pichillilorenzo.flutter_inappwebview.plugin_scripts_js;

import com.pichillilorenzo.flutter_inappwebview.types.PluginScript;
import com.pichillilorenzo.flutter_inappwebview.types.UserScriptInjectionTime;

public class PrintJS {
  public static final String PRINT_JS_PLUGIN_SCRIPT_GROUP_NAME = "IN_APP_WEBVIEW_PRINT_JS_PLUGIN_SCRIPT";
  public static final PluginScript PRINT_JS_PLUGIN_SCRIPT = new PluginScript(
          PrintJS.PRINT_JS_PLUGIN_SCRIPT_GROUP_NAME,
          PrintJS.PRINT_JS_SOURCE,
          UserScriptInjectionTime.AT_DOCUMENT_START,
          null,
          false
  );

  public static final String PRINT_JS_SOURCE = "window.print = function() {" +
          "  if (window.top == null || window.top === window) {" +
          "     window." + JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_NAME + ".callHandler('onPrint', window.location.href);" +
          "  } else {" +
          "     window.top.print();" +
          "  }" +
          "};";
}
