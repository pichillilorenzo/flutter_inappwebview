package com.pichillilorenzo.flutter_inappbrowser;

import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Build;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
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
    ActionBar actionBar;
    InAppBrowserWebViewClient inAppBrowserWebViewClient;
    InAppBrowserWebChromeClient inAppBrowserWebChromeClient;
    SearchView searchView;
    InAppBrowserOptions options;
    ProgressBar progressBar;
    public boolean isLoading = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_web_view);

        webView = findViewById(R.id.webView);

        Bundle b = getIntent().getExtras();
        String url = b.getString("url");

        options = new InAppBrowserOptions();
        options.parse((HashMap<String, Object>) b.getSerializable("options"));

        InAppBrowserFlutterPlugin.webViewActivity = this;

        actionBar = getSupportActionBar();

        prepareWebView();

        webView.loadUrl(url);

    }

    public void prepareWebView() {

        inAppBrowserWebChromeClient = new InAppBrowserWebChromeClient(this);
        webView.setWebChromeClient(inAppBrowserWebChromeClient);

        inAppBrowserWebViewClient = new InAppBrowserWebViewClient(this);
        webView.setWebViewClient(inAppBrowserWebViewClient);

//        final Activity activity = this;
//
//        webView.setDownloadListener(new DownloadListener() {
//            @Override
//            public void onDownloadStart(final String url, final String userAgent,
//                                        final String contentDisposition, final String mimetype,
//                                        final long contentLength) {
//
//                RequestPermissionHandler.checkAndRun(activity, Manifest.permission.WRITE_EXTERNAL_STORAGE, RequestPermissionHandler.REQUEST_CODE_WRITE_EXTERNAL_STORAGE, new Runnable(){
//                    @Override
//                    public void run(){
//                        DownloadManager.Request request = new DownloadManager.Request(
//                                Uri.parse(url));
//
//                        final String filename = URLUtil.guessFileName(url, contentDisposition, mimetype);
//                        request.allowScanningByMediaScanner();
//                        request.setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED); //Notify client once download is completed!
//                        request.setVisibleInDownloadsUi(true);
//                        request.setDestinationInExternalPublicDir(Environment.DIRECTORY_DOWNLOADS, filename);
//                        DownloadManager dm = (DownloadManager) getSystemService(DOWNLOAD_SERVICE);
//                        if (dm != null) {
//                            dm.enqueue(request);
//                            Toast.makeText(getApplicationContext(), "Downloading File: " + filename, //To notify the Client that the file is being downloaded
//                                    Toast.LENGTH_LONG).show();
//                        }
//                        else {
//                            Toast.makeText(getApplicationContext(), "Cannot Download File: " + filename, //To notify the Client that the file cannot be downloaded
//                                    Toast.LENGTH_LONG).show();
//                        }
//                    }
//                });
//            }
//        });

        WebSettings settings = webView.getSettings();

        if (options.hidden)
            hide();
        else
            show();

        settings.setJavaScriptEnabled(options.javaScriptEnabled);
        settings.setJavaScriptCanOpenWindowsAutomatically(options.javaScriptCanOpenWindowsAutomatically);
        settings.setBuiltInZoomControls(options.builtInZoomControls);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
            settings.setSafeBrowsingEnabled(options.safeBrowsingEnabled);

        settings.setMediaPlaybackRequiresUserGesture(options.mediaPlaybackRequiresUserGesture);

        settings.setDatabaseEnabled(options.databaseEnabled);
        settings.setDomStorageEnabled(options.domStorageEnabled);

        if (!options.userAgent.isEmpty())
            settings.setUserAgentString(options.userAgent);

        if (options.clearCache)
            clearCache();
        else if (options.clearSessionCache)
            CookieManager.getInstance().removeSessionCookie();

        // Enable Thirdparty Cookies on >=Android 5.0 device
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
          CookieManager.getInstance().setAcceptThirdPartyCookies(webView,true);

        settings.setLoadWithOverviewMode(true);
        settings.setUseWideViewPort(options.useWideViewPort);
        settings.setSupportZoom(options.supportZoom);

        // fix webview scaling
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT)
            settings.setLayoutAlgorithm(WebSettings.LayoutAlgorithm.TEXT_AUTOSIZING);
        else
            settings.setTextZoom(100);

        if (options.progressBar) {
            progressBar = findViewById(R.id.progressBar);
            progressBar.setMax(100);
        }

        actionBar.setDisplayShowTitleEnabled(!options.hideTitleBar);

        if (!options.toolbarTop)
            actionBar.hide();

        if (!options.toolbarTopBackgroundColor.isEmpty())
            actionBar.setBackgroundDrawable(new ColorDrawable(Color.parseColor(options.toolbarTopBackgroundColor)));

        if (!options.toolbarTopFixedTitle.isEmpty())
            actionBar.setTitle(options.toolbarTopFixedTitle);

    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        MenuInflater inflater = getMenuInflater();
        // Inflate menu to add items to action bar if it is present.
        inflater.inflate(R.menu.menu_main, menu);

        searchView = (SearchView) menu.findItem(R.id.menu_search).getActionView();
        searchView.setFocusable(true);

        if (options.hideUrlBar)
            menu.findItem(R.id.menu_search).setVisible(false);

        searchView.setQuery(webView.getUrl(), false);

        if (options.toolbarTopFixedTitle.isEmpty())
            actionBar.setTitle(webView.getTitle());

        searchView.setOnQueryTextListener(new SearchView.OnQueryTextListener() {
            @Override
            public boolean onQueryTextSubmit(String query) {
                if (!query.isEmpty()) {
                    webView.loadUrl(query);
                    searchView.setQuery("", false);
                    searchView.setIconified(true);
                    return true;
                }
                return false;
            }

            @Override
            public boolean onQueryTextChange(String newText) {
                return false;
            }

        });

        searchView.setOnCloseListener(new SearchView.OnCloseListener() {
            @Override
            public boolean onClose() {
                if (searchView.getQuery().toString().isEmpty())
                    searchView.setQuery(webView.getUrl(), false);
                return false;
            }
        });

        searchView.setOnQueryTextFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View view, boolean b) {
                if (!b) {
                    searchView.setQuery("", false);
                    searchView.setIconified(true);
                }
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
            if (canGoBack())
                goBack();
            else if (options.closeOnCannotGoBack)
                close();
            return true;
        }
        return super.onKeyDown(keyCode, event);
    }

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
