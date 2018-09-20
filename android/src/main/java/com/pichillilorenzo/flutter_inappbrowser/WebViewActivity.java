package com.pichillilorenzo.flutter_inappbrowser;

import android.annotation.TargetApi;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.support.annotation.RequiresApi;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.Display;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.WindowManager;
import android.webkit.CookieManager;
import android.webkit.ValueCallback;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.widget.ProgressBar;
import android.widget.SearchView;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class WebViewActivity extends AppCompatActivity {

    WebView webView;
    InAppBrowserWebViewClient inAppBrowserWebViewClient;
    InAppBrowserWebChromeClient inAppBrowserWebChromeClient;
    SearchView searchView;
    InAppBrowserOptions options;
    ProgressBar progressBar;
    public boolean isLoading = false;

    @RequiresApi(api = Build.VERSION_CODES.KITKAT)
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_web_view);

        webView = findViewById(R.id.webView);
        progressBar = findViewById(R.id.progressBar);
        progressBar.setMax(100);

        Bundle b = getIntent().getExtras();
        String url = b.getString("url");

        options = new InAppBrowserOptions();
        options.parse((HashMap<String, Object>) b.getSerializable("options"));
        InAppBrowser.webViewActivity = this;

        prepareWebView();

        webView.loadUrl(url);

    }

    public void prepareWebView() {

        inAppBrowserWebChromeClient = new InAppBrowserWebChromeClient(this);
        webView.setWebChromeClient(inAppBrowserWebChromeClient);

        inAppBrowserWebViewClient = new InAppBrowserWebViewClient(this);
        webView.setWebViewClient(inAppBrowserWebViewClient);

        WebSettings settings = webView.getSettings();

        settings.setJavaScriptEnabled(options.javaScriptEnabled);
        settings.setJavaScriptCanOpenWindowsAutomatically(options.javaScriptCanOpenWindowsAutomatically);
        settings.setBuiltInZoomControls(options.builtInZoomControls);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            settings.setSafeBrowsingEnabled(options.safeBrowsingEnabled);
        }

        settings.setMediaPlaybackRequiresUserGesture(options.mediaPlaybackRequiresUserGesture);

        settings.setDatabaseEnabled(options.databaseEnabled);
        settings.setDomStorageEnabled(options.domStorageEnabled);

        if (!options.userAgent.isEmpty()) {
            settings.setUserAgentString(options.userAgent);
        }

        if (options.clearCache) {
            clearCache();
        } else if (options.clearSessionCache) {
            CookieManager.getInstance().removeSessionCookie();
        }

        // Enable Thirdparty Cookies on >=Android 5.0 device
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
          CookieManager.getInstance().setAcceptThirdPartyCookies(webView,true);
        }

        settings.setLoadWithOverviewMode(true);
        settings.setUseWideViewPort(options.useWideViewPort);
        settings.setSupportZoom(options.supportZoom);

    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        MenuInflater inflater = getMenuInflater();
        // Inflate menu to add items to action bar if it is present.
        inflater.inflate(R.menu.menu_main, menu);

        searchView = (SearchView) menu.findItem(R.id.menu_search).getActionView();
        searchView.setQuery(webView.getUrl(), false);
        getSupportActionBar().setTitle(webView.getTitle());

        searchView.setOnQueryTextListener(new SearchView.OnQueryTextListener() {
            @Override
            public boolean onQueryTextSubmit(String query) {
                webView.loadUrl(query);
                return false;
            }

            @Override
            public boolean onQueryTextChange(String newText) {
                return false;
            }
        });

        return true;
    }

    public void loadUrl (String url, MethodChannel.Result result) {
        if (webView != null && !url.isEmpty()) {
            webView.loadUrl(url);
        }
        else {
            result.error("Cannot load url", "", null);
        }
    }

    public void loadUrl (String url, Map<String, String> headers, MethodChannel.Result result) {
        if (webView != null && !url.isEmpty()) {
            webView.loadUrl(url, headers);
        }
        else {
            result.error("Cannot load url", "", null);
        }
    }

    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if ((keyCode == KeyEvent.KEYCODE_BACK)) {
            goBack();
            return true;
        }
        return super.onKeyDown(keyCode, event);
    }

//    @TargetApi(Build.VERSION_CODES.KITKAT)
//    void eval(MethodCall call, final MethodChannel.Result result) {
//        String code = call.argument("code");
//
//        webView.evaluateJavascript(code, new ValueCallback<String>() {
//            @Override
//            public void onReceiveValue(String value) {
//                result.success(value);
//            }
//        });
//    }

    public void close() {
        finish();
    }

    public void reload() {
        if (webView != null)
            webView.reload();
    }

    public void goBack() {
        if (webView != null && canGoBack())
            webView.goBack();
    }

    public void goForward() {
        if (webView != null && canGoForward())
            webView.goForward();
    }

    public boolean canGoBack() {
        return webView.canGoBack();
    }

    public boolean canGoForward() {
        return webView.canGoForward();
    }

    public void hide() {
        if (webView != null)
            webView.setVisibility(View.INVISIBLE);
    }
    public void show() {
        if (webView != null)
            webView.setVisibility(View.VISIBLE);
    }

    public boolean isLoading() {
        if (webView != null)
            return isLoading;
        return false;
    }

    public void stopLoading(){
        if (webView != null)
            webView.stopLoading();
    }

    private void clearCookies() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            CookieManager.getInstance().removeAllCookies(new ValueCallback<Boolean>() {
                @Override
                public void onReceiveValue(Boolean aBoolean) {

                }
            });
        } else {
            CookieManager.getInstance().removeAllCookie();
        }
    }

    private void clearCache() {
        webView.clearCache(true);
        clearCookies();
        webView.clearFormData();
    }

    public void goBackButtonClicked(MenuItem item) {
        goBack();
    }

    public void goForwardButtonClicked(MenuItem item) {
        goForward();
    }

    public void shareButtonClicked(MenuItem item) {
        Intent share = new Intent(Intent.ACTION_SEND);
        share.setType("text/plain");
        share.putExtra(Intent.EXTRA_TEXT, webView.getUrl());
        startActivity(Intent.createChooser(share, "Share"));
    }

    public void reloadButtonClicked(MenuItem item) {
        reload();
    }

    public void closeButtonClicked(MenuItem item) {
        close();
    }

}
