package com.pichillilorenzo.flutter_inappbrowser.chrome_custom_tabs;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.support.customtabs.CustomTabsIntent;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;

import com.pichillilorenzo.flutter_inappbrowser.InAppBrowserFlutterPlugin;
import com.pichillilorenzo.flutter_inappbrowser.InAppBrowserOptions;
import com.pichillilorenzo.flutter_inappbrowser.R;

import java.util.HashMap;

public class ChromeCustomTabsActivity extends Activity {

    CustomTabsIntent.Builder builder;
    InAppBrowserOptions options;
    private CustomTabActivityHelper customTabActivityHelper;
    private final int CHROME_CUSTOM_TAB_REQUEST_CODE = 100;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.chrome_custom_tabs_layout);

        Bundle b = getIntent().getExtras();
        String url = b.getString("url");

        options = new InAppBrowserOptions();
        options.parse((HashMap<String, Object>) b.getSerializable("options"));

        customTabActivityHelper = new CustomTabActivityHelper();

        builder = new CustomTabsIntent.Builder();

        prepareCustomTabs();

        CustomTabsIntent customTabsIntent = builder.build();

        customTabActivityHelper.openCustomTab(this, customTabsIntent, Uri.parse(url), CHROME_CUSTOM_TAB_REQUEST_CODE,
                new CustomTabActivityHelper.CustomTabFallback() {
                    @Override
                    public void openUri(Activity activity, Uri uri) {
                        InAppBrowserFlutterPlugin.open(uri.toString(), options);
                    }
                });
    }

    private void prepareCustomTabs() {
        if (options.CCT_addShareButton)
            builder.addDefaultShareMenuItem();

        if (!options.CCT_toolbarColor.isEmpty())
            builder.setToolbarColor(Color.parseColor(options.CCT_toolbarColor));

        builder.setShowTitle(options.CCT_showTitle);

        if (options.CCT_enableUrlBarHiding)
            builder.enableUrlBarHiding();

        builder.setInstantAppsEnabled(options.CCT_instantAppsEnabled);
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
        }
    }
}
