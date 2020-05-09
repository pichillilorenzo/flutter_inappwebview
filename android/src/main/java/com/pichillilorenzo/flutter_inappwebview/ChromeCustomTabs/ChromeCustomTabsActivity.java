package com.pichillilorenzo.flutter_inappwebview.ChromeCustomTabs;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;

import androidx.browser.customtabs.CustomTabsCallback;
import androidx.browser.customtabs.CustomTabsIntent;
import androidx.browser.customtabs.CustomTabsService;
import androidx.browser.customtabs.CustomTabsSession;

import com.pichillilorenzo.flutter_inappwebview.InAppWebViewFlutterPlugin;
import com.pichillilorenzo.flutter_inappwebview.R;
import com.pichillilorenzo.flutter_inappwebview.Shared;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class ChromeCustomTabsActivity extends Activity implements MethodChannel.MethodCallHandler {

  protected static final String LOG_TAG = "CustomTabsActivity";
  public MethodChannel channel;
  public String uuid;
  private CustomTabsIntent.Builder builder;
  private ChromeCustomTabsOptions options;
  private CustomTabActivityHelper customTabActivityHelper;
  private CustomTabsSession customTabsSession;
  private final int CHROME_CUSTOM_TAB_REQUEST_CODE = 100;
  private boolean onChromeSafariBrowserOpened = false;
  private boolean onChromeSafariBrowserCompletedInitialLoad = false;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    setContentView(R.layout.chrome_custom_tabs_layout);

    Bundle b = getIntent().getExtras();
    assert b != null;
    uuid = b.getString("uuid");

    channel = new MethodChannel(Shared.messenger, "com.pichillilorenzo/flutter_chromesafaribrowser_" + uuid);
    channel.setMethodCallHandler(this);

    final String url = b.getString("url");

    options = new ChromeCustomTabsOptions();
    options.parse((HashMap<String, Object>) b.getSerializable("options"));

    final ChromeCustomTabsActivity chromeCustomTabsActivity = this;

    customTabActivityHelper = new CustomTabActivityHelper();
    customTabActivityHelper.setConnectionCallback(new CustomTabActivityHelper.ConnectionCallback() {
      @Override
      public void onCustomTabsConnected() {
        customTabsSession = customTabActivityHelper.getSession();
        Uri uri = Uri.parse(url);
        customTabActivityHelper.mayLaunchUrl(uri, null, null);

        builder = new CustomTabsIntent.Builder(customTabsSession);
        CustomTabsIntent customTabsIntent = builder.build();
        prepareCustomTabs(customTabsIntent);
        CustomTabActivityHelper.openCustomTab(chromeCustomTabsActivity, customTabsIntent, uri, CHROME_CUSTOM_TAB_REQUEST_CODE);
      }

      @Override
      public void onCustomTabsDisconnected() {
        customTabsSession = null;
        finish();
        Map<String, Object> obj = new HashMap<>();
        obj.put("uuid", uuid);
        channel.invokeMethod("onChromeSafariBrowserClosed", obj);
      }
    });

    customTabActivityHelper.setCustomTabsCallback(new CustomTabsCallback() {
      @Override
      public void onNavigationEvent(int navigationEvent, Bundle extras) {
        if (navigationEvent == TAB_SHOWN && !onChromeSafariBrowserOpened) {
          onChromeSafariBrowserOpened = true;
          Map<String, Object> obj = new HashMap<>();
          obj.put("uuid", uuid);
          channel.invokeMethod("onChromeSafariBrowserOpened", obj);
        }

        if (navigationEvent == NAVIGATION_FINISHED && !onChromeSafariBrowserCompletedInitialLoad) {
          onChromeSafariBrowserCompletedInitialLoad = true;
          Map<String, Object> obj = new HashMap<>();
          obj.put("uuid", uuid);
          channel.invokeMethod("onChromeSafariBrowserCompletedInitialLoad", obj);
        }
      }

      @Override
      public void extraCallback(String callbackName, Bundle args) {

      }

      @Override
      public void onMessageChannelReady(Bundle extras) {

      }

      @Override
      public void onPostMessage(String message, Bundle extras) {

      }

      @Override
      public void onRelationshipValidationResult(@CustomTabsService.Relation int relation, Uri requestedOrigin,
                                                 boolean result, Bundle extras) {

      }
    });
  }

  @Override
  public void onMethodCall(final MethodCall call, final MethodChannel.Result result) {
    switch (call.method) {
      default:
        result.notImplemented();
    }
  }

  private void prepareCustomTabs(CustomTabsIntent customTabsIntent) {
    if (options.addDefaultShareMenuItem)
      builder.addDefaultShareMenuItem();

    if (!options.toolbarBackgroundColor.isEmpty())
      builder.setToolbarColor(Color.parseColor(options.toolbarBackgroundColor));

    builder.setShowTitle(options.showTitle);

    if (options.enableUrlBarHiding)
      builder.enableUrlBarHiding();

    builder.setInstantAppsEnabled(options.instantAppsEnabled);

    if (options.packageName != null)
      customTabsIntent.intent.setPackage(options.packageName);
    else
      customTabsIntent.intent.setPackage(CustomTabsHelper.getPackageNameToUse(this));

    if (options.keepAliveEnabled)
      CustomTabsHelper.addKeepAliveExtra(this, customTabsIntent.intent);
  }

  @Override
  protected void onStart() {
    super.onStart();
    customTabActivityHelper.bindCustomTabsService(this);
  }

  @Override
  protected void onStop() {
    super.onStop();
    customTabActivityHelper.unbindCustomTabsService(this);
  }

  @Override
  protected void onActivityResult(int requestCode, int resultCode, Intent data) {
    if (requestCode == CHROME_CUSTOM_TAB_REQUEST_CODE) {
      customTabsSession = null;
      finish();
      Map<String, Object> obj = new HashMap<>();
      obj.put("uuid", uuid);
      InAppWebViewFlutterPlugin.inAppBrowserManager.channel.invokeMethod("onChromeSafariBrowserClosed", obj);
    }
  }

}
