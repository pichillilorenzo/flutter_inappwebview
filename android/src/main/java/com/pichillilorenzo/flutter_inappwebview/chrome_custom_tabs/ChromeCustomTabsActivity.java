package com.pichillilorenzo.flutter_inappwebview.chrome_custom_tabs;

import android.app.Activity;
import android.app.PendingIntent;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.browser.customtabs.CustomTabColorSchemeParams;
import androidx.browser.customtabs.CustomTabsCallback;
import androidx.browser.customtabs.CustomTabsIntent;
import androidx.browser.customtabs.CustomTabsService;
import androidx.browser.customtabs.CustomTabsSession;

import com.pichillilorenzo.flutter_inappwebview.R;
import com.pichillilorenzo.flutter_inappwebview.types.CustomTabsActionButton;
import com.pichillilorenzo.flutter_inappwebview.types.CustomTabsMenuItem;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class ChromeCustomTabsActivity extends Activity implements MethodChannel.MethodCallHandler {

  protected static final String LOG_TAG = "CustomTabsActivity";
  public MethodChannel channel;
  public String id;
  public CustomTabsIntent.Builder builder;
  public ChromeCustomTabsOptions options;
  public CustomTabActivityHelper customTabActivityHelper = new CustomTabActivityHelper();
  @Nullable
  public CustomTabsSession customTabsSession;
  protected final int CHROME_CUSTOM_TAB_REQUEST_CODE = 100;
  protected boolean onChromeSafariBrowserOpened = false;
  protected boolean onChromeSafariBrowserCompletedInitialLoad = false;
  @Nullable
  public ChromeSafariBrowserManager manager;
  public String initialUrl;
  public List<CustomTabsMenuItem> menuItems = new ArrayList<>();
  @Nullable
  public CustomTabsActionButton actionButton;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    setContentView(R.layout.chrome_custom_tabs_layout);

    Bundle b = getIntent().getExtras();
    if (b == null) return;
    
    id = b.getString("id");

    String managerId = b.getString("managerId");
    manager = ChromeSafariBrowserManager.shared.get(managerId);
    if (manager == null || manager.plugin == null|| manager.plugin.messenger == null) return;

    channel = new MethodChannel(manager.plugin.messenger, "com.pichillilorenzo/flutter_chromesafaribrowser_" + id);
    channel.setMethodCallHandler(this);

    initialUrl = b.getString("url");

    options = new ChromeCustomTabsOptions();
    options.parse((Map<String, Object>) b.getSerializable("options"));
    actionButton = CustomTabsActionButton.fromMap((Map<String, Object>) b.getSerializable("actionButton"));
    List<Map<String, Object>> menuItemList = (List<Map<String, Object>>) b.getSerializable("menuItemList");
    for (Map<String, Object> menuItem : menuItemList) {
      menuItems.add(CustomTabsMenuItem.fromMap(menuItem));
    }
    
    final ChromeCustomTabsActivity chromeCustomTabsActivity = this;

    customTabActivityHelper.setConnectionCallback(new CustomTabActivityHelper.ConnectionCallback() {
      @Override
      public void onCustomTabsConnected() {
        customTabsConnected();
      }

      @Override
      public void onCustomTabsDisconnected() {
        chromeCustomTabsActivity.close();
        dispose();
      }
    });

    customTabActivityHelper.setCustomTabsCallback(new CustomTabsCallback() {
      @Override
      public void onNavigationEvent(int navigationEvent, Bundle extras) {
        if (navigationEvent == TAB_SHOWN && !onChromeSafariBrowserOpened) {
          onChromeSafariBrowserOpened = true;
          Map<String, Object> obj = new HashMap<>();
          channel.invokeMethod("onChromeSafariBrowserOpened", obj);
        }

        if (navigationEvent == NAVIGATION_FINISHED && !onChromeSafariBrowserCompletedInitialLoad) {
          onChromeSafariBrowserCompletedInitialLoad = true;
          Map<String, Object> obj = new HashMap<>();
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

        if (manager != null && manager.plugin != null && manager.plugin.activity != null) {
          // https://stackoverflow.com/a/41596629/4637638
          Intent myIntent = new Intent(manager.plugin.activity, manager.plugin.activity.getClass());
          myIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
          myIntent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
          manager.plugin.activity.startActivity(myIntent);
        }

        dispose();
        
        result.success(true);
        break;
      default:
        result.notImplemented();
    }
  }

  public void customTabsConnected() {
    customTabsSession = customTabActivityHelper.getSession();
    Uri uri = Uri.parse(initialUrl);
    customTabActivityHelper.mayLaunchUrl(uri, null, null);

    builder = new CustomTabsIntent.Builder(customTabsSession);
    prepareCustomTabs();

    CustomTabsIntent customTabsIntent = builder.build();
    prepareCustomTabsIntent(customTabsIntent);

    CustomTabActivityHelper.openCustomTab(this, customTabsIntent, uri, CHROME_CUSTOM_TAB_REQUEST_CODE);
  }

  private void prepareCustomTabs() {
    if (options.addDefaultShareMenuItem != null) {
      builder.setShareState(options.addDefaultShareMenuItem ?
              CustomTabsIntent.SHARE_STATE_ON : CustomTabsIntent.SHARE_STATE_OFF);
    } else {
      builder.setShareState(options.shareState);
    }

    if (options.toolbarBackgroundColor != null && !options.toolbarBackgroundColor.isEmpty()) {
      CustomTabColorSchemeParams.Builder defaultColorSchemeBuilder = new CustomTabColorSchemeParams.Builder();
      builder.setDefaultColorSchemeParams(defaultColorSchemeBuilder
              .setToolbarColor(Color.parseColor(options.toolbarBackgroundColor))
              .build());
    }

    builder.setShowTitle(options.showTitle);
    builder.setUrlBarHidingEnabled(options.enableUrlBarHiding);
    builder.setInstantAppsEnabled(options.instantAppsEnabled);

    for (CustomTabsMenuItem menuItem : menuItems) {
      PendingIntent pendingIntent = createPendingIntent(menuItem.getId());
      if (pendingIntent != null) {
        builder.addMenuItem(menuItem.getLabel(), pendingIntent);
      }
    }

    if (actionButton != null) {
      byte[] data = actionButton.getIcon();
      BitmapFactory.Options bitmapOptions = new BitmapFactory.Options();
      bitmapOptions.inMutable = true;
      Bitmap bmp = BitmapFactory.decodeByteArray(
              data, 0, data.length, bitmapOptions
      );
      PendingIntent pendingIntent = createPendingIntent(actionButton.getId());
      if (pendingIntent != null) {
        builder.setActionButton(bmp, actionButton.getDescription(),
                pendingIntent,
                actionButton.isShouldTint());
      }
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
      dispose();
    }
  }

  @Nullable
  private PendingIntent createPendingIntent(int actionSourceId) {
    if (manager == null) return null;
    Intent actionIntent = new Intent(this, ActionBroadcastReceiver.class);

    Bundle extras = new Bundle();
    extras.putInt(ActionBroadcastReceiver.KEY_ACTION_ID, actionSourceId);
    extras.putString(ActionBroadcastReceiver.KEY_ACTION_VIEW_ID, id);
    extras.putString(ActionBroadcastReceiver.CHROME_MANAGER_ID, manager.id);
    actionIntent.putExtras(extras);

    if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
      return PendingIntent.getBroadcast(
              this, actionSourceId, actionIntent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_MUTABLE);
    } else {
      return PendingIntent.getBroadcast(
              this, actionSourceId, actionIntent, PendingIntent.FLAG_UPDATE_CURRENT);
    }
  }

  public void dispose() {
    onStop();
    onDestroy();
    channel.setMethodCallHandler(null);
    manager = null;
  }

  public void close() {
    onStop();
    onDestroy();
    customTabsSession = null;
    finish();
    Map<String, Object> obj = new HashMap<>();
    channel.invokeMethod("onChromeSafariBrowserClosed", obj);
  }
}
