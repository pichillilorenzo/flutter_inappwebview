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

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.webkit.CookieManager;
import android.webkit.CookieSyncManager;
import android.webkit.HttpAuthHandler;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.EditText;
import android.util.Log;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

/**
 * The webview client receives notifications about appView
 */
public class InAppBrowserClient extends WebViewClient {

    protected static final String LOG_TAG = "InAppBrowser";
    private static final String LOAD_START_EVENT = "loadstart";
    private static final String LOAD_STOP_EVENT = "loadstop";
    private static final String LOAD_ERROR_EVENT = "loaderror";

    private String[] allowedSchemes;
    
    private EditText edittext;
    private Activity activity;
    private final MethodChannel channel;

    /**
     * Constructor.
     *
     * @param mEditText
     * @param activity
     */
    public InAppBrowserClient(EditText mEditText, Activity activity, MethodChannel channel) {
        this.edittext = mEditText;
        this.activity = activity;
        this.channel = channel;
    }

    /**
     * Override the URL that should be loaded
     *
     * This handles a small subset of all the URIs that would be encountered.
     *
     * @param webView
     * @param url
     */
    @Override
    public boolean shouldOverrideUrlLoading(WebView webView, String url) {
        if (url.startsWith(WebView.SCHEME_TEL)) {
            try {
                Intent intent = new Intent(Intent.ACTION_DIAL);
                intent.setData(Uri.parse(url));
                activity.startActivity(intent);
                return true;
            } catch (android.content.ActivityNotFoundException e) {
                Log.e(LOG_TAG, "Error dialing " + url + ": " + e.toString());
            }
        } else if (url.startsWith("geo:") || url.startsWith(WebView.SCHEME_MAILTO) || url.startsWith("market:") || url.startsWith("intent:")) {
            try {
                Intent intent = new Intent(Intent.ACTION_VIEW);
                intent.setData(Uri.parse(url));
                activity.startActivity(intent);
                return true;
            } catch (android.content.ActivityNotFoundException e) {
                Log.e(LOG_TAG, "Error with " + url + ": " + e.toString());
            }
        }
        // If sms:5551212?body=This is the message
        else if (url.startsWith("sms:")) {
            try {
                Intent intent = new Intent(Intent.ACTION_VIEW);

                // Get address
                String address = null;
                int parmIndex = url.indexOf('?');
                if (parmIndex == -1) {
                    address = url.substring(4);
                } else {
                    address = url.substring(4, parmIndex);

                    // If body, then set sms body
                    Uri uri = Uri.parse(url);
                    String query = uri.getQuery();
                    if (query != null) {
                        if (query.startsWith("body=")) {
                            intent.putExtra("sms_body", query.substring(5));
                        }
                    }
                }
                intent.setData(Uri.parse("sms:" + address));
                intent.putExtra("address", address);
                intent.setType("vnd.android-dir/mms-sms");
                activity.startActivity(intent);
                return true;
            } catch (android.content.ActivityNotFoundException e) {
                Log.e(LOG_TAG, "Error sending sms " + url + ":" + e.toString());
            }
        }
        // Test for whitelisted custom scheme names like mycoolapp:// or twitteroauthresponse:// (Twitter Oauth Response)
        else if (!url.startsWith("http:") && !url.startsWith("https:") && url.matches("^[A-Za-z0-9+.-]*://.*?$")) {
            if (allowedSchemes == null) {
                String allowed = activity.getPreferences(0).getString("AllowedSchemes", null);
                if(allowed != null) {
                    allowedSchemes = allowed.split(",");
                }
            }
            if (allowedSchemes != null) {
                for (String scheme : allowedSchemes) {
                    if (url.startsWith(scheme)) {
                        Map<String, Object> obj = new HashMap<>();
                        obj.put("type", "customscheme");
                        obj.put("url", url);
                        channel.invokeMethod("customscheme", obj);
                        return true;
                    }
                }
            }
        }

        return false;
    }


    /*
     * onPageStarted fires the LOAD_START_EVENT
     *
     * @param view
     * @param url
     * @param favicon
     */
    @Override
    public void onPageStarted(WebView view, String url, Bitmap favicon) {
        super.onPageStarted(view, url, favicon);
        String newloc = "";
        if (url.startsWith("http:") || url.startsWith("https:") || url.startsWith("file:")) {
            newloc = url;
        }
        else
        {
            // Assume that everything is HTTP at this point, because if we don't specify,
            // it really should be.  Complain loudly about this!!!
            Log.e(LOG_TAG, "Possible Uncaught/Unknown URI");
            newloc = "http://" + url;
        }

        // Update the UI if we haven't already
        if (!newloc.equals(edittext.getText().toString())) {
            edittext.setText(newloc);
        }

        Map<String, Object> obj = new HashMap<>();
        obj.put("type", LOAD_START_EVENT);
        obj.put("url", newloc);
        channel.invokeMethod(LOAD_START_EVENT, obj);
    }



    public void onPageFinished(WebView view, String url) {
        super.onPageFinished(view, url);

        // CB-10395 InAppBrowser's WebView not storing cookies reliable to local device storage
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP) {
            CookieManager.getInstance().flush();
        } else {
            CookieSyncManager.getInstance().sync();
        }

        // https://issues.apache.org/jira/browse/CB-11248
        view.clearFocus();
        view.requestFocus();

        Map<String, Object> obj = new HashMap<>();
        obj.put("type", LOAD_STOP_EVENT);
        obj.put("url", url);
        channel.invokeMethod(LOAD_STOP_EVENT, obj);
    }

    public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {
        super.onReceivedError(view, errorCode, description, failingUrl);

        Map<String, Object> obj = new HashMap<>();
        obj.put("type", LOAD_ERROR_EVENT);
        obj.put("url", failingUrl);
        obj.put("code", errorCode);
        obj.put("message", description);
        channel.invokeMethod(LOAD_ERROR_EVENT, obj);
    }

    /**
     * On received http auth request.
     */
    @Override
    public void onReceivedHttpAuthRequest(WebView view, HttpAuthHandler handler, String host, String realm) {
        // By default handle 401 like we'd normally do!
        super.onReceivedHttpAuthRequest(view, handler, host, realm);
    }
}