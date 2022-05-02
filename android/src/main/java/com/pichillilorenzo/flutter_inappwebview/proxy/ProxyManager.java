package com.pichillilorenzo.flutter_inappwebview.proxy;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.webkit.ProxyConfig;
import androidx.webkit.ProxyController;
import androidx.webkit.WebViewFeature;

import com.pichillilorenzo.flutter_inappwebview.InAppWebViewFlutterPlugin;
import com.pichillilorenzo.flutter_inappwebview.types.ProxyRuleExt;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.Executor;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class ProxyManager implements MethodChannel.MethodCallHandler {

  static final String LOG_TAG = "ProxyManager";

  public MethodChannel channel;
  @Nullable
  public static ProxyController proxyController;
  @Nullable
  public InAppWebViewFlutterPlugin plugin;

  public ProxyManager(final InAppWebViewFlutterPlugin plugin) {
    this.plugin = plugin;
    channel = new MethodChannel(plugin.messenger, "com.pichillilorenzo/flutter_inappwebview_proxycontroller");
    channel.setMethodCallHandler(this);
    if (WebViewFeature.isFeatureSupported(WebViewFeature.PROXY_OVERRIDE)) {
      proxyController = ProxyController.getInstance();
    } else {
      proxyController = null;
    }
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    switch (call.method) {
      case "setProxyOverride":
        if (proxyController != null) {
          HashMap<String, Object> settingsMap = (HashMap<String, Object>) call.argument("settings");
          ProxySettings settings = new ProxySettings();
          if (settingsMap != null) {
            settings.parse(settingsMap);
          }
          setProxyOverride(settings, result);
        } else {
          result.success(false);
        }
        break;
      case "clearProxyOverride":
        if (proxyController != null ) {
          clearProxyOverride(result);
        } else {
          result.success(false);
        }
        break;
      default:
        result.notImplemented();
    }
  }
  
  private void setProxyOverride(ProxySettings settings, final MethodChannel.Result result) {
    if (proxyController != null) {
      ProxyConfig.Builder proxyConfigBuilder = new ProxyConfig.Builder();
      for (String bypassRule : settings.bypassRules) {
        proxyConfigBuilder.addBypassRule(bypassRule);
      }
      for (String direct : settings.directs) {
        proxyConfigBuilder.addDirect(direct);
      }
      for (ProxyRuleExt proxyRule : settings.proxyRules) {
        if (proxyRule.getSchemeFilter() != null) {
          proxyConfigBuilder.addProxyRule(proxyRule.getUrl(), proxyRule.getSchemeFilter());
        } else {
          proxyConfigBuilder.addProxyRule(proxyRule.getUrl());
        }
      }
      if (settings.bypassSimpleHostnames != null && settings.bypassSimpleHostnames) {
        proxyConfigBuilder.bypassSimpleHostnames();
      }
      if (settings.removeImplicitRules != null && settings.removeImplicitRules) {
        proxyConfigBuilder.removeImplicitRules();
      }
      proxyController.setProxyOverride(proxyConfigBuilder.build(), new Executor() {
        @Override
        public void execute(Runnable command) {
          command.run();
        }
      }, new Runnable() {
        @Override
        public void run() {
          result.success(true);
        }
      });
    }
  }

  private void clearProxyOverride(final MethodChannel.Result result) {
    if (proxyController != null) {
      proxyController.clearProxyOverride(new Executor() {
        @Override
        public void execute(Runnable command) {
          command.run();
        }
      }, new Runnable() {
        @Override
        public void run() {
          result.success(true);
        }
      });
    }
  }

  public void dispose() {
    channel.setMethodCallHandler(null);
    if (proxyController != null) {
      // Clears the proxy settings
      proxyController.clearProxyOverride(new Executor() {
        @Override
        public void execute(Runnable command) {

        }
      }, new Runnable() {
        @Override
        public void run() {

        }
      });
      proxyController = null;
    }
    plugin = null;
  }
}
