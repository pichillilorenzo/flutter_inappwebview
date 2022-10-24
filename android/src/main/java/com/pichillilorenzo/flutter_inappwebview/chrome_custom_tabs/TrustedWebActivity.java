package com.pichillilorenzo.flutter_inappwebview.chrome_custom_tabs;

import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.browser.customtabs.CustomTabColorSchemeParams;
import androidx.browser.customtabs.CustomTabsIntent;
import androidx.browser.customtabs.CustomTabsService;
import androidx.browser.trusted.TrustedWebActivityIntent;
import androidx.browser.trusted.TrustedWebActivityIntentBuilder;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TrustedWebActivity extends ChromeCustomTabsActivity {

  protected static final String LOG_TAG = "TrustedWebActivity";

  public TrustedWebActivityIntentBuilder builder;

  @Override
  public void launchUrl(@NonNull String url,
                        @Nullable Map<String, String> headers,
                        @Nullable List<String> otherLikelyURLs) {
    if (customTabsSession == null) {
      return;
    }

    Uri uri = mayLaunchUrl(url, headers, otherLikelyURLs);
    builder = new TrustedWebActivityIntentBuilder(uri);
    prepareCustomTabs();

    TrustedWebActivityIntent trustedWebActivityIntent = builder.build(customTabsSession);
    prepareCustomTabsIntent(trustedWebActivityIntent);

    CustomTabActivityHelper.openCustomTab(this, trustedWebActivityIntent, uri, CHROME_CUSTOM_TAB_REQUEST_CODE);
  }

  @Override
  public void customTabsConnected() {
    customTabsSession = customTabActivityHelper.getSession();
    if (initialUrl != null) {
      launchUrl(initialUrl, initialHeaders, initialOtherLikelyURLs);
    }

  }

  private void prepareCustomTabs() {
    if (customSettings.toolbarBackgroundColor != null && !customSettings.toolbarBackgroundColor.isEmpty()) {
      CustomTabColorSchemeParams.Builder defaultColorSchemeBuilder = new CustomTabColorSchemeParams.Builder();
      builder.setDefaultColorSchemeParams(defaultColorSchemeBuilder
              .setToolbarColor(Color.parseColor(customSettings.toolbarBackgroundColor))
              .build());
    }

    if (customSettings.additionalTrustedOrigins != null && !customSettings.additionalTrustedOrigins.isEmpty()) {
      builder.setAdditionalTrustedOrigins(customSettings.additionalTrustedOrigins);
    }

    if (customSettings.displayMode != null) {
      builder.setDisplayMode(customSettings.displayMode);
    }
    
    builder.setScreenOrientation(customSettings.screenOrientation);
  }

  private void prepareCustomTabsIntent(TrustedWebActivityIntent trustedWebActivityIntent) {
    Intent intent = trustedWebActivityIntent.getIntent();
    if (customSettings.packageName != null)
      intent.setPackage(customSettings.packageName);
    else
      intent.setPackage(CustomTabsHelper.getPackageNameToUse(this));

    if (customSettings.keepAliveEnabled)
      CustomTabsHelper.addKeepAliveExtra(this, intent);
  }
}
