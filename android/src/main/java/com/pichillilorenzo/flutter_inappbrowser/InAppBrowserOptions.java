package com.pichillilorenzo.flutter_inappbrowser;

public class InAppBrowserOptions extends Options {

  public static final String LOG_TAG = "InAppBrowserOptions";

  public boolean hidden = false;
  public boolean toolbarTop = true;
  public String toolbarTopBackgroundColor = "";
  public String toolbarTopFixedTitle = "";
  public boolean hideUrlBar = false;

  public boolean hideTitleBar = false;
  public boolean closeOnCannotGoBack = true;
  public boolean progressBar = true;
}
