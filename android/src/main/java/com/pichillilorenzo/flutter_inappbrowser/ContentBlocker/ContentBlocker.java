package com.pichillilorenzo.flutter_inappbrowser.ContentBlocker;

import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.webkit.WebResourceResponse;

import com.pichillilorenzo.flutter_inappbrowser.InAppWebView.InAppWebView;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import okhttp3.Request;
import okhttp3.Response;

public class ContentBlocker {
    protected static final String LOG_TAG = "ContentBlocker";

    public static WebResourceResponse checkUrl(final InAppWebView webView, String url, ContentBlockerTriggerResourceType responseResourceType) {
        if (webView.options.contentBlockers == null)
            return null;

        for (Map<String, Map<String, Object>> contentBlocker : webView.options.contentBlockers) {
            ContentBlockerTrigger trigger =  ContentBlockerTrigger.fromMap(contentBlocker.get("trigger"));
            List<ContentBlockerTriggerResourceType> resourceTypes = trigger.resourceType;

            ContentBlockerAction action = ContentBlockerAction.fromMap(contentBlocker.get("action"));

            Pattern mPattern = Pattern.compile(trigger.urlFilter);
            Matcher m = mPattern.matcher(url);

            if (m.matches()) {
                Log.d(LOG_TAG, url);
                Log.d(LOG_TAG, responseResourceType.toString());
                Log.d(LOG_TAG, resourceTypes.toString());

                if (resourceTypes != null && resourceTypes.size() > 0 && !resourceTypes.contains(responseResourceType)) {
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
                                    webView.evaluateJavascript(jsScript, null);
                                } else {
                                    webView.loadUrl("javascript:" + jsScript);
                                }
                            }
                        });
                        break;

                    case MAKE_HTTPS:
                        if (url.startsWith("http://")) {
                            String urlHttps = url.replace("http://", "https://");

                            Request mRequest = new Request.Builder().url(urlHttps).build();
                            Response response = null;

                            try {

                                response = webView.httpClient.newCall(mRequest).execute();
                                byte[] dataBytes = response.body().bytes();
                                InputStream dataStream = new ByteArrayInputStream(dataBytes);

                                String[] contentTypeSplitted = response.header("content-type", "text/plain").split(";");

                                String contentType = contentTypeSplitted[0].trim();
                                String encoding = (contentTypeSplitted.length > 1 && contentTypeSplitted[1].contains("charset="))
                                        ? contentTypeSplitted[1].replace("charset=", "").trim()
                                        : "utf-8";

                                response.close();

                                return new WebResourceResponse(contentType, encoding, dataStream);

                            } catch (IOException e) {
                                e.printStackTrace();
                                if (response != null) {
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

    public static WebResourceResponse checkUrl(final InAppWebView webView, String url) {
        ContentBlockerTriggerResourceType responseResourceType = getResourceTypeFromUrl(webView, url);
        return checkUrl(webView, url, responseResourceType);
    }

    public static WebResourceResponse checkUrl(final InAppWebView webView, String url, String contentType) {
        ContentBlockerTriggerResourceType responseResourceType = getResourceTypeFromContentType(contentType);
        return checkUrl(webView, url, responseResourceType);
    }


    public static ContentBlockerTriggerResourceType getResourceTypeFromUrl(InAppWebView webView, String url) {
        ContentBlockerTriggerResourceType responseResourceType = ContentBlockerTriggerResourceType.RAW;

        // make an HTTP "HEAD" request to the server for that URL. This will not return the full content of the URL.
        if (url.startsWith("http://") || url.startsWith("https://")) {
            Request mRequest = new Request.Builder().url(url).head().build();
            Response response = null;
            try {
                response = webView.httpClient.newCall(mRequest).execute();

                if (response.header("content-type") != null) {
                    String[] contentTypeSplitted = response.header("content-type").split(";");

                    String contentType = contentTypeSplitted[0].trim();
                    String encoding = (contentTypeSplitted.length > 1 && contentTypeSplitted[1].contains("charset="))
                            ? contentTypeSplitted[1].replace("charset=", "").trim()
                            : "utf-8";

                    response.close();
                    responseResourceType = getResourceTypeFromContentType(contentType);
                }

            } catch (IOException e) {
                if (response != null) {
                    response.close();
                }
                e.printStackTrace();
            }
        }
        return responseResourceType;
    }

    public static ContentBlockerTriggerResourceType getResourceTypeFromContentType(String contentType) {
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
