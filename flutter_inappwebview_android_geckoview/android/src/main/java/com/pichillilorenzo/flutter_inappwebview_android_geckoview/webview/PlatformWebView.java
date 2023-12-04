package com.pichillilorenzo.flutter_inappwebview_android_geckoview.webview;

import java.util.HashMap;

import io.flutter.plugin.platform.PlatformView;

public interface PlatformWebView extends PlatformView {
  void makeInitialLoad(HashMap<String, Object> params);
}
