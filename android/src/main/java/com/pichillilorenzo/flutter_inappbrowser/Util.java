package com.pichillilorenzo.flutter_inappbrowser;

import android.content.res.AssetManager;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.CountDownLatch;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class Util {

  static final String LOG_TAG = "Util";
  public static final String ANDROID_ASSET_URL = "file:///android_asset/";

  public static String getUrlAsset(PluginRegistry.Registrar registrar, String assetFilePath) throws IOException {
    String key = registrar.lookupKeyForAsset(assetFilePath);
    AssetManager mg = registrar.activeContext().getResources().getAssets();
    InputStream is = null;
    IOException e = null;

    try {
      is = mg.open(key);
    } catch (IOException ex) {
      e = ex;
    } finally {
      if (is != null) {
        try {
          is.close();
        } catch (IOException ex) {
          e = ex;
        }
      }
    }
    if (e != null) {
      throw e;
    }

    return ANDROID_ASSET_URL + key;
  }

    public static WaitFlutterResult invokeMethodAndWait(final MethodChannel channel, final String method, final Object arguments) throws InterruptedException {
      final CountDownLatch latch = new CountDownLatch(1);

      final Map<String, Object> flutterResultMap = new HashMap<>();
      flutterResultMap.put("result", null);
      flutterResultMap.put("error", null);

      Handler handler = new Handler(Looper.getMainLooper());
      handler.post(new Runnable() {
        @Override
        public void run() {
          channel.invokeMethod(method, arguments, new MethodChannel.Result() {
            @Override
            public void success(Object result) {
              flutterResultMap.put("result", result);
              latch.countDown();
            }

            @Override
            public void error(String s, String s1, Object o) {
              flutterResultMap.put("error", "ERROR: " + s + " " + s1);
              flutterResultMap.put("result", o);
              latch.countDown();
            }

            @Override
            public void notImplemented() {
              latch.countDown();
            }
          });
        }
      });

      latch.await();

      return new WaitFlutterResult(flutterResultMap.get("result"), (String) flutterResultMap.get("error"));
    }

    public static class WaitFlutterResult {
      public Object result;
      public String error;

      public WaitFlutterResult(Object r, String e) {
        result = r;
        error = e;
      }

    }
}
