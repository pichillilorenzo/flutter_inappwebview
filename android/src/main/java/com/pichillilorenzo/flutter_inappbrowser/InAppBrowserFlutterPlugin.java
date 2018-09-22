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
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.os.Parcelable;
import android.provider.Browser;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.RequiresApi;
import android.util.JsonReader;
import android.util.JsonToken;
import android.webkit.MimeTypeMap;
import android.webkit.ValueCallback;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.util.Log;

import java.io.IOException;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** InAppBrowserFlutterPlugin */
public class InAppBrowserFlutterPlugin implements MethodCallHandler {

  public static Registrar registrar;
  public Activity activity;
  public static MethodChannel channel;
  public static WebViewActivity webViewActivity;

  private static final String NULL = "null";
  protected static final String LOG_TAG = "InAppBrowserFlutterP";


  public InAppBrowserFlutterPlugin(Registrar r, Activity activity) {
    registrar = r;
    this.activity = activity;
    channel = new MethodChannel(registrar.messenger(), "com.pichillilorenzo/flutter_inappbrowser");
  }

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "com.pichillilorenzo/flutter_inappbrowser");
    channel.setMethodCallHandler(new InAppBrowserFlutterPlugin(registrar, registrar.activity()));
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
              // load in InAppBrowserFlutterPlugin
              else {
                Log.d(LOG_TAG, "loading in InAppBrowserFlutterPlugin");
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
        jsWrapper = "(function(){return JSON.stringify(eval(%s));})();";
        injectDeferredObject(source, jsWrapper, result);
        break;
      case "injectScriptFile":
        urlFile = call.argument("urlFile").toString();
        jsWrapper = "(function(d) { var c = d.createElement('script'); c.src = %s; d.body.appendChild(c); })(document);";
        injectDeferredObject(urlFile, jsWrapper, null);
        result.success(true);
        break;
      case "injectStyleCode":
        source = call.argument("source").toString();
        jsWrapper = "(function(d) { var c = d.createElement('style'); c.innerHTML = %s; d.body.appendChild(c); })(document);";
        injectDeferredObject(source, jsWrapper, null);
        result.success(true);
        break;
      case "injectStyleFile":
        urlFile = call.argument("urlFile").toString();
        jsWrapper = "(function(d) { var c = d.createElement('link'); c.rel='stylesheet'; c.type='text/css'; c.href = %s; d.head.appendChild(c); })(document);";
        injectDeferredObject(urlFile, jsWrapper, null);
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
   * Inject an object (script or style) into the InAppBrowserFlutterPlugin WebView.
   *
   * This is a helper method for the inject{Script|Style}{Code|File} API calls, which
   * provides a consistent method for injecting JavaScript code into the document.
   *
   * If a wrapper string is supplied, then the source string will be JSON-encoded (adding
   * quotes) and wrapped using string formatting. (The wrapper string should have a single
   * '%s' marker)
   *  @param source      The source object (filename or script/style text) to inject into
   *                    the document.
   * @param jsWrapper   A JavaScript string to wrap the source string in, so that the object
   *                    is properly injected, or null if the source string is JavaScript text
   * @param result
   */
  private void injectDeferredObject(String source, String jsWrapper, final Result result) {
    if (webViewActivity != null) {
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
        @Override
        public void run() {
          if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) {
            // This action will have the side-effect of blurring the currently focused element
            webViewActivity.webView.loadUrl("javascript:" + finalScriptToInject);
          } else {
            webViewActivity.webView.evaluateJavascript(finalScriptToInject, new ValueCallback<String>() {
              @Override
              public void onReceiveValue(String s) {
                if (result == null)
                  return;

                JsonReader reader = new JsonReader(new StringReader(s));

                // Must set lenient to parse single values
                reader.setLenient(true);

                try {
                  String msg;
                  msg = reader.nextString();

                  JsonReader reader2 = new JsonReader(new StringReader(msg));
                  reader2.setLenient(true);

                  if (reader2.peek() == JsonToken.STRING)
                    msg = reader2.nextString();

                  result.success(msg);

                } catch (IOException e) {
                  Log.e(LOG_TAG, "IOException", e);
                } finally {
                  try {
                    reader.close();
                  } catch (IOException e) {
                    // NOOP
                  }
                }
              }
            });
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
      // CB-10795: Avoid circular loops by preventing it from opening in the current app
      this.openExternalExcludeCurrentApp(intent);
      // not catching FileUriExposedException explicitly because buildtools<24 doesn't know about it
    } catch (java.lang.RuntimeException e) {
      Log.d(LOG_TAG, "InAppBrowserFlutterPlugin: Error loading url "+url+":"+ e.toString());
    }
  }

  /**
   * Opens the intent, providing a chooser that excludes the current app to avoid
   * circular loops.
   */
  private void openExternalExcludeCurrentApp(Intent intent) {
    String currentPackage = activity.getPackageName();
    boolean hasCurrentPackage = false;
    PackageManager pm = activity.getPackageManager();
    List<ResolveInfo> activities = pm.queryIntentActivities(intent, 0);
    ArrayList<Intent> targetIntents = new ArrayList<Intent>();
    for (ResolveInfo ri : activities) {
      if (!currentPackage.equals(ri.activityInfo.packageName)) {
        Intent targetIntent = (Intent)intent.clone();
        targetIntent.setPackage(ri.activityInfo.packageName);
        targetIntents.add(targetIntent);
      }
      else {
        hasCurrentPackage = true;
      }
    }
    // If the current app package isn't a target for this URL, then use
    // the normal launch behavior
    if (hasCurrentPackage == false || targetIntents.size() == 0) {
      activity.startActivity(intent);
    }
    // If there's only one possible intent, launch it directly
    else if (targetIntents.size() == 1) {
      activity.startActivity(targetIntents.get(0));
    }
    // Otherwise, show a custom chooser without the current app listed
    else if (targetIntents.size() > 0) {
      Intent chooser = Intent.createChooser(targetIntents.remove(targetIntents.size()-1), null);
      chooser.putExtra(Intent.EXTRA_INITIAL_INTENTS, targetIntents.toArray(new Parcelable[] {}));
      activity.startActivity(chooser);
    }
  }

  private void open(final String url, InAppBrowserOptions options) {
    Intent intent = new Intent(activity, WebViewActivity.class);

    Bundle extras = new Bundle();
    extras.putString("url", url);
    extras.putSerializable("options", options.getHashMap());

    intent.putExtras(extras);

    activity.startActivity(intent);
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

      Map<String, Object> obj = new HashMap<>();
      channel.invokeMethod("exit", obj);

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
      }
    });
  }
}
