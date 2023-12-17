package com.pichillilorenzo.flutter_inappwebview_android.plugin_scripts_js;

import com.pichillilorenzo.flutter_inappwebview_android.types.PluginScript;
import com.pichillilorenzo.flutter_inappwebview_android.types.UserScriptInjectionTime;

public class ConsoleLogJS {
  public static final String CONSOLE_LOG_JS_PLUGIN_SCRIPT_GROUP_NAME = "IN_APP_WEBVIEW_CONSOLE_LOG_JS_PLUGIN_SCRIPT";
  public static final PluginScript CONSOLE_LOG_JS_PLUGIN_SCRIPT = new PluginScript(
          ConsoleLogJS.CONSOLE_LOG_JS_PLUGIN_SCRIPT_GROUP_NAME,
          ConsoleLogJS.CONSOLE_LOG_JS_SOURCE,
          UserScriptInjectionTime.AT_DOCUMENT_START,
          null,
          true,
          null
  );

  public static final String CONSOLE_LOG_JS_SOURCE = "(function(console) {" +
          "   function _buildMessage(args) {" +
          "     var message = '';" +
          "     for (var i in args) {" +
          "       try {" +
          "         message += message === '' ? args[i] : ' ' + args[i];" +
          "       } catch(ignored) {}" +
          "     }" +
          "     return message;" +
          "   }" +
          "   var oldLogs = {" +
          "       'log': console.log," +
          "       'debug': console.debug," +
          "       'error': console.error," +
          "       'info': console.info," +
          "       'warn': console.warn" +
          "   };" +
          "   for (var k in oldLogs) {" +
          "       (function(oldLog) {" +
          "           console[oldLog] = function() {" +
          "               oldLogs[oldLog].call(console, _buildMessage(arguments));" +
          "           }" +
          "       })(k);" +
          "   }" +
          "})(window.console);";
}
