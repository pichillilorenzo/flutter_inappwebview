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

import com.pichillilorenzo.flutter_inappwebview.types.WebResourceRequestExt;
import com.pichillilorenzo.flutter_inappwebview.types.WebResourceResponseExt;

import java.io.ByteArrayInputStream;
import java.util.Map;

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
    channel = new MethodChannel(plugin.messenger, "com.pichillilorenzo/flutter_inappwebview_serviceworkercontroller");
    channel.setMethodCallHandler(this);
    if (WebViewFeature.isFeatureSupported(WebViewFeature.SERVICE_WORKER_BASIC_USAGE)) {
      serviceWorkerController = ServiceWorkerControllerCompat.getInstance();
    } else {
      serviceWorkerController = null;
    }
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
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
          WebResourceRequestExt requestExt = WebResourceRequestExt.fromWebResourceRequest(request);
          
          Util.WaitFlutterResult flutterResult;
          try {
            flutterResult = Util.invokeMethodAndWait(channel, "shouldInterceptRequest", requestExt.toMap());
          } catch (InterruptedException e) {
            e.printStackTrace();
            return null;
          }

          if (flutterResult.error != null) {
            Log.e(LOG_TAG, flutterResult.error);
          }
          else if (flutterResult.result != null) {
            WebResourceResponseExt response = WebResourceResponseExt.fromMap((Map<String, Object>) flutterResult.result);
            if (response != null) {
              String contentType = response.getContentType();
              String contentEncoding = response.getContentEncoding();
              byte[] data = response.getData();
              Map<String, String> responseHeaders = response.getHeaders();
              Integer statusCode = response.getStatusCode();
              String reasonPhrase = response.getReasonPhrase();

              ByteArrayInputStream inputStream = (data != null) ? new ByteArrayInputStream(data) : null;

              if (statusCode != null && reasonPhrase != null) {
                return new WebResourceResponse(contentType, contentEncoding, statusCode, reasonPhrase, responseHeaders, inputStream);
              } else {
                return new WebResourceResponse(contentType, contentEncoding, inputStream);
              }
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
