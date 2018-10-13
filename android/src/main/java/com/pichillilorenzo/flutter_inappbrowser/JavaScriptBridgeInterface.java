package com.pichillilorenzo.flutter_inappbrowser;

import android.webkit.JavascriptInterface;

import java.util.HashMap;
import java.util.Map;

public class JavaScriptBridgeInterface {
  private static final String LOG_TAG = "JSBridgeInterface";
  static final String name = "flutter_inappbrowser";
  WebViewActivity activity;

  static final String flutterInAppBroserJSClass = "window." + name + ".callHandler = function(handlerName, ...args) {\n" +
    "window." + name + "._callHandler(handlerName, JSON.stringify(args));\n" +
  "}\n";

  JavaScriptBridgeInterface(WebViewActivity a) {
    activity = a;
  }

  @JavascriptInterface
  public void _callHandler(String handlerName, String args) {
    Map<String, Object> obj = new HashMap<>();
    obj.put("uuid", activity.uuid);
    obj.put("handlerName", handlerName);
    obj.put("args", args);
    InAppBrowserFlutterPlugin.channel.invokeMethod("onCallJsHandler", obj);
  }
}
