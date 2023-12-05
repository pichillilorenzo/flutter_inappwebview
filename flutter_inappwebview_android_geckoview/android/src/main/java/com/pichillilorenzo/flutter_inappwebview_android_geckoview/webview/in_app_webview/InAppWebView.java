package com.pichillilorenzo.flutter_inappwebview_android_geckoview.webview.in_app_webview;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Point;
import android.net.Uri;
import android.net.http.SslCertificate;
import android.os.Handler;
import android.os.Looper;
import android.util.AttributeSet;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewParent;
import android.webkit.ValueCallback;
import android.webkit.WebMessage;
import android.webkit.WebView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.pichillilorenzo.flutter_inappwebview_android_geckoview.InAppWebViewFlutterPlugin;
import com.pichillilorenzo.flutter_inappwebview_android_geckoview.Util;
import com.pichillilorenzo.flutter_inappwebview_android_geckoview.find_interaction.FindInteractionController;
import com.pichillilorenzo.flutter_inappwebview_android_geckoview.in_app_browser.InAppBrowserDelegate;
import com.pichillilorenzo.flutter_inappwebview_android_geckoview.print_job.PrintJobSettings;
import com.pichillilorenzo.flutter_inappwebview_android_geckoview.pull_to_refresh.PullToRefreshLayout;
import com.pichillilorenzo.flutter_inappwebview_android_geckoview.types.ContentWorld;
import com.pichillilorenzo.flutter_inappwebview_android_geckoview.types.HitTestResult;
import com.pichillilorenzo.flutter_inappwebview_android_geckoview.types.URLRequest;
import com.pichillilorenzo.flutter_inappwebview_android_geckoview.types.UserContentController;
import com.pichillilorenzo.flutter_inappwebview_android_geckoview.types.UserScript;
import com.pichillilorenzo.flutter_inappwebview_android_geckoview.webview.InAppWebViewManager;
import com.pichillilorenzo.flutter_inappwebview_android_geckoview.webview.WebViewChannelDelegate;

import org.mozilla.geckoview.GeckoResult;
import org.mozilla.geckoview.GeckoRuntime;
import org.mozilla.geckoview.GeckoSession;
import org.mozilla.geckoview.PanZoomController;
import org.mozilla.geckoview.ScreenLength;
import org.mozilla.geckoview.StorageController;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

final public class InAppWebView extends InputAwareWebView {
  protected static final String LOG_TAG = "InAppWebView";
  public static final String METHOD_CHANNEL_NAME_PREFIX = "com.pichillilorenzo/flutter_inappwebview_gecko_";

  @Nullable
  public InAppWebViewFlutterPlugin plugin;
  @Nullable
  public InAppBrowserDelegate inAppBrowserDelegate;
  public Object id;
  @Nullable
  public Integer windowId;
  @Nullable
  public WebViewChannelDelegate channelDelegate;
  public InAppWebViewSettings customSettings = new InAppWebViewSettings();
  @Nullable
  public Map<String, Object> contextMenu = null;
  @Nullable
  public String lastSearchString;
  public Handler mainLooperHandler = new Handler(Looper.getMainLooper());
  @Nullable
  public FindInteractionController findInteractionController;

  public InAppWebView(Context context) {
    super(context);
  }

  public InAppWebView(Context context, AttributeSet attrs) {
    super(context, attrs);
  }

  public InAppWebView(Context context, @NonNull InAppWebViewFlutterPlugin plugin,
                      @NonNull Object id, @Nullable Integer windowId, InAppWebViewSettings customSettings,
                      @Nullable Map<String, Object> contextMenu, View containerView,
                      List<UserScript> userScripts) {
    super(context, containerView, customSettings.useHybridComposition);
    this.plugin = plugin;
    this.id = id;
    final MethodChannel channel = new MethodChannel(plugin.messenger, METHOD_CHANNEL_NAME_PREFIX + id);
    this.channelDelegate = new WebViewChannelDelegate(this, channel);
    this.windowId = windowId;
    this.customSettings = customSettings;
    this.contextMenu = contextMenu;
    if (plugin != null && plugin.activity != null) {
      plugin.activity.registerForContextMenu(this);
    }
  }

  public void prepare() {
    if (InAppWebViewManager.geckoRuntime == null || plugin == null) {
      Log.d(LOG_TAG, "InAppWebViewManager.geckoRuntime is null or plugin is null");
      return;
    }

    GeckoSession session = new GeckoSession();

    session.setContentDelegate(new InAppWebViewContentDelegate(plugin, this));
    session.setNavigationDelegate(new InAppWebViewNavigationDelegate(plugin, this));
    session.setProgressDelegate(new InAppWebViewProgressDelegate(plugin, this));
    session.setHistoryDelegate(new InAppWebViewHistoryDelegate(plugin, this));
    session.setScrollDelegate(new InAppWebViewScrollDelegate(plugin, this));

    session.open(InAppWebViewManager.geckoRuntime);
    setSession(session);
  }

  @Nullable
  public PanZoomController.InputResultDetail inputResultDetail;

  @SuppressLint("ClickableViewAccessibility")
  @Override
  public boolean onTouchEvent(MotionEvent ev) {
    MotionEvent event = MotionEvent.obtain(ev);
    if (ev.getActionMasked() == MotionEvent.ACTION_DOWN) {
      onTouchEventForDetailResult(event).accept(detail -> {
        inputResultDetail = detail;
      });
      event.recycle();
      return true;
    }
    boolean eventHandled = super.onTouchEvent(event);
    event.recycle();
    return eventHandled;
  }

  @Nullable
  public String getUrl() {
    InAppWebViewProgressDelegate progressDelegate = getProgressDelegate();
    if (progressDelegate == null) {
      return null;
    }
    return progressDelegate.currentUrl;
  }

  @Nullable
  public String getTitle() {
    InAppWebViewContentDelegate contentDelegate = getContentDelegate();
    if (contentDelegate == null) {
      return null;
    }
    return contentDelegate.currentTitle;
  }

  public int getProgress() {
    return 0;
  }

  public void loadUrl(URLRequest urlRequest) {
    GeckoSession session = getSession();
    String url = urlRequest.getUrl();
    if (session == null || url == null) {
      return;
    }

    String method = urlRequest.getMethod();
    if (method != null && method.equals("POST")) {
      byte[] postData = urlRequest.getBody();
      postUrl(url, postData);
      return;
    }

    GeckoSession.Loader loader = new GeckoSession.Loader();
    loader.uri(url);
    Map<String, String> headers = urlRequest.getHeaders();
    if (headers != null) {
      loader.additionalHeaders(headers);
    }

    session.load(loader);
  }

  public void loadUrl(@NonNull String url) {
    GeckoSession session = getSession();
    if (session == null) {
      return;
    }

    GeckoSession.Loader loader = new GeckoSession.Loader().uri(url);
    session.load(loader);
  }

  public void postUrl(@NonNull String url, byte[] postData) {
    GeckoSession session = getSession();
    if (session == null) {
      return;
    }

    String data = new String(postData, StandardCharsets.UTF_8);
    String[] queryParameters = data.split("&");

    String source = "(function() { const postForm = document.createElement('FORM');" +
            "postForm.style = 'display: none;';" +
            "postForm.method = 'POST';" +
            "postForm.action = '" + url.replaceAll("'", "\\\\'") + "';";
    int count = 0;
    for (String queryParameter : queryParameters) {
      String[] queryParameterSplitted = queryParameter.split("=", 2);
      String name = queryParameterSplitted[0].replaceAll("'", "\\\\'");
      String value = queryParameterSplitted.length > 1 ? queryParameterSplitted[1].replaceAll("'", "\\\\'") : "";
      source += "const postFormInput" + count + " = document.createElement('INPUT');" +
              "postFormInput" + count + ".setAttribute('type', 'hidden');" +
              "postFormInput" + count + ".setAttribute('name', '" + name + "');" +
              "postFormInput" + count + ".setAttribute('value', '" + value + "');" +
              "postForm.appendChild(postFormInput" + count + ");";
      count++;
    }
    source += "document.body.appendChild(postForm);" +
            "postForm.submit();" +
            "document.body.removeChild(postForm);" +
            "})();";
    GeckoSession.Loader loader = new GeckoSession.Loader()
            .uri("javascript:" + source);
    session.load(loader);
  }

  public void loadDataWithBaseURL(String baseUrl, String data, String mimeType, String encoding, String historyUrl) {
    GeckoSession session = getSession();
    if (session == null) {
      return;
    }

    if (!baseUrl.isEmpty() && !baseUrl.equals("about:blank")) {
      data = data.replaceFirst("<head>", "<head><base href=\"" + baseUrl + "\">");
    }
    GeckoSession.Loader loader = new GeckoSession.Loader()
            .data(data, mimeType);
    session.load(loader);
  }

  public void loadFile(String assetFilePath) throws IOException {
    if (plugin == null) {
      return;
    }

    loadUrl(Util.getUrlAsset(plugin, assetFilePath));
  }

  public void evaluateJavascript(String source, ContentWorld contentWorld, ValueCallback<String> resultCallback) {

  }

  public void injectJavascriptFileFromUrl(String urlFile, Map<String, Object> scriptHtmlTagAttributes) {

  }

  public void injectCSSCode(String source) {

  }

  public void injectCSSFileFromUrl(String urlFile, Map<String, Object> cssLinkHtmlTagAttributes) {

  }

  public void reload() {
    GeckoSession session = getSession();
    if (session != null) {
      session.reload();
    }
  }

  public void goBack() {
    GeckoSession session = getSession();
    if (session != null) {
      session.goBack();
    }
  }

  public boolean canGoBack() {
    InAppWebViewNavigationDelegate navigationDelegate = getNavigationDelegate();
    if (navigationDelegate == null) {
      return false;
    }
    return navigationDelegate.canGoBack;
  }

  public void goForward() {
    GeckoSession session = getSession();
    if (session != null) {
      session.goForward();
    }
  }

  public boolean canGoForward() {
    InAppWebViewNavigationDelegate navigationDelegate = getNavigationDelegate();
    if (navigationDelegate == null) {
      return false;
    }
    return navigationDelegate.canGoForward;
  }

  public void goBackOrForward(int steps) {
    GeckoSession session = getSession();
    InAppWebViewHistoryDelegate historyDelegate = getHistoryDelegate();
    if (session == null || historyDelegate == null) {
      return;
    }
    GeckoSession.HistoryDelegate.HistoryList historyList = historyDelegate.historyList;
    if (historyList == null) {
      return;
    }

    int currentIndex = historyList.getCurrentIndex();
    session.gotoHistoryIndex(currentIndex + steps);
  }

  public boolean canGoBackOrForward(int steps) {
    GeckoSession session = getSession();
    InAppWebViewHistoryDelegate historyDelegate = getHistoryDelegate();
    if (session == null || historyDelegate == null) {
      return false;
    }
    GeckoSession.HistoryDelegate.HistoryList historyList = historyDelegate.historyList;
    if (historyList == null || historyList.size() > 0) {
      return false;
    }

    if (steps < 0) {
      return historyList.getCurrentIndex() - steps >= 0;
    }
    return historyList.getCurrentIndex() + steps <= historyList.size() - 1;
  }

  public void stopLoading() {
    GeckoSession session = getSession();
    if (session == null) {
      return;
    }

    session.stop();
  }

  public boolean isLoading() {
    InAppWebViewProgressDelegate progressDelegate = getProgressDelegate();
    if (progressDelegate == null) {
      return false;
    }
    return progressDelegate.isLoading;
  }

  public void takeScreenshot(Map<String, Object> screenshotConfiguration, MethodChannel.Result result) {
    final float pixelDensity = Util.getPixelDensity(getContext());

    mainLooperHandler.post(new Runnable() {
      @Override
      public void run() {

        capturePixels().accept(new GeckoResult.Consumer<Bitmap>() {
          @Override
          public void accept(@Nullable Bitmap screenshotBitmap) {
            if (screenshotBitmap == null) {
              mainLooperHandler.post(new Runnable() {
                @Override
                public void run() {
                  result.success(null);
                }
              });
              return;
            }

            final ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
            Bitmap.CompressFormat compressFormat = Bitmap.CompressFormat.PNG;
            int quality = 100;

            if (screenshotConfiguration != null) {
              Map<String, Double> rect = (Map<String, Double>) screenshotConfiguration.get("rect");
              if (rect != null) {
                int rectX = (int) Math.floor(rect.get("x") * pixelDensity + 0.5);
                int rectY = (int) Math.floor(rect.get("y") * pixelDensity + 0.5);
                int rectWidth = Math.min(screenshotBitmap.getWidth(), (int) Math.floor(rect.get("width") * pixelDensity + 0.5));
                int rectHeight = Math.min(screenshotBitmap.getHeight(), (int) Math.floor(rect.get("height") * pixelDensity + 0.5));
                screenshotBitmap = Bitmap.createBitmap(
                        screenshotBitmap,
                        rectX,
                        rectY,
                        rectWidth,
                        rectHeight);
              }

              Double snapshotWidth = (Double) screenshotConfiguration.get("snapshotWidth");
              if (snapshotWidth != null) {
                int dstWidth = (int) Math.floor(snapshotWidth * pixelDensity + 0.5);
                float ratioBitmap = (float) screenshotBitmap.getWidth() / (float) screenshotBitmap.getHeight();
                int dstHeight = (int) ((float) dstWidth / ratioBitmap);
                screenshotBitmap = Bitmap.createScaledBitmap(screenshotBitmap, dstWidth, dstHeight, true);
              }

              try {
                compressFormat = Bitmap.CompressFormat.valueOf((String) screenshotConfiguration.get("compressFormat"));
              } catch (IllegalArgumentException e) {
                Log.e(LOG_TAG, "", e);
              }

              quality = (Integer) screenshotConfiguration.get("quality");
            }

            int finalQuality = quality;
            Bitmap.CompressFormat finalCompressFormat = compressFormat;
            Bitmap finalScreenshotBitmap = screenshotBitmap;
            mainLooperHandler.post(new Runnable() {
              @Override
              public void run() {
                finalScreenshotBitmap.compress(
                        finalCompressFormat,
                        finalQuality,
                        byteArrayOutputStream);

                try {
                  byteArrayOutputStream.close();
                } catch (IOException e) {
                  Log.e(LOG_TAG, "", e);
                }
                finalScreenshotBitmap.recycle();
                result.success(byteArrayOutputStream.toByteArray());
              }
            });
          }
        }, new GeckoResult.Consumer<Throwable>() {
          @Override
          public void accept(@Nullable Throwable throwable) {
            if (throwable != null) {
              Log.e(LOG_TAG, "", throwable);
            }

            mainLooperHandler.post(new Runnable() {
              @Override
              public void run() {
                result.success(null);
              }
            });
          }
        });
      }
    });
  }

  public void setSettings(InAppWebViewSettings newCustomSettings, HashMap<String, Object> newSettingsMap) {

    customSettings = newCustomSettings;
  }

  public Map<String, Object> getCustomSettings() {
    return (customSettings != null) ? customSettings.getRealSettings(this) : null;
  }

  @Nullable
  public HashMap<String, Object> getCopyBackForwardList() {
    InAppWebViewHistoryDelegate historyDelegate = getHistoryDelegate();
    if (historyDelegate == null) {
      return null;
    }
    GeckoSession.HistoryDelegate.HistoryList historyList = historyDelegate.historyList;
    if (historyList == null) {
      return null;
    }

    int currentIndex = historyList.getCurrentIndex();

    List<HashMap<String, String>> history = new ArrayList<>();

    for (GeckoSession.HistoryDelegate.HistoryItem historyItem : historyList) {
      HashMap<String, String> historyItemMap = new HashMap<>();

      historyItemMap.put("originalUrl", historyItem.getUri());
      historyItemMap.put("title", historyItem.getTitle());
      historyItemMap.put("url", historyItem.getUri());

      history.add(historyItemMap);
    }

    HashMap<String, Object> result = new HashMap<>();

    result.put("list", history);
    result.put("currentIndex", currentIndex);

    return result;
  }

  public void clearAllCache() {
    GeckoRuntime geckoRuntime = InAppWebViewManager.geckoRuntime;
    if (geckoRuntime == null) {
      return;
    }
    geckoRuntime.getStorageController().clearData(StorageController.ClearFlags.ALL);
  }

  public void findAllAsync(String find) {
    GeckoSession session = getSession();
    if (session == null) {
      return;
    }

    lastSearchString = find;
    session.getFinder().find(find, 0).accept(new GeckoResult.Consumer<GeckoSession.FinderResult>() {
      @Override
      public void accept(@Nullable GeckoSession.FinderResult finderResult) {
        if (finderResult != null && finderResult.found) {
          int activeMatchOrdinal = finderResult.current - 1;
          int numberOfMatches = finderResult.total;
          boolean isDoneCounting = finderResult.current == finderResult.total;
          if (findInteractionController != null && findInteractionController.channelDelegate != null)
            findInteractionController.channelDelegate.onFindResultReceived(activeMatchOrdinal, numberOfMatches, isDoneCounting);
          if (channelDelegate != null)
            channelDelegate.onFindResultReceived(activeMatchOrdinal, numberOfMatches, isDoneCounting);
        }
      }
    }, new GeckoResult.Consumer<Throwable>() {
      @Override
      public void accept(@Nullable Throwable throwable) {
        if (throwable != null) {
          Log.e(LOG_TAG, "", throwable);
        }
      }
    });
  }

  public void findNext(boolean forward) {
    GeckoSession session = getSession();
    if (session == null || lastSearchString == null) {
      return;
    }

    int flags = forward ? 0 : GeckoSession.FINDER_FIND_BACKWARDS;

    session.getFinder().find(lastSearchString, flags).accept(new GeckoResult.Consumer<GeckoSession.FinderResult>() {
      @Override
      public void accept(@Nullable GeckoSession.FinderResult finderResult) {
        if (finderResult != null && finderResult.found) {
          int activeMatchOrdinal = finderResult.current - 1;
          int numberOfMatches = finderResult.total;
          boolean isDoneCounting = finderResult.current == finderResult.total;
          if (findInteractionController != null && findInteractionController.channelDelegate != null)
            findInteractionController.channelDelegate.onFindResultReceived(activeMatchOrdinal, numberOfMatches, isDoneCounting);
          if (channelDelegate != null)
            channelDelegate.onFindResultReceived(activeMatchOrdinal, numberOfMatches, isDoneCounting);
        }
      }
    }, new GeckoResult.Consumer<Throwable>() {
      @Override
      public void accept(@Nullable Throwable throwable) {
        if (throwable != null) {
          Log.e(LOG_TAG, "", throwable);
        }
      }
    });
  }

  public void clearMatches() {
    GeckoSession session = getSession();
    if (session == null) {
      return;
    }

    session.getFinder().clear();
  }

  public void scrollTo(Integer x, Integer y, Boolean animated) {
    getPanZoomController().scrollTo(ScreenLength.fromPixels(x),
            ScreenLength.fromPixels(y),
            animated ? PanZoomController.SCROLL_BEHAVIOR_SMOOTH : PanZoomController.SCROLL_BEHAVIOR_AUTO);
  }

  public void scrollBy(Integer x, Integer y, Boolean animated) {
    getPanZoomController().scrollBy(ScreenLength.fromPixels(x),
            ScreenLength.fromPixels(y),
            animated ? PanZoomController.SCROLL_BEHAVIOR_SMOOTH : PanZoomController.SCROLL_BEHAVIOR_AUTO);
  }

  public void onPause() {
    GeckoSession session = getSession();
    if (session == null) {
      return;
    }
    session.setActive(false);
  }

  public void onResume() {
    GeckoSession session = getSession();
    if (session == null) {
      return;
    }
    session.setActive(true);
  }

  @Nullable
  public String printCurrentPage(@Nullable PrintJobSettings settings) {
    GeckoSession session = getSession();
    if (session == null) {
      return null;
    }
    session.getPrintDelegate();
    return null;
  }

  public int getContentHeight() {
    return 0;
  }

  @Override
  protected void onWindowVisibilityChanged(int visibility) {
    if (customSettings.allowBackgroundAudioPlaying) {
      if (visibility != View.GONE) {
        super.onWindowVisibilityChanged(View.VISIBLE);
      }
      return;
    }
    super.onWindowVisibilityChanged(visibility);
  }

  @Nullable
  public Map<String, Object> getContextMenu() {
    return contextMenu;
  }

  public void setContextMenu(@Nullable Map<String, Object> contextMenu) {
    this.contextMenu = contextMenu;
  }

  @Nullable
  public InAppWebViewFlutterPlugin getPlugin() {
    return plugin;
  }

  public void setPlugin(@Nullable InAppWebViewFlutterPlugin plugin) {
    this.plugin = plugin;
  }

  @Nullable
  public InAppBrowserDelegate getInAppBrowserDelegate() {
    return inAppBrowserDelegate;
  }

  public void setInAppBrowserDelegate(@Nullable InAppBrowserDelegate inAppBrowserDelegate) {
    this.inAppBrowserDelegate = inAppBrowserDelegate;
  }

  public UserContentController getUserContentController() {
    return null;
  }

  public void setUserContentController(UserContentController userContentController) {

  }

  public boolean isInFullscreen() {
    InAppWebViewContentDelegate contentDelegate = getContentDelegate();
    if (contentDelegate == null) {
      return false;
    }
    return contentDelegate.fullScreen;
  }

  public void getContentWidth(ValueCallback<Integer> callback) {

  }

  public void zoomBy(float zoomFactor) {

  }

  public String getOriginalUrl() {
    InAppWebViewProgressDelegate progressDelegate = getProgressDelegate();
    if (progressDelegate == null) {
      return null;
    }
    return progressDelegate.currentOriginalUrl;
  }

  public String getSelectedText() {
    InAppWebViewContentDelegate contentDelegate = getContentDelegate();
    if (contentDelegate == null || contentDelegate.lastContextElement == null) {
      return null;
    }
    return contentDelegate.lastContextElement.textContent;
  }

  public WebView.HitTestResult getHitTestResult() {
    return null;
  }

  public void getHitTestResult(ValueCallback<HitTestResult> callback) {

  }

  public boolean pageDown(boolean bottom) {
    return false;
  }

  public boolean pageUp(boolean top) {
    return false;
  }

  public void saveWebArchive(String basename, boolean autoname, ValueCallback<String> callback) {

  }

  public boolean zoomIn() {
    return false;
  }

  public boolean zoomOut() {
    return false;
  }

  public Map<String, Object> requestFocusNodeHref() {
    return null;
  }

  public Map<String, Object> requestImageRef() {
    return null;
  }

  public SslCertificate getCertificate() {
    InAppWebViewProgressDelegate progressDelegate = getProgressDelegate();
    if (progressDelegate == null) {
      return null;
    }
    return progressDelegate.certificate;
  }

  public void clearHistory() {
    GeckoSession session = getSession();
    if (session == null) {
      return;
    }
    session.purgeHistory();
  }

  public void callAsyncJavaScript(String functionBody, Map<String, Object> arguments, ContentWorld contentWorld, ValueCallback<String> resultCallback) {

  }

  public boolean isSecureContext() {
    InAppWebViewProgressDelegate progressDelegate = getProgressDelegate();
    if (progressDelegate == null) {
      return false;
    }
    return progressDelegate.secureContext;
  }

  public void postWebMessage(WebMessage message, Uri targetOrigin) {

  }

  public boolean canScrollToLeft() {
    if (inputResultDetail == null) {
      return false;
    }
    return inputResultDetail.handledResult() == PanZoomController.INPUT_RESULT_HANDLED &&
            Util.hasFlag(inputResultDetail.scrollableDirections(), PanZoomController.SCROLLABLE_FLAG_LEFT);
  }

  public boolean canScrollToTop() {
    if (inputResultDetail == null) {
      return false;
    }
    return inputResultDetail.handledResult() == PanZoomController.INPUT_RESULT_HANDLED &&
            Util.hasFlag(inputResultDetail.scrollableDirections(), PanZoomController.SCROLLABLE_FLAG_TOP);
  }

  public boolean canScrollToRight() {
    if (inputResultDetail == null) {
      return false;
    }
    return inputResultDetail.handledResult() == PanZoomController.INPUT_RESULT_HANDLED &&
            Util.hasFlag(inputResultDetail.scrollableDirections(), PanZoomController.SCROLLABLE_FLAG_RIGHT);
  }

  public boolean canScrollToBottom() {
    if (inputResultDetail == null) {
      return false;
    }
    return inputResultDetail.handledResult() == PanZoomController.INPUT_RESULT_HANDLED &&
            Util.hasFlag(inputResultDetail.scrollableDirections(), PanZoomController.SCROLLABLE_FLAG_BOTTOM);
  }

  public boolean canOverscrollLeft() {
    if (inputResultDetail == null) {
      return false;
    }
    return inputResultDetail.handledResult() != PanZoomController.INPUT_RESULT_HANDLED_CONTENT &&
            !Util.hasFlag(inputResultDetail.scrollableDirections(), PanZoomController.SCROLLABLE_FLAG_LEFT) &&
            Util.hasFlag(inputResultDetail.overscrollDirections(), PanZoomController.OVERSCROLL_FLAG_HORIZONTAL);
  }

  public boolean canOverscrollRight() {
    if (inputResultDetail == null) {
      return false;
    }
    return inputResultDetail.handledResult() != PanZoomController.INPUT_RESULT_HANDLED_CONTENT &&
            !Util.hasFlag(inputResultDetail.scrollableDirections(), PanZoomController.SCROLLABLE_FLAG_RIGHT) &&
            Util.hasFlag(inputResultDetail.overscrollDirections(), PanZoomController.OVERSCROLL_FLAG_HORIZONTAL);
  }

  public boolean canOverscrollBottom() {
    if (inputResultDetail == null) {
      return false;
    }
    return inputResultDetail.handledResult() != PanZoomController.INPUT_RESULT_HANDLED_CONTENT &&
            !Util.hasFlag(inputResultDetail.scrollableDirections(), PanZoomController.SCROLLABLE_FLAG_BOTTOM) &&
            Util.hasFlag(inputResultDetail.overscrollDirections(), PanZoomController.OVERSCROLL_FLAG_VERTICAL);
  }

  public boolean canOverscrollTop() {
    if (inputResultDetail == null) {
      return false;
    }
    return inputResultDetail.handledResult() != PanZoomController.INPUT_RESULT_HANDLED_CONTENT &&
            !Util.hasFlag(inputResultDetail.scrollableDirections(), PanZoomController.SCROLLABLE_FLAG_TOP) &&
            Util.hasFlag(inputResultDetail.overscrollDirections(), PanZoomController.OVERSCROLL_FLAG_VERTICAL);
  }

  public boolean canScrollVertically() {
    return false;
  }

  public boolean canScrollHorizontally() {
    return false;
  }

  public int scrollX() {
    InAppWebViewScrollDelegate scrollDelegate = getScrollDelegate();
    if (scrollDelegate == null) {
      return 0;
    }
    return scrollDelegate.scrollX;
  }

  public int scrollY() {
    InAppWebViewScrollDelegate scrollDelegate = getScrollDelegate();
    if (scrollDelegate == null) {
      return 0;
    }
    return scrollDelegate.scrollY;
  }

  public float getZoomScale() {
    return 0;
  }

  public void getZoomScale(ValueCallback<Float> callback) {

  }

  @Nullable
  public WebViewChannelDelegate getChannelDelegate() {
    return channelDelegate;
  }

  public void setChannelDelegate(@Nullable WebViewChannelDelegate channelDelegate) {
    this.channelDelegate = channelDelegate;
  }

  @Nullable
  public InAppWebViewContentDelegate getContentDelegate() {
    GeckoSession session = getSession();
    if (session == null) {
      return null;
    }
    return (InAppWebViewContentDelegate) session.getContentDelegate();
  }

  @Nullable
  public InAppWebViewNavigationDelegate getNavigationDelegate() {
    GeckoSession session = getSession();
    if (session == null) {
      return null;
    }
    return (InAppWebViewNavigationDelegate) session.getNavigationDelegate();
  }

  @Nullable
  public InAppWebViewProgressDelegate getProgressDelegate() {
    GeckoSession session = getSession();
    if (session == null) {
      return null;
    }
    return (InAppWebViewProgressDelegate) session.getProgressDelegate();
  }

  @Nullable
  public InAppWebViewHistoryDelegate getHistoryDelegate() {
    GeckoSession session = getSession();
    if (session == null) {
      return null;
    }
    return (InAppWebViewHistoryDelegate) session.getHistoryDelegate();
  }

  @Nullable
  public InAppWebViewScrollDelegate getScrollDelegate() {
    GeckoSession session = getSession();
    if (session == null) {
      return null;
    }
    return (InAppWebViewScrollDelegate) session.getScrollDelegate();
  }

  @Override
  public void dispose() {
    if (channelDelegate != null) {
      channelDelegate.dispose();
      channelDelegate = null;
    }
    super.dispose();
    InAppWebViewContentDelegate contentDelegate = getContentDelegate();
    if (contentDelegate != null) {
      contentDelegate.dispose();
    }
    InAppWebViewNavigationDelegate navigationDelegate = getNavigationDelegate();
    if (navigationDelegate != null) {
      navigationDelegate.dispose();
    }
    InAppWebViewProgressDelegate progressDelegate = getProgressDelegate();
    if (progressDelegate != null) {
      progressDelegate.dispose();
    }
    InAppWebViewHistoryDelegate historyDelegate = getHistoryDelegate();
    if (historyDelegate != null) {
      historyDelegate.dispose();
    }
    InAppWebViewScrollDelegate scrollDelegate = getScrollDelegate();
    if (scrollDelegate != null) {
      scrollDelegate.dispose();
    }
    GeckoSession session = getSession();
    if (session != null) {
      session.setContentDelegate(null);
      session.setNavigationDelegate(null);
      session.setProgressDelegate(null);
      session.setHistoryDelegate(null);
      session.setScrollDelegate(null);
      session.close();
    }
    if (windowId != null && plugin != null && plugin.inAppWebViewManager != null) {
      plugin.inAppWebViewManager.windowWebViewMessages.remove(windowId);
    }
    removeAllViews();
    inAppBrowserDelegate = null;
    plugin = null;
  }
}
