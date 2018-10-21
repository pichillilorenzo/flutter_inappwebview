package com.pichillilorenzo.flutter_inappbrowser;

import android.app.Activity;
import android.content.Context;

import java.util.HashMap;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class FlutterWebViewFactory extends PlatformViewFactory {
  private final BinaryMessenger messenger;
  private final Registrar registrar;
  private final Activity activity;

  public FlutterWebViewFactory(Registrar registrar, Activity activity) {
    super(StandardMessageCodec.INSTANCE);
    this.registrar = registrar;
    this.messenger = registrar.messenger();
    this.activity = activity;
  }

  @Override
  public PlatformView create(Context context, int id, Object args) {
    HashMap<String, Object> params = (HashMap<String, Object>) args;
    return new FlutterWebView(registrar, id, params);
  }
}

