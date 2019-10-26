package com.pichillilorenzo.flutter_inappbrowser.InAppWebView;

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
  public int textZoom = 100;
  public boolean verticalScrollBarEnabled = true;
  public boolean horizontalScrollBarEnabled = true;
  public List<String> resourceCustomSchemes = new ArrayList<>();
  public List<Map<String, Map<String, Object>>> contentBlockers = new ArrayList<>();

  public boolean clearSessionCache = false;
  public boolean builtInZoomControls = false;
  public boolean displayZoomControls = false;
  public boolean supportZoom = true;
  public boolean databaseEnabled = false;
  public boolean domStorageEnabled = false;
  public boolean useWideViewPort = true;
  public boolean safeBrowsingEnabled = true;
  public boolean transparentBackground = false;
  public String mixedContentMode = "";
}
