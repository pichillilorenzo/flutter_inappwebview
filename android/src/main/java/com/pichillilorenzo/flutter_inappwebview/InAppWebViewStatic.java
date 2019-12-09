package com.pichillilorenzo.flutter_inappwebview;

import android.util.Log;
import android.webkit.WebSettings;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class InAppWebViewStatic implements MethodChannel.MethodCallHandler {
  public PluginRegistry.Registrar registrar;
  public MethodChannel channel;

  protected static final String LOG_TAG = "InAppWebViewStatic";

  public InAppWebViewStatic(PluginRegistry.Registrar r) {
    registrar = r;
    channel = new MethodChannel(registrar.messenger(), "com.pichillilorenzo/flutter_inappwebview_static");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    Log.d(LOG_TAG, call.method);
    switch (call.method) {
      case "getDefaultUserAgent":
        result.success(WebSettings.getDefaultUserAgent(registrar.activeContext()));
        break;
      default:
        result.notImplemented();
    }
  }

  public void dispose() {
    channel.setMethodCallHandler(null);
  }
}
