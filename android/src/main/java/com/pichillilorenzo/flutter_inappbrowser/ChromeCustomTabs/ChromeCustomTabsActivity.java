package com.pichillilorenzo.flutter_inappbrowser.ChromeCustomTabs;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import androidx.browser.customtabs.CustomTabsIntent;

import com.pichillilorenzo.flutter_inappbrowser.InAppBrowserFlutterPlugin;
import com.pichillilorenzo.flutter_inappbrowser.R;

import java.util.HashMap;
import java.util.Map;

public class ChromeCustomTabsActivity extends Activity {

  protected static final String LOG_TAG = "CustomTabsActivity";
  String uuid;
  CustomTabsIntent.Builder builder;
  ChromeCustomTabsOptions options;
  private CustomTabActivityHelper customTabActivityHelper;
  private final int CHROME_CUSTOM_TAB_REQUEST_CODE = 100;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    setContentView(R.layout.chrome_custom_tabs_layout);

    Bundle b = getIntent().getExtras();
    assert b != null;
    uuid = b.getString("uuid");
    String url = b.getString("url");

    options = new ChromeCustomTabsOptions();
    options.parse((HashMap<String, Object>) b.getSerializable("options"));

    InAppBrowserFlutterPlugin.inAppBrowser.chromeCustomTabsActivities.put(uuid, this);

    customTabActivityHelper = new CustomTabActivityHelper();
    builder = new CustomTabsIntent.Builder();

    prepareCustomTabs();

    CustomTabsIntent customTabsIntent = builder.build();

    CustomTabActivityHelper.openCustomTab(this, customTabsIntent, Uri.parse(url), CHROME_CUSTOM_TAB_REQUEST_CODE);

    Map<String, Object> obj = new HashMap<>();
    obj.put("uuid", uuid);
    InAppBrowserFlutterPlugin.inAppBrowser.channel.invokeMethod("onChromeSafariBrowserOpened", obj);
    InAppBrowserFlutterPlugin.inAppBrowser.channel.invokeMethod("onChromeSafariBrowserLoaded", obj);
  }

  private void prepareCustomTabs() {
    if (options.addShareButton)
      builder.addDefaultShareMenuItem();

    if (!options.toolbarBackgroundColor.isEmpty())
      builder.setToolbarColor(Color.parseColor(options.toolbarBackgroundColor));

    builder.setShowTitle(options.showTitle);

    if (options.enableUrlBarHiding)
      builder.enableUrlBarHiding();

    builder.setInstantAppsEnabled(options.instantAppsEnabled);
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
      finish();
      Map<String, Object> obj = new HashMap<>();
      obj.put("uuid", uuid);
      InAppBrowserFlutterPlugin.inAppBrowser.channel.invokeMethod("onChromeSafariBrowserClosed", obj);
    }
  }

}
