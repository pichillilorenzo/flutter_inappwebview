package com.pichillilorenzo.flutter_inappwebview.chrome_custom_tabs;

import android.app.Activity;
import android.content.Intent;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.pichillilorenzo.flutter_inappwebview.headless_in_app_webview.HeadlessInAppWebView;
import com.pichillilorenzo.flutter_inappwebview.types.ChannelDelegateImpl;
import com.pichillilorenzo.flutter_inappwebview.types.Disposable;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class ChromeCustomTabsChannelDelegate extends ChannelDelegateImpl {
  @Nullable
  private ChromeCustomTabsActivity chromeCustomTabsActivity;

  public ChromeCustomTabsChannelDelegate(@NonNull ChromeCustomTabsActivity chromeCustomTabsActivity, @NonNull MethodChannel channel) {
    super(channel);
    this.chromeCustomTabsActivity = chromeCustomTabsActivity;
  }

  @Override
  public void onMethodCall(@NonNull final MethodCall call, @NonNull final MethodChannel.Result result) {
    switch (call.method) {
      case "close":
        if (chromeCustomTabsActivity != null) {
          chromeCustomTabsActivity.onStop();
          chromeCustomTabsActivity.onDestroy();
          chromeCustomTabsActivity.close();

          if (chromeCustomTabsActivity.manager != null && chromeCustomTabsActivity.manager.plugin != null && 
                  chromeCustomTabsActivity.manager.plugin.activity != null) {
            Activity activity = chromeCustomTabsActivity.manager.plugin.activity;
            // https://stackoverflow.com/a/41596629/4637638
            Intent myIntent = new Intent(activity, activity.getClass());
            myIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            myIntent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
            activity.startActivity(myIntent);
          }
          chromeCustomTabsActivity.dispose();
          result.success(true);
        } else {
          result.success(false);
        }
        break;
      default:
        result.notImplemented();
    }
  }

  public void onChromeSafariBrowserOpened() {
    MethodChannel channel = getChannel();
    if (channel == null) return;
    Map<String, Object> obj = new HashMap<>();
    channel.invokeMethod("onChromeSafariBrowserOpened", obj);
  }

  public void onChromeSafariBrowserCompletedInitialLoad() {
    MethodChannel channel = getChannel();
    if (channel == null) return;
    Map<String, Object> obj = new HashMap<>();
    channel.invokeMethod("onChromeSafariBrowserCompletedInitialLoad", obj);
  }

  public void onChromeSafariBrowserClosed() {
    MethodChannel channel = getChannel();
    if (channel == null) return;
    Map<String, Object> obj = new HashMap<>();
    channel.invokeMethod("onChromeSafariBrowserClosed", obj);
  }

  public void onChromeSafariBrowserItemActionPerform(int id, String url, String title) {
    MethodChannel channel = getChannel();
    if (channel == null) return;
    Map<String, Object> obj = new HashMap<>();
    obj.put("id", id);
    obj.put("url", url);
    obj.put("title", title);
    channel.invokeMethod("onChromeSafariBrowserItemActionPerform", obj);
  }

  @Override
  public void dispose() {
    super.dispose();
    chromeCustomTabsActivity = null; 
  }
}
