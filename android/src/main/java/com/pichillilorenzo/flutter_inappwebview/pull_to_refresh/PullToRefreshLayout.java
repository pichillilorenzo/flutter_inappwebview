package com.pichillilorenzo.flutter_inappwebview.pull_to_refresh;

import android.content.Context;
import android.graphics.Color;
import android.util.AttributeSet;
import android.util.Log;
import android.view.DragEvent;
import android.view.MotionEvent;
import android.view.View;
import android.webkit.WebView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.pichillilorenzo.flutter_inappwebview.R;
import com.pichillilorenzo.flutter_inappwebview.in_app_webview.InAppWebView;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class PullToRefreshLayout extends SwipeRefreshLayout implements MethodChannel.MethodCallHandler {
  static final String LOG_TAG = "PullToRefreshLayout";
  
  public MethodChannel channel;
  public PullToRefreshOptions options;

  public PullToRefreshLayout(@NonNull Context context, @NonNull MethodChannel channel, @NonNull PullToRefreshOptions options) {
    super(context);
    this.channel = channel;
    this.options = options;
  }

  public PullToRefreshLayout(@NonNull Context context) {
    super(context);
    this.channel = null;
    this.options = null;
  }

  public PullToRefreshLayout(@NonNull Context context, @Nullable AttributeSet attrs) {
    super(context, attrs);
    this.channel = null;
    this.options = null;
  }

  public void prepare() {
    final PullToRefreshLayout self = this;

    if (channel != null) {
      this.channel.setMethodCallHandler(this);
    }

    setEnabled(options.enabled);
    setOnChildScrollUpCallback(new OnChildScrollUpCallback() {
      @Override
      public boolean canChildScrollUp(@NonNull SwipeRefreshLayout parent, @Nullable View child) {
        if (child instanceof InAppWebView) {
          InAppWebView inAppWebView = (InAppWebView) child;
          return (inAppWebView.canScrollVertically() && inAppWebView.getScrollY() > 0) ||
                 (!inAppWebView.canScrollVertically() && inAppWebView.getScrollY() == 0);
        }
        return true;
      }
    });
    setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
      @Override
      public void onRefresh() {
        if (channel == null) {
          self.setRefreshing(false);
          return;
        }
        Map<String, Object> obj = new HashMap<>();
        channel.invokeMethod("onRefresh", obj);
      }
    });
    if (options.color != null)
      setColorSchemeColors(Color.parseColor(options.color));
    if (options.backgroundColor != null)
      setProgressBackgroundColorSchemeColor(Color.parseColor(options.backgroundColor));
    if (options.distanceToTriggerSync != null)
      setDistanceToTriggerSync(options.distanceToTriggerSync);
    if (options.slingshotDistance != null)
      setSlingshotDistance(options.slingshotDistance);
    if (options.size != null)
      setSize(options.size);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull final MethodChannel.Result result) {
    switch (call.method) {
      case "setEnabled":
        {
          Boolean enabled = (Boolean) call.argument("enabled");
          options.enabled = enabled; // used by InAppWebView.onOverScrolled
          setEnabled(enabled);
        }
        result.success(true);
        break;
      case "setRefreshing":
        {
          Boolean refreshing = (Boolean) call.argument("refreshing");
          setRefreshing(refreshing);
        }
        result.success(true);
        break;
      case "isRefreshing":
        result.success(isRefreshing());
        break;
      case "setColor":
        {
          String color = (String) call.argument("color");
          setColorSchemeColors(Color.parseColor(color));
        }
        result.success(true);
        break;
      case "setBackgroundColor":
        {
          String color = (String) call.argument("color");
          setProgressBackgroundColorSchemeColor(Color.parseColor(color));
        }
        result.success(true);
        break;
      case "setDistanceToTriggerSync":
        {
          Integer distanceToTriggerSync = (Integer) call.argument("distanceToTriggerSync");
          setDistanceToTriggerSync(distanceToTriggerSync);
        }
        result.success(true);
        break;
      case "setSlingshotDistance":
        {
          Integer slingshotDistance = (Integer) call.argument("slingshotDistance");
          setSlingshotDistance(slingshotDistance);
        }
        result.success(true);
        break;
      case "getDefaultSlingshotDistance":
        result.success(SwipeRefreshLayout.DEFAULT_SLINGSHOT_DISTANCE);
        break;
      case "setSize":
        {
          Integer size = (Integer) call.argument("size");
          setSize(size);
        }
        result.success(true);
        break;
      default:
        result.notImplemented();
    }
  }

  public void dispose() {
    removeAllViews();
    if (channel != null) {
      channel.setMethodCallHandler(null);
    }
  }
}
