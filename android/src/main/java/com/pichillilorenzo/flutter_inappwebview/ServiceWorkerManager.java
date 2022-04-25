package com.pichillilorenzo.flutter_inappwebview;

import android.os.Build;
import android.util.Log;
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.webkit.ServiceWorkerClientCompat;
import androidx.webkit.ServiceWorkerControllerCompat;
import androidx.webkit.ServiceWorkerWebSettingsCompat;
import androidx.webkit.WebViewFeature;

import java.io.ByteArrayInputStream;
import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

@RequiresApi(api = Build.VERSION_CODES.N)
public class ServiceWorkerManager implements MethodChannel.MethodCallHandler {

  static final String LOG_TAG = "ServiceWorkerManager";

  public MethodChannel channel;
  @Nullable
  public static ServiceWorkerControllerCompat serviceWorkerController;
  @Nullable
  public InAppWebViewFlutterPlugin plugin;

  public ServiceWorkerManager(final InAppWebViewFlutterPlugin plugin) {
    this.plugin = plugin;
    channel = new MethodChannel(plugin.messenger, "com.pichillilorenzo/flutter_inappwebview_android_serviceworkercontroller");
    channel.setMethodCallHandler(this);
    if (WebViewFeature.isFeatureSupported(WebViewFeature.SERVICE_WORKER_BASIC_USAGE)) {
      serviceWorkerController = ServiceWorkerControllerCompat.getInstance();
    } else {
      serviceWorkerController = null;
    }
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    ServiceWorkerWebSettingsCompat serviceWorkerWebSettings = (serviceWorkerController != null) ? serviceWorkerController.getServiceWorkerWebSettings() : null;

    switch (call.method) {
      case "setServiceWorkerClient":
        {
          Boolean isNull = (Boolean) call.argument("isNull");
          setServiceWorkerClient(isNull);
        }
        result.success(true);
        break;
      case "getAllowContentAccess":
        if (serviceWorkerWebSettings != null && WebViewFeature.isFeatureSupported(WebViewFeature.SERVICE_WORKER_CONTENT_ACCESS)) {
          result.success(serviceWorkerWebSettings.getAllowContentAccess());
        } else {
          result.success(false);
        }
        break;
      case "getAllowFileAccess":
        if (serviceWorkerWebSettings != null && WebViewFeature.isFeatureSupported(WebViewFeature.SERVICE_WORKER_FILE_ACCESS)) {
          result.success(serviceWorkerWebSettings.getAllowFileAccess());
        } else {
          result.success(false);
        }
        break;
      case "getBlockNetworkLoads":
        if (serviceWorkerWebSettings != null && WebViewFeature.isFeatureSupported(WebViewFeature.SERVICE_WORKER_BLOCK_NETWORK_LOADS)) {
          result.success(serviceWorkerWebSettings.getBlockNetworkLoads());
        } else {
          result.success(false);
        }
        break;
      case "getCacheMode":
        if (serviceWorkerWebSettings != null && WebViewFeature.isFeatureSupported(WebViewFeature.SERVICE_WORKER_CACHE_MODE)) {
          result.success(serviceWorkerWebSettings.getCacheMode());
        } else {
          result.success(null);
        }
        break;
      case "setAllowContentAccess":
        if (serviceWorkerWebSettings != null && WebViewFeature.isFeatureSupported(WebViewFeature.SERVICE_WORKER_CONTENT_ACCESS)) {
          Boolean allow = (Boolean) call.argument("allow");
          serviceWorkerWebSettings.setAllowContentAccess(allow);
        }
        result.success(true);
        break;
      case "setAllowFileAccess":
        if (serviceWorkerWebSettings != null && WebViewFeature.isFeatureSupported(WebViewFeature.SERVICE_WORKER_FILE_ACCESS)) {
          Boolean allow = (Boolean) call.argument("allow");
          serviceWorkerWebSettings.setAllowFileAccess(allow);
        }
        result.success(true);
        break;
      case "setBlockNetworkLoads":
        if (serviceWorkerWebSettings != null && WebViewFeature.isFeatureSupported(WebViewFeature.SERVICE_WORKER_BLOCK_NETWORK_LOADS)) {
          Boolean flag = (Boolean) call.argument("flag");
          serviceWorkerWebSettings.setBlockNetworkLoads(flag);
        }
        result.success(true);
        break;
      case "setCacheMode":
        if (serviceWorkerWebSettings != null && WebViewFeature.isFeatureSupported(WebViewFeature.SERVICE_WORKER_CACHE_MODE)) {
          Integer mode = (Integer) call.argument("mode");
          serviceWorkerWebSettings.setCacheMode(mode);
        }
        result.success(true);
        break;
      default:
        result.notImplemented();
    }
  }
  
  private void setServiceWorkerClient(Boolean isNull) {
    if (serviceWorkerController != null) {
      // set ServiceWorkerClient as null makes the app crashes, so just set a dummy ServiceWorkerClientCompat.
      // https://github.com/pichillilorenzo/flutter_inappwebview/issues/1151
      serviceWorkerController.setServiceWorkerClient(isNull ? dummyServiceWorkerClientCompat() : new ServiceWorkerClientCompat() {
        @Nullable
        @Override
        public WebResourceResponse shouldInterceptRequest(@NonNull WebResourceRequest request) {
          final Map<String, Object> obj = new HashMap<>();
          obj.put("url", request.getUrl().toString());
          obj.put("method", request.getMethod());
          obj.put("headers", request.getRequestHeaders());
          obj.put("isForMainFrame", request.isForMainFrame());
          obj.put("hasGesture", request.hasGesture());
          obj.put("isRedirect", request.isRedirect());

          Util.WaitFlutterResult flutterResult;
          try {
            flutterResult = Util.invokeMethodAndWait(channel, "shouldInterceptRequest", obj);
          } catch (InterruptedException e) {
            e.printStackTrace();
            return null;
          }

          if (flutterResult.error != null) {
            Log.e(LOG_TAG, flutterResult.error);
          }
          else if (flutterResult.result != null) {
            Map<String, Object> res = (Map<String, Object>) flutterResult.result;
            String contentType = (String) res.get("contentType");
            String contentEncoding = (String) res.get("contentEncoding");
            byte[] data = (byte[]) res.get("data");
            Map<String, String> responseHeaders = (Map<String, String>) res.get("headers");
            Integer statusCode = (Integer) res.get("statusCode");
            String reasonPhrase = (String) res.get("reasonPhrase");

            ByteArrayInputStream inputStream = (data != null) ? new ByteArrayInputStream(data) : null;

            if ((responseHeaders == null && statusCode == null && reasonPhrase == null) || Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
              return new WebResourceResponse(contentType, contentEncoding, inputStream);
            } else {
              return new WebResourceResponse(contentType, contentEncoding, statusCode, reasonPhrase, responseHeaders, inputStream);
            }
          }

          return null;
        }
      }); 
    }
  }

  private ServiceWorkerClientCompat dummyServiceWorkerClientCompat() {
    return new ServiceWorkerClientCompat() {
      @Nullable
      @Override
      public WebResourceResponse shouldInterceptRequest(@NonNull WebResourceRequest request) {
        return null;
      }
    };
  }

  public void dispose() {
    channel.setMethodCallHandler(null);
    if (serviceWorkerController != null) {
      serviceWorkerController.setServiceWorkerClient(dummyServiceWorkerClientCompat());
      serviceWorkerController = null; 
    }
    plugin = null;
  }
}
