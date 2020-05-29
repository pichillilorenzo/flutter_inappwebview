package com.pichillilorenzo.flutter_inappwebview.ChromeCustomTabs;

import android.app.Activity;
import android.app.PendingIntent;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;

import androidx.browser.customtabs.CustomTabsCallback;
import androidx.browser.customtabs.CustomTabsIntent;
import androidx.browser.customtabs.CustomTabsService;
import androidx.browser.customtabs.CustomTabsSession;

import com.pichillilorenzo.flutter_inappwebview.R;
import com.pichillilorenzo.flutter_inappwebview.Shared;

import java.io.Serializable;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class ChromeCustomTabsActivity extends Activity implements MethodChannel.MethodCallHandler {

  protected static final String LOG_TAG = "CustomTabsActivity";
  public MethodChannel channel;
  public String uuid;
  public CustomTabsIntent.Builder builder;
  public ChromeCustomTabsOptions options;
  public CustomTabActivityHelper customTabActivityHelper;
  public CustomTabsSession customTabsSession;
  protected final int CHROME_CUSTOM_TAB_REQUEST_CODE = 100;
  protected boolean onChromeSafariBrowserOpened = false;
  protected boolean onChromeSafariBrowserCompletedInitialLoad = false;

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

    final List<HashMap<String, Object>> menuItemList = (List<HashMap<String, Object>>) b.getSerializable("menuItemList");

    final ChromeCustomTabsActivity chromeCustomTabsActivity = this;

    customTabActivityHelper = new CustomTabActivityHelper();
    customTabActivityHelper.setConnectionCallback(new CustomTabActivityHelper.ConnectionCallback() {
      @Override
      public void onCustomTabsConnected() {
        customTabsSession = customTabActivityHelper.getSession();
        Uri uri = Uri.parse(url);
        customTabActivityHelper.mayLaunchUrl(uri, null, null);

        builder = new CustomTabsIntent.Builder(customTabsSession);
        prepareCustomTabs(menuItemList);

        CustomTabsIntent customTabsIntent = builder.build();
        prepareCustomTabsIntent(customTabsIntent);

        CustomTabActivityHelper.openCustomTab(chromeCustomTabsActivity, customTabsIntent, uri, CHROME_CUSTOM_TAB_REQUEST_CODE);
      }

      @Override
      public void onCustomTabsDisconnected() {
        chromeCustomTabsActivity.close();
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
      case "close":
        this.onStop();
        this.onDestroy();
        this.close();

        // https://stackoverflow.com/a/41596629/4637638
        Intent myIntent = new Intent(Shared.activity, Shared.activity.getClass());
        myIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        myIntent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
        Shared.activity.startActivity(myIntent);
        result.success(true);
        break;
      default:
        result.notImplemented();
    }
  }

  private void prepareCustomTabs(List<HashMap<String, Object>> menuItemList) {
    if (options.addDefaultShareMenuItem)
      builder.addDefaultShareMenuItem();

    if (!options.toolbarBackgroundColor.isEmpty())
      builder.setToolbarColor(Color.parseColor(options.toolbarBackgroundColor));

    builder.setShowTitle(options.showTitle);

    if (options.enableUrlBarHiding)
      builder.enableUrlBarHiding();

    builder.setInstantAppsEnabled(options.instantAppsEnabled);

    for (HashMap<String, Object> menuItem : menuItemList) {
      int id = (int) menuItem.get("id");
      String label = (String) menuItem.get("label");
      builder.addMenuItem(label, createPendingIntent(id));
    }
  }

  private void prepareCustomTabsIntent(CustomTabsIntent customTabsIntent) {
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
      close();
    }
  }

  public void close() {
    customTabsSession = null;
    finish();
    Map<String, Object> obj = new HashMap<>();
    obj.put("uuid", uuid);
    channel.invokeMethod("onChromeSafariBrowserClosed", obj);
  }

  private PendingIntent createPendingIntent(int actionSourceId) {
    Intent actionIntent = new Intent(this, ActionBroadcastReceiver.class);

    Bundle extras = new Bundle();
    extras.putInt(ActionBroadcastReceiver.KEY_ACTION_ID, actionSourceId);
    extras.putString(ActionBroadcastReceiver.KEY_ACTION_UUID, uuid);
    actionIntent.putExtras(extras);

    return PendingIntent.getBroadcast(
            this, actionSourceId, actionIntent, 0);
  }
}
