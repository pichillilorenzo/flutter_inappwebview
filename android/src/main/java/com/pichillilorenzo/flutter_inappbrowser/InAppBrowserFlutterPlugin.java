package com.pichillilorenzo.flutter_inappbrowser;

import android.net.Uri;
import android.os.Build;
import android.webkit.ValueCallback;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.embedding.engine.plugins.FlutterPlugin;

public class InAppBrowserFlutterPlugin implements FlutterPlugin {
  public PluginRegistry.Registrar registrar;
  public MethodChannel channel;

  protected static final String LOG_TAG = "InAppBrowserFlutterPlugin";

  public static InAppBrowser inAppBrowser;
  public static MyCookieManager myCookieManager;
  public static CredentialDatabaseHandler credentialDatabaseHandler;
  public static ValueCallback<Uri[]> uploadMessageArray;

  public InAppBrowserFlutterPlugin() {}

  public static void registerWith(PluginRegistry.Registrar registrar) {
    inAppBrowser = new InAppBrowser(registrar);

    registrar
            .platformViewRegistry()
            .registerViewFactory(
                    "com.pichillilorenzo/flutter_inappwebview", new FlutterWebViewFactory(registrar, registrar.view()));
    new MyCookieManager(registrar);
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      new CredentialDatabaseHandler(registrar);
    }
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    //BinaryMessenger messenger = binding.getFlutterEngine().getDartExecutor();
    inAppBrowser = new InAppBrowser(registrar);
    binding
            .getFlutterEngine()
            .getPlatformViewsController()
            .getRegistry()
            .registerViewFactory(
                    "com.pichillilorenzo/flutter_inappwebview", new FlutterWebViewFactory(registrar,null));
    myCookieManager = new MyCookieManager(registrar);
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      credentialDatabaseHandler = new CredentialDatabaseHandler(registrar);
    }
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    if (inAppBrowser != null) {
      inAppBrowser.dispose();
      inAppBrowser = null;
    }
    if (myCookieManager != null) {
      myCookieManager.dispose();
      myCookieManager = null;
    }
    if (credentialDatabaseHandler != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      credentialDatabaseHandler.dispose();
      credentialDatabaseHandler = null;
    }
    uploadMessageArray = null;
  }
}
