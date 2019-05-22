package com.pichillilorenzo.flutter_inappbrowser;

import android.content.Context;

import java.util.HashMap;

import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class FlutterWebViewFactory extends PlatformViewFactory {
  private final Registrar registrar;

  public FlutterWebViewFactory(Registrar registrar) {
    super(StandardMessageCodec.INSTANCE);
    this.registrar = registrar;
  }

  @Override
  public PlatformView create(Context context, int id, Object args) {
    HashMap<String, Object> params = (HashMap<String, Object>) args;
    return new FlutterWebView(registrar, id, params);
  }
}

