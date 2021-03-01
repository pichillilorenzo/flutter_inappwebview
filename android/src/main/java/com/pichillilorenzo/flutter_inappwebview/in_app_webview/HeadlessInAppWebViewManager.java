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

package com.pichillilorenzo.flutter_inappwebview.in_app_webview;

import android.app.Activity;

import com.pichillilorenzo.flutter_inappwebview.Shared;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * InAppBrowserManager
 */
public class HeadlessInAppWebViewManager implements MethodChannel.MethodCallHandler {

  public MethodChannel channel;
  protected static final String LOG_TAG = "HeadlessInAppWebViewManager";
  Map<String, FlutterWebView> flutterWebViews = new HashMap<>();

  public HeadlessInAppWebViewManager(BinaryMessenger messenger) {
    channel = new MethodChannel(messenger, "com.pichillilorenzo/flutter_headless_inappwebview");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(final MethodCall call, final Result result) {
    final Activity activity = Shared.activity;
    final String id = (String) call.argument("id");

    switch (call.method) {
      case "createHeadlessWebView":
        {
          HashMap<String, Object> params = (HashMap<String, Object>) call.argument("params");
          createHeadlessWebView(activity, id, params);
        }
        result.success(true);
        break;
      case "disposeHeadlessWebView":
        disposeHeadlessWebView(id);
        result.success(true);
        break;
      default:
        result.notImplemented();
    }

  }

  public void createHeadlessWebView(Activity activity, String id, HashMap<String, Object> params) {
    FlutterWebView flutterWebView = new FlutterWebView(Shared.messenger, activity, id, params, null);
    flutterWebViews.put(id, flutterWebView);
  }

  public void disposeHeadlessWebView(String id) {
    if (flutterWebViews.containsKey(id)) {
      flutterWebViews.get(id).dispose();
      flutterWebViews.remove(id);
    }
  }

  public void dispose() {
    channel.setMethodCallHandler(null);
  }
}
