package com.pichillilorenzo.flutter_inappbrowser.InAppWebView;

import android.os.Build;
import android.util.Log;
import android.webkit.WebSettings;

import com.pichillilorenzo.flutter_inappbrowser.Options;

import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import static android.webkit.WebSettings.LayoutAlgorithm.NORMAL;

public class InAppWebViewOptions extends Options {

  public static final String LOG_TAG = "InAppWebViewOptions";

  public Boolean useShouldOverrideUrlLoading = false;
  public Boolean useOnLoadResource = false;
  public Boolean useOnDownloadStart = false;
  public Boolean useOnTargetBlank = false;
  public Boolean clearCache = false;
  public String userAgent = "";
  public String applicationNameForUserAgent = "";
  public Boolean javaScriptEnabled = true;
  public Boolean debuggingEnabled = false;
  public Boolean javaScriptCanOpenWindowsAutomatically = false;
  public Boolean mediaPlaybackRequiresUserGesture = true;
  public Integer minimumFontSize = 8;
  public Boolean verticalScrollBarEnabled = true;
  public Boolean horizontalScrollBarEnabled = true;
  public List<String> resourceCustomSchemes = new ArrayList<>();
  public List<Map<String, Map<String, Object>>> contentBlockers = new ArrayList<>();
  public Integer preferredContentMode = PreferredContentModeOptionType.RECOMMENDED.toValue();
  public Boolean useShouldInterceptAjaxRequest = false;
  public Boolean useShouldInterceptFetchRequest = false;
  public Boolean incognito = false;
  public Boolean cacheEnabled = true;
  public Boolean transparentBackground = false;
  public Boolean disableVerticalScroll = false;
  public Boolean disableHorizontalScroll = false;

  public Integer textZoom = 100;
  public Boolean clearSessionCache = false;
  public Boolean builtInZoomControls = false;
  public Boolean displayZoomControls = false;
  public Boolean supportZoom = true;
  public Boolean databaseEnabled = false;
  public Boolean domStorageEnabled = false;
  public Boolean useWideViewPort = true;
  public Boolean safeBrowsingEnabled = true;
  public Integer mixedContentMode;
  public Boolean allowContentAccess = true;
  public Boolean allowFileAccess = true;
  public Boolean allowFileAccessFromFileURLs = true;
  public Boolean allowUniversalAccessFromFileURLs = true;
  public String appCachePath;
  public Boolean blockNetworkImage = false;
  public Boolean blockNetworkLoads = false;
  public Integer cacheMode = WebSettings.LOAD_DEFAULT;
  public String cursiveFontFamily = "cursive";
  public Integer defaultFixedFontSize = 16;
  public Integer defaultFontSize = 16;
  public String defaultTextEncodingName = "UTF-8";
  public Integer disabledActionModeMenuItems;
  public String fantasyFontFamily = "fantasy";
  public String fixedFontFamily = "monospace";
  public Integer forceDark = 0; // WebSettings.FORCE_DARK_OFF
  public Boolean geolocationEnabled = true;
  public WebSettings.LayoutAlgorithm layoutAlgorithm;
  public Boolean loadWithOverviewMode = true;
  public Boolean loadsImagesAutomatically = true;
  public Integer minimumLogicalFontSize = 8;
  public Integer initialScale = 0;
  public Boolean needInitialFocus = true;
  public Boolean offscreenPreRaster = false;
  public String sansSerifFontFamily = "sans-serif";
  public String serifFontFamily = "sans-serif";
  public String standardFontFamily = "sans-serif";
  public Boolean saveFormData = true;
  public Boolean thirdPartyCookiesEnabled = true;
  public Boolean hardwareAcceleration = true;

  @Override
  public Object onParse(Map.Entry<String, Object> pair) {
    if (pair.getKey().equals("layoutAlgorithm")) {
      String value = (String) pair.getValue();
      if (value != null) {
        switch (value) {
          case "NORMAL":
            pair.setValue(NORMAL);
            return pair;
          case "TEXT_AUTOSIZING":
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
              return pair.setValue(WebSettings.LayoutAlgorithm.TEXT_AUTOSIZING);
            } else {
              pair.setValue(NORMAL);
            }
            return pair;
        }
      }
    }
    return super.onParse(pair);
  }

  @Override
  public Object onGetHashMap(Field field) {
    if (field.getName().equals("layoutAlgorithm")) {
      try {
        WebSettings.LayoutAlgorithm value = (WebSettings.LayoutAlgorithm) field.get(this);
        if (value != null) {
          switch (value) {
            case NORMAL:
              return "NORMAL";
            default:
              if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT && value.equals(WebSettings.LayoutAlgorithm.TEXT_AUTOSIZING)) {
                return "TEXT_AUTOSIZING";
              }
              return "NORMAL";
          }
        }
      } catch (IllegalAccessException e) {
        Log.d(LOG_TAG, e.getMessage());
      }
    }
    return super.onGetHashMap(field);
  }
}
