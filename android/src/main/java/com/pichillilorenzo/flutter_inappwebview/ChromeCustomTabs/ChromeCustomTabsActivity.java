package com.pichillilorenzo.flutter_inappwebview.ChromeCustomTabs;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;

import androidx.browser.customtabs.CustomTabsCallback;
import androidx.browser.customtabs.CustomTabsIntent;
import androidx.browser.customtabs.CustomTabsService;
import androidx.browser.customtabs.CustomTabsSession;

import com.pichillilorenzo.flutter_inappwebview.InAppWebViewFlutterPlugin;
import com.pichillilorenzo.flutter_inappwebview.R;

import java.util.HashMap;
import java.util.Map;

public class ChromeCustomTabsActivity extends Activity {

  protected static final String LOG_TAG = "CustomTabsActivity";
  String uuid;
  CustomTabsIntent.Builder builder;
  ChromeCustomTabsOptions options;
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
    final String url = b.getString("url");

    options = new ChromeCustomTabsOptions();
    options.parse((HashMap<String, Object>) b.getSerializable("options"));

    InAppWebViewFlutterPlugin.inAppBrowser.chromeCustomTabsActivities.put(uuid, this);

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
        InAppWebViewFlutterPlugin.inAppBrowser.channel.invokeMethod("onChromeSafariBrowserClosed", obj);
      }
    });

    customTabActivityHelper.setCustomTabsCallback(new CustomTabsCallback() {
      @Override
      public void onNavigationEvent(int navigationEvent, Bundle extras) {
        if (navigationEvent == TAB_SHOWN && !onChromeSafariBrowserOpened) {
          onChromeSafariBrowserOpened = true;
          Map<String, Object> obj = new HashMap<>();
          obj.put("uuid", uuid);
          InAppWebViewFlutterPlugin.inAppBrowser.channel.invokeMethod("onChromeSafariBrowserOpened", obj);
        }

        if (navigationEvent == NAVIGATION_FINISHED && !onChromeSafariBrowserCompletedInitialLoad) {
          onChromeSafariBrowserCompletedInitialLoad = true;
          Map<String, Object> obj = new HashMap<>();
          obj.put("uuid", uuid);
          InAppWebViewFlutterPlugin.inAppBrowser.channel.invokeMethod("onChromeSafariBrowserCompletedInitialLoad", obj);
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
      InAppWebViewFlutterPlugin.inAppBrowser.channel.invokeMethod("onChromeSafariBrowserClosed", obj);
    }
  }

}
