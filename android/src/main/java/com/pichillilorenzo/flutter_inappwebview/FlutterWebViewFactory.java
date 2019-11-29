package com.pichillilorenzo.flutter_inappwebview;

import android.content.Context;
import android.view.View;

import java.util.HashMap;

import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class FlutterWebViewFactory extends PlatformViewFactory {
  private final Registrar registrar;
  private final View containerView;

  public FlutterWebViewFactory(Registrar registrar, View containerView) {
    super(StandardMessageCodec.INSTANCE);
    this.registrar = registrar;
    this.containerView = containerView;
  }

  @Override
  public PlatformView create(Context context, int id, Object args) {
    HashMap<String, Object> params = (HashMap<String, Object>) args;
    return new FlutterWebView(registrar, context, id, params, containerView);
  }
}

