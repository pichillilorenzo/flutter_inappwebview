package com.pichillilorenzo.flutter_inappwebview;

import android.content.pm.PackageInfo;
import android.os.Build;
import android.webkit.ValueCallback;
import android.webkit.WebSettings;
import android.webkit.WebView;

import androidx.webkit.WebViewCompat;
import androidx.webkit.WebViewFeature;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class InAppWebViewStatic implements MethodChannel.MethodCallHandler {
  public MethodChannel channel;

  protected static final String LOG_TAG = "InAppWebViewStatic";

  public InAppWebViewStatic(BinaryMessenger messenger) {
    channel = new MethodChannel(messenger, "com.pichillilorenzo/flutter_inappwebview_static");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(MethodCall call, final MethodChannel.Result result) {
    switch (call.method) {
      case "getDefaultUserAgent":
        result.success(WebSettings.getDefaultUserAgent(Shared.applicationContext));
        break;
      case "clearClientCertPreferences":
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
          WebView.clearClientCertPreferences(new Runnable() {
            @Override
            public void run() {
              result.success(true);
            }
          });
        } else {
          result.success(false);
        }
        break;
      case "getSafeBrowsingPrivacyPolicyUrl":
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1 && WebViewFeature.isFeatureSupported(WebViewFeature.SAFE_BROWSING_PRIVACY_POLICY_URL)) {
          result.success(WebViewCompat.getSafeBrowsingPrivacyPolicyUrl().toString());
        } else
          result.success(null);
        break;
      case "setSafeBrowsingWhitelist":
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1 && WebViewFeature.isFeatureSupported(WebViewFeature.SAFE_BROWSING_WHITELIST)) {
          List<String> hosts = (List<String>) call.argument("hosts");
          WebViewCompat.setSafeBrowsingWhitelist(hosts, new ValueCallback<Boolean>() {
            @Override
            public void onReceiveValue(Boolean value) {
              result.success(value);
            }
          });
        }
        else
          result.success(false);
        break;
      case "getCurrentWebViewPackage":
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
          result.success(
                  convertWebViewPackageToMap(WebViewCompat.getCurrentWebViewPackage(Shared.activity)));
        } else {
          result.success(null);
        }
        break;
      default:
        result.notImplemented();
    }
  }

  public Map<String, Object> convertWebViewPackageToMap(PackageInfo webViewPackageInfo) {
    if (webViewPackageInfo == null) {
      return null;
    }
    HashMap<String, Object> webViewPackageInfoMap = new HashMap<>();

    webViewPackageInfoMap.put("versionName", webViewPackageInfo.versionName);
    webViewPackageInfoMap.put("packageName", webViewPackageInfo.packageName);

    return webViewPackageInfoMap;
  }

  public void dispose() {
    channel.setMethodCallHandler(null);
  }
}
