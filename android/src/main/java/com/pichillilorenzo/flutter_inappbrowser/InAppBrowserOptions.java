package com.pichillilorenzo.flutter_inappbrowser;

public class InAppBrowserOptions extends Options {

  static final String LOG_TAG = "InAppBrowserOptions";

  public boolean useShouldOverrideUrlLoading = false;
  public boolean useOnLoadResource = false;
  public boolean openWithSystemBrowser = false;
  public boolean clearCache = false;
  public String userAgent = "";
  public boolean javaScriptEnabled = true;
  public boolean javaScriptCanOpenWindowsAutomatically = false;
  public boolean hidden = false;
  public boolean toolbarTop = true;
  public String toolbarTopBackgroundColor = "";
  public String toolbarTopFixedTitle = "";
  public boolean hideUrlBar = false;
  public boolean mediaPlaybackRequiresUserGesture = true;
  public boolean isLocalFile = false;

  public boolean hideTitleBar = false;
  public boolean closeOnCannotGoBack = true;
  public boolean clearSessionCache = false;
  public boolean builtInZoomControls = false;
  public boolean supportZoom = true;
  public boolean databaseEnabled = false;
  public boolean domStorageEnabled = false;
  public boolean useWideViewPort = true;
  public boolean safeBrowsingEnabled = true;
  public boolean progressBar = true;
}
