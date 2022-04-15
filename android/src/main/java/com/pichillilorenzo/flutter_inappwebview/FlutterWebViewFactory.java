package com.pichillilorenzo.flutter_inappwebview;

import android.content.Context;
import android.view.View;

import com.pichillilorenzo.flutter_inappwebview.InAppWebViewFlutterPlugin;
import com.pichillilorenzo.flutter_inappwebview.in_app_geckoview.FlutterGeckoView;
import com.pichillilorenzo.flutter_inappwebview.in_app_webview.FlutterWebView;
import com.pichillilorenzo.flutter_inappwebview.types.PlatformWebView;
import com.pichillilorenzo.flutter_inappwebview.types.WebViewImplementation;

import java.util.HashMap;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class FlutterWebViewFactory extends PlatformViewFactory {
  private final InAppWebViewFlutterPlugin plugin;

  public FlutterWebViewFactory(final InAppWebViewFlutterPlugin plugin) {
    super(StandardMessageCodec.INSTANCE);
    this.plugin = plugin;
  }

  @Override
  public PlatformView create(Context context, int id, Object args) {
    HashMap<String, Object> params = (HashMap<String, Object>) args;
    
    PlatformWebView flutterWebView;
    WebViewImplementation implementation = WebViewImplementation.fromValue((Integer) params.get("implementation"));
    switch (implementation) {
      case GECKO:
        flutterWebView = new FlutterGeckoView(plugin, context, id, params);
        break;
      case NATIVE:
      default:
        flutterWebView = new FlutterWebView(plugin, context, id, params);
    }
    flutterWebView.makeInitialLoad(params);
    
    return flutterWebView;
  }
}

