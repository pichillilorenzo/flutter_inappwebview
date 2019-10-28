package com.pichillilorenzo.flutter_inappbrowser.InAppWebView;

import android.webkit.WebSettings;

import com.pichillilorenzo.flutter_inappbrowser.Options;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class InAppWebViewOptions extends Options {

  static final String LOG_TAG = "InAppWebViewOptions";

  public boolean useShouldOverrideUrlLoading = false;
  public boolean useOnLoadResource = false;
  public boolean useOnDownloadStart = false;
  public boolean useOnTargetBlank = false;
  public boolean clearCache = false;
  public String userAgent = "";
  public boolean javaScriptEnabled = true;
  public boolean javaScriptCanOpenWindowsAutomatically = false;
  public boolean mediaPlaybackRequiresUserGesture = true;
  public Integer textZoom = 100;
  public boolean verticalScrollBarEnabled = true;
  public boolean horizontalScrollBarEnabled = true;
  public List<String> resourceCustomSchemes = new ArrayList<>();
  public List<Map<String, Map<String, Object>>> contentBlockers = new ArrayList<>();
  public Integer minimumFontSize = 8;

  public boolean clearSessionCache = false;
  public boolean builtInZoomControls = false;
  public boolean displayZoomControls = false;
  public boolean supportZoom = true;
  public boolean databaseEnabled = false;
  public boolean domStorageEnabled = false;
  public boolean useWideViewPort = true;
  public boolean safeBrowsingEnabled = true;
  public boolean transparentBackground = false;
  public Integer mixedContentMode;
  public boolean allowContentAccess = true;
  public boolean allowFileAccess = true;
  public boolean allowFileAccessFromFileURLs = true;
  public boolean allowUniversalAccessFromFileURLs = true;
  public boolean appCacheEnabled = true;
  public String appCachePath;
  public boolean blockNetworkImage = false;
  public boolean blockNetworkLoads = false;
  public Integer cacheMode = WebSettings.LOAD_DEFAULT;
  public String cursiveFontFamily = "cursive";
  public Integer defaultFixedFontSize = 16;
  public Integer defaultFontSize = 16;
  public String defaultTextEncodingName = "UTF-8";
  public Integer disabledActionModeMenuItems;
  public String fantasyFontFamily = "fantasy";
  public String fixedFontFamily = "monospace";
  public Integer forceDark = 0; // WebSettings.FORCE_DARK_OFF
  public boolean geolocationEnabled = true;
  public WebSettings.LayoutAlgorithm layoutAlgorithm;
  public boolean loadWithOverviewMode = true;
  public boolean loadsImagesAutomatically = true;
  public Integer minimumLogicalFontSize = 8;
  public boolean needInitialFocus = true;
  public boolean offscreenPreRaster = false;
  public String sansSerifFontFamily = "sans-serif";
  public String serifFontFamily = "sans-serif";
  public String standardFontFamily = "sans-serif";
}
