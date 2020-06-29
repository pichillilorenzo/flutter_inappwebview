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

package com.pichillilorenzo.flutter_inappwebview;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.os.Parcelable;
import android.provider.Browser;
import android.net.Uri;
import android.os.Bundle;
import android.webkit.MimeTypeMap;
import android.util.Log;

import com.pichillilorenzo.flutter_inappwebview.InAppBrowser.InAppBrowserActivity;

import java.io.IOException;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * InAppBrowserManager
 */
public class InAppBrowserManager implements MethodChannel.MethodCallHandler {

  public MethodChannel channel;
  protected static final String LOG_TAG = "InAppBrowserManager";

  public InAppBrowserManager(BinaryMessenger messenger) {
    channel = new MethodChannel(messenger, "com.pichillilorenzo/flutter_inappbrowser");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(final MethodCall call, final Result result) {
    final Activity activity = Shared.activity;
    final String uuid = (String) call.argument("uuid");

    switch (call.method) {
      case "openUrl":
        {
          String url = (String) call.argument("url");
          HashMap<String, Object> options = (HashMap<String, Object>) call.argument("options");
          Map<String, String> headers = (Map<String, String>) call.argument("headers");
          HashMap<String, Object> contextMenu = (HashMap<String, Object>) call.argument("contextMenu");
          Integer windowId = (Integer) call.argument("windowId");
          openUrl(activity, uuid, url, options, headers, contextMenu, windowId);
        }
        result.success(true);
        break;
      case "openFile":
        {
          String url = (String) call.argument("url");
          try {
            url = Util.getUrlAsset(url);
          } catch (IOException e) {
            e.printStackTrace();
            result.error(LOG_TAG, url + " asset file cannot be found!", e);
            return;
          }
          HashMap<String, Object> options = (HashMap<String, Object>) call.argument("options");
          Map<String, String> headers = (Map<String, String>) call.argument("headers");
          HashMap<String, Object> contextMenu = (HashMap<String, Object>) call.argument("contextMenu");
          Integer windowId = (Integer) call.argument("windowId");
          openUrl(activity, uuid, url, options, headers, contextMenu, windowId);
        }
        result.success(true);
        break;
      case "openData":
        {
          HashMap<String, Object> options = (HashMap<String, Object>) call.argument("options");
          String data = (String) call.argument("data");
          String mimeType = (String) call.argument("mimeType");
          String encoding = (String) call.argument("encoding");
          String baseUrl = (String) call.argument("baseUrl");
          String historyUrl = (String) call.argument("historyUrl");
          HashMap<String, Object> contextMenu = (HashMap<String, Object>) call.argument("contextMenu");
          Integer windowId = (Integer) call.argument("windowId");
          openData(activity, uuid, options, data, mimeType, encoding, baseUrl, historyUrl, contextMenu, windowId);
        }
        result.success(true);
        break;
      case "openWithSystemBrowser":
        {
          String url = (String) call.argument("url");
          openWithSystemBrowser(activity, url, result);
        }
        break;
      default:
        result.notImplemented();
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
   * @param result
   * @return "" if ok, or error message.
   */
  public void openWithSystemBrowser(Activity activity, String url, Result result) {
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
      this.openExternalExcludeCurrentApp(activity, intent);
      result.success(true);
      // not catching FileUriExposedException explicitly because buildtools<24 doesn't know about it
    } catch (java.lang.RuntimeException e) {
      Log.d(LOG_TAG, url + " cannot be opened: " + e.toString());
      result.error(LOG_TAG, url + " cannot be opened!", null);
    }
  }

  /**
   * Opens the intent, providing a chooser that excludes the current app to avoid
   * circular loops.
   */
  public void openExternalExcludeCurrentApp(Activity activity, Intent intent) {
    String currentPackage = activity.getPackageName();
    boolean hasCurrentPackage = false;
    PackageManager pm = activity.getPackageManager();
    List<ResolveInfo> activities = pm.queryIntentActivities(intent, 0);
    ArrayList<Intent> targetIntents = new ArrayList<Intent>();
    for (ResolveInfo ri : activities) {
      if (!currentPackage.equals(ri.activityInfo.packageName)) {
        Intent targetIntent = (Intent) intent.clone();
        targetIntent.setPackage(ri.activityInfo.packageName);
        targetIntents.add(targetIntent);
      } else {
        hasCurrentPackage = true;
      }
    }
    // If the current app package isn't a target for this URL, then use
    // the normal launch behavior
    if (!hasCurrentPackage || targetIntents.size() == 0) {
      activity.startActivity(intent);
    }
    // If there's only one possible intent, launch it directly
    else if (targetIntents.size() == 1) {
      activity.startActivity(targetIntents.get(0));
    }
    // Otherwise, show a custom chooser without the current app listed
    else if (targetIntents.size() > 0) {
      Intent chooser = Intent.createChooser(targetIntents.remove(targetIntents.size() - 1), null);
      chooser.putExtra(Intent.EXTRA_INITIAL_INTENTS, targetIntents.toArray(new Parcelable[]{}));
      activity.startActivity(chooser);
    }
  }

  public void openUrl(Activity activity, String uuid, String url, HashMap<String, Object> options, Map<String, String> headers,
                      HashMap<String, Object> contextMenu, Integer windowId) {
    Bundle extras = new Bundle();
    extras.putString("fromActivity", activity.getClass().getName());
    extras.putString("url", url);
    extras.putBoolean("isData", false);
    extras.putString("uuid", uuid);
    extras.putSerializable("options", options);
    extras.putSerializable("headers", (Serializable) headers);
    extras.putSerializable("contextMenu", (Serializable) contextMenu);
    extras.putInt("windowId", windowId != null ? windowId : -1);
    startInAppBrowserActivity(activity, extras);
  }

  public void openData(Activity activity, String uuid, HashMap<String, Object> options, String data, String mimeType, String encoding,
                       String baseUrl, String historyUrl, HashMap<String, Object> contextMenu, Integer windowId) {
    Bundle extras = new Bundle();
    extras.putBoolean("isData", true);
    extras.putString("uuid", uuid);
    extras.putSerializable("options", options);
    extras.putString("data", data);
    extras.putString("mimeType", mimeType);
    extras.putString("encoding", encoding);
    extras.putString("baseUrl", baseUrl);
    extras.putString("historyUrl", historyUrl);
    extras.putSerializable("contextMenu", (Serializable) contextMenu);
    extras.putInt("windowId", windowId != null ? windowId : -1);
    startInAppBrowserActivity(activity, extras);
  }

  public void startInAppBrowserActivity(Activity activity, Bundle extras) {
    Intent intent = new Intent(activity, InAppBrowserActivity.class);
    if (extras != null)
      intent.putExtras(extras);
    activity.startActivity(intent);
  }

  public void dispose() {
    channel.setMethodCallHandler(null);
  }
}
