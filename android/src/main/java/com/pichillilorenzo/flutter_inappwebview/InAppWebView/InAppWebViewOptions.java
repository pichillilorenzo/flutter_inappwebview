package com.pichillilorenzo.flutter_inappwebview.InAppWebView;

import android.os.Build;
import android.util.Log;
import android.webkit.WebSettings;

import com.pichillilorenzo.flutter_inappwebview.Options;

import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import static android.webkit.WebSettings.LayoutAlgorithm.NORMAL;

public class InAppWebViewOptions implements Options {

    public static final String LOG_TAG = "InAppWebViewOptions";

    public Boolean useShouldOverrideUrlLoading = false;
    public Boolean useOnLoadResource = false;
    public Boolean useOnDownloadStart = false;
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
    public Boolean domStorageEnabled = true;
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
    public Boolean supportMultipleWindows = false;
    public String regexToCancelSubFramesLoading;

    public InAppWebViewOptions parse(HashMap<String, Object> options) {
        Iterator it = options.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry<String, Object> pair = (Map.Entry<String, Object>) it.next();
            String key = pair.getKey();
            Object value = pair.getValue();
            if (value == null) {
                continue;
            }

            switch (key) {
                case "useShouldOverrideUrlLoading":
                    useShouldOverrideUrlLoading = (boolean) value;
                    break;
                case "useOnDownloadStart":
                    useOnDownloadStart = (boolean) value;
                    break;
                case "useOnLoadResource":
                    useOnLoadResource = (boolean) value;
                    break;
                case "clearCache":
                    clearCache = (boolean) value;
                    break;
                case "userAgent":
                    userAgent = (String) value;
                    break;
                case "applicationNameForUserAgent":
                    applicationNameForUserAgent = (String) value;
                    break;
                case "javaScriptEnabled":
                    javaScriptEnabled = (boolean) value;
                    break;
                case "debuggingEnabled":
                    debuggingEnabled = (boolean) value;
                    break;
                case "javaScriptCanOpenWindowsAutomatically":
                    javaScriptCanOpenWindowsAutomatically = (boolean) value;
                    break;
                case "mediaPlaybackRequiresUserGesture":
                    mediaPlaybackRequiresUserGesture = (boolean) value;
                    break;
                case "minimumFontSize":
                    minimumFontSize = (int) value;
                    break;
                case "verticalScrollBarEnabled":
                    verticalScrollBarEnabled = (boolean) value;
                    break;
                case "horizontalScrollBarEnabled":
                    horizontalScrollBarEnabled = (boolean) value;
                    break;
                case "resourceCustomSchemes":
                    resourceCustomSchemes = (List<String>) value;
                    break;
                case "contentBlockers":
                    contentBlockers = (List<Map<String, Map<String, Object>>>) value;
                    break;
                case "preferredContentMode":
                    preferredContentMode = (int) value;
                    break;
                case "useShouldInterceptAjaxRequest":
                    useShouldInterceptAjaxRequest = (boolean) value;
                    break;
                case "useShouldInterceptFetchRequest":
                    useShouldInterceptFetchRequest = (boolean) value;
                    break;
                case "incognito":
                    incognito = (boolean) value;
                    break;
                case "cacheEnabled":
                    cacheEnabled = (boolean) value;
                    break;
                case "transparentBackground":
                    transparentBackground = (boolean) value;
                    break;
                case "disableVerticalScroll":
                    disableVerticalScroll = (boolean) value;
                    break;
                case "disableHorizontalScroll":
                    disableHorizontalScroll = (boolean) value;
                    break;
                case "textZoom":
                    textZoom = (int) value;
                    break;
                case "clearSessionCache":
                    clearSessionCache = (boolean) value;
                    break;
                case "builtInZoomControls":
                    builtInZoomControls = (boolean) value;
                    break;
                case "displayZoomControls":
                    displayZoomControls = (boolean) value;
                    break;
                case "supportZoom":
                    supportZoom = (boolean) value;
                    break;
                case "databaseEnabled":
                    databaseEnabled = (boolean) value;
                    break;
                case "domStorageEnabled":
                    domStorageEnabled = (boolean) value;
                    break;
                case "useWideViewPort":
                    useWideViewPort = (boolean) value;
                    break;
                case "safeBrowsingEnabled":
                    safeBrowsingEnabled = (boolean) value;
                    break;
                case "mixedContentMode":
                    mixedContentMode = (int) value;
                    break;
                case "allowContentAccess":
                    allowContentAccess = (boolean) value;
                    break;
                case "allowFileAccess":
                    allowFileAccess = (boolean) value;
                    break;
                case "allowFileAccessFromFileURLs":
                    allowFileAccessFromFileURLs = (boolean) value;
                    break;
                case "allowUniversalAccessFromFileURLs":
                    allowUniversalAccessFromFileURLs = (boolean) value;
                    break;
                case "appCachePath":
                    appCachePath = (String) value;
                    break;
                case "blockNetworkImage":
                    blockNetworkImage = (boolean) value;
                    break;
                case "blockNetworkLoads":
                    blockNetworkLoads = (boolean) value;
                    break;
                case "cacheMode":
                    cacheMode = (int) value;
                    break;
                case "cursiveFontFamily":
                    cursiveFontFamily = (String) value;
                    break;
                case "defaultFixedFontSize":
                    defaultFixedFontSize = (int) value;
                    break;
                case "defaultFontSize":
                    defaultFontSize = (int) value;
                    break;
                case "defaultTextEncodingName":
                    defaultTextEncodingName = (String) value;
                    break;
                case "disabledActionModeMenuItems":
                    disabledActionModeMenuItems = (int) value;
                    break;
                case "fantasyFontFamily":
                    fantasyFontFamily = (String) value;
                    break;
                case "fixedFontFamily":
                    fixedFontFamily = (String) value;
                    break;
                case "forceDark":
                    forceDark = (int) value;
                    break;
                case "geolocationEnabled":
                    geolocationEnabled = (boolean) value;
                    break;
                case "layoutAlgorithm":
                    setLayoutAlgorithm(pair);
                    break;
                case "loadWithOverviewMode":
                    loadWithOverviewMode = (boolean) value;
                    break;
                case "loadsImagesAutomatically":
                    loadsImagesAutomatically = (boolean) value;
                    break;
                case "minimumLogicalFontSize":
                    minimumLogicalFontSize = (int) value;
                    break;
                case "initialScale":
                    initialScale = (int) value;
                    break;
                case "needInitialFocus":
                    needInitialFocus = (boolean) value;
                    break;
                case "offscreenPreRaster":
                    offscreenPreRaster = (boolean) value;
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
                    saveFormData = (boolean) value;
                    break;
                case "thirdPartyCookiesEnabled":
                    thirdPartyCookiesEnabled = (boolean) value;
                    break;
                case "hardwareAcceleration":
                    hardwareAcceleration = (boolean) value;
                    break;
                case "supportMultipleWindows":
                    supportMultipleWindows = (boolean) value;
                    break;
                case "regexToCancelSubFramesLoading":
                    regexToCancelSubFramesLoading = (String) value;
                    break;
            }
        }
        return this;
    }

    private void setLayoutAlgorithm(Map.Entry<String, Object> pair) {
        if (pair.getKey().equals("layoutAlgorithm")) {
            String value = (String) pair.getValue();
            if (value != null) {
                switch (value) {
                    case "NORMAL":
                        this.layoutAlgorithm = NORMAL;
                    case "TEXT_AUTOSIZING":
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                            this.layoutAlgorithm = WebSettings.LayoutAlgorithm.TEXT_AUTOSIZING;
                        } else {
                            layoutAlgorithm = NORMAL;
                        }
                }
            }
        }
    }

    @Override
    public HashMap<String, Object> getHashMap() {
        HashMap<String, Object> options = new HashMap<>();
        options.put("useShouldOverrideUrlLoading", useShouldOverrideUrlLoading);
        options.put("useOnLoadResource", useOnLoadResource);
        options.put("useOnDownloadStart", useOnDownloadStart);
        options.put("clearCache", clearCache);
        options.put("userAgent", userAgent);
        options.put("applicationNameForUserAgent", applicationNameForUserAgent);
        options.put("javaScriptEnabled", javaScriptEnabled);
        options.put("debuggingEnabled", debuggingEnabled);
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
        options.put("layoutAlgorithm", layoutAlgorithm);
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

        return options;
    }
}
