package com.pichillilorenzo.flutter_inappbrowser.chrome_custom_tabs;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.support.customtabs.CustomTabsIntent;
import android.util.Log;

import com.pichillilorenzo.flutter_inappbrowser.InAppBrowserFlutterPlugin;
import com.pichillilorenzo.flutter_inappbrowser.InAppBrowserOptions;
import com.pichillilorenzo.flutter_inappbrowser.R;

import java.util.HashMap;
import java.util.Map;

public class ChromeCustomTabsActivity extends Activity {

    protected static final String LOG_TAG = "CustomTabsActivity";
    String uuid;
    String uuidFallback;
    CustomTabsIntent.Builder builder;
    ChromeCustomTabsOptions options;
    Map<String, String> headersFallback;
    InAppBrowserOptions optionsFallback;
    private CustomTabActivityHelper customTabActivityHelper;
    private final int CHROME_CUSTOM_TAB_REQUEST_CODE = 100;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.chrome_custom_tabs_layout);

        Bundle b = getIntent().getExtras();
        uuid = b.getString("uuid");
        uuidFallback = b.getString("uuidFallback");
        String url = b.getString("url");

        options = new ChromeCustomTabsOptions();
        options.parse((HashMap<String, Object>) b.getSerializable("options"));

        headersFallback = (HashMap<String, String>) b.getSerializable("headers");

        optionsFallback = new InAppBrowserOptions();
        optionsFallback.parse((HashMap<String, Object>) b.getSerializable("optionsFallback"));

        InAppBrowserFlutterPlugin.chromeCustomTabsActivities.put(uuid, this);

        customTabActivityHelper = new CustomTabActivityHelper();
        builder = new CustomTabsIntent.Builder();

        prepareCustomTabs();

        CustomTabsIntent customTabsIntent = builder.build();

        boolean chromeCustomTabsOpened = customTabActivityHelper.openCustomTab(this, customTabsIntent, Uri.parse(url), CHROME_CUSTOM_TAB_REQUEST_CODE,
                new CustomTabActivityHelper.CustomTabFallback() {
                    @Override
                    public void openUri(Activity activity, Uri uri) {
                      if (!uuidFallback.isEmpty())
                          InAppBrowserFlutterPlugin.open(uuidFallback, null, uri.toString(), optionsFallback, headersFallback, false, null);
                      else {
                        Log.d(LOG_TAG, "No WebView fallback declared.");
                        activity.finish();
                      }
                    }
                });

        if (chromeCustomTabsOpened) {
            Map<String, Object> obj = new HashMap<>();
            obj.put("uuid", uuid);
            InAppBrowserFlutterPlugin.channel.invokeMethod("onChromeSafariBrowserOpened", obj);
            InAppBrowserFlutterPlugin.channel.invokeMethod("onChromeSafariBrowserLoaded", obj);
        }
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
            InAppBrowserFlutterPlugin.channel.invokeMethod("onChromeSafariBrowserClosed", obj);
        }
    }
}
