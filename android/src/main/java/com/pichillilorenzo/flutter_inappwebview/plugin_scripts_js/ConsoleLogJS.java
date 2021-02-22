package com.pichillilorenzo.flutter_inappwebview.plugin_scripts_js;

import com.pichillilorenzo.flutter_inappwebview.types.PluginScript;
import com.pichillilorenzo.flutter_inappwebview.types.UserScriptInjectionTime;

public class ConsoleLogJS {
  public static final String CONSOLE_LOG_JS_PLUGIN_SCRIPT_GROUP_NAME = "IN_APP_WEBVIEW_CONSOLE_LOG_JS_PLUGIN_SCRIPT";
  public static final PluginScript CONSOLE_LOG_JS_PLUGIN_SCRIPT = new PluginScript(
          ConsoleLogJS.CONSOLE_LOG_JS_PLUGIN_SCRIPT_GROUP_NAME,
          ConsoleLogJS.CONSOLE_LOG_JS_SOURCE,
          UserScriptInjectionTime.AT_DOCUMENT_START,
          null,
          true
  );

  public static final String CONSOLE_LOG_JS_SOURCE = "(function(console) {" +
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
          "               var message = '';" +
          "               for (var i in arguments) {" +
          "                   if (message == '') {" +
          "                       message += arguments[i];" +
          "                   }" +
          "                   else {" +
          "                       message += ' ' + arguments[i];" +
          "                   }" +
          "               }" +
          "               oldLogs[oldLog].call(console, message);" +
          "           }" +
          "       })(k);" +
          "   }" +
          "})(window.console);";
}
