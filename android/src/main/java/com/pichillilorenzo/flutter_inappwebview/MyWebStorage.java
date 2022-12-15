package com.pichillilorenzo.flutter_inappwebview;

import android.webkit.ValueCallback;
import android.webkit.WebStorage;

import androidx.annotation.Nullable;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MyWebStorage implements MethodChannel.MethodCallHandler {

  static final String LOG_TAG = "MyWebStorage";

  public MethodChannel channel;
  public static WebStorage webStorageManager;
  @Nullable
  public InAppWebViewFlutterPlugin plugin;

  public MyWebStorage(final InAppWebViewFlutterPlugin plugin) {
    this.plugin = plugin;
    channel = new MethodChannel(plugin.messenger, "com.pichillilorenzo/flutter_inappwebview_webstoragemanager");
    channel.setMethodCallHandler(this);
  }

  public static void init() {
    if (webStorageManager == null) {
      webStorageManager = WebStorage.getInstance();
    }
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    init();

    switch (call.method) {
      case "getOrigins":
        getOrigins(result);
        break;
      case "deleteAllData":
        webStorageManager.deleteAllData();
        result.success(true);
        break;
      case "deleteOrigin":
        {
          String origin = (String) call.argument("origin");
          webStorageManager.deleteOrigin(origin);
        }
        result.success(true);
        break;
      case "getQuotaForOrigin":
        {
          String origin = (String) call.argument("origin");
          getQuotaForOrigin(origin, result);
        }
        break;
      case "getUsageForOrigin":
       {
          String origin = (String) call.argument("origin");
         getUsageForOrigin(origin, result);
       }
       break;
      default:
        result.notImplemented();
    }
  }

  public void getOrigins(final MethodChannel.Result result) {
    webStorageManager.getOrigins(new ValueCallback<Map>() {
      @Override
      public void onReceiveValue(Map value) {
        List<Map<String, Object>> origins = new ArrayList<>();
        for(Object key : value.keySet()) {
          WebStorage.Origin originObj = (WebStorage.Origin) value.get(key);

          Map<String, Object> originInfo = new HashMap<>();
          originInfo.put("origin", originObj.getOrigin());
          originInfo.put("quota", originObj.getQuota());
          originInfo.put("usage", originObj.getUsage());

          origins.add(originInfo);
        }
        result.success(origins);
      }
    });
  }

  public void getQuotaForOrigin(String origin, final MethodChannel.Result result) {
    webStorageManager.getQuotaForOrigin(origin, new ValueCallback<Long>() {
      @Override
      public void onReceiveValue(Long value) {
        result.success(value);
      }
    });
  }

  public void getUsageForOrigin(String origin, final MethodChannel.Result result) {
    webStorageManager.getUsageForOrigin(origin, new ValueCallback<Long>() {
      @Override
      public void onReceiveValue(Long value) {
        result.success(value);
      }
    });
  }

  public void dispose() {
    channel.setMethodCallHandler(null);
    plugin = null;
  }
}
