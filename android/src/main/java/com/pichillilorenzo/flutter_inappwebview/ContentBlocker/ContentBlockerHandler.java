package com.pichillilorenzo.flutter_inappwebview.ContentBlocker;

import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.webkit.WebResourceResponse;

import com.pichillilorenzo.flutter_inappwebview.InAppWebView.InAppWebView;
import com.pichillilorenzo.flutter_inappwebview.Util;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.CountDownLatch;
import java.util.regex.Matcher;

import io.flutter.plugin.common.MethodChannel;
import okhttp3.Request;
import okhttp3.Response;

public class ContentBlockerHandler {
    protected static final String LOG_TAG = "ContentBlockerHandler";

    protected List<ContentBlocker> ruleList = new ArrayList<>();

    public ContentBlockerHandler() {}

    public ContentBlockerHandler(List<ContentBlocker> ruleList) {
        this.ruleList = ruleList;
    }

    public List<ContentBlocker> getRuleList() {
        return this.ruleList;
    }

    public void setRuleList(List<ContentBlocker> newRuleList) {
        this.ruleList = newRuleList;
    }

    public WebResourceResponse checkUrl(final InAppWebView webView, String url, ContentBlockerTriggerResourceType responseResourceType) throws URISyntaxException, InterruptedException, MalformedURLException {
        if (webView.options.contentBlockers == null)
            return null;

        URI u;
        try {
            u = new URI(url);
        } catch (URISyntaxException e) {
            String[] urlSplitted = url.split(":");
            String scheme = urlSplitted[0];
            URL tempUrl = new URL(url.replace(scheme, "https"));
            u = new URI(scheme, tempUrl.getUserInfo(), tempUrl.getHost(), tempUrl.getPort(), tempUrl.getPath(), tempUrl.getQuery(), tempUrl.getRef());
        }
        String host = u.getHost();
        int port = u.getPort();
        String scheme = u.getScheme();
        // thread safe copy list
        List<ContentBlocker> ruleListCopy = new CopyOnWriteArrayList<ContentBlocker>(ruleList);

        for (ContentBlocker contentBlocker : ruleListCopy) {
            ContentBlockerTrigger trigger =  contentBlocker.trigger;
            List<ContentBlockerTriggerResourceType> resourceTypes = trigger.resourceType;
            if (resourceTypes.contains(ContentBlockerTriggerResourceType.IMAGE) && !resourceTypes.contains(ContentBlockerTriggerResourceType.SVG_DOCUMENT)) {
                resourceTypes.add(ContentBlockerTriggerResourceType.SVG_DOCUMENT);
            }

            ContentBlockerAction action = contentBlocker.action;

            Matcher m = trigger.urlFilterPatternCompiled.matcher(url);
            if (m.matches()) {

                if (!resourceTypes.isEmpty() && !resourceTypes.contains(responseResourceType)) {
                    return null;
                }
                if (!trigger.ifDomain.isEmpty()) {
                    boolean matchFound = false;
                    for (String domain : trigger.ifDomain) {
                        if ((domain.startsWith("*") && host.endsWith(domain.replace("*", ""))) || domain.equals(host)) {
                            matchFound = true;
                            break;
                        }
                    }
                    if (!matchFound)
                        return null;
                }
                if (!trigger.unlessDomain.isEmpty()) {
                    for (String domain : trigger.unlessDomain)
                        if ((domain.startsWith("*") && host.endsWith(domain.replace("*", ""))) || domain.equals(host))
                            return null;
                }

                final String[] webViewUrl = new String[1];
                if (!trigger.loadType.isEmpty() || !trigger.ifTopUrl.isEmpty() || !trigger.unlessTopUrl.isEmpty()) {
                    final CountDownLatch latch = new CountDownLatch(1);
                    Handler handler = new Handler(Looper.getMainLooper());
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            webViewUrl[0] = webView.getUrl();
                            latch.countDown();
                        }
                    });
                    latch.await();
                }

                if (!trigger.loadType.isEmpty()) {
                    URI cUrl = new URI(webViewUrl[0]);
                    String cHost = cUrl.getHost();
                    int cPort = cUrl.getPort();
                    String cScheme = cUrl.getScheme();

                    if ( (trigger.loadType.contains("first-party") && cHost != null && !(cScheme.equals(scheme) && cHost.equals(host) && cPort == port)) ||
                            (trigger.loadType.contains("third-party") && cHost != null && cHost.equals(host)) )
                        return null;
                }
                if (!trigger.ifTopUrl.isEmpty()) {
                    boolean matchFound = false;
                    for (String topUrl : trigger.ifTopUrl) {
                        if (webViewUrl[0].startsWith(topUrl)) {
                            matchFound = true;
                            break;
                        }
                    }
                    if (!matchFound)
                        return null;
                }
                if (!trigger.unlessTopUrl.isEmpty()) {
                    for (String topUrl : trigger.unlessTopUrl)
                        if (webViewUrl[0].startsWith(topUrl))
                            return null;
                }

                switch (action.type) {

                    case BLOCK:
                        return new WebResourceResponse("", "", null);

                    case CSS_DISPLAY_NONE:
                        final String jsScript = "function hide () { document.querySelectorAll('" + action.selector + "').forEach(function (item, index) { item.style.display = \"none\"; }); }; hide(); document.addEventListener(\"DOMContentLoaded\", function(event) { hide(); });";
                        final Handler handler = new Handler(Looper.getMainLooper());
                        Log.d(LOG_TAG, jsScript);
                        handler.post(new Runnable() {
                            @Override
                            public void run() {
                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                                    webView.evaluateJavascript(jsScript, (MethodChannel.Result) null);
                                } else {
                                    webView.loadUrl("javascript:" + jsScript);
                                }
                            }
                        });
                        break;

                    case MAKE_HTTPS:
                        if (scheme.equals("http") && (port == -1 || port == 80)) {
                            String urlHttps = url.replace("http://", "https://");

                            Request mRequest = new Request.Builder().url(urlHttps).build();
                            Response response = null;

                            try {
                                response = Util.getUnsafeOkHttpClient().newCall(mRequest).execute();
                                byte[] dataBytes = response.body().bytes();
                                InputStream dataStream = new ByteArrayInputStream(dataBytes);

                                String[] contentTypeSplitted = response.header("content-type", "text/plain").split(";");

                                String contentType = contentTypeSplitted[0].trim();
                                String encoding = (contentTypeSplitted.length > 1 && contentTypeSplitted[1].contains("charset="))
                                        ? contentTypeSplitted[1].replace("charset=", "").trim()
                                        : "utf-8";

                                response.body().close();
                                response.close();

                                return new WebResourceResponse(contentType, encoding, dataStream);

                            } catch (Exception e) {
                                e.printStackTrace();
                                if (response != null) {
                                    response.body().close();
                                    response.close();
                                }
                                Log.e(LOG_TAG, e.getMessage());
                            }
                        }
                        break;
                }
            }
        }
        return null;
    }

    public WebResourceResponse checkUrl(final InAppWebView webView, String url) throws URISyntaxException, InterruptedException, MalformedURLException {
        ContentBlockerTriggerResourceType responseResourceType = getResourceTypeFromUrl(url);
        return checkUrl(webView, url, responseResourceType);
    }

    public WebResourceResponse checkUrl(final InAppWebView webView, String url, String contentType) throws URISyntaxException, InterruptedException, MalformedURLException {
        ContentBlockerTriggerResourceType responseResourceType = getResourceTypeFromContentType(contentType);
        return checkUrl(webView, url, responseResourceType);
    }

    public ContentBlockerTriggerResourceType getResourceTypeFromUrl(String url) {
        ContentBlockerTriggerResourceType responseResourceType = ContentBlockerTriggerResourceType.RAW;

        if (url.startsWith("http://") || url.startsWith("https://")) {
            // make an HTTP "HEAD" request to the server for that URL. This will not return the full content of the URL.
            Request mRequest = new Request.Builder().url(url).head().build();
            Response response = null;
            try {
                response = Util.getUnsafeOkHttpClient().newCall(mRequest).execute();

                if (response.header("content-type") != null) {
                    String[] contentTypeSplitted = response.header("content-type").split(";");

                    String contentType = contentTypeSplitted[0].trim();
                    String encoding = (contentTypeSplitted.length > 1 && contentTypeSplitted[1].contains("charset="))
                            ? contentTypeSplitted[1].replace("charset=", "").trim()
                            : "utf-8";

                    response.body().close();
                    response.close();
                    responseResourceType = getResourceTypeFromContentType(contentType);
                }

            } catch (Exception e) {
                if (response != null) {
                    response.body().close();
                    response.close();
                }
                e.printStackTrace();
                Log.e(LOG_TAG, e.getMessage());
            }
        }
        return responseResourceType;
    }

    public ContentBlockerTriggerResourceType getResourceTypeFromContentType(String contentType) {
        ContentBlockerTriggerResourceType responseResourceType = ContentBlockerTriggerResourceType.RAW;

        // https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types
        if (contentType.equals("text/css")) {
            responseResourceType = ContentBlockerTriggerResourceType.STYLE_SHEET;
        } else if (contentType.equals("image/svg+xml")) {
            responseResourceType = ContentBlockerTriggerResourceType.SVG_DOCUMENT;
        } else if (contentType.startsWith("image/")) {
            responseResourceType = ContentBlockerTriggerResourceType.IMAGE;
        } else if (contentType.startsWith("font/")) {
            responseResourceType = ContentBlockerTriggerResourceType.FONT;
        } else if (contentType.startsWith("audio/") || contentType.startsWith("video/") || contentType.equals("application/ogg")) {
            responseResourceType = ContentBlockerTriggerResourceType.MEDIA;
        } else if (contentType.endsWith("javascript")) {
            responseResourceType = ContentBlockerTriggerResourceType.SCRIPT;
        } else if (contentType.startsWith("text/")) {
            responseResourceType = ContentBlockerTriggerResourceType.DOCUMENT;
        }

        return responseResourceType;
    }
}
