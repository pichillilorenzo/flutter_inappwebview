package com.pichillilorenzo.flutter_inappwebview.InAppWebView;

import android.content.Context;
import android.view.View;

import com.pichillilorenzo.flutter_inappwebview.InAppWebView.FlutterWebView;

import java.util.HashMap;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class FlutterWebViewFactory extends PlatformViewFactory {
  private final View containerView;
  private final BinaryMessenger messenger;

  public FlutterWebViewFactory(BinaryMessenger messenger, View containerView) {
    super(StandardMessageCodec.INSTANCE);
    this.containerView = containerView;
    this.messenger = messenger;
  }

  @Override
  public PlatformView create(Context context, int id, Object args) {
    HashMap<String, Object> params = (HashMap<String, Object>) args;
    return new FlutterWebView(messenger, context, id, params, containerView);
  }
}

