package com.pichillilorenzo.flutter_inappwebview;

import android.webkit.WebSettings;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class InAppWebViewStatic implements MethodChannel.MethodCallHandler {
  public MethodChannel channel;

  protected static final String LOG_TAG = "InAppWebViewStatic";

  public InAppWebViewStatic(BinaryMessenger messenger) {
    channel = new MethodChannel(messenger, "com.pichillilorenzo/flutter_inappwebview_static");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    switch (call.method) {
      case "getDefaultUserAgent":
        result.success(WebSettings.getDefaultUserAgent(Shared.applicationContext));
        break;
      default:
        result.notImplemented();
    }
  }

  public void dispose() {
    channel.setMethodCallHandler(null);
  }
}
