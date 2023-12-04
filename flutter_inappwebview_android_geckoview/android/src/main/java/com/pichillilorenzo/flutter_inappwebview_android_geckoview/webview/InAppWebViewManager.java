package com.pichillilorenzo.flutter_inappwebview_android_geckoview.webview;

import android.os.Message;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.pichillilorenzo.flutter_inappwebview_android_geckoview.InAppWebViewFlutterPlugin;
import com.pichillilorenzo.flutter_inappwebview_android_geckoview.types.ChannelDelegateImpl;
import com.pichillilorenzo.flutter_inappwebview_android_geckoview.webview.in_app_webview.FlutterWebView;

import org.mozilla.geckoview.GeckoRuntime;
import org.mozilla.geckoview.GeckoSession;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class InAppWebViewManager extends ChannelDelegateImpl {
  protected static final String LOG_TAG = "InAppWebViewManager";
  public static final String METHOD_CHANNEL_NAME = "com.pichillilorenzo/flutter_inappwebview_gecko_manager";
  
  @Nullable
  public InAppWebViewFlutterPlugin plugin;

  @Nullable
  public static GeckoRuntime geckoRuntime;

  public final Map<String, FlutterWebView> keepAliveWebViews = new HashMap<>();

  public final Map<Integer, Message> windowWebViewMessages = new HashMap<>();
  public int windowAutoincrementId = 0;

  public InAppWebViewManager(final InAppWebViewFlutterPlugin plugin) {
    super(new MethodChannel(plugin.messenger, METHOD_CHANNEL_NAME));
    this.plugin = plugin;
    if (geckoRuntime == null) {
      geckoRuntime = GeckoRuntime.create(plugin.applicationContext);
    }
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull final MethodChannel.Result result) {
    switch (call.method) {
      case "getDefaultUserAgent":
        if (plugin != null) {
          result.success(GeckoSession.getDefaultUserAgent());
        } else {
          result.success(null);
        }
        break;
      case "setWebContentsDebuggingEnabled":
        if (geckoRuntime != null) {
          boolean debuggingEnabled = (boolean) call.argument("debuggingEnabled");
          geckoRuntime.getSettings().setRemoteDebuggingEnabled(debuggingEnabled);
        }
        result.success(true);
        break;
      case "disposeKeepAlive":
        final String keepAliveId = (String) call.argument("keepAliveId");
        if (keepAliveId != null) {
          disposeKeepAlive(keepAliveId);
        }
        result.success(true);
        break;
      default:
        result.notImplemented();
    }
  }

  public void disposeKeepAlive(@NonNull String keepAliveId) {
    FlutterWebView flutterWebView = keepAliveWebViews.get(keepAliveId);
    if (flutterWebView != null) {
      flutterWebView.keepAliveId = null;
      // be sure to remove the view from the previous parent.
      View view = flutterWebView.getView();
      if (view != null) {
        ViewGroup parent = (ViewGroup) view.getParent();
        if (parent != null) {
          parent.removeView(view);
        }
      }
      flutterWebView.dispose();
    }
    if (keepAliveWebViews.containsKey(keepAliveId)) {
      keepAliveWebViews.put(keepAliveId, null);
    }
  }

  @Override
  public void dispose() {
    super.dispose();
    Collection<FlutterWebView> flutterWebViews = keepAliveWebViews.values();
    for (FlutterWebView flutterWebView : flutterWebViews) {
      String keepAliveId = flutterWebView.keepAliveId;
      if (keepAliveId != null) {
        disposeKeepAlive(flutterWebView.keepAliveId);
      }
    }
    keepAliveWebViews.clear();
    windowWebViewMessages.clear();
    plugin = null;
  }
}
