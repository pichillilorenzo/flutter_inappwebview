package com.pichillilorenzo.flutter_inappbrowser.InAppWebView;

import android.webkit.WebSettings;

import com.pichillilorenzo.flutter_inappbrowser.Options;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

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
  public Integer textZoom = 100;
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
  public Integer initialScale;
  public Boolean needInitialFocus = true;
  public Boolean offscreenPreRaster = false;
  public String sansSerifFontFamily = "sans-serif";
  public String serifFontFamily = "sans-serif";
  public String standardFontFamily = "sans-serif";
  public Boolean saveFormData = true;
  public Boolean thirdPartyCookiesEnabled = true;
  public Boolean hardwareAcceleration = true;
}
