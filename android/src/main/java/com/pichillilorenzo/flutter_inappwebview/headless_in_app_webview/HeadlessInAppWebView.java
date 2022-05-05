package com.pichillilorenzo.flutter_inappwebview.headless_in_app_webview;

import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.pichillilorenzo.flutter_inappwebview.InAppWebViewFlutterPlugin;
import com.pichillilorenzo.flutter_inappwebview.Util;
import com.pichillilorenzo.flutter_inappwebview.in_app_webview.FlutterWebView;
import com.pichillilorenzo.flutter_inappwebview.types.Size2D;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class HeadlessInAppWebView implements MethodChannel.MethodCallHandler {

  protected static final String LOG_TAG = "HeadlessInAppWebView";
  @NonNull
  public final String id;
  public final MethodChannel channel;
  @Nullable
  public FlutterWebView flutterWebView;
  @Nullable
  public InAppWebViewFlutterPlugin plugin;

  public HeadlessInAppWebView(@NonNull final InAppWebViewFlutterPlugin plugin, @NonNull String id, @NonNull FlutterWebView flutterWebView) {
    this.id = id;
    this.plugin = plugin;
    this.flutterWebView = flutterWebView;
    this.channel = new MethodChannel(plugin.messenger, "com.pichillilorenzo/flutter_headless_inappwebview_" + id);
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    switch (call.method) {
      case "dispose":
        dispose();
        result.success(true);
        break;
      case "setSize":
        {
          Map<String, Object> sizeMap = (Map<String, Object>) call.argument("size");
          Size2D size = Size2D.fromMap(sizeMap);
          if (size != null)
            setSize(size);
        }
        result.success(true);
        break;
      case "getSize":
        {
          Size2D size = getSize();
          result.success(size != null ? size.toMap() : null);
        }
        break;
      default:
        result.notImplemented();
    }
  }

  public void onWebViewCreated() {
    Map<String, Object> obj = new HashMap<>();
    channel.invokeMethod("onWebViewCreated", obj);
  }

  public void prepare(Map<String, Object> params) {
    if (plugin != null && plugin.activity != null) {
      // Add the headless WebView to the view hierarchy.
      // This way is also possible to take screenshots.
      ViewGroup contentView = (ViewGroup) plugin.activity.findViewById(android.R.id.content);
      if (contentView != null) {
        ViewGroup mainView = (ViewGroup) (contentView).getChildAt(0);
        if (mainView != null && flutterWebView != null) {
          View view = flutterWebView.getView();
          final Map<String, Object> initialSize = (Map<String, Object>) params.get("initialSize");
          Size2D size = Size2D.fromMap(initialSize);
          if (size != null) {
            setSize(size);
          } else {
            view.setLayoutParams(new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
          }
          mainView.addView(view, 0);
          view.setVisibility(View.INVISIBLE);
        }
      }
    }
  }
  
  public void setSize(@NonNull Size2D size) {
    if (flutterWebView != null && flutterWebView.webView != null) {
      View view = flutterWebView.getView();
      float scale = Util.getPixelDensity(view.getContext());
      view.setLayoutParams(new FrameLayout.LayoutParams((int) (size.getWidth() * scale), (int) (size.getHeight() * scale)));
    }
  }

  @Nullable
  public Size2D getSize() {
    if (flutterWebView != null && flutterWebView.webView != null) {
      View view = flutterWebView.getView();
      float scale = Util.getPixelDensity(view.getContext());
      ViewGroup.LayoutParams layoutParams = view.getLayoutParams();
      return new Size2D(layoutParams.width / scale, layoutParams.height / scale);
    }
    return null;
  }

  public void dispose() {
    channel.setMethodCallHandler(null);
    if (HeadlessInAppWebViewManager.webViews.containsKey(id)) {
      HeadlessInAppWebViewManager.webViews.put(id, null);
    }
    if (plugin != null && plugin.activity != null) {
      ViewGroup contentView = (ViewGroup) plugin.activity.findViewById(android.R.id.content);
      if (contentView != null) {
        ViewGroup mainView = (ViewGroup) (contentView).getChildAt(0);
        if (mainView != null && flutterWebView != null) {
          mainView.removeView(flutterWebView.getView());
        }
      }
    }
    if (flutterWebView != null) {
      flutterWebView.dispose();
    }
    flutterWebView = null;
    plugin = null;
  }
}
