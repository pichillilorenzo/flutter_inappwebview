package com.pichillilorenzo.flutter_inappwebview.chrome_custom_tabs;

import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;

import androidx.browser.customtabs.CustomTabColorSchemeParams;
import androidx.browser.trusted.TrustedWebActivityIntent;
import androidx.browser.trusted.TrustedWebActivityIntentBuilder;

import java.util.HashMap;
import java.util.List;

public class TrustedWebActivity extends ChromeCustomTabsActivity {

  protected static final String LOG_TAG = "TrustedWebActivity";

  public TrustedWebActivityIntentBuilder builder;

  @Override
  public void customTabsConnected() {
    customTabsSession = customTabActivityHelper.getSession();
    Uri uri = Uri.parse(initialUrl);
    customTabActivityHelper.mayLaunchUrl(uri, null, null);

    builder = new TrustedWebActivityIntentBuilder(uri);
    prepareCustomTabs();

    TrustedWebActivityIntent trustedWebActivityIntent = builder.build(customTabsSession);
    prepareCustomTabsIntent(trustedWebActivityIntent);

    CustomTabActivityHelper.openCustomTab(this, trustedWebActivityIntent, uri, CHROME_CUSTOM_TAB_REQUEST_CODE);
  }

  private void prepareCustomTabs() {
    if (options.toolbarBackgroundColor != null && !options.toolbarBackgroundColor.isEmpty()) {
      CustomTabColorSchemeParams.Builder defaultColorSchemeBuilder = new CustomTabColorSchemeParams.Builder();
      builder.setDefaultColorSchemeParams(defaultColorSchemeBuilder
              .setToolbarColor(Color.parseColor(options.toolbarBackgroundColor))
              .build());
    }

    if (options.additionalTrustedOrigins != null && !options.additionalTrustedOrigins.isEmpty()) {
      builder.setAdditionalTrustedOrigins(options.additionalTrustedOrigins);
    }

    if (options.displayMode != null) {
      builder.setDisplayMode(options.displayMode);
    }
    
    builder.setScreenOrientation(options.screenOrientation);
  }

  private void prepareCustomTabsIntent(TrustedWebActivityIntent trustedWebActivityIntent) {
    Intent intent = trustedWebActivityIntent.getIntent();
    if (options.packageName != null)
      intent.setPackage(options.packageName);
    else
      intent.setPackage(CustomTabsHelper.getPackageNameToUse(this));

    if (options.keepAliveEnabled)
      CustomTabsHelper.addKeepAliveExtra(this, intent);
  }
}
