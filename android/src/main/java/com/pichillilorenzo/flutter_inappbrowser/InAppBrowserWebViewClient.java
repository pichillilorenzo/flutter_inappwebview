package com.pichillilorenzo.flutter_inappbrowser;

import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.util.Log;
import android.webkit.CookieManager;
import android.webkit.CookieSyncManager;
import android.webkit.HttpAuthHandler;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import java.util.HashMap;
import java.util.Map;

public class InAppBrowserWebViewClient extends WebViewClient {

    protected static final String LOG_TAG = "IABWebViewClient";
    private WebViewActivity activity;

    public InAppBrowserWebViewClient(WebViewActivity activity) {
        super();
        this.activity = activity;
    }

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
        }
        else if (url.startsWith("geo:") || url.startsWith(WebView.SCHEME_MAILTO) || url.startsWith("market:") || url.startsWith("intent:")) {
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
                String address;
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
        else {
            return super.shouldOverrideUrlLoading(webView, url);
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

        activity.isLoading = true;

        if (activity.searchView != null && !url.equals(activity.searchView.getQuery().toString())) {
            activity.searchView.setQuery(url, false);
        }

        Map<String, Object> obj = new HashMap<>();
        obj.put("url", url);
        InAppBrowser.channel.invokeMethod("loadstart", obj);
    }



    public void onPageFinished(WebView view, String url) {
        super.onPageFinished(view, url);

        activity.isLoading = false;

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
        obj.put("url", url);
        InAppBrowser.channel.invokeMethod("loadstop", obj);
    }

    public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {
        super.onReceivedError(view, errorCode, description, failingUrl);

        activity.isLoading = false;

        Map<String, Object> obj = new HashMap<>();
        obj.put("url", failingUrl);
        obj.put("code", errorCode);
        obj.put("message", description);
        InAppBrowser.channel.invokeMethod("loaderror", obj);
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
