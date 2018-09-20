/*
 *
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
 */

package com.pichillilorenzo.flutter_inappbrowser;

import android.annotation.TargetApi;
import android.app.Activity;
import android.annotation.SuppressLint;
import android.content.Intent;
import android.provider.Browser;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.RequiresApi;
import android.webkit.MimeTypeMap;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.util.Log;
import android.widget.Toast;

import java.time.Duration;
import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** InAppBrowser */
public class InAppBrowser implements MethodCallHandler {

  public static Registrar registrar;
  public Activity activity;
  public static MethodChannel channel;
  public static WebViewActivity webViewActivity;

  private static final String NULL = "null";
  protected static final String LOG_TAG = "InAppBrowser";


  public InAppBrowser(Registrar r, Activity activity) {
    registrar = r;
    this.activity = activity;
    channel = new MethodChannel(registrar.messenger(), "com.pichillilorenzo/flutter_inappbrowser");
  }

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "com.pichillilorenzo/flutter_inappbrowser");
    channel.setMethodCallHandler(new InAppBrowser(registrar, registrar.activity()));
  }

  @RequiresApi(api = Build.VERSION_CODES.KITKAT)
  @Override
  public void onMethodCall(MethodCall call, final Result result) {
    String source;
    String jsWrapper;
    String urlFile;

    switch (call.method) {
      case "open":
        final String url = call.argument("url").toString();

        String t = call.argument("target").toString();
        if (t == null || t.equals("") || t.equals(NULL)) {
          t = "_self";
        }
        final String target = t;

        final InAppBrowserOptions options = new InAppBrowserOptions();
        options.parse((HashMap<String, Object>) call.argument("options"));

        Log.d(LOG_TAG, "target = " + target);

        this.activity.runOnUiThread(new Runnable() {
          @Override
          public void run() {
            if ("_self".equals(target)) {
              Log.d(LOG_TAG, "in self");

              //Load the dialer
              if (url.startsWith(WebView.SCHEME_TEL))
              {
                try {
                  Log.d(LOG_TAG, "loading in dialer");
                  Intent intent = new Intent(Intent.ACTION_DIAL);
                  intent.setData(Uri.parse(url));
                  activity.startActivity(intent);
                } catch (android.content.ActivityNotFoundException e) {
                  Log.e(LOG_TAG, "Error dialing " + url + ": " + e.toString());
                }
              }
              // load in InAppBrowser
              else {
                Log.d(LOG_TAG, "loading in InAppBrowser");
                open(url, options);
              }
            }
            // SYSTEM
            else if ("_system".equals(target)) {
              Log.d(LOG_TAG, "in system");
              openExternal(url, result);
            }
            // BLANK - or anything else
            else {
              Log.d(LOG_TAG, "in blank");
              open(url, options);
            }

            result.success(true);
          }
        });
        break;
      case "loadUrl":
        loadUrl(call.argument("url").toString(), (Map<String, String>) call.argument("headers"), result);
        break;
      case "close":
        close();
        result.success(true);
        break;
      case "injectScriptCode":
        source = call.argument("source").toString();
        jsWrapper = "(function(){JSON.stringify([eval(%s)])})()";
        injectDeferredObject(source, jsWrapper);
        result.success(true);
        break;
      case "injectScriptFile":
        urlFile = call.argument("urlFile").toString();
        jsWrapper = "(function(d) { var c = d.createElement('script'); c.src = %s; d.body.appendChild(c); })(document)";
        injectDeferredObject(urlFile, jsWrapper);
        result.success(true);
        break;
      case "injectStyleCode":
        source = call.argument("source").toString();
        jsWrapper = "(function(d) { var c = d.createElement('style'); c.innerHTML = %s; d.body.appendChild(c); })(document)";
        injectDeferredObject(source, jsWrapper);
        result.success(true);
        break;
      case "injectStyleFile":
        urlFile = call.argument("urlFile").toString();
        jsWrapper = "(function(d) { var c = d.createElement('link'); c.rel='stylesheet'; c.type='text/css'; c.href = %s; d.head.appendChild(c); })(document)";
        injectDeferredObject(urlFile, jsWrapper);
        result.success(true);
        break;
      case "show":
        show();
        result.success(true);
        break;
      case "hide":
        hide();
        result.success(true);
        break;
      case "reload":
        reload();
        result.success(true);
        break;
      case "goBack":
        goBack();
        result.success(true);
        break;
      case "canGoBack":
        result.success(canGoBack());
        break;
      case "goForward":
        goForward();
        result.success(true);
        break;
      case "canGoForward":
        result.success(canGoForward());
        break;
      case "isLoading":
        result.success(isLoading());
        break;
      case "stopLoading":
        stopLoading();
        result.success(true);
        break;
      default:
        result.notImplemented();
    }

  }

  /**
   * Inject an object (script or style) into the InAppBrowser WebView.
   *
   * This is a helper method for the inject{Script|Style}{Code|File} API calls, which
   * provides a consistent method for injecting JavaScript code into the document.
   *
   * If a wrapper string is supplied, then the source string will be JSON-encoded (adding
   * quotes) and wrapped using string formatting. (The wrapper string should have a single
   * '%s' marker)
   *
   * @param source      The source object (filename or script/style text) to inject into
   *                    the document.
   * @param jsWrapper   A JavaScript string to wrap the source string in, so that the object
   *                    is properly injected, or null if the source string is JavaScript text
   *                    which should be executed directly.
   */
  private void injectDeferredObject(String source, String jsWrapper) {
    if (webViewActivity!=null) {
      String scriptToInject;
      if (jsWrapper != null) {
        org.json.JSONArray jsonEsc = new org.json.JSONArray();
        jsonEsc.put(source);
        String jsonRepr = jsonEsc.toString();
        String jsonSourceString = jsonRepr.substring(1, jsonRepr.length()-1);
        scriptToInject = String.format(jsWrapper, jsonSourceString);
      } else {
        scriptToInject = source;
      }
      final String finalScriptToInject = scriptToInject;
      activity.runOnUiThread(new Runnable() {
        @SuppressLint("NewApi")
        @Override
        public void run() {
          if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) {
            // This action will have the side-effect of blurring the currently focused element
            webViewActivity.webView.loadUrl("javascript:" + finalScriptToInject);
          } else {
            webViewActivity.webView.evaluateJavascript(finalScriptToInject, null);
          }
        }
      });
    } else {
      Log.d(LOG_TAG, "Can't inject code into the system browser");
    }
  }

  public static String getMimeType(String url) {
    String type = null;
    String extension = MimeTypeMap.getFileExtensionFromUrl(url);
    if (extension != null) {
      type = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension);
    }
    return type;
  }

  /**
   * Display a new browser with the specified URL.
   *
   * @param url the url to load.
   * @return "" if ok, or error message.
   */
  public void openExternal(String url, Result result) {
    try {
      Intent intent;
      intent = new Intent(Intent.ACTION_VIEW);
      // Omitting the MIME type for file: URLs causes "No Activity found to handle Intent".
      // Adding the MIME type to http: URLs causes them to not be handled by the downloader.
      Uri uri = Uri.parse(url);
      if ("file".equals(uri.getScheme())) {
        intent.setDataAndType(uri, getMimeType(url));
      } else {
        intent.setData(uri);
      }
      intent.putExtra(Browser.EXTRA_APPLICATION_ID, activity.getPackageName());
      activity.startActivity(intent);
      // not catching FileUriExposedException explicitly because buildtools<24 doesn't know about it
    } catch (java.lang.RuntimeException e) {
      Log.d(LOG_TAG, "InAppBrowser: Error loading url "+url+":"+ e.toString());
    }
  }

  @TargetApi(8)
  private void open(final String url, InAppBrowserOptions options) {
    Intent intent = new Intent(activity, WebViewActivity.class);

    Bundle extras = new Bundle();
    extras.putString("url", url);
    extras.putSerializable("options", options.getHashMap());

    intent.putExtras(extras);

    activity.startActivity(intent);

    // Determine if we should hide the location bar.
//    showLocationBar = true;
//    showZoomControls = true;
//    openWindowHidden = false;
//    mediaPlaybackRequiresUserGesture = false;

//    if (features != null) {
//      String show = features.get(LOCATION);
//      if (show != null) {
//        showLocationBar = show.equals("yes") ? true : false;
//      }
//      if(showLocationBar) {
//        String hideNavigation = features.get(HIDE_NAVIGATION);
//        String hideUrl = features.get(HIDE_URL);
//        if(hideNavigation != null) hideNavigationButtons = hideNavigation.equals("yes") ? true : false;
//        if(hideUrl != null) hideUrlBar = hideUrl.equals("yes") ? true : false;
//      }
//      String zoom = features.get(ZOOM);
//      if (zoom != null) {
//        showZoomControls = zoom.equals("yes") ? true : false;
//      }
//      String hidden = features.get(HIDDEN);
//      if (hidden != null) {
//        openWindowHidden = hidden.equals("yes") ? true : false;
//      }
//      String hardwareBack = features.get(HARDWARE_BACK_BUTTON);
//      if (hardwareBack != null) {
//        hadwareBackButton = hardwareBack.equals("yes") ? true : false;
//      } else {
//        hadwareBackButton = DEFAULT_HARDWARE_BACK;
//      }
//      String mediaPlayback = features.get(MEDIA_PLAYBACK_REQUIRES_USER_ACTION);
//      if (mediaPlayback != null) {
//        mediaPlaybackRequiresUserGesture = mediaPlayback.equals("yes") ? true : false;
//      }
//      String cache = features.get(CLEAR_ALL_CACHE);
//      if (cache != null) {
//        clearAllCache = cache.equals("yes") ? true : false;
//      } else {
//        cache = features.get(CLEAR_SESSION_CACHE);
//        if (cache != null) {
//          clearSessionCache = cache.equals("yes") ? true : false;
//        }
//      }
//      String shouldPause = features.get(SHOULD_PAUSE);
//      if (shouldPause != null) {
//        shouldPauseInAppBrowser = shouldPause.equals("yes") ? true : false;
//      }
//      String wideViewPort = features.get(USER_WIDE_VIEW_PORT);
//      if (wideViewPort != null ) {
//        useWideViewPort = wideViewPort.equals("yes") ? true : false;
//      }
//      String closeButtonCaptionSet = features.get(CLOSE_BUTTON_CAPTION);
//      if (closeButtonCaptionSet != null) {
//        closeButtonCaption = closeButtonCaptionSet;
//      }
//      String closeButtonColorSet = features.get(CLOSE_BUTTON_COLOR);
//      if (closeButtonColorSet != null) {
//        closeButtonColor = closeButtonColorSet;
//      }
//      String toolbarColorSet = features.get(TOOLBAR_COLOR);
//      if (toolbarColorSet != null) {
//        toolbarColor = android.graphics.Color.parseColor(toolbarColorSet);
//      }
//      String navigationButtonColorSet = features.get(NAVIGATION_COLOR);
//      if (navigationButtonColorSet != null) {
//        navigationButtonColor = navigationButtonColorSet;
//      }
//      String showFooterSet = features.get(FOOTER);
//      if (showFooterSet != null) {
//        showFooter = showFooterSet.equals("yes") ? true : false;
//      }
//      String footerColorSet = features.get(FOOTER_COLOR);
//      if (footerColorSet != null) {
//        footerColor = footerColorSet;
//      }
//    }
//
//    // Create dialog in new thread
//    Runnable runnable = new Runnable() {
//      /**
//       * Convert our DIP units to Pixels
//       *
//       * @return int
//       */
//      private int dpToPixels(int dipValue) {
//        int value = (int) TypedValue.applyDimension( TypedValue.COMPLEX_UNIT_DIP,
//                (float) dipValue,
//                activity.getResources().getDisplayMetrics()
//        );
//
//        return value;
//      }
//
//      @TargetApi(8)
//      private View createCloseButton(int id){
//        View _close;
//        Resources activityRes = activity.getResources();
//
//        if (closeButtonCaption != "") {
//          // Use TextView for text
//          TextView close = new TextView(activity);
//          close.setText(closeButtonCaption);
//          close.setTextSize(20);
//          if (closeButtonColor != "") close.setTextColor(android.graphics.Color.parseColor(closeButtonColor));
//          close.setGravity(android.view.Gravity.CENTER_VERTICAL);
//          close.setPadding(this.dpToPixels(10), 0, this.dpToPixels(10), 0);
//          _close = close;
//        }
//        else {
//          ImageButton close = new ImageButton(activity);
//          int closeResId = activityRes.getIdentifier("ic_action_remove", "drawable", activity.getPackageName());
//          Drawable closeIcon = activityRes.getDrawable(closeResId);
//          if (closeButtonColor != "") close.setColorFilter(android.graphics.Color.parseColor(closeButtonColor));
//          close.setImageDrawable(closeIcon);
//          close.setScaleType(ImageView.ScaleType.FIT_CENTER);
//          if (Build.VERSION.SDK_INT >= 16)
//            close.getAdjustViewBounds();
//
//          _close = close;
//        }
//
//        RelativeLayout.LayoutParams closeLayoutParams = new RelativeLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.MATCH_PARENT);
//        closeLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
//        _close.setLayoutParams(closeLayoutParams);
//
//        if (Build.VERSION.SDK_INT >= 16)
//          _close.setBackground(null);
//        else
//          _close.setBackgroundDrawable(null);
//
//        _close.setContentDescription("Close Button");
//        _close.setId(Integer.valueOf(id));
//        _close.setOnClickListener(new View.OnClickListener() {
//          public void onClick(View v) {
//            closeDialog();
//          }
//        });
//
//        return _close;
//      }
//
//      @SuppressLint("NewApi")
//      public void run() {
//        // CB-6702 InAppBrowser hangs when opening more than one instance
//        if (dialog != null) {
//          dialog.dismiss();
//        };
//
//        // Let's create the main dialog
//        dialog = new InAppBrowserDialog(activity, android.R.style.Theme_NoTitleBar);
//        dialog.getWindow().getAttributes().windowAnimations = android.R.style.Animation_Dialog;
//        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
//        dialog.setCancelable(true);
//        dialog.setInAppBroswer(getInAppBrowser());
//
//        int mainId = activity.getResources().getIdentifier("activity_web_view", "layout", activity.getPackageName());
//        LinearLayout main = (LinearLayout) LayoutInflater.from(registrar.context()).inflate(mainId, null);
//
//        WebView webView = (WebView) main.getChildAt(1));
//        webView.loadUrl("https://www.google.com");
//
//        // Main container layout
////        LinearLayout main = new LinearLayout(activity);
////        main.setOrientation(LinearLayout.VERTICAL);
////
////        // Toolbar layout
////        RelativeLayout toolbar = new RelativeLayout(activity);
////        //Please, no more black!
////
////        toolbar.setBackgroundColor(toolbarColor);
////        toolbar.setLayoutParams(new RelativeLayout.LayoutParams(LayoutParams.MATCH_PARENT, this.dpToPixels(44)));
////        toolbar.setPadding(this.dpToPixels(2), this.dpToPixels(2), this.dpToPixels(2), this.dpToPixels(2));
////        toolbar.setHorizontalGravity(Gravity.LEFT);
////        toolbar.setVerticalGravity(Gravity.TOP);
////
////        // Action Button Container layout
////        RelativeLayout actionButtonContainer = new RelativeLayout(activity);
////        actionButtonContainer.setLayoutParams(new RelativeLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
////        actionButtonContainer.setHorizontalGravity(Gravity.LEFT);
////        actionButtonContainer.setVerticalGravity(Gravity.CENTER_VERTICAL);
////        actionButtonContainer.setId(Integer.valueOf(1));
////
////        // Back button
////        ImageButton back = new ImageButton(activity);
////        RelativeLayout.LayoutParams backLayoutParams = new RelativeLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.MATCH_PARENT);
////        backLayoutParams.addRule(RelativeLayout.ALIGN_LEFT);
////        back.setLayoutParams(backLayoutParams);
////        back.setContentDescription("Back Button");
////        back.setId(Integer.valueOf(2));
////        Resources activityRes = activity.getResources();
////        int backResId = activityRes.getIdentifier("ic_action_previous_item", "drawable", activity.getPackageName());
////        Drawable backIcon = activityRes.getDrawable(backResId);
////        if (navigationButtonColor != "") back.setColorFilter(android.graphics.Color.parseColor(navigationButtonColor));
////        if (Build.VERSION.SDK_INT >= 16)
////          back.setBackground(null);
////        else
////          back.setBackgroundDrawable(null);
////        back.setImageDrawable(backIcon);
////        back.setScaleType(ImageView.ScaleType.FIT_CENTER);
////        back.setPadding(0, this.dpToPixels(10), 0, this.dpToPixels(10));
////        if (Build.VERSION.SDK_INT >= 16)
////          back.getAdjustViewBounds();
////
////        back.setOnClickListener(new View.OnClickListener() {
////          public void onClick(View v) {
////            goBack();
////          }
////        });
////
////        // Forward button
////        ImageButton forward = new ImageButton(activity);
////        RelativeLayout.LayoutParams forwardLayoutParams = new RelativeLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.MATCH_PARENT);
////        forwardLayoutParams.addRule(RelativeLayout.RIGHT_OF, 2);
////        forward.setLayoutParams(forwardLayoutParams);
////        forward.setContentDescription("Forward Button");
////        forward.setId(Integer.valueOf(3));
////        int fwdResId = activityRes.getIdentifier("ic_action_next_item", "drawable", activity.getPackageName());
////        Drawable fwdIcon = activityRes.getDrawable(fwdResId);
////        if (navigationButtonColor != "") forward.setColorFilter(android.graphics.Color.parseColor(navigationButtonColor));
////        if (Build.VERSION.SDK_INT >= 16)
////          forward.setBackground(null);
////        else
////          forward.setBackgroundDrawable(null);
////        forward.setImageDrawable(fwdIcon);
////        forward.setScaleType(ImageView.ScaleType.FIT_CENTER);
////        forward.setPadding(0, this.dpToPixels(10), 0, this.dpToPixels(10));
////        if (Build.VERSION.SDK_INT >= 16)
////          forward.getAdjustViewBounds();
////
////        forward.setOnClickListener(new View.OnClickListener() {
////          public void onClick(View v) {
////            goForward();
////          }
////        });
////
////        // Edit Text Box
////        edittext = new EditText(activity);
////        RelativeLayout.LayoutParams textLayoutParams = new RelativeLayout.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);
////        textLayoutParams.addRule(RelativeLayout.RIGHT_OF, 1);
////        textLayoutParams.addRule(RelativeLayout.LEFT_OF, 5);
////        edittext.setLayoutParams(textLayoutParams);
////        edittext.setId(Integer.valueOf(4));
////        edittext.setSingleLine(true);
////        edittext.setText(url);
////        edittext.setInputType(InputType.TYPE_TEXT_VARIATION_URI);
////        edittext.setImeOptions(EditorInfo.IME_ACTION_GO);
////        edittext.setInputType(InputType.TYPE_NULL); // Will not except input... Makes the text NON-EDITABLE
////        edittext.setOnKeyListener(new View.OnKeyListener() {
////          public boolean onKey(View v, int keyCode, KeyEvent event) {
////            // If the event is a key-down event on the "enter" button
////            if ((event.getAction() == KeyEvent.ACTION_DOWN) && (keyCode == KeyEvent.KEYCODE_ENTER)) {
////              navigate(edittext.getText().toString());
////              return true;
////            }
////            return false;
////          }
////        });
////
////
////        // Header Close/Done button
////        View close = createCloseButton(5);
////        toolbar.addView(close);
////
////        // Footer
////        RelativeLayout footer = new RelativeLayout(activity);
////        int _footerColor;
////        if(footerColor != ""){
////          _footerColor = Color.parseColor(footerColor);
////        }else{
////          _footerColor = android.graphics.Color.LTGRAY;
////        }
////        footer.setBackgroundColor(_footerColor);
////        RelativeLayout.LayoutParams footerLayout = new RelativeLayout.LayoutParams(LayoutParams.MATCH_PARENT, this.dpToPixels(44));
////        footerLayout.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM, RelativeLayout.TRUE);
////        footer.setLayoutParams(footerLayout);
////        if (closeButtonCaption != "") footer.setPadding(this.dpToPixels(8), this.dpToPixels(8), this.dpToPixels(8), this.dpToPixels(8));
////        footer.setHorizontalGravity(Gravity.LEFT);
////        footer.setVerticalGravity(Gravity.BOTTOM);
////
////        View footerClose = createCloseButton(7);
////        footer.addView(footerClose);
////
////
////        // WebView
////        inAppWebView = new WebView(activity);
////        inAppWebView.setLayoutParams(new LinearLayout.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT));
////        inAppWebView.setId(Integer.valueOf(6));
////        inAppWebView.setWebChromeClient(new WebChromeClient() {
////
////          @Override
////          public void onProgressChanged(WebView view, int newProgress) {
////            super.onProgressChanged(view, newProgress);
////          }
////
////          @Override
////          public void onReceivedTitle(WebView view, String title) {
////            super.onReceivedTitle(view, title);
////          }
////
////          @Override
////          public void onReceivedIcon(WebView view, Bitmap icon) {
////            super.onReceivedIcon(view, icon);
////          }
////
////          // For Android 5.0+
////          public boolean onShowFileChooser (WebView webView, ValueCallback<Uri[]> filePathCallback, WebChromeClient.FileChooserParams fileChooserParams)
////          {
////            Log.d(LOG_TAG, "File Chooser 5.0+");
////            // If callback exists, finish it.
////            if(mUploadCallbackLollipop != null) {
////              mUploadCallbackLollipop.onReceiveValue(null);
////            }
////            mUploadCallbackLollipop = filePathCallback;
////
////            // Create File Chooser Intent
////            Intent content = new Intent(Intent.ACTION_GET_CONTENT);
////            content.addCategory(Intent.CATEGORY_OPENABLE);
////            content.setType("*/*");
////
////            registrar.context().startActivity(Intent.createChooser(content, "Select File"));
////            return true;
////          }
////
////          // For Android 4.1+
////          public void openFileChooser(ValueCallback<Uri> uploadMsg, String acceptType, String capture)
////          {
////            Log.d(LOG_TAG, "File Chooser 4.1+");
////            // Call file chooser for Android 3.0+
////            openFileChooser(uploadMsg, acceptType);
////          }
////
////          // For Android 3.0+
////          public void openFileChooser(ValueCallback<Uri> uploadMsg, String acceptType)
////          {
////            Log.d(LOG_TAG, "File Chooser 3.0+");
////            mUploadCallback = uploadMsg;
////            Intent content = new Intent(Intent.ACTION_GET_CONTENT);
////            content.addCategory(Intent.CATEGORY_OPENABLE);
////
////            registrar.context().startActivity(Intent.createChooser(content, "Select File"));
////          }
////        });
////
////        WebViewClient client = new InAppBrowserClient(edittext, activity, channel);
////        inAppWebView.setWebViewClient(client);
////        WebSettings settings = inAppWebView.getSettings();
////        settings.setJavaScriptEnabled(true);
////        //settings.setJavaScinAppWebViewriptCanOpenWindowsAutomatically(true);
////        settings.setBuiltInZoomControls(showZoomControls);
////        settings.setPluginState(android.webkit.WebSettings.PluginState.ON);
////
////        if(android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.JELLY_BEAN_MR1) {
////          settings.setMediaPlaybackRequiresUserGesture(mediaPlaybackRequiresUserGesture);
////        }
////
////        String overrideUserAgent = activity.getPreferences(0).getString("OverrideUserAgent", null);
////        String appendUserAgent = activity.getPreferences(0).getString("AppendUserAgent", null);
////
////        if (overrideUserAgent != null) {
////          settings.setUserAgentString(overrideUserAgent);
////        }
////        if (appendUserAgent != null) {
////          settings.setUserAgentString(settings.getUserAgentString() + appendUserAgent);
////        }
////
////        //Toggle whether this is enabled or not!
////        Bundle appSettings = activity.getIntent().getExtras();
////        boolean enableDatabase = appSettings == null ? true : appSettings.getBoolean("InAppBrowserStorageEnabled", true);
////        if (enableDatabase) {
////          String databasePath = activity.getApplicationContext().getDir("inAppBrowserDB", Context.MODE_PRIVATE).getPath();
////          settings.setDatabasePath(databasePath);
////          settings.setDatabaseEnabled(true);
////        }
////        settings.setDomStorageEnabled(true);
////
////        if (clearAllCache) {
////          CookieManager.getInstance().removeAllCookie();
////        } else if (clearSessionCache) {
////          CookieManager.getInstance().removeSessionCookie();
////        }
////
////        // Enable Thirdparty Cookies on >=Android 5.0 device
////        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP) {
////          CookieManager.getInstance().setAcceptThirdPartyCookies(inAppWebView,true);
////        }
////
////        inAppWebView.loadUrl(url);
////        inAppWebView.setId(Integer.valueOf(6));
////        inAppWebView.getSettings().setLoadWithOverviewMode(true);
////        inAppWebView.getSettings().setUseWideViewPort(useWideViewPort);
////        inAppWebView.requestFocus();
////        inAppWebView.requestFocusFromTouch();
////
////        // Add the back and forward buttons to our action button container layout
////        actionButtonContainer.addView(back);
////        actionButtonContainer.addView(forward);
////
////        // Add the views to our toolbar if they haven't been disabled
////        if (!hideNavigationButtons) toolbar.addView(actionButtonContainer);
////        if (!hideUrlBar) toolbar.addView(edittext);
////
////        // Don't add the toolbar if its been disabled
////        if (getShowLocationBar()) {
////          // Add our toolbar to our main view/layout
////          main.addView(toolbar);
////        }
////
////        // Add our webview to our main view/layout
////        RelativeLayout webViewLayout = new RelativeLayout(activity);
////        webViewLayout.addView(inAppWebView);
////        main.addView(webViewLayout);
////
////        // Don't add the footer unless it's been enabled
////        if (showFooter) {
////          webViewLayout.addView(footer);
////        }
//
//        WindowManager.LayoutParams lp = new WindowManager.LayoutParams();
//        lp.copyFrom(dialog.getWindow().getAttributes());
//        lp.width = WindowManager.LayoutParams.MATCH_PARENT;
//        lp.height = WindowManager.LayoutParams.MATCH_PARENT;
//
//        dialog.setContentView(main);
//        dialog.show();
//        dialog.getWindow().setAttributes(lp);
//        // the goal of openhidden is to load the url and not display it
//        // Show() needs to be called to cause the URL to be loaded
//        if(openWindowHidden) {
//          dialog.hide();
//        }
//      }
//    };
//    this.activity.runOnUiThread(runnable);
    //return "";
  }

  public void loadUrl(String url, Map<String, String> headers, Result result) {
    if (webViewActivity != null) {
      if (headers != null)
        webViewActivity.loadUrl(url, headers, result);
      else
        webViewActivity.loadUrl(url, result);
    }
  }

  public void show() {
    if (webViewActivity != null)
      webViewActivity.show();
  }

  public void hide() {
    if (webViewActivity != null)
      webViewActivity.hide();
  }

  public void reload() {
    if (webViewActivity != null)
      webViewActivity.reload();
  }

  public boolean isLoading() {
    if (webViewActivity != null)
      return webViewActivity.isLoading();
    return false;
  }

  public void stopLoading() {
    if (webViewActivity != null)
      webViewActivity.stopLoading();
  }

  public void goBack() {
    if (webViewActivity != null)
      webViewActivity.goBack();
  }

  public boolean canGoBack() {
    if (webViewActivity != null)
      return webViewActivity.canGoBack();
    return false;
  }

  public void goForward() {
    if (webViewActivity != null)
      webViewActivity.goForward();
  }

  public boolean canGoForward() {
    if (webViewActivity != null)
      return webViewActivity.canGoForward();
    return false;
  }


  public void close() {
    this.activity.runOnUiThread(new Runnable() {
      @Override
      public void run() {
        // The JS protects against multiple calls, so this should happen only when
        // close() is called by other native code.
        if (webViewActivity == null)
          return;

        webViewActivity.webView.setWebViewClient(new WebViewClient() {
          // NB: wait for about:blank before dismissing
          public void onPageFinished(WebView view, String url) {
            webViewActivity.close();
          }
        });
        // NB: From SDK 19: "If you call methods on WebView from any thread
        // other than your app's UI thread, it can cause unexpected results."
        // http://developer.android.com/guide/webapps/migrating.html#Threads
        webViewActivity.webView.loadUrl("about:blank");

        Map<String, Object> obj = new HashMap<>();
        channel.invokeMethod("exit", obj);
      }
    });
  }
}
