package com.pichillilorenzo.flutter_inappwebview.in_app_geckoview;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.Nullable;

import com.pichillilorenzo.flutter_inappwebview.InAppWebViewFlutterPlugin;
import com.pichillilorenzo.flutter_inappwebview.Util;

import org.mozilla.geckoview.GeckoResult;
import org.mozilla.geckoview.GeckoRuntime;
import org.mozilla.geckoview.WebExtension;

import java.util.HashMap;
import java.util.Map;

public class GeckoRuntimeManager {

  static final String LOG_TAG = "GeckoRuntimeManager";

  public static final Map<String, WebExtension> defaultWebExtensions = new HashMap<>();
  public static BackgroundMessageDelegate backgroundMessageDelegate;

  public static final String EVALUATE_JAVASCRIPT_WEB_EXT_ID = "evaluateJavascript@inappwebview.dev";
  public static final String BACKGROUND_WEB_EXT_ID = "background@inappwebview.dev";
  public static final String JAVASCRIPT_BRIDGE_WEB_EXT_ID = "javascriptBridge@inappwebview.dev";

  public static void create(Context applicationContext) {
    if (InAppWebViewFlutterPlugin.geckoRuntime == null && Util.isClass("org.mozilla.geckoview.GeckoView")) {
      InAppWebViewFlutterPlugin.geckoRuntime = GeckoRuntime.create(applicationContext);
      backgroundMessageDelegate = new BackgroundMessageDelegate();
      loadDefaultWebExtensions();
    }
  }

  private static void loadDefaultWebExtensions() {
    GeckoRuntime runtime = InAppWebViewFlutterPlugin.geckoRuntime;
    if (runtime != null) {
      InAppWebViewFlutterPlugin.geckoRuntime
              .getWebExtensionController()
              .ensureBuiltIn("resource://android/assets/flutter_assets/packages/flutter_inappwebview/assets/gecko_default_web_extensions/evaluateJavascript/", EVALUATE_JAVASCRIPT_WEB_EXT_ID)
              .accept(new GeckoResult.Consumer<WebExtension>() {
                @Override
                public void accept(@Nullable WebExtension webExtension) {
                  defaultWebExtensions.put(EVALUATE_JAVASCRIPT_WEB_EXT_ID, webExtension);
                }
              }, new GeckoResult.Consumer<Throwable>() {
                @Override
                public void accept(@Nullable Throwable throwable) {
                  Log.e(LOG_TAG, throwable.toString());
                }
              });

      InAppWebViewFlutterPlugin.geckoRuntime
              .getWebExtensionController()
              .ensureBuiltIn("resource://android/assets/flutter_assets/packages/flutter_inappwebview/assets/gecko_default_web_extensions/background/", BACKGROUND_WEB_EXT_ID)
              .accept(new GeckoResult.Consumer<WebExtension>() {
                @Override
                public void accept(@Nullable final WebExtension webExtension) {
                  final Handler handler = new Handler(Looper.getMainLooper());
                  handler.post(new Runnable() {
                    @Override
                    public void run() {
                      webExtension.setMessageDelegate(backgroundMessageDelegate, "background");
                    }
                  });
                  defaultWebExtensions.put(BACKGROUND_WEB_EXT_ID, webExtension);
                }
              }, new GeckoResult.Consumer<Throwable>() {
                @Override
                public void accept(@Nullable Throwable throwable) {
                  Log.e(LOG_TAG, throwable.toString());
                }
              });

      InAppWebViewFlutterPlugin.geckoRuntime
              .getWebExtensionController()
              .ensureBuiltIn("resource://android/assets/flutter_assets/packages/flutter_inappwebview/assets/gecko_default_web_extensions/javascriptBridge/", JAVASCRIPT_BRIDGE_WEB_EXT_ID)
              .accept(new GeckoResult.Consumer<WebExtension>() {
                @Override
                public void accept(@Nullable WebExtension webExtension) {
                  defaultWebExtensions.put(JAVASCRIPT_BRIDGE_WEB_EXT_ID, webExtension);
                }
              }, new GeckoResult.Consumer<Throwable>() {
                @Override
                public void accept(@Nullable Throwable throwable) {
                  Log.e(LOG_TAG, throwable.toString());
                }
              });
    }
  }
}
