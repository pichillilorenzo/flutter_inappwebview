package com.pichillilorenzo.flutter_inappwebview.in_app_webview;

import android.os.Build;
import android.view.View;
import android.webkit.WebSettings;

import androidx.annotation.Nullable;

import com.pichillilorenzo.flutter_inappwebview.Options;
import com.pichillilorenzo.flutter_inappwebview.types.InAppWebViewInterface;
import com.pichillilorenzo.flutter_inappwebview.types.PreferredContentModeOptionType;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static android.webkit.WebSettings.LayoutAlgorithm.NARROW_COLUMNS;
import static android.webkit.WebSettings.LayoutAlgorithm.NORMAL;

public class InAppWebViewOptions implements Options<InAppWebViewInterface> {

  public static final String LOG_TAG = "InAppWebViewOptions";

  public Boolean useShouldOverrideUrlLoading = false;
  public Boolean useOnLoadResource = false;
  public Boolean useOnDownloadStart = false;
  public Boolean clearCache = false;
  public String userAgent = "";
  public String applicationNameForUserAgent = "";
  public Boolean javaScriptEnabled = true;
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
  public Boolean disableContextMenu = false;
  public Boolean supportZoom = true;
  public Boolean allowFileAccessFromFileURLs = false;
  public Boolean allowUniversalAccessFromFileURLs = false;

  public Integer textZoom = 100;
  public Boolean clearSessionCache = false;
  public Boolean builtInZoomControls = true;
  public Boolean displayZoomControls = false;
  public Boolean databaseEnabled = false;
  public Boolean domStorageEnabled = true;
  public Boolean useWideViewPort = true;
  public Boolean safeBrowsingEnabled = true;
  public Integer mixedContentMode;
  public Boolean allowContentAccess = true;
  public Boolean allowFileAccess = true;
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
  public Boolean supportMultipleWindows = false;
  public String regexToCancelSubFramesLoading;
  public Integer overScrollMode = View.OVER_SCROLL_IF_CONTENT_SCROLLS;
  public Boolean networkAvailable = null;
  public Integer scrollBarStyle = View.SCROLLBARS_INSIDE_OVERLAY;
  public Integer verticalScrollbarPosition = View.SCROLLBAR_POSITION_DEFAULT;
  public Integer scrollBarDefaultDelayBeforeFade = null;
  public Boolean scrollbarFadingEnabled = true;
  public Integer scrollBarFadeDuration = null;
  public Map<String, Object> rendererPriorityPolicy = new HashMap<>();
  public Boolean useShouldInterceptRequest = false;
  public Boolean useOnRenderProcessGone = false;
  public Boolean disableDefaultErrorPage = false;
  public Boolean useHybridComposition = false;
  @Nullable
  public String verticalScrollbarThumbColor;
  @Nullable
  public String verticalScrollbarTrackColor;
  @Nullable
  public String horizontalScrollbarThumbColor;
  @Nullable
  public String horizontalScrollbarTrackColor;

  @Override
  public InAppWebViewOptions parse(Map<String, Object> options) {
    for (Map.Entry<String, Object> pair : options.entrySet()) {
      String key = pair.getKey();
      Object value = pair.getValue();
      if (value == null) {
        continue;
      }

      switch (key) {
        case "useShouldOverrideUrlLoading":
          useShouldOverrideUrlLoading = (Boolean) value;
          break;
        case "useOnLoadResource":
          useOnLoadResource = (Boolean) value;
          break;
        case "useOnDownloadStart":
          useOnDownloadStart = (Boolean) value;
          break;
        case "clearCache":
          clearCache = (Boolean) value;
          break;
        case "userAgent":
          userAgent = (String) value;
          break;
        case "applicationNameForUserAgent":
          applicationNameForUserAgent = (String) value;
          break;
        case "javaScriptEnabled":
          javaScriptEnabled = (Boolean) value;
          break;
        case "javaScriptCanOpenWindowsAutomatically":
          javaScriptCanOpenWindowsAutomatically = (Boolean) value;
          break;
        case "mediaPlaybackRequiresUserGesture":
          mediaPlaybackRequiresUserGesture = (Boolean) value;
          break;
        case "minimumFontSize":
          minimumFontSize = (Integer) value;
          break;
        case "verticalScrollBarEnabled":
          verticalScrollBarEnabled = (Boolean) value;
          break;
        case "horizontalScrollBarEnabled":
          horizontalScrollBarEnabled = (Boolean) value;
          break;
        case "resourceCustomSchemes":
          resourceCustomSchemes = (List<String>) value;
          break;
        case "contentBlockers":
          contentBlockers = (List<Map<String, Map<String, Object>>>) value;
          break;
        case "preferredContentMode":
          preferredContentMode = (Integer) value;
          break;
        case "useShouldInterceptAjaxRequest":
          useShouldInterceptAjaxRequest = (Boolean) value;
          break;
        case "useShouldInterceptFetchRequest":
          useShouldInterceptFetchRequest = (Boolean) value;
          break;
        case "incognito":
          incognito = (Boolean) value;
          break;
        case "cacheEnabled":
          cacheEnabled = (Boolean) value;
          break;
        case "transparentBackground":
          transparentBackground = (Boolean) value;
          break;
        case "disableVerticalScroll":
          disableVerticalScroll = (Boolean) value;
          break;
        case "disableHorizontalScroll":
          disableHorizontalScroll = (Boolean) value;
          break;
        case "disableContextMenu":
          disableContextMenu = (Boolean) value;
          break;
        case "textZoom":
          textZoom = (Integer) value;
          break;
        case "clearSessionCache":
          clearSessionCache = (Boolean) value;
          break;
        case "builtInZoomControls":
          builtInZoomControls = (Boolean) value;
          break;
        case "displayZoomControls":
          displayZoomControls = (Boolean) value;
          break;
        case "supportZoom":
          supportZoom = (Boolean) value;
          break;
        case "databaseEnabled":
          databaseEnabled = (Boolean) value;
          break;
        case "domStorageEnabled":
          domStorageEnabled = (Boolean) value;
          break;
        case "useWideViewPort":
          useWideViewPort = (Boolean) value;
          break;
        case "safeBrowsingEnabled":
          safeBrowsingEnabled = (Boolean) value;
          break;
        case "mixedContentMode":
          mixedContentMode = (Integer) value;
          break;
        case "allowContentAccess":
          allowContentAccess = (Boolean) value;
          break;
        case "allowFileAccess":
          allowFileAccess = (Boolean) value;
          break;
        case "allowFileAccessFromFileURLs":
          allowFileAccessFromFileURLs = (Boolean) value;
          break;
        case "allowUniversalAccessFromFileURLs":
          allowUniversalAccessFromFileURLs = (Boolean) value;
          break;
        case "appCachePath":
          appCachePath = (String) value;
          break;
        case "blockNetworkImage":
          blockNetworkImage = (Boolean) value;
          break;
        case "blockNetworkLoads":
          blockNetworkLoads = (Boolean) value;
          break;
        case "cacheMode":
          cacheMode = (Integer) value;
          break;
        case "cursiveFontFamily":
          cursiveFontFamily = (String) value;
          break;
        case "defaultFixedFontSize":
          defaultFixedFontSize = (Integer) value;
          break;
        case "defaultFontSize":
          defaultFontSize = (Integer) value;
          break;
        case "defaultTextEncodingName":
          defaultTextEncodingName = (String) value;
          break;
        case "disabledActionModeMenuItems":
          disabledActionModeMenuItems = (Integer) value;
          break;
        case "fantasyFontFamily":
          fantasyFontFamily = (String) value;
          break;
        case "fixedFontFamily":
          fixedFontFamily = (String) value;
          break;
        case "forceDark":
          forceDark = (Integer) value;
          break;
        case "geolocationEnabled":
          geolocationEnabled = (Boolean) value;
          break;
        case "layoutAlgorithm":
          setLayoutAlgorithm((String) value);
          break;
        case "loadWithOverviewMode":
          loadWithOverviewMode = (Boolean) value;
          break;
        case "loadsImagesAutomatically":
          loadsImagesAutomatically = (Boolean) value;
          break;
        case "minimumLogicalFontSize":
          minimumLogicalFontSize = (Integer) value;
          break;
        case "initialScale":
          initialScale = (Integer) value;
          break;
        case "needInitialFocus":
          needInitialFocus = (Boolean) value;
          break;
        case "offscreenPreRaster":
          offscreenPreRaster = (Boolean) value;
          break;
        case "sansSerifFontFamily":
          sansSerifFontFamily = (String) value;
          break;
        case "serifFontFamily":
          serifFontFamily = (String) value;
          break;
        case "standardFontFamily":
          standardFontFamily = (String) value;
          break;
        case "saveFormData":
          saveFormData = (Boolean) value;
          break;
        case "thirdPartyCookiesEnabled":
          thirdPartyCookiesEnabled = (Boolean) value;
          break;
        case "hardwareAcceleration":
          hardwareAcceleration = (Boolean) value;
          break;
        case "supportMultipleWindows":
          supportMultipleWindows = (Boolean) value;
          break;
        case "regexToCancelSubFramesLoading":
          regexToCancelSubFramesLoading = (String) value;
          break;
        case "overScrollMode":
          overScrollMode = (Integer) value;
          break;
        case "networkAvailable":
          networkAvailable = (Boolean) value;
          break;
        case "scrollBarStyle":
          scrollBarStyle = (Integer) value;
          break;
        case "verticalScrollbarPosition":
          verticalScrollbarPosition = (Integer) value;
          break;
        case "scrollBarDefaultDelayBeforeFade":
          scrollBarDefaultDelayBeforeFade = (Integer) value;
          break;
        case "scrollbarFadingEnabled":
          scrollbarFadingEnabled = (Boolean) value;
          break;
        case "scrollBarFadeDuration":
          scrollBarFadeDuration = (Integer) value;
          break;
        case "rendererPriorityPolicy":
          rendererPriorityPolicy = (Map<String, Object>) value;
          break;
        case "useShouldInterceptRequest":
          useShouldInterceptRequest = (Boolean) value;
          break;
        case "useOnRenderProcessGone":
          useOnRenderProcessGone = (Boolean) value;
          break;
        case "disableDefaultErrorPage":
          disableDefaultErrorPage = (Boolean) value;
          break;
        case "useHybridComposition":
          useHybridComposition = (Boolean) value;
          break;
        case "verticalScrollbarThumbColor":
          verticalScrollbarThumbColor = (String) value;
          break;
        case "verticalScrollbarTrackColor":
          verticalScrollbarTrackColor = (String) value;
          break;
        case "horizontalScrollbarThumbColor":
          horizontalScrollbarThumbColor = (String) value;
          break;
        case "horizontalScrollbarTrackColor":
          horizontalScrollbarTrackColor = (String) value;
          break;
      }
    }

    return this;
  }

  @Override
  public Map<String, Object> toMap() {
    Map<String, Object> options = new HashMap<>();
    options.put("useShouldOverrideUrlLoading", useShouldOverrideUrlLoading);
    options.put("useOnLoadResource", useOnLoadResource);
    options.put("useOnDownloadStart", useOnDownloadStart);
    options.put("clearCache", clearCache);
    options.put("userAgent", userAgent);
    options.put("applicationNameForUserAgent", applicationNameForUserAgent);
    options.put("javaScriptEnabled", javaScriptEnabled);
    options.put("javaScriptCanOpenWindowsAutomatically", javaScriptCanOpenWindowsAutomatically);
    options.put("mediaPlaybackRequiresUserGesture", mediaPlaybackRequiresUserGesture);
    options.put("minimumFontSize", minimumFontSize);
    options.put("verticalScrollBarEnabled", verticalScrollBarEnabled);
    options.put("horizontalScrollBarEnabled", horizontalScrollBarEnabled);
    options.put("resourceCustomSchemes", resourceCustomSchemes);
    options.put("contentBlockers", contentBlockers);
    options.put("preferredContentMode", preferredContentMode);
    options.put("useShouldInterceptAjaxRequest", useShouldInterceptAjaxRequest);
    options.put("useShouldInterceptFetchRequest", useShouldInterceptFetchRequest);
    options.put("incognito", incognito);
    options.put("cacheEnabled", cacheEnabled);
    options.put("transparentBackground", transparentBackground);
    options.put("disableVerticalScroll", disableVerticalScroll);
    options.put("disableHorizontalScroll", disableHorizontalScroll);
    options.put("disableContextMenu", disableContextMenu);
    options.put("textZoom", textZoom);
    options.put("clearSessionCache", clearSessionCache);
    options.put("builtInZoomControls", builtInZoomControls);
    options.put("displayZoomControls", displayZoomControls);
    options.put("supportZoom", supportZoom);
    options.put("databaseEnabled", databaseEnabled);
    options.put("domStorageEnabled", domStorageEnabled);
    options.put("useWideViewPort", useWideViewPort);
    options.put("safeBrowsingEnabled", safeBrowsingEnabled);
    options.put("mixedContentMode", mixedContentMode);
    options.put("allowContentAccess", allowContentAccess);
    options.put("allowFileAccess", allowFileAccess);
    options.put("allowFileAccessFromFileURLs", allowFileAccessFromFileURLs);
    options.put("allowUniversalAccessFromFileURLs", allowUniversalAccessFromFileURLs);
    options.put("appCachePath", appCachePath);
    options.put("blockNetworkImage", blockNetworkImage);
    options.put("blockNetworkLoads", blockNetworkLoads);
    options.put("cacheMode", cacheMode);
    options.put("cursiveFontFamily", cursiveFontFamily);
    options.put("defaultFixedFontSize", defaultFixedFontSize);
    options.put("defaultFontSize", defaultFontSize);
    options.put("defaultTextEncodingName", defaultTextEncodingName);
    options.put("disabledActionModeMenuItems", disabledActionModeMenuItems);
    options.put("fantasyFontFamily", fantasyFontFamily);
    options.put("fixedFontFamily", fixedFontFamily);
    options.put("forceDark", forceDark);
    options.put("geolocationEnabled", geolocationEnabled);
    options.put("layoutAlgorithm", getLayoutAlgorithm());
    options.put("loadWithOverviewMode", loadWithOverviewMode);
    options.put("loadsImagesAutomatically", loadsImagesAutomatically);
    options.put("minimumLogicalFontSize", minimumLogicalFontSize);
    options.put("initialScale", initialScale);
    options.put("needInitialFocus", needInitialFocus);
    options.put("offscreenPreRaster", offscreenPreRaster);
    options.put("sansSerifFontFamily", sansSerifFontFamily);
    options.put("serifFontFamily", serifFontFamily);
    options.put("standardFontFamily", standardFontFamily);
    options.put("saveFormData", saveFormData);
    options.put("thirdPartyCookiesEnabled", thirdPartyCookiesEnabled);
    options.put("hardwareAcceleration", hardwareAcceleration);
    options.put("supportMultipleWindows", supportMultipleWindows);
    options.put("regexToCancelSubFramesLoading", regexToCancelSubFramesLoading);
    options.put("overScrollMode", overScrollMode);
    options.put("networkAvailable", networkAvailable);
    options.put("scrollBarStyle", scrollBarStyle);
    options.put("verticalScrollbarPosition", verticalScrollbarPosition);
    options.put("scrollBarDefaultDelayBeforeFade", scrollBarDefaultDelayBeforeFade);
    options.put("scrollbarFadingEnabled", scrollbarFadingEnabled);
    options.put("scrollBarFadeDuration", scrollBarFadeDuration);
    options.put("rendererPriorityPolicy", rendererPriorityPolicy);
    options.put("useShouldInterceptRequest", useShouldInterceptRequest);
    options.put("useOnRenderProcessGone", useOnRenderProcessGone);
    options.put("disableDefaultErrorPage", disableDefaultErrorPage);
    options.put("useHybridComposition", useHybridComposition);
    options.put("verticalScrollbarThumbColor", verticalScrollbarThumbColor);
    options.put("verticalScrollbarTrackColor", verticalScrollbarTrackColor);
    options.put("horizontalScrollbarThumbColor", horizontalScrollbarThumbColor);
    options.put("horizontalScrollbarTrackColor", horizontalScrollbarTrackColor);
    return options;
  }

  @Override
  public Map<String, Object> getRealOptions(InAppWebViewInterface inAppWebView) {
    Map<String, Object> realOptions = toMap();
    if (inAppWebView instanceof InAppWebView) {
      InAppWebView webView = (InAppWebView) inAppWebView;
      WebSettings settings = webView.getSettings();
      realOptions.put("userAgent", settings.getUserAgentString());
      realOptions.put("javaScriptEnabled", settings.getJavaScriptEnabled());
      realOptions.put("javaScriptCanOpenWindowsAutomatically", settings.getJavaScriptCanOpenWindowsAutomatically());
      realOptions.put("mediaPlaybackRequiresUserGesture", settings.getMediaPlaybackRequiresUserGesture());
      realOptions.put("minimumFontSize", settings.getMinimumFontSize());
      realOptions.put("verticalScrollBarEnabled", webView.isVerticalScrollBarEnabled());
      realOptions.put("horizontalScrollBarEnabled", webView.isHorizontalScrollBarEnabled());
      realOptions.put("textZoom", settings.getTextZoom());
      realOptions.put("builtInZoomControls", settings.getBuiltInZoomControls());
      realOptions.put("supportZoom", settings.supportZoom());
      realOptions.put("displayZoomControls", settings.getDisplayZoomControls());
      realOptions.put("databaseEnabled", settings.getDatabaseEnabled());
      realOptions.put("domStorageEnabled", settings.getDomStorageEnabled());
      realOptions.put("useWideViewPort", settings.getUseWideViewPort());
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        realOptions.put("safeBrowsingEnabled", settings.getSafeBrowsingEnabled());
      }
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
        realOptions.put("mixedContentMode", settings.getMixedContentMode());
      }
      realOptions.put("allowContentAccess", settings.getAllowContentAccess());
      realOptions.put("allowFileAccess", settings.getAllowFileAccess());
      realOptions.put("allowFileAccessFromFileURLs", settings.getAllowFileAccessFromFileURLs());
      realOptions.put("allowUniversalAccessFromFileURLs", settings.getAllowUniversalAccessFromFileURLs());
      realOptions.put("blockNetworkImage", settings.getBlockNetworkImage());
      realOptions.put("blockNetworkLoads", settings.getBlockNetworkLoads());
      realOptions.put("cacheMode", settings.getCacheMode());
      realOptions.put("cursiveFontFamily", settings.getCursiveFontFamily());
      realOptions.put("defaultFixedFontSize", settings.getDefaultFixedFontSize());
      realOptions.put("defaultFontSize", settings.getDefaultFontSize());
      realOptions.put("defaultTextEncodingName", settings.getDefaultTextEncodingName());
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
        realOptions.put("disabledActionModeMenuItems", settings.getDisabledActionModeMenuItems());
      }
      realOptions.put("fantasyFontFamily", settings.getFantasyFontFamily());
      realOptions.put("fixedFontFamily", settings.getFixedFontFamily());
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
        realOptions.put("forceDark", settings.getForceDark());
      }
      realOptions.put("layoutAlgorithm", settings.getLayoutAlgorithm().name());
      realOptions.put("loadWithOverviewMode", settings.getLoadWithOverviewMode());
      realOptions.put("loadsImagesAutomatically", settings.getLoadsImagesAutomatically());
      realOptions.put("minimumLogicalFontSize", settings.getMinimumLogicalFontSize());
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
        realOptions.put("offscreenPreRaster", settings.getOffscreenPreRaster());
      }
      realOptions.put("sansSerifFontFamily", settings.getSansSerifFontFamily());
      realOptions.put("serifFontFamily", settings.getSerifFontFamily());
      realOptions.put("standardFontFamily", settings.getStandardFontFamily());
      realOptions.put("saveFormData", settings.getSaveFormData());
      realOptions.put("supportMultipleWindows", settings.supportMultipleWindows());
      realOptions.put("overScrollMode", webView.getOverScrollMode());
      realOptions.put("scrollBarStyle", webView.getScrollBarStyle());
      realOptions.put("verticalScrollbarPosition", webView.getVerticalScrollbarPosition());
      realOptions.put("scrollBarDefaultDelayBeforeFade", webView.getScrollBarDefaultDelayBeforeFade());
      realOptions.put("scrollbarFadingEnabled", webView.isScrollbarFadingEnabled());
      realOptions.put("scrollBarFadeDuration", webView.getScrollBarFadeDuration());
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        Map<String, Object> rendererPriorityPolicy = new HashMap<>();
        rendererPriorityPolicy.put("rendererRequestedPriority", webView.getRendererRequestedPriority());
        rendererPriorityPolicy.put("waivedWhenNotVisible", webView.getRendererPriorityWaivedWhenNotVisible());
        realOptions.put("rendererPriorityPolicy", rendererPriorityPolicy);
      }
    }
    return realOptions;
  }

  private void setLayoutAlgorithm(String value) {
    if (value != null) {
      switch (value) {
        case "NARROW_COLUMNS":
          layoutAlgorithm = NARROW_COLUMNS;
        case "NORMAL":
          layoutAlgorithm = NORMAL;
        case "TEXT_AUTOSIZING":
          if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            layoutAlgorithm = WebSettings.LayoutAlgorithm.TEXT_AUTOSIZING;
          } else {
            layoutAlgorithm = NORMAL;
          }
          break;
      }
    }
  }

  private String getLayoutAlgorithm() {
    if (layoutAlgorithm != null) {
      switch (layoutAlgorithm) {
        case NORMAL:
          return "NORMAL";
        case TEXT_AUTOSIZING:
          if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            return "TEXT_AUTOSIZING";
          } else {
            return "NORMAL";
          }
        case NARROW_COLUMNS:
          return "NARROW_COLUMNS";
      }
    }
    return null;
  }
}
