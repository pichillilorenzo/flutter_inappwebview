package com.pichillilorenzo.flutter_inappwebview;

public class InAppBrowserOptions extends Options {

  public static final String LOG_TAG = "InAppBrowserOptions";

  public Boolean hidden = false;
  public Boolean toolbarTop = true;
  public String toolbarTopBackgroundColor = "";
  public String toolbarTopFixedTitle = "";
  public Boolean hideUrlBar = false;

  public Boolean hideTitleBar = false;
  public Boolean closeOnCannotGoBack = true;
  public Boolean progressBar = true;
}
