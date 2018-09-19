package com.pichillilorenzo.flutter_inappbrowser;

import android.app.SearchManager;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.support.annotation.RequiresApi;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.webkit.WebView;
import android.widget.EditText;
import android.widget.SearchView;

import java.util.HashMap;

public class WebViewActivity extends AppCompatActivity {

    WebView wv;
    SearchView searchView;
    InAppBrowserOptions options;

    @RequiresApi(api = Build.VERSION_CODES.KITKAT)
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Bundle b = getIntent().getExtras();
        String url = b.getString("url");

        options = new InAppBrowserOptions();
        options.parse((HashMap<String, Object>) b.getSerializable("options"));

        setContentView(R.layout.activity_web_view);
        wv = (WebView) findViewById(R.id.webView);

        InAppBrowser.webViewActivity = this;

        wv.loadUrl(url);
        getSupportActionBar().setTitle(wv.getTitle());

    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        MenuInflater inflater = getMenuInflater();
        // Inflate menu to add items to action bar if it is present.
        inflater.inflate(R.menu.menu_main, menu);

        searchView = (SearchView) menu.findItem(R.id.menu_search).getActionView();
        searchView.setQuery(wv.getUrl(), false);
        getSupportActionBar().setTitle(wv.getTitle());

        searchView.setOnQueryTextListener(new SearchView.OnQueryTextListener() {
            @Override
            public boolean onQueryTextSubmit(String query) {
                wv.loadUrl(query);
                return false;
            }

            @Override
            public boolean onQueryTextChange(String newText) {
                return false;
            }
        });

        return true;
    }

}
