package com.pichillilorenzo.flutter_inappwebview.in_app_webview;

import android.animation.ObjectAnimator;
import android.animation.PropertyValuesHolder;
import android.annotation.TargetApi;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Point;
import android.graphics.drawable.ColorDrawable;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.print.PrintAttributes;
import android.print.PrintDocumentAdapter;
import android.print.PrintManager;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.util.Log;
import android.view.ActionMode;
import android.view.ContextMenu;
import android.view.GestureDetector;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.view.ViewTreeObserver;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputConnection;
import android.view.inputmethod.InputMethodManager;
import android.webkit.CookieManager;
import android.webkit.DownloadListener;
import android.webkit.URLUtil;
import android.webkit.ValueCallback;
import android.webkit.WebBackForwardList;
import android.webkit.WebHistoryItem;
import android.webkit.WebSettings;
import android.webkit.WebStorage;
import android.widget.HorizontalScrollView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.webkit.WebViewCompat;
import androidx.webkit.WebViewFeature;

import com.pichillilorenzo.flutter_inappwebview.InAppWebViewFlutterPlugin;
import com.pichillilorenzo.flutter_inappwebview.types.DownloadStartRequest;
import com.pichillilorenzo.flutter_inappwebview.types.HitTestResult;
import com.pichillilorenzo.flutter_inappwebview.types.InAppWebViewInterface;
import com.pichillilorenzo.flutter_inappwebview.JavaScriptBridgeInterface;
import com.pichillilorenzo.flutter_inappwebview.R;
import com.pichillilorenzo.flutter_inappwebview.Util;
import com.pichillilorenzo.flutter_inappwebview.content_blocker.ContentBlocker;
import com.pichillilorenzo.flutter_inappwebview.content_blocker.ContentBlockerAction;
import com.pichillilorenzo.flutter_inappwebview.content_blocker.ContentBlockerHandler;
import com.pichillilorenzo.flutter_inappwebview.content_blocker.ContentBlockerTrigger;
import com.pichillilorenzo.flutter_inappwebview.in_app_browser.InAppBrowserDelegate;
import com.pichillilorenzo.flutter_inappwebview.plugin_scripts_js.ConsoleLogJS;
import com.pichillilorenzo.flutter_inappwebview.plugin_scripts_js.InterceptAjaxRequestJS;
import com.pichillilorenzo.flutter_inappwebview.plugin_scripts_js.InterceptFetchRequestJS;
import com.pichillilorenzo.flutter_inappwebview.plugin_scripts_js.JavaScriptBridgeJS;
import com.pichillilorenzo.flutter_inappwebview.plugin_scripts_js.OnLoadResourceJS;
import com.pichillilorenzo.flutter_inappwebview.plugin_scripts_js.OnWindowBlurEventJS;
import com.pichillilorenzo.flutter_inappwebview.plugin_scripts_js.OnWindowFocusEventJS;
import com.pichillilorenzo.flutter_inappwebview.plugin_scripts_js.PluginScriptsUtil;
import com.pichillilorenzo.flutter_inappwebview.plugin_scripts_js.PrintJS;
import com.pichillilorenzo.flutter_inappwebview.plugin_scripts_js.PromisePolyfillJS;
import com.pichillilorenzo.flutter_inappwebview.pull_to_refresh.PullToRefreshLayout;
import com.pichillilorenzo.flutter_inappwebview.types.ContentWorld;
import com.pichillilorenzo.flutter_inappwebview.types.PluginScript;
import com.pichillilorenzo.flutter_inappwebview.types.PreferredContentModeOptionType;
import com.pichillilorenzo.flutter_inappwebview.types.URLRequest;
import com.pichillilorenzo.flutter_inappwebview.types.UserContentController;
import com.pichillilorenzo.flutter_inappwebview.types.UserScript;
import com.pichillilorenzo.flutter_inappwebview.types.WebMessageChannel;
import com.pichillilorenzo.flutter_inappwebview.types.WebMessageListener;

import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.regex.Pattern;

import io.flutter.plugin.common.MethodChannel;
import okhttp3.OkHttpClient;

import static android.content.Context.INPUT_METHOD_SERVICE;
import static com.pichillilorenzo.flutter_inappwebview.types.PreferredContentModeOptionType.fromValue;

final public class InAppWebView extends InputAwareWebView implements InAppWebViewInterface {

  static final String LOG_TAG = "InAppWebView";

  @Nullable
  public InAppWebViewFlutterPlugin plugin;
  @Nullable
  public InAppBrowserDelegate inAppBrowserDelegate;
  public MethodChannel channel;
  public Object id;
  @Nullable
  public Integer windowId;
  public InAppWebViewClient inAppWebViewClient;
  public InAppWebViewChromeClient inAppWebViewChromeClient;
  @Nullable
  public InAppWebViewRenderProcessClient inAppWebViewRenderProcessClient;
  public JavaScriptBridgeInterface javaScriptBridgeInterface;
  public InAppWebViewSettings customSettings;
  public boolean isLoading = false;
  public OkHttpClient httpClient;
  public float zoomScale = 1.0f;
  int okHttpClientCacheSize = 10 * 1024 * 1024; // 10MB
  public ContentBlockerHandler contentBlockerHandler = new ContentBlockerHandler();
  public Pattern regexToCancelSubFramesLoadingCompiled;
  @Nullable
  public GestureDetector gestureDetector = null;
  @Nullable
  public LinearLayout floatingContextMenu = null;
  @Nullable
  public Map<String, Object> contextMenu = null;
  public Handler mainLooperHandler = new Handler(getWebViewLooper());
  static Handler mHandler = new Handler();

  public Runnable checkScrollStoppedTask;
  public int initialPositionScrollStoppedTask;
  public int newCheckScrollStoppedTask = 100; // ms

  public Runnable checkContextMenuShouldBeClosedTask;
  public int newCheckContextMenuShouldBeClosedTaskTask = 100; // ms

  public UserContentController userContentController = new UserContentController();

  public Map<String, ValueCallback<String>> callAsyncJavaScriptCallbacks = new HashMap<>();
  public Map<String, ValueCallback<String>> evaluateJavaScriptContentWorldCallbacks = new HashMap<>();

  public Map<String, WebMessageChannel> webMessageChannels = new HashMap<>();
  public List<WebMessageListener> webMessageListeners = new ArrayList<>();

  public InAppWebView(Context context) {
    super(context);
  }

  public InAppWebView(Context context, AttributeSet attrs) {
    super(context, attrs);
  }

  public InAppWebView(Context context, AttributeSet attrs, int defaultStyle) {
    super(context, attrs, defaultStyle);
  }

  public InAppWebView(Context context, InAppWebViewFlutterPlugin plugin,
                      MethodChannel channel, Object id,
                      @Nullable Integer windowId, InAppWebViewSettings customSettings,
                      @Nullable Map<String, Object> contextMenu, View containerView,
                      List<UserScript> userScripts) {
    super(context, containerView, customSettings.useHybridComposition);
    this.plugin = plugin;
    this.channel = channel;
    this.id = id;
    this.windowId = windowId;
    this.customSettings = customSettings;
    this.contextMenu = contextMenu;
    this.userContentController.addUserOnlyScripts(userScripts);
    plugin.activity.registerForContextMenu(this);
  }

  public void prepare() {

    httpClient = new OkHttpClient().newBuilder().build();

    javaScriptBridgeInterface = new JavaScriptBridgeInterface(this);
    addJavascriptInterface(javaScriptBridgeInterface, JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_NAME);

    inAppWebViewChromeClient = new InAppWebViewChromeClient(plugin, channel, inAppBrowserDelegate);
    setWebChromeClient(inAppWebViewChromeClient);

    inAppWebViewClient = new InAppWebViewClient(channel, inAppBrowserDelegate);
    setWebViewClient(inAppWebViewClient);

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && WebViewFeature.isFeatureSupported(WebViewFeature.WEB_VIEW_RENDERER_CLIENT_BASIC_USAGE)) {
      inAppWebViewRenderProcessClient = new InAppWebViewRenderProcessClient(channel);
      WebViewCompat.setWebViewRenderProcessClient(this, inAppWebViewRenderProcessClient);
    }

    userContentController.addPluginScript(PromisePolyfillJS.PROMISE_POLYFILL_JS_PLUGIN_SCRIPT);
    userContentController.addPluginScript(JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_JS_PLUGIN_SCRIPT);
    userContentController.addPluginScript(ConsoleLogJS.CONSOLE_LOG_JS_PLUGIN_SCRIPT);
    userContentController.addPluginScript(PrintJS.PRINT_JS_PLUGIN_SCRIPT);
    userContentController.addPluginScript(OnWindowBlurEventJS.ON_WINDOW_BLUR_EVENT_JS_PLUGIN_SCRIPT);
    userContentController.addPluginScript(OnWindowFocusEventJS.ON_WINDOW_FOCUS_EVENT_JS_PLUGIN_SCRIPT);
    if (customSettings.useShouldInterceptAjaxRequest) {
      userContentController.addPluginScript(InterceptAjaxRequestJS.INTERCEPT_AJAX_REQUEST_JS_PLUGIN_SCRIPT);
    }
    if (customSettings.useShouldInterceptFetchRequest) {
      userContentController.addPluginScript(InterceptFetchRequestJS.INTERCEPT_FETCH_REQUEST_JS_PLUGIN_SCRIPT);
    }
    if (customSettings.useOnLoadResource) {
      userContentController.addPluginScript(OnLoadResourceJS.ON_LOAD_RESOURCE_JS_PLUGIN_SCRIPT);
    }
    if (!customSettings.useHybridComposition) {
      userContentController.addPluginScript(PluginScriptsUtil.CHECK_GLOBAL_KEY_DOWN_EVENT_TO_HIDE_CONTEXT_MENU_JS_PLUGIN_SCRIPT);
    }

    if (customSettings.useOnDownloadStart)
      setDownloadListener(new DownloadStartListener());

    WebSettings settings = getSettings();

    settings.setJavaScriptEnabled(customSettings.javaScriptEnabled);
    settings.setJavaScriptCanOpenWindowsAutomatically(customSettings.javaScriptCanOpenWindowsAutomatically);
    settings.setBuiltInZoomControls(customSettings.builtInZoomControls);
    settings.setDisplayZoomControls(customSettings.displayZoomControls);
    settings.setSupportMultipleWindows(customSettings.supportMultipleWindows);

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
      settings.setSafeBrowsingEnabled(customSettings.safeBrowsingEnabled);

    settings.setMediaPlaybackRequiresUserGesture(customSettings.mediaPlaybackRequiresUserGesture);

    settings.setDatabaseEnabled(customSettings.databaseEnabled);
    settings.setDomStorageEnabled(customSettings.domStorageEnabled);

    if (customSettings.userAgent != null && !customSettings.userAgent.isEmpty())
      settings.setUserAgentString(customSettings.userAgent);
    else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1)
      settings.setUserAgentString(WebSettings.getDefaultUserAgent(getContext()));

    if (customSettings.applicationNameForUserAgent != null && !customSettings.applicationNameForUserAgent.isEmpty()) {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
        String userAgent = (customSettings.userAgent != null && !customSettings.userAgent.isEmpty()) ? customSettings.userAgent : WebSettings.getDefaultUserAgent(getContext());
        String userAgentWithApplicationName = userAgent + " " + customSettings.applicationNameForUserAgent;
        settings.setUserAgentString(userAgentWithApplicationName);
      }
    }

    if (customSettings.clearCache)
      clearAllCache();
    else if (customSettings.clearSessionCache)
      CookieManager.getInstance().removeSessionCookie();

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
      CookieManager.getInstance().setAcceptThirdPartyCookies(this, customSettings.thirdPartyCookiesEnabled);

    settings.setLoadWithOverviewMode(customSettings.loadWithOverviewMode);
    settings.setUseWideViewPort(customSettings.useWideViewPort);
    settings.setSupportZoom(customSettings.supportZoom);
    settings.setTextZoom(customSettings.textZoom);

    setVerticalScrollBarEnabled(!customSettings.disableVerticalScroll && customSettings.verticalScrollBarEnabled);
    setHorizontalScrollBarEnabled(!customSettings.disableHorizontalScroll && customSettings.horizontalScrollBarEnabled);

    if (customSettings.transparentBackground)
      setBackgroundColor(Color.TRANSPARENT);

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP && customSettings.mixedContentMode != null)
      settings.setMixedContentMode(customSettings.mixedContentMode);

    settings.setAllowContentAccess(customSettings.allowContentAccess);
    settings.setAllowFileAccess(customSettings.allowFileAccess);
    settings.setAllowFileAccessFromFileURLs(customSettings.allowFileAccessFromFileURLs);
    settings.setAllowUniversalAccessFromFileURLs(customSettings.allowUniversalAccessFromFileURLs);
    setCacheEnabled(customSettings.cacheEnabled);
    if (customSettings.appCachePath != null && !customSettings.appCachePath.isEmpty() && customSettings.cacheEnabled)
      settings.setAppCachePath(customSettings.appCachePath);
    settings.setBlockNetworkImage(customSettings.blockNetworkImage);
    settings.setBlockNetworkLoads(customSettings.blockNetworkLoads);
    if (customSettings.cacheMode != null)
      settings.setCacheMode(customSettings.cacheMode);
    settings.setCursiveFontFamily(customSettings.cursiveFontFamily);
    settings.setDefaultFixedFontSize(customSettings.defaultFixedFontSize);
    settings.setDefaultFontSize(customSettings.defaultFontSize);
    settings.setDefaultTextEncodingName(customSettings.defaultTextEncodingName);
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N && customSettings.disabledActionModeMenuItems != null)
      settings.setDisabledActionModeMenuItems(customSettings.disabledActionModeMenuItems);
    settings.setFantasyFontFamily(customSettings.fantasyFontFamily);
    settings.setFixedFontFamily(customSettings.fixedFontFamily);
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && customSettings.forceDark != null)
      settings.setForceDark(customSettings.forceDark);
    settings.setGeolocationEnabled(customSettings.geolocationEnabled);
    if (customSettings.layoutAlgorithm != null) {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT && customSettings.layoutAlgorithm.equals(WebSettings.LayoutAlgorithm.TEXT_AUTOSIZING)) {
        settings.setLayoutAlgorithm(customSettings.layoutAlgorithm);
      } else {
        settings.setLayoutAlgorithm(customSettings.layoutAlgorithm);
      }
    }
    settings.setLoadsImagesAutomatically(customSettings.loadsImagesAutomatically);
    settings.setMinimumFontSize(customSettings.minimumFontSize);
    settings.setMinimumLogicalFontSize(customSettings.minimumLogicalFontSize);
    setInitialScale(customSettings.initialScale);
    settings.setNeedInitialFocus(customSettings.needInitialFocus);
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
      settings.setOffscreenPreRaster(customSettings.offscreenPreRaster);
    settings.setSansSerifFontFamily(customSettings.sansSerifFontFamily);
    settings.setSerifFontFamily(customSettings.serifFontFamily);
    settings.setStandardFontFamily(customSettings.standardFontFamily);
    if (customSettings.preferredContentMode != null &&
            customSettings.preferredContentMode == PreferredContentModeOptionType.DESKTOP.toValue()) {
      setDesktopMode(true);
    }
    settings.setSaveFormData(customSettings.saveFormData);
    if (customSettings.incognito)
      setIncognito(true);
    if (customSettings.hardwareAcceleration)
      setLayerType(View.LAYER_TYPE_HARDWARE, null);
    else
      setLayerType(View.LAYER_TYPE_SOFTWARE, null);
    if (customSettings.regexToCancelSubFramesLoading != null) {
      regexToCancelSubFramesLoadingCompiled = Pattern.compile(customSettings.regexToCancelSubFramesLoading);
    }
    setScrollBarStyle(customSettings.scrollBarStyle);
    if (customSettings.scrollBarDefaultDelayBeforeFade != null) {
      setScrollBarDefaultDelayBeforeFade(customSettings.scrollBarDefaultDelayBeforeFade);
    } else {
      customSettings.scrollBarDefaultDelayBeforeFade = getScrollBarDefaultDelayBeforeFade();
    }
    setScrollbarFadingEnabled(customSettings.scrollbarFadingEnabled);
    if (customSettings.scrollBarFadeDuration != null) {
      setScrollBarFadeDuration(customSettings.scrollBarFadeDuration);
    } else {
      customSettings.scrollBarFadeDuration = getScrollBarFadeDuration();
    }
    setVerticalScrollbarPosition(customSettings.verticalScrollbarPosition);

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
      if (customSettings.verticalScrollbarThumbColor != null)
        setVerticalScrollbarThumbDrawable(new ColorDrawable(Color.parseColor(customSettings.verticalScrollbarThumbColor)));
      if (customSettings.verticalScrollbarTrackColor != null)
        setVerticalScrollbarTrackDrawable(new ColorDrawable(Color.parseColor(customSettings.verticalScrollbarTrackColor)));
      if (customSettings.horizontalScrollbarThumbColor != null)
        setHorizontalScrollbarThumbDrawable(new ColorDrawable(Color.parseColor(customSettings.horizontalScrollbarThumbColor)));
      if (customSettings.horizontalScrollbarTrackColor != null)
        setHorizontalScrollbarTrackDrawable(new ColorDrawable(Color.parseColor(customSettings.horizontalScrollbarTrackColor)));
    }

    setOverScrollMode(customSettings.overScrollMode);
    if (customSettings.networkAvailable != null) {
      setNetworkAvailable(customSettings.networkAvailable);
    }
    if (customSettings.rendererPriorityPolicy != null && !customSettings.rendererPriorityPolicy.isEmpty() && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      setRendererPriorityPolicy(
              (int) customSettings.rendererPriorityPolicy.get("rendererRequestedPriority"),
              (boolean) customSettings.rendererPriorityPolicy.get("waivedWhenNotVisible"));
    } else if ((customSettings.rendererPriorityPolicy == null || (customSettings.rendererPriorityPolicy != null && customSettings.rendererPriorityPolicy.isEmpty())) &&
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      customSettings.rendererPriorityPolicy.put("rendererRequestedPriority", getRendererRequestedPriority());
      customSettings.rendererPriorityPolicy.put("waivedWhenNotVisible", getRendererPriorityWaivedWhenNotVisible());
    }

    contentBlockerHandler.getRuleList().clear();
    for (Map<String, Map<String, Object>> contentBlocker : customSettings.contentBlockers) {
      // compile ContentBlockerTrigger urlFilter
      ContentBlockerTrigger trigger = ContentBlockerTrigger.fromMap(contentBlocker.get("trigger"));
      ContentBlockerAction action = ContentBlockerAction.fromMap(contentBlocker.get("action"));
      contentBlockerHandler.getRuleList().add(new ContentBlocker(trigger, action));
    }

    setFindListener(new FindListener() {
      @Override
      public void onFindResultReceived(int activeMatchOrdinal, int numberOfMatches, boolean isDoneCounting) {
        Map<String, Object> obj = new HashMap<>();
        obj.put("activeMatchOrdinal", activeMatchOrdinal);
        obj.put("numberOfMatches", numberOfMatches);
        obj.put("isDoneCounting", isDoneCounting);
        channel.invokeMethod("onFindResultReceived", obj);
      }
    });

    gestureDetector = new GestureDetector(this.getContext(), new GestureDetector.SimpleOnGestureListener() {
      @Override
      public boolean onSingleTapUp(MotionEvent ev) {
        if (floatingContextMenu != null) {
          hideContextMenu();
        }
        return super.onSingleTapUp(ev);
      }
    });

    checkScrollStoppedTask = new Runnable() {
      @Override
      public void run() {
        int newPosition = getScrollY();
        if (initialPositionScrollStoppedTask - newPosition == 0) {
          // has stopped
          onScrollStopped();
        } else {
          initialPositionScrollStoppedTask = getScrollY();
          mainLooperHandler.postDelayed(checkScrollStoppedTask, newCheckScrollStoppedTask);
        }
      }
    };

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT && !customSettings.useHybridComposition) {
      checkContextMenuShouldBeClosedTask = new Runnable() {
        @Override
        public void run() {
          if (floatingContextMenu != null) {
            evaluateJavascript(PluginScriptsUtil.CHECK_CONTEXT_MENU_SHOULD_BE_HIDDEN_JS_SOURCE, new ValueCallback<String>() {
              @Override
              public void onReceiveValue(String value) {
                if (value == null || value.equals("true")) {
                  if (floatingContextMenu != null) {
                    hideContextMenu();
                  }
                } else {
                  mainLooperHandler.postDelayed(checkContextMenuShouldBeClosedTask, newCheckContextMenuShouldBeClosedTaskTask);
                }
              }
            });
          }
        }
      };
    }

    setOnTouchListener(new OnTouchListener() {
      float m_downX;
      float m_downY;

      @Override
      public boolean onTouch(View v, MotionEvent event) {
        gestureDetector.onTouchEvent(event);

        if (event.getAction() == MotionEvent.ACTION_UP) {
          checkScrollStoppedTask.run();
        }

        if (customSettings.disableHorizontalScroll && customSettings.disableVerticalScroll) {
          return (event.getAction() == MotionEvent.ACTION_MOVE);
        } else if (customSettings.disableHorizontalScroll || customSettings.disableVerticalScroll) {
          switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN: {
              // save the x
              m_downX = event.getX();
              // save the y
              m_downY = event.getY();
              break;
            }
            case MotionEvent.ACTION_MOVE:
            case MotionEvent.ACTION_CANCEL:
            case MotionEvent.ACTION_UP: {
              if (customSettings.disableHorizontalScroll) {
                // set x so that it doesn't move
                event.setLocation(m_downX, event.getY());
              } else {
                // set y so that it doesn't move
                event.setLocation(event.getX(), m_downY);
              }
              break;
            }
          }
        }
        return false;
      }
    });

    setOnLongClickListener(new OnLongClickListener() {
      @Override
      public boolean onLongClick(View v) {
        com.pichillilorenzo.flutter_inappwebview.types.HitTestResult hitTestResult =
                com.pichillilorenzo.flutter_inappwebview.types.HitTestResult.fromWebViewHitTestResult(getHitTestResult());
        channel.invokeMethod("onLongPressHitTestResult", hitTestResult.toMap());
        return false;
      }
    });
  }

  public void setIncognito(boolean enabled) {
    WebSettings settings = getSettings();
    if (enabled) {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
        CookieManager.getInstance().removeAllCookies(null);
      } else {
        CookieManager.getInstance().removeAllCookie();
      }

      // Disable caching
      settings.setCacheMode(WebSettings.LOAD_NO_CACHE);
      settings.setAppCacheEnabled(false);
      clearHistory();
      clearCache(true);

      // No form data or autofill enabled
      clearFormData();
      settings.setSavePassword(false);
      settings.setSaveFormData(false);
    } else {
      settings.setCacheMode(WebSettings.LOAD_DEFAULT);
      settings.setAppCacheEnabled(true);
      settings.setSavePassword(true);
      settings.setSaveFormData(true);
    }
  }

  public void setCacheEnabled(boolean enabled) {
    WebSettings settings = getSettings();
    if (enabled) {
      Context ctx = getContext();
      if (ctx != null) {
        settings.setAppCachePath(ctx.getCacheDir().getAbsolutePath());
        settings.setCacheMode(WebSettings.LOAD_DEFAULT);
        settings.setAppCacheEnabled(true);
      }
    } else {
      settings.setCacheMode(WebSettings.LOAD_NO_CACHE);
      settings.setAppCacheEnabled(false);
    }
  }

  public void loadUrl(URLRequest urlRequest) {
    String url = urlRequest.getUrl();
    String method = urlRequest.getMethod();
    if (method != null && method.equals("POST")) {
      byte[] postData = urlRequest.getBody();
      postUrl(url, postData);
      return;
    }
    Map<String, String> headers = urlRequest.getHeaders();
    if (headers != null) {
      loadUrl(url, headers);
      return;
    }
    loadUrl(url);
  }

  public void loadFile(String assetFilePath) throws IOException {
    if (plugin == null) {
      return;
    }
    
    loadUrl(Util.getUrlAsset(plugin, assetFilePath));
  }

  public boolean isLoading() {
    return isLoading;
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

  public void clearAllCache() {
    clearCache(true);
    clearCookies();
    clearFormData();
    WebStorage.getInstance().deleteAllData();
  }

  public void takeScreenshot(final @Nullable Map<String, Object> screenshotConfiguration, final MethodChannel.Result result) {
    final float pixelDensity = Util.getPixelDensity(getContext());
    
    mainLooperHandler.post(new Runnable() {
      @Override
      public void run() {
        try {
          Bitmap screenshotBitmap = Bitmap.createBitmap(getMeasuredWidth(), getMeasuredHeight(), Bitmap.Config.ARGB_8888);
          Canvas c = new Canvas(screenshotBitmap);
          c.translate(-getScrollX(), -getScrollY());
          draw(c);

          ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
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
              e.printStackTrace();
            }

            quality = (Integer) screenshotConfiguration.get("quality");
          }

          screenshotBitmap.compress(
                  compressFormat,
                  quality,
                  byteArrayOutputStream);

          try {
            byteArrayOutputStream.close();
          } catch (IOException e) {
            e.printStackTrace();
          }
          screenshotBitmap.recycle();
          result.success(byteArrayOutputStream.toByteArray());

        } catch (IllegalArgumentException e) {
          e.printStackTrace();
          result.success(null);
        }
      }
    });
  }

  public void setSettings(InAppWebViewSettings newSettings, HashMap<String, Object> newSettingsMap) {

    WebSettings settings = getSettings();

    if (newSettingsMap.get("javaScriptEnabled") != null && customSettings.javaScriptEnabled != newSettings.javaScriptEnabled)
      settings.setJavaScriptEnabled(newSettings.javaScriptEnabled);

    if (newSettingsMap.get("useShouldInterceptAjaxRequest") != null && customSettings.useShouldInterceptAjaxRequest != newSettings.useShouldInterceptAjaxRequest) {
      enablePluginScriptAtRuntime(
              InterceptAjaxRequestJS.FLAG_VARIABLE_FOR_SHOULD_INTERCEPT_AJAX_REQUEST_JS_SOURCE,
              newSettings.useShouldInterceptAjaxRequest,
              InterceptAjaxRequestJS.INTERCEPT_AJAX_REQUEST_JS_PLUGIN_SCRIPT
      );
    }

    if (newSettingsMap.get("useShouldInterceptFetchRequest") != null && customSettings.useShouldInterceptFetchRequest != newSettings.useShouldInterceptFetchRequest) {
      enablePluginScriptAtRuntime(
              InterceptFetchRequestJS.FLAG_VARIABLE_FOR_SHOULD_INTERCEPT_FETCH_REQUEST_JS_SOURCE,
              newSettings.useShouldInterceptFetchRequest,
              InterceptFetchRequestJS.INTERCEPT_FETCH_REQUEST_JS_PLUGIN_SCRIPT
      );
    }

    if (newSettingsMap.get("useOnLoadResource") != null && customSettings.useOnLoadResource != newSettings.useOnLoadResource) {
      enablePluginScriptAtRuntime(
              OnLoadResourceJS.FLAG_VARIABLE_FOR_ON_LOAD_RESOURCE_JS_SOURCE,
              newSettings.useOnLoadResource,
              OnLoadResourceJS.ON_LOAD_RESOURCE_JS_PLUGIN_SCRIPT
      );
    }

    if (newSettingsMap.get("javaScriptCanOpenWindowsAutomatically") != null && customSettings.javaScriptCanOpenWindowsAutomatically != newSettings.javaScriptCanOpenWindowsAutomatically)
      settings.setJavaScriptCanOpenWindowsAutomatically(newSettings.javaScriptCanOpenWindowsAutomatically);

    if (newSettingsMap.get("builtInZoomControls") != null && customSettings.builtInZoomControls != newSettings.builtInZoomControls)
      settings.setBuiltInZoomControls(newSettings.builtInZoomControls);

    if (newSettingsMap.get("displayZoomControls") != null && customSettings.displayZoomControls != newSettings.displayZoomControls)
      settings.setDisplayZoomControls(newSettings.displayZoomControls);

    if (newSettingsMap.get("safeBrowsingEnabled") != null && customSettings.safeBrowsingEnabled != newSettings.safeBrowsingEnabled && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
      settings.setSafeBrowsingEnabled(newSettings.safeBrowsingEnabled);

    if (newSettingsMap.get("mediaPlaybackRequiresUserGesture") != null && customSettings.mediaPlaybackRequiresUserGesture != newSettings.mediaPlaybackRequiresUserGesture)
      settings.setMediaPlaybackRequiresUserGesture(newSettings.mediaPlaybackRequiresUserGesture);

    if (newSettingsMap.get("databaseEnabled") != null && customSettings.databaseEnabled != newSettings.databaseEnabled)
      settings.setDatabaseEnabled(newSettings.databaseEnabled);

    if (newSettingsMap.get("domStorageEnabled") != null && customSettings.domStorageEnabled != newSettings.domStorageEnabled)
      settings.setDomStorageEnabled(newSettings.domStorageEnabled);

    if (newSettingsMap.get("userAgent") != null && !customSettings.userAgent.equals(newSettings.userAgent) && !newSettings.userAgent.isEmpty())
      settings.setUserAgentString(newSettings.userAgent);

    if (newSettingsMap.get("applicationNameForUserAgent") != null && !customSettings.applicationNameForUserAgent.equals(newSettings.applicationNameForUserAgent) && !newSettings.applicationNameForUserAgent.isEmpty()) {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
        String userAgent = (newSettings.userAgent != null && !newSettings.userAgent.isEmpty()) ? newSettings.userAgent : WebSettings.getDefaultUserAgent(getContext());
        String userAgentWithApplicationName = userAgent + " " + customSettings.applicationNameForUserAgent;
        settings.setUserAgentString(userAgentWithApplicationName);
      }
    }

    if (newSettingsMap.get("clearCache") != null && newSettings.clearCache)
      clearAllCache();
    else if (newSettingsMap.get("clearSessionCache") != null && newSettings.clearSessionCache)
      CookieManager.getInstance().removeSessionCookie();

    if (newSettingsMap.get("thirdPartyCookiesEnabled") != null && customSettings.thirdPartyCookiesEnabled != newSettings.thirdPartyCookiesEnabled && Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
      CookieManager.getInstance().setAcceptThirdPartyCookies(this, newSettings.thirdPartyCookiesEnabled);

    if (newSettingsMap.get("useWideViewPort") != null && customSettings.useWideViewPort != newSettings.useWideViewPort)
      settings.setUseWideViewPort(newSettings.useWideViewPort);

    if (newSettingsMap.get("supportZoom") != null && customSettings.supportZoom != newSettings.supportZoom)
      settings.setSupportZoom(newSettings.supportZoom);

    if (newSettingsMap.get("textZoom") != null && !customSettings.textZoom.equals(newSettings.textZoom))
      settings.setTextZoom(newSettings.textZoom);

    if (newSettingsMap.get("verticalScrollBarEnabled") != null && customSettings.verticalScrollBarEnabled != newSettings.verticalScrollBarEnabled)
      setVerticalScrollBarEnabled(newSettings.verticalScrollBarEnabled);

    if (newSettingsMap.get("horizontalScrollBarEnabled") != null && customSettings.horizontalScrollBarEnabled != newSettings.horizontalScrollBarEnabled)
      setHorizontalScrollBarEnabled(newSettings.horizontalScrollBarEnabled);

    if (newSettingsMap.get("transparentBackground") != null && customSettings.transparentBackground != newSettings.transparentBackground) {
      if (newSettings.transparentBackground) {
        setBackgroundColor(Color.TRANSPARENT);
      } else {
        setBackgroundColor(Color.parseColor("#FFFFFF"));
      }
    }

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
      if (newSettingsMap.get("mixedContentMode") != null && (customSettings.mixedContentMode == null || !customSettings.mixedContentMode.equals(newSettings.mixedContentMode)))
        settings.setMixedContentMode(newSettings.mixedContentMode);

    if (newSettingsMap.get("supportMultipleWindows") != null && customSettings.supportMultipleWindows != newSettings.supportMultipleWindows)
      settings.setSupportMultipleWindows(newSettings.supportMultipleWindows);

    if (newSettingsMap.get("useOnDownloadStart") != null && customSettings.useOnDownloadStart != newSettings.useOnDownloadStart) {
      if (newSettings.useOnDownloadStart) {
        setDownloadListener(new DownloadStartListener());
      } else {
        setDownloadListener(null);
      }
    }

    if (newSettingsMap.get("allowContentAccess") != null && customSettings.allowContentAccess != newSettings.allowContentAccess)
      settings.setAllowContentAccess(newSettings.allowContentAccess);

    if (newSettingsMap.get("allowFileAccess") != null && customSettings.allowFileAccess != newSettings.allowFileAccess)
      settings.setAllowFileAccess(newSettings.allowFileAccess);

    if (newSettingsMap.get("allowFileAccessFromFileURLs") != null && customSettings.allowFileAccessFromFileURLs != newSettings.allowFileAccessFromFileURLs)
      settings.setAllowFileAccessFromFileURLs(newSettings.allowFileAccessFromFileURLs);

    if (newSettingsMap.get("allowUniversalAccessFromFileURLs") != null && customSettings.allowUniversalAccessFromFileURLs != newSettings.allowUniversalAccessFromFileURLs)
      settings.setAllowUniversalAccessFromFileURLs(newSettings.allowUniversalAccessFromFileURLs);

    if (newSettingsMap.get("cacheEnabled") != null && customSettings.cacheEnabled != newSettings.cacheEnabled)
      setCacheEnabled(newSettings.cacheEnabled);

    if (newSettingsMap.get("appCachePath") != null && (customSettings.appCachePath == null || !customSettings.appCachePath.equals(newSettings.appCachePath)))
      settings.setAppCachePath(newSettings.appCachePath);

    if (newSettingsMap.get("blockNetworkImage") != null && customSettings.blockNetworkImage != newSettings.blockNetworkImage)
      settings.setBlockNetworkImage(newSettings.blockNetworkImage);

    if (newSettingsMap.get("blockNetworkLoads") != null && customSettings.blockNetworkLoads != newSettings.blockNetworkLoads)
      settings.setBlockNetworkLoads(newSettings.blockNetworkLoads);

    if (newSettingsMap.get("cacheMode") != null && !customSettings.cacheMode.equals(newSettings.cacheMode))
      settings.setCacheMode(newSettings.cacheMode);

    if (newSettingsMap.get("cursiveFontFamily") != null && !customSettings.cursiveFontFamily.equals(newSettings.cursiveFontFamily))
      settings.setCursiveFontFamily(newSettings.cursiveFontFamily);

    if (newSettingsMap.get("defaultFixedFontSize") != null && !customSettings.defaultFixedFontSize.equals(newSettings.defaultFixedFontSize))
      settings.setDefaultFixedFontSize(newSettings.defaultFixedFontSize);

    if (newSettingsMap.get("defaultFontSize") != null && !customSettings.defaultFontSize.equals(newSettings.defaultFontSize))
      settings.setDefaultFontSize(newSettings.defaultFontSize);

    if (newSettingsMap.get("defaultTextEncodingName") != null && !customSettings.defaultTextEncodingName.equals(newSettings.defaultTextEncodingName))
      settings.setDefaultTextEncodingName(newSettings.defaultTextEncodingName);

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N)
      if (newSettingsMap.get("disabledActionModeMenuItems") != null && (customSettings.disabledActionModeMenuItems == null ||
              !customSettings.disabledActionModeMenuItems.equals(newSettings.disabledActionModeMenuItems)))
        settings.setDisabledActionModeMenuItems(newSettings.disabledActionModeMenuItems);

    if (newSettingsMap.get("fantasyFontFamily") != null && !customSettings.fantasyFontFamily.equals(newSettings.fantasyFontFamily))
      settings.setFantasyFontFamily(newSettings.fantasyFontFamily);

    if (newSettingsMap.get("fixedFontFamily") != null && !customSettings.fixedFontFamily.equals(newSettings.fixedFontFamily))
      settings.setFixedFontFamily(newSettings.fixedFontFamily);

    if (newSettingsMap.get("forceDark") != null && !customSettings.forceDark.equals(newSettings.forceDark))
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q)
        settings.setForceDark(newSettings.forceDark);

    if (newSettingsMap.get("geolocationEnabled") != null && customSettings.geolocationEnabled != newSettings.geolocationEnabled)
      settings.setGeolocationEnabled(newSettings.geolocationEnabled);

    if (newSettingsMap.get("layoutAlgorithm") != null && customSettings.layoutAlgorithm != newSettings.layoutAlgorithm) {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT && newSettings.layoutAlgorithm.equals(WebSettings.LayoutAlgorithm.TEXT_AUTOSIZING)) {
        settings.setLayoutAlgorithm(newSettings.layoutAlgorithm);
      } else {
        settings.setLayoutAlgorithm(newSettings.layoutAlgorithm);
      }
    }

    if (newSettingsMap.get("loadWithOverviewMode") != null && customSettings.loadWithOverviewMode != newSettings.loadWithOverviewMode)
      settings.setLoadWithOverviewMode(newSettings.loadWithOverviewMode);

    if (newSettingsMap.get("loadsImagesAutomatically") != null && customSettings.loadsImagesAutomatically != newSettings.loadsImagesAutomatically)
      settings.setLoadsImagesAutomatically(newSettings.loadsImagesAutomatically);

    if (newSettingsMap.get("minimumFontSize") != null && !customSettings.minimumFontSize.equals(newSettings.minimumFontSize))
      settings.setMinimumFontSize(newSettings.minimumFontSize);

    if (newSettingsMap.get("minimumLogicalFontSize") != null && !customSettings.minimumLogicalFontSize.equals(newSettings.minimumLogicalFontSize))
      settings.setMinimumLogicalFontSize(newSettings.minimumLogicalFontSize);

    if (newSettingsMap.get("initialScale") != null && !customSettings.initialScale.equals(newSettings.initialScale))
      setInitialScale(newSettings.initialScale);

    if (newSettingsMap.get("needInitialFocus") != null && customSettings.needInitialFocus != newSettings.needInitialFocus)
      settings.setNeedInitialFocus(newSettings.needInitialFocus);

    if (newSettingsMap.get("offscreenPreRaster") != null && customSettings.offscreenPreRaster != newSettings.offscreenPreRaster)
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
        settings.setOffscreenPreRaster(newSettings.offscreenPreRaster);

    if (newSettingsMap.get("sansSerifFontFamily") != null && !customSettings.sansSerifFontFamily.equals(newSettings.sansSerifFontFamily))
      settings.setSansSerifFontFamily(newSettings.sansSerifFontFamily);

    if (newSettingsMap.get("serifFontFamily") != null && !customSettings.serifFontFamily.equals(newSettings.serifFontFamily))
      settings.setSerifFontFamily(newSettings.serifFontFamily);

    if (newSettingsMap.get("standardFontFamily") != null && !customSettings.standardFontFamily.equals(newSettings.standardFontFamily))
      settings.setStandardFontFamily(newSettings.standardFontFamily);

    if (newSettingsMap.get("preferredContentMode") != null && !customSettings.preferredContentMode.equals(newSettings.preferredContentMode)) {
      switch (fromValue(newSettings.preferredContentMode)) {
        case DESKTOP:
          setDesktopMode(true);
          break;
        case MOBILE:
        case RECOMMENDED:
          setDesktopMode(false);
          break;
      }
    }

    if (newSettingsMap.get("saveFormData") != null && customSettings.saveFormData != newSettings.saveFormData)
      settings.setSaveFormData(newSettings.saveFormData);

    if (newSettingsMap.get("incognito") != null && customSettings.incognito != newSettings.incognito)
      setIncognito(newSettings.incognito);

    if (newSettingsMap.get("hardwareAcceleration") != null && customSettings.hardwareAcceleration != newSettings.hardwareAcceleration) {
      if (newSettings.hardwareAcceleration)
        setLayerType(View.LAYER_TYPE_HARDWARE, null);
      else
        setLayerType(View.LAYER_TYPE_SOFTWARE, null);
    }

    if (newSettingsMap.get("regexToCancelSubFramesLoading") != null && (customSettings.regexToCancelSubFramesLoading == null ||
            !customSettings.regexToCancelSubFramesLoading.equals(newSettings.regexToCancelSubFramesLoading))) {
      if (newSettings.regexToCancelSubFramesLoading == null)
        regexToCancelSubFramesLoadingCompiled = null;
      else
        regexToCancelSubFramesLoadingCompiled = Pattern.compile(customSettings.regexToCancelSubFramesLoading);
    }

    if (newSettings.contentBlockers != null) {
      contentBlockerHandler.getRuleList().clear();
      for (Map<String, Map<String, Object>> contentBlocker : newSettings.contentBlockers) {
        // compile ContentBlockerTrigger urlFilter
        ContentBlockerTrigger trigger = ContentBlockerTrigger.fromMap(contentBlocker.get("trigger"));
        ContentBlockerAction action = ContentBlockerAction.fromMap(contentBlocker.get("action"));
        contentBlockerHandler.getRuleList().add(new ContentBlocker(trigger, action));
      }
    }

    if (newSettingsMap.get("scrollBarStyle") != null && !customSettings.scrollBarStyle.equals(newSettings.scrollBarStyle))
      setScrollBarStyle(newSettings.scrollBarStyle);

    if (newSettingsMap.get("scrollBarDefaultDelayBeforeFade") != null && (customSettings.scrollBarDefaultDelayBeforeFade == null ||
            !customSettings.scrollBarDefaultDelayBeforeFade.equals(newSettings.scrollBarDefaultDelayBeforeFade)))
      setScrollBarDefaultDelayBeforeFade(newSettings.scrollBarDefaultDelayBeforeFade);

    if (newSettingsMap.get("scrollbarFadingEnabled") != null && !customSettings.scrollbarFadingEnabled.equals(newSettings.scrollbarFadingEnabled))
      setScrollbarFadingEnabled(newSettings.scrollbarFadingEnabled);

    if (newSettingsMap.get("scrollBarFadeDuration") != null && (customSettings.scrollBarFadeDuration == null ||
            !customSettings.scrollBarFadeDuration.equals(newSettings.scrollBarFadeDuration)))
      setScrollBarFadeDuration(newSettings.scrollBarFadeDuration);

    if (newSettingsMap.get("verticalScrollbarPosition") != null && !customSettings.verticalScrollbarPosition.equals(newSettings.verticalScrollbarPosition))
      setVerticalScrollbarPosition(newSettings.verticalScrollbarPosition);

    if (newSettingsMap.get("disableVerticalScroll") != null && customSettings.disableVerticalScroll != newSettings.disableVerticalScroll)
      setVerticalScrollBarEnabled(!newSettings.disableVerticalScroll && newSettings.verticalScrollBarEnabled);

    if (newSettingsMap.get("disableHorizontalScroll") != null && customSettings.disableHorizontalScroll != newSettings.disableHorizontalScroll)
      setHorizontalScrollBarEnabled(!newSettings.disableHorizontalScroll && newSettings.horizontalScrollBarEnabled);

    if (newSettingsMap.get("overScrollMode") != null && !customSettings.overScrollMode.equals(newSettings.overScrollMode))
      setOverScrollMode(newSettings.overScrollMode);

    if (newSettingsMap.get("networkAvailable") != null && customSettings.networkAvailable != newSettings.networkAvailable)
      setNetworkAvailable(newSettings.networkAvailable);

    if (newSettingsMap.get("rendererPriorityPolicy") != null &&
            (customSettings.rendererPriorityPolicy.get("rendererRequestedPriority") != newSettings.rendererPriorityPolicy.get("rendererRequestedPriority") ||
                    customSettings.rendererPriorityPolicy.get("waivedWhenNotVisible") != newSettings.rendererPriorityPolicy.get("waivedWhenNotVisible")) &&
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      setRendererPriorityPolicy(
              (int) newSettings.rendererPriorityPolicy.get("rendererRequestedPriority"),
              (boolean) newSettings.rendererPriorityPolicy.get("waivedWhenNotVisible"));
    }

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
      if (newSettingsMap.get("verticalScrollbarThumbColor") != null && !Util.objEquals(customSettings.verticalScrollbarThumbColor, newSettings.verticalScrollbarThumbColor))
        setVerticalScrollbarThumbDrawable(new ColorDrawable(Color.parseColor(newSettings.verticalScrollbarThumbColor)));

      if (newSettingsMap.get("verticalScrollbarTrackColor") != null && !Util.objEquals(customSettings.verticalScrollbarTrackColor, newSettings.verticalScrollbarTrackColor))
        setVerticalScrollbarTrackDrawable(new ColorDrawable(Color.parseColor(newSettings.verticalScrollbarTrackColor)));

      if (newSettingsMap.get("horizontalScrollbarThumbColor") != null && !Util.objEquals(customSettings.horizontalScrollbarThumbColor, newSettings.horizontalScrollbarThumbColor))
        setHorizontalScrollbarThumbDrawable(new ColorDrawable(Color.parseColor(newSettings.horizontalScrollbarThumbColor)));

      if (newSettingsMap.get("horizontalScrollbarTrackColor") != null && !Util.objEquals(customSettings.horizontalScrollbarTrackColor, newSettings.horizontalScrollbarTrackColor))
        setHorizontalScrollbarTrackDrawable(new ColorDrawable(Color.parseColor(newSettings.horizontalScrollbarTrackColor)));
    }

    customSettings = newSettings;
  }

  public Map<String, Object> getCustomSettings() {
    return (customSettings != null) ? customSettings.getRealSettings(this) : null;
  }

  public void enablePluginScriptAtRuntime(final String flagVariable,
                                          final boolean enable,
                                          final PluginScript pluginScript) {
    evaluateJavascript("window." + flagVariable, null, new ValueCallback<String>() {
      @Override
      public void onReceiveValue(String value) {
        boolean alreadyLoaded = value != null && !value.equalsIgnoreCase("null");
        if (alreadyLoaded) {
          String enableSource = "window." + flagVariable + " = " + enable + ";";
          evaluateJavascript(enableSource, null, null);
          if (!enable) {
            userContentController.removePluginScript(pluginScript);
          }
        } else if (enable) {
          evaluateJavascript(pluginScript.getSource(), null, null);
          userContentController.addPluginScript(pluginScript);
        }
      }
    });
  }

  public void injectDeferredObject(String source, @Nullable final ContentWorld contentWorld, String jsWrapper, @Nullable final ValueCallback<String> resultCallback) {
    final String resultUuid = contentWorld != null && !contentWorld.equals(ContentWorld.PAGE) ? UUID.randomUUID().toString() : null;
    String scriptToInject = source;
    if (jsWrapper != null) {
      org.json.JSONArray jsonEsc = new org.json.JSONArray();
      jsonEsc.put(source);
      String jsonRepr = jsonEsc.toString();
      String jsonSourceString = jsonRepr.substring(1, jsonRepr.length() - 1);
      scriptToInject = String.format(jsWrapper, jsonSourceString);
    }
    if (resultUuid != null && resultCallback != null) {
      evaluateJavaScriptContentWorldCallbacks.put(resultUuid, resultCallback);
      scriptToInject = Util.replaceAll(PluginScriptsUtil.EVALUATE_JAVASCRIPT_WITH_CONTENT_WORLD_WRAPPER_JS_SOURCE,
              PluginScriptsUtil.VAR_RANDOM_NAME, "_" + JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_NAME + "_" + Math.round(Math.random() * 1000000))
              .replace(PluginScriptsUtil.VAR_PLACEHOLDER_VALUE, UserContentController.escapeCode(source))
              .replace(PluginScriptsUtil.VAR_RESULT_UUID, resultUuid);
    }
    final String finalScriptToInject = scriptToInject;
    mainLooperHandler.post(new Runnable() {
      @Override
      public void run() {
        String scriptToInject = userContentController.generateCodeForScriptEvaluation(finalScriptToInject, contentWorld);
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) {
          // This action will have the side-effect of blurring the currently focused element
          loadUrl("javascript:" + scriptToInject.replaceAll("[\r\n]+", ""));
          if (contentWorld != null && resultCallback != null) {
            resultCallback.onReceiveValue("");
          }
        } else {
          evaluateJavascript(scriptToInject, new ValueCallback<String>() {
            @Override
            public void onReceiveValue(String s) {
              if (resultUuid != null || resultCallback == null)
                return;
              resultCallback.onReceiveValue(s);
            }
          });
        }
      }
    });
  }

  public void evaluateJavascript(String source, @Nullable ContentWorld contentWorld, @Nullable ValueCallback<String> resultCallback) {
    injectDeferredObject(source, contentWorld, null, resultCallback);
  }

  public void injectJavascriptFileFromUrl(String urlFile, @Nullable Map<String, Object> scriptHtmlTagAttributes) {
    String scriptAttributes = "";
    if (scriptHtmlTagAttributes != null) {
      String typeAttr = (String) scriptHtmlTagAttributes.get("type");
      if (typeAttr != null) {
        scriptAttributes += " script.type = '" + typeAttr.replaceAll("'", "\\\\'") + "'; ";
      }
      String idAttr = (String) scriptHtmlTagAttributes.get("id");
      if (idAttr != null) {
        String scriptIdEscaped = idAttr.replaceAll("'", "\\\\'");
        scriptAttributes += " script.id = '" + scriptIdEscaped + "'; ";
        scriptAttributes += " script.onload = function() {" +
        "  if (window." + JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_NAME + " != null) {" +
        "    window." + JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_NAME + ".callHandler('onInjectedScriptLoaded', '" + scriptIdEscaped + "');" +
        "  }" +
        "};";
        scriptAttributes += " script.onerror = function() {" +
        "  if (window." + JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_NAME + " != null) {" +
        "    window." + JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_NAME + ".callHandler('onInjectedScriptError', '" + scriptIdEscaped + "');" +
        "  }" +
        "};";
      }
      Boolean asyncAttr = (Boolean) scriptHtmlTagAttributes.get("async");
      if (asyncAttr != null && asyncAttr) {
        scriptAttributes += " script.async = true; ";
      }
      Boolean deferAttr = (Boolean) scriptHtmlTagAttributes.get("defer");
      if (deferAttr != null && deferAttr) {
        scriptAttributes += " script.defer = true; ";
      }
      String crossOriginAttr = (String) scriptHtmlTagAttributes.get("crossOrigin");
      if (crossOriginAttr != null) {
        scriptAttributes += " script.crossOrigin = '" + crossOriginAttr.replaceAll("'", "\\\\'") + "'; ";
      }
      String integrityAttr = (String) scriptHtmlTagAttributes.get("integrity");
      if (integrityAttr != null) {
        scriptAttributes += " script.integrity = '" + integrityAttr.replaceAll("'", "\\\\'") + "'; ";
      }
      Boolean noModuleAttr = (Boolean) scriptHtmlTagAttributes.get("noModule");
      if (noModuleAttr != null && noModuleAttr) {
        scriptAttributes += " script.noModule = true; ";
      }
      String nonceAttr = (String) scriptHtmlTagAttributes.get("nonce");
      if (nonceAttr != null) {
        scriptAttributes += " script.nonce = '" + nonceAttr.replaceAll("'", "\\\\'") + "'; ";
      }
      String referrerPolicyAttr = (String) scriptHtmlTagAttributes.get("referrerPolicy");
      if (referrerPolicyAttr != null) {
        scriptAttributes += " script.referrerPolicy = '" + referrerPolicyAttr.replaceAll("'", "\\\\'") + "'; ";
      }
    }
    String jsWrapper = "(function(d) { var script = d.createElement('script'); " + scriptAttributes +
            " script.src = %s; if (d.body != null) { d.body.appendChild(script); } })(document);";
    injectDeferredObject(urlFile, null, jsWrapper, null);
  }

  public void injectCSSCode(String source) {
    String jsWrapper = "(function(d) { var style = d.createElement('style'); style.innerHTML = %s;" +
            " if (d.head != null) { d.head.appendChild(style); } })(document);";
    injectDeferredObject(source, null, jsWrapper, null);
  }

  public void injectCSSFileFromUrl(String urlFile, @Nullable Map<String, Object> cssLinkHtmlTagAttributes) {
    String cssLinkAttributes = "";
    String alternateStylesheet = "";
    if (cssLinkHtmlTagAttributes != null) {
      String idAttr = (String) cssLinkHtmlTagAttributes.get("id");
      if (idAttr != null) {
        cssLinkAttributes += " link.id = '" + idAttr.replaceAll("'", "\\\\'") + "'; ";
      }
      String mediaAttr = (String) cssLinkHtmlTagAttributes.get("media");
      if (mediaAttr != null) {
        cssLinkAttributes += " link.media = '" + mediaAttr.replaceAll("'", "\\\\'") + "'; ";
      }
      String crossOriginAttr = (String) cssLinkHtmlTagAttributes.get("crossOrigin");
      if (crossOriginAttr != null) {
        cssLinkAttributes += " link.crossOrigin = '" + crossOriginAttr.replaceAll("'", "\\\\'") + "'; ";
      }
      String integrityAttr = (String) cssLinkHtmlTagAttributes.get("integrity");
      if (integrityAttr != null) {
        cssLinkAttributes += " link.integrity = '" + integrityAttr.replaceAll("'", "\\\\'") + "'; ";
      }
      String referrerPolicyAttr = (String) cssLinkHtmlTagAttributes.get("referrerPolicy");
      if (referrerPolicyAttr != null) {
        cssLinkAttributes += " link.referrerPolicy = '" + referrerPolicyAttr.replaceAll("'", "\\\\'") + "'; ";
      }
      Boolean disabledAttr = (Boolean) cssLinkHtmlTagAttributes.get("disabled");
      if (disabledAttr != null && disabledAttr) {
        cssLinkAttributes += " link.disabled = true; ";
      }
      Boolean alternateAttr = (Boolean) cssLinkHtmlTagAttributes.get("alternate");
      if (alternateAttr != null && alternateAttr) {
        alternateStylesheet = "alternate ";
      }
      String titleAttr = (String) cssLinkHtmlTagAttributes.get("title");
      if (titleAttr != null) {
        cssLinkAttributes += " link.title = '" + titleAttr.replaceAll("'", "\\\\'") + "'; ";
      }
    }
    String jsWrapper = "(function(d) { var link = d.createElement('link'); link.rel='" + alternateStylesheet + "stylesheet'; link.type='text/css'; " +
            cssLinkAttributes + " link.href = %s; if (d.head != null) { d.head.appendChild(link); } })(document);";
    injectDeferredObject(urlFile, null, jsWrapper, null);
  }

  public HashMap<String, Object> getCopyBackForwardList() {
    WebBackForwardList currentList = copyBackForwardList();
    int currentSize = currentList.getSize();
    int currentIndex = currentList.getCurrentIndex();

    List<HashMap<String, String>> history = new ArrayList<HashMap<String, String>>();

    for (int i = 0; i < currentSize; i++) {
      WebHistoryItem historyItem = currentList.getItemAtIndex(i);
      HashMap<String, String> historyItemMap = new HashMap<>();

      historyItemMap.put("originalUrl", historyItem.getOriginalUrl());
      historyItemMap.put("title", historyItem.getTitle());
      historyItemMap.put("url", historyItem.getUrl());

      history.add(historyItemMap);
    }

    HashMap<String, Object> result = new HashMap<>();

    result.put("history", history);
    result.put("currentIndex", currentIndex);

    return result;
  }

  @Override
  protected void onScrollChanged(int x,
                                 int y,
                                 int oldX,
                                 int oldY) {
    super.onScrollChanged(x, y, oldX, oldY);

    if (floatingContextMenu != null) {
      floatingContextMenu.setAlpha(0f);
      floatingContextMenu.setVisibility(View.GONE);
    }

    Map<String, Object> obj = new HashMap<>();
    obj.put("x", x);
    obj.put("y", y);
    channel.invokeMethod("onScrollChanged", obj);
  }

  public void scrollTo(Integer x, Integer y, Boolean animated) {
    if (animated) {
      PropertyValuesHolder pvhX = PropertyValuesHolder.ofInt("scrollX", x);
      PropertyValuesHolder pvhY = PropertyValuesHolder.ofInt("scrollY", y);
      ObjectAnimator anim = ObjectAnimator.ofPropertyValuesHolder(this, pvhX, pvhY);
      anim.setDuration(300).start();
    } else {
      scrollTo(x, y);
    }
  }

  public void scrollBy(Integer x, Integer y, Boolean animated) {
    if (animated) {
      PropertyValuesHolder pvhX = PropertyValuesHolder.ofInt("scrollX", getScrollX() + x);
      PropertyValuesHolder pvhY = PropertyValuesHolder.ofInt("scrollY", getScrollY() + y);
      ObjectAnimator anim = ObjectAnimator.ofPropertyValuesHolder(this, pvhX, pvhY);
      anim.setDuration(300).start();
    } else {
      scrollBy(x, y);
    }
  }

  class DownloadStartListener implements DownloadListener {
    @Override
    public void onDownloadStart(String url, String userAgent, String contentDisposition, String mimeType, long contentLength) {
      DownloadStartRequest downloadStartRequest = new DownloadStartRequest(
        url,
        userAgent,
        contentDisposition,
        mimeType,
        contentLength,
        URLUtil.guessFileName(url, contentDisposition, mimeType),
        null
      );
      channel.invokeMethod("onDownloadStartRequest", downloadStartRequest.toMap());
    }
  }

  public void setDesktopMode(final boolean enabled) {
    final WebSettings webSettings = getSettings();

    final String newUserAgent;
    if (enabled) {
      newUserAgent = webSettings.getUserAgentString().replace("Mobile", "eliboM").replace("Android", "diordnA");
    } else {
      newUserAgent = webSettings.getUserAgentString().replace("eliboM", "Mobile").replace("diordnA", "Android");
    }

    webSettings.setUserAgentString(newUserAgent);
    webSettings.setUseWideViewPort(enabled);
    webSettings.setLoadWithOverviewMode(enabled);
    webSettings.setSupportZoom(enabled);
    webSettings.setBuiltInZoomControls(enabled);
  }

  @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
  public void printCurrentPage() {
    // Get a PrintManager instance
    PrintManager printManager = (PrintManager) plugin.activity.getSystemService(Context.PRINT_SERVICE);

    if (printManager != null) {
      String jobName = getTitle() + " Document";

      // Get a printCurrentPage adapter instance
      PrintDocumentAdapter printAdapter = createPrintDocumentAdapter(jobName);

      // Create a printCurrentPage job with name and adapter instance
      printManager.print(jobName, printAdapter,
              new PrintAttributes.Builder().build());
    } else {
      Log.e(LOG_TAG, "No PrintManager available");
    }
  }

  @Override
  public void onCreateContextMenu(ContextMenu menu) {
    super.onCreateContextMenu(menu);
    sendOnCreateContextMenuEvent();
  }

  private void sendOnCreateContextMenuEvent() {
    com.pichillilorenzo.flutter_inappwebview.types.HitTestResult hitTestResult =
            com.pichillilorenzo.flutter_inappwebview.types.HitTestResult.fromWebViewHitTestResult(getHitTestResult());
    channel.invokeMethod("onCreateContextMenu", hitTestResult.toMap());
  }

  private Point contextMenuPoint = new Point(0, 0);
  private Point lastTouch = new Point(0, 0);

  @Override
  public boolean onTouchEvent(MotionEvent ev) {
    lastTouch = new Point((int) ev.getX(), (int) ev.getY());

    ViewParent parent = getParent();
    if (parent instanceof PullToRefreshLayout) {
      PullToRefreshLayout pullToRefreshLayout = (PullToRefreshLayout) parent;
      if (ev.getActionMasked() == MotionEvent.ACTION_DOWN) {
        pullToRefreshLayout.setEnabled(false);
      }
    }

    return super.onTouchEvent(ev);
  }

  @Override
  protected void onOverScrolled(int scrollX, int scrollY, boolean clampedX, boolean clampedY) {
    super.onOverScrolled(scrollX, scrollY, clampedX, clampedY);

    boolean overScrolledHorizontally = canScrollHorizontally() && clampedX;
    boolean overScrolledVertically = canScrollVertically() && clampedY;

    ViewParent parent = getParent();
    if (parent instanceof PullToRefreshLayout && overScrolledVertically && scrollY <= 10) {
      PullToRefreshLayout pullToRefreshLayout = (PullToRefreshLayout) parent;
      // change over scroll mode to OVER_SCROLL_NEVER in order to disable temporarily the glow effect
      setOverScrollMode(OVER_SCROLL_NEVER);
      pullToRefreshLayout.setEnabled(pullToRefreshLayout.options.enabled);
      // reset over scroll mode
      setOverScrollMode(customSettings.overScrollMode);
    }

    if (overScrolledHorizontally || overScrolledVertically) {
      Map<String, Object> obj = new HashMap<>();
      obj.put("x", scrollX);
      obj.put("y", scrollY);
      obj.put("clampedX", overScrolledHorizontally);
      obj.put("clampedY", overScrolledVertically);
      channel.invokeMethod("onOverScrolled", obj);
    }
  }

  @Override
  public boolean dispatchTouchEvent(MotionEvent event) {
    return super.dispatchTouchEvent(event);
  }

  @Override
  public InputConnection onCreateInputConnection(EditorInfo outAttrs) {
    InputConnection connection = super.onCreateInputConnection(outAttrs);
    if (connection == null && !customSettings.useHybridComposition && containerView != null) {
      // workaround to hide the Keyboard when the user click outside
      // on something not focusable such as input or a textarea.
      containerView
              .getHandler()
              .postDelayed(
                      new Runnable() {
                        @Override
                        public void run() {
                          InputMethodManager imm =
                                  (InputMethodManager) getContext().getSystemService(INPUT_METHOD_SERVICE);
                          if (containerView != null && imm != null && !imm.isAcceptingText()) {
                            imm.hideSoftInputFromWindow(
                                    containerView.getWindowToken(), InputMethodManager.HIDE_NOT_ALWAYS);
                          }
                        }
                      },
                      128);
    }
    return connection;
  }

  @Override
  public ActionMode startActionMode(ActionMode.Callback callback) {
    if (customSettings.useHybridComposition && !customSettings.disableContextMenu && (contextMenu == null || contextMenu.keySet().size() == 0)) {
      return super.startActionMode(callback);
    }
    return rebuildActionMode(super.startActionMode(callback), callback);
  }

  @RequiresApi(api = Build.VERSION_CODES.M)
  @Override
  public ActionMode startActionMode(ActionMode.Callback callback, int type) {
    if (customSettings.useHybridComposition && !customSettings.disableContextMenu && (contextMenu == null || contextMenu.keySet().size() == 0)) {
      return super.startActionMode(callback, type);
    }
    return rebuildActionMode(super.startActionMode(callback, type), callback);
  }

  public ActionMode rebuildActionMode(
          final ActionMode actionMode,
          final ActionMode.Callback callback
  ) {
    // fix Android 10 clipboard not working properly https://github.com/pichillilorenzo/flutter_inappwebview/issues/678
    if (!customSettings.useHybridComposition && containerView != null) {
      onWindowFocusChanged(containerView.isFocused());
    }

    boolean hasBeenRemovedAndRebuilt = false;
    if (floatingContextMenu != null) {
      hideContextMenu();
      hasBeenRemovedAndRebuilt = true;
    }
    if (actionMode == null) {
      return null;
    }

    Menu actionMenu = actionMode.getMenu();
    if (customSettings.disableContextMenu) {
      actionMenu.clear();
      return actionMode;
    }

    floatingContextMenu = (LinearLayout) LayoutInflater.from(this.getContext())
            .inflate(R.layout.floating_action_mode, this, false);
    HorizontalScrollView horizontalScrollView = (HorizontalScrollView) floatingContextMenu.getChildAt(0);
    LinearLayout menuItemListLayout = (LinearLayout) horizontalScrollView.getChildAt(0);

    List<Map<String, Object>> customMenuItems = new ArrayList<>();
    ContextMenuSettings contextMenuSettings = new ContextMenuSettings();
    if (contextMenu != null) {
      customMenuItems = (List<Map<String, Object>>) contextMenu.get("menuItems");
      Map<String, Object> contextMenuOptionsMap = (Map<String, Object>) contextMenu.get("settings");
      if (contextMenuOptionsMap != null) {
        contextMenuSettings.parse(contextMenuOptionsMap);
      }
    }
    customMenuItems = customMenuItems == null ? new ArrayList<Map<String, Object>>() : customMenuItems;

    if (contextMenuSettings.hideDefaultSystemContextMenuItems == null || !contextMenuSettings.hideDefaultSystemContextMenuItems) {
      for (int i = 0; i < actionMenu.size(); i++) {
        final MenuItem menuItem = actionMenu.getItem(i);
        final int itemId = menuItem.getItemId();
        final String itemTitle = menuItem.getTitle().toString();

        TextView text = (TextView) LayoutInflater.from(this.getContext())
                .inflate(R.layout.floating_action_mode_item, this, false);
        text.setText(itemTitle);
        text.setOnClickListener(new OnClickListener() {
          @Override
          public void onClick(View v) {
            hideContextMenu();
            callback.onActionItemClicked(actionMode, menuItem);

            Map<String, Object> obj = new HashMap<>();
            obj.put("id", itemId);
            obj.put("androidId", itemId);
            obj.put("iosId", null);
            obj.put("title", itemTitle);
            channel.invokeMethod("onContextMenuActionItemClicked", obj);
          }
        });
        if (floatingContextMenu != null) {
          menuItemListLayout.addView(text);
        }
      }
    }

    for (final Map<String, Object> menuItem : customMenuItems) {
      final int itemId = (int) menuItem.get("id");
      final String itemTitle = (String) menuItem.get("title");
      TextView text = (TextView) LayoutInflater.from(this.getContext())
              .inflate(R.layout.floating_action_mode_item, this, false);
      text.setText(itemTitle);
      text.setOnClickListener(new OnClickListener() {
        @Override
        public void onClick(View v) {
          hideContextMenu();

          Map<String, Object> obj = new HashMap<>();
          obj.put("id", itemId);
          obj.put("androidId", itemId);
          obj.put("iosId", null);
          obj.put("title", itemTitle);
          channel.invokeMethod("onContextMenuActionItemClicked", obj);
        }
      });
      if (floatingContextMenu != null) {
        menuItemListLayout.addView(text);

      }
    }

    final int x = (lastTouch != null) ? lastTouch.x : 0;
    final int y = (lastTouch != null) ? lastTouch.y : 0;
    contextMenuPoint = new Point(x, y);

    if (floatingContextMenu != null) {
      floatingContextMenu.getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {

        @Override
        public void onGlobalLayout() {
          if (floatingContextMenu != null) {
            floatingContextMenu.getViewTreeObserver().removeOnGlobalLayoutListener(this);
            if (getSettings().getJavaScriptEnabled()) {
              onScrollStopped();
            } else {
              onFloatingActionGlobalLayout(x, y);
            }
          }
        }
      });
      addView(floatingContextMenu, new LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT, x, y));
      if (hasBeenRemovedAndRebuilt) {
        sendOnCreateContextMenuEvent();
      }
      if (checkContextMenuShouldBeClosedTask != null) {
        checkContextMenuShouldBeClosedTask.run();
      }
    }
    actionMenu.clear();

    return actionMode;
  }

  public void onFloatingActionGlobalLayout(int x, int y) {
    int maxWidth = getWidth();
    int maxHeight = getHeight();
    int width = floatingContextMenu.getWidth();
    int height = floatingContextMenu.getHeight();
    int curx = x - (width / 2);
    if (curx < 0) {
      curx = 0;
    } else if (curx + width > maxWidth) {
      curx = maxWidth - width;
    }
    // float size = 12 * scale;
    float cury = y - (height * 1.5f);
    if (cury < 0) {
      cury = y + height;
    }

    updateViewLayout(
            floatingContextMenu,
            new LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT, curx, ((int) cury) + getScrollY())
    );

    mainLooperHandler.post(new Runnable() {
      @Override
      public void run() {
        if (floatingContextMenu != null) {
          floatingContextMenu.setVisibility(View.VISIBLE);
          floatingContextMenu.animate().alpha(1f).setDuration(100).setListener(null);
        }
      }
    });
  }

  public void hideContextMenu() {
    removeView(floatingContextMenu);
    floatingContextMenu = null;
    onHideContextMenu();
  }

  public void onHideContextMenu() {
    Map<String, Object> obj = new HashMap<>();
    channel.invokeMethod("onHideContextMenu", obj);
  }

  public void onScrollStopped() {
    if (floatingContextMenu != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
      adjustFloatingContextMenuPosition();
    }
  }

  @RequiresApi(api = Build.VERSION_CODES.KITKAT)
  public void adjustFloatingContextMenuPosition() {
    evaluateJavascript("(function(){" +
            "  var selection = window.getSelection();" +
            "  var rangeY = null;" +
            "  if (selection != null && selection.rangeCount > 0) {" +
            "    var range = selection.getRangeAt(0);" +
            "    var clientRect = range.getClientRects();" +
            "    if (clientRect.length > 0) {" +
            "      rangeY = clientRect[0].y;" +
            "    } else if (document.activeElement != null && document.activeElement.tagName.toLowerCase() !== 'iframe') {" +
            "      var boundingClientRect = document.activeElement.getBoundingClientRect();" +
            "      rangeY = boundingClientRect.y;" +
            "    }" +
            "  }" +
            "  return rangeY;" +
            "})();", new ValueCallback<String>() {
      @Override
      public void onReceiveValue(String value) {
        if (floatingContextMenu != null) {
          if (value != null && !value.equalsIgnoreCase("null")) {
            int x = contextMenuPoint.x;
            int y = (int) ((Float.parseFloat(value) * Util.getPixelDensity(getContext())) + (floatingContextMenu.getHeight() / 3.5));
            contextMenuPoint.y = y;
            onFloatingActionGlobalLayout(x, y);
          } else {
            floatingContextMenu.setVisibility(View.VISIBLE);
            floatingContextMenu.animate().alpha(1f).setDuration(100).setListener(null);
            onFloatingActionGlobalLayout(contextMenuPoint.x, contextMenuPoint.y);
          }
        }
      }
    });
  }

  @RequiresApi(api = Build.VERSION_CODES.KITKAT)
  public void getSelectedText(final ValueCallback<String> resultCallback) {
    evaluateJavascript(PluginScriptsUtil.GET_SELECTED_TEXT_JS_SOURCE, new ValueCallback<String>() {
      @Override
      public void onReceiveValue(String value) {
        value = (value != null && !value.equalsIgnoreCase("null")) ? value.substring(1, value.length() - 1) : null;
        resultCallback.onReceiveValue(value);
      }
    });
  }

  public Map<String, Object> requestFocusNodeHref() {
    Message msg = InAppWebView.mHandler.obtainMessage();
    requestFocusNodeHref(msg);
    Bundle bundle = msg.peekData();

    Map<String, Object> obj = new HashMap<>();
    obj.put("src", bundle.getString("src"));
    obj.put("url", bundle.getString("url"));
    obj.put("title", bundle.getString("title"));

    return obj;
  }

  public Map<String, Object> requestImageRef() {
    Message msg = InAppWebView.mHandler.obtainMessage();
    requestImageRef(msg);
    Bundle bundle = msg.peekData();

    Map<String, Object> obj = new HashMap<>();
    obj.put("url", bundle.getString("url"));

    return obj;
  }

  @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
  public void callAsyncJavaScript(String functionBody, Map<String, Object> arguments, @Nullable ContentWorld contentWorld, @Nullable ValueCallback<String> resultCallback) {
    String resultUuid = UUID.randomUUID().toString();
    if (resultCallback != null) {
      callAsyncJavaScriptCallbacks.put(resultUuid, resultCallback);
    }

    JSONObject functionArguments = new JSONObject(arguments);
    Iterator<String> keys = functionArguments.keys();

    List<String> functionArgumentNamesList = new ArrayList<>();
    List<String> functionArgumentValuesList = new ArrayList<>();
    while (keys.hasNext()) {
      String key = keys.next();
      functionArgumentNamesList.add(key);
      functionArgumentValuesList.add("obj." + key);
    }

    String functionArgumentNames = TextUtils.join(", ", functionArgumentNamesList);
    String functionArgumentValues = TextUtils.join(", ", functionArgumentValuesList);
    String functionArgumentsObj = Util.JSONStringify(arguments);

    String sourceToInject = PluginScriptsUtil.CALL_ASYNC_JAVA_SCRIPT_WRAPPER_JS_SOURCE
            .replace(PluginScriptsUtil.VAR_FUNCTION_ARGUMENT_NAMES, functionArgumentNames)
            .replace(PluginScriptsUtil.VAR_FUNCTION_ARGUMENT_VALUES, functionArgumentValues)
            .replace(PluginScriptsUtil.VAR_FUNCTION_ARGUMENTS_OBJ, functionArgumentsObj)
            .replace(PluginScriptsUtil.VAR_FUNCTION_BODY, functionBody)
            .replace(PluginScriptsUtil.VAR_RESULT_UUID, resultUuid)
            .replace(PluginScriptsUtil.VAR_RESULT_UUID, resultUuid);

    sourceToInject = userContentController.generateCodeForScriptEvaluation(sourceToInject, contentWorld);
    evaluateJavascript(sourceToInject, null);
  }

  @TargetApi(Build.VERSION_CODES.LOLLIPOP)
  public void isSecureContext(final ValueCallback<Boolean> resultCallback) {
    evaluateJavascript("window.isSecureContext", new ValueCallback<String>() {
      @Override
      public void onReceiveValue(String value) {
        if (value == null || value.isEmpty() || value.equalsIgnoreCase("null")
                || value.equalsIgnoreCase("false")) {
          resultCallback.onReceiveValue(false);
          return;
        }
        resultCallback.onReceiveValue(true);
      }
    });
  }

  public boolean canScrollVertically() {
    return computeVerticalScrollRange() > computeVerticalScrollExtent();
  }

  public boolean canScrollHorizontally() {
    return computeHorizontalScrollRange() > computeHorizontalScrollExtent();
  }

  public WebMessageChannel createCompatWebMessageChannel() {
    String id = UUID.randomUUID().toString();
    WebMessageChannel webMessageChannel = new WebMessageChannel(id, this);
    webMessageChannels.put(id, webMessageChannel);
    return webMessageChannel;
  }

  @Override
  public WebMessageChannel createWebMessageChannel(ValueCallback<WebMessageChannel> callback) {
    WebMessageChannel webMessageChannel = createCompatWebMessageChannel();
    callback.onReceiveValue(webMessageChannel);
    return webMessageChannel;
  }

  public void addWebMessageListener(@NonNull WebMessageListener webMessageListener) throws Exception {
    WebViewCompat.addWebMessageListener(this, webMessageListener.jsObjectName, webMessageListener.allowedOriginRules, webMessageListener.listener);
    webMessageListeners.add(webMessageListener);
  }

  public void disposeWebMessageChannels() {
    for (WebMessageChannel webMessageChannel : webMessageChannels.values()) {
      webMessageChannel.dispose();
    }
    webMessageChannels.clear();
  }

  public void disposeWebMessageListeners() {
    for (WebMessageListener webMessageListener : webMessageListeners) {
      webMessageListener.dispose();
    }
    webMessageListeners.clear();
  }

  @Override
  public Looper getWebViewLooper() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
      return super.getWebViewLooper();
    }
    return Looper.getMainLooper();
  }

  @Override
  public void postWebMessage(com.pichillilorenzo.flutter_inappwebview.types.WebMessage message, Uri targetOrigin, ValueCallback<String> callback) throws Exception {
    throw new UnsupportedOperationException();
  }

  //  @Override
//  protected void onWindowVisibilityChanged(int visibility) {
//    if (visibility != View.GONE) super.onWindowVisibilityChanged(View.VISIBLE);
//  }

  public float getZoomScale() {
    return zoomScale;
  }

  @Override
  public void getZoomScale(final ValueCallback<Float> callback) {
    callback.onReceiveValue(zoomScale);
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
    return userContentController;
  }

  public void setUserContentController(UserContentController userContentController) {
    this.userContentController = userContentController;
  }

  public Map<String, WebMessageChannel> getWebMessageChannels() {
    return webMessageChannels;
  }

  public void setWebMessageChannels(Map<String, WebMessageChannel> webMessageChannels) {
    this.webMessageChannels = webMessageChannels;
  }

  @Override
  public void getContentHeight(ValueCallback<Integer> callback) {
    callback.onReceiveValue(getContentHeight());
  }

  @Override
  public void getHitTestResult(ValueCallback<com.pichillilorenzo.flutter_inappwebview.types.HitTestResult> callback) {
    callback.onReceiveValue(com.pichillilorenzo.flutter_inappwebview.types.HitTestResult.fromWebViewHitTestResult(getHitTestResult()));
  }

  @Override
  public void dispose() {
    if (windowId != null) {
      InAppWebViewChromeClient.windowWebViewMessages.remove(windowId);
    }
    mainLooperHandler.removeCallbacksAndMessages(null);
    mHandler.removeCallbacksAndMessages(null);
    disposeWebMessageChannels();
    disposeWebMessageListeners();
    removeAllViews();
    if (checkContextMenuShouldBeClosedTask != null)
      removeCallbacks(checkContextMenuShouldBeClosedTask);
    if (checkScrollStoppedTask != null)
      removeCallbacks(checkScrollStoppedTask);
    callAsyncJavaScriptCallbacks.clear();
    evaluateJavaScriptContentWorldCallbacks.clear();
    inAppBrowserDelegate = null;
    inAppWebViewChromeClient = null;
    inAppWebViewClient = null;
    javaScriptBridgeInterface = null;
    inAppWebViewRenderProcessClient = null;
    plugin = null;
    super.dispose();
  }

  @Override
  public void destroy() {
    super.destroy();
  }
}
