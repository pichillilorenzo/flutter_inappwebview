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
import com.pichillilorenzo.flutter_inappwebview.types.DownloadStartRequest;
import com.pichillilorenzo.flutter_inappwebview.types.InAppWebViewInterface;
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
  public InAppWebViewOptions options;
  public boolean isLoading = false;
  public float zoomScale = 1.0f;
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
                      @Nullable Integer windowId, InAppWebViewOptions options,
                      @Nullable Map<String, Object> contextMenu, View containerView,
                      List<UserScript> userScripts) {
    super(context, containerView, options.useHybridComposition);
    this.plugin = plugin;
    this.channel = channel;
    this.id = id;
    this.windowId = windowId;
    this.options = options;
    this.contextMenu = contextMenu;
    this.userContentController.addUserOnlyScripts(userScripts);
    if (plugin != null && plugin.activity != null) {
      plugin.activity.registerForContextMenu(this);
    }
  }

  public void prepare() {
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
    if (options.useShouldInterceptAjaxRequest) {
      userContentController.addPluginScript(InterceptAjaxRequestJS.INTERCEPT_AJAX_REQUEST_JS_PLUGIN_SCRIPT);
    }
    if (options.useShouldInterceptFetchRequest) {
      userContentController.addPluginScript(InterceptFetchRequestJS.INTERCEPT_FETCH_REQUEST_JS_PLUGIN_SCRIPT);
    }
    if (options.useOnLoadResource) {
      userContentController.addPluginScript(OnLoadResourceJS.ON_LOAD_RESOURCE_JS_PLUGIN_SCRIPT);
    }
    if (!options.useHybridComposition) {
      userContentController.addPluginScript(PluginScriptsUtil.CHECK_GLOBAL_KEY_DOWN_EVENT_TO_HIDE_CONTEXT_MENU_JS_PLUGIN_SCRIPT);
    }

    if (options.useOnDownloadStart)
      setDownloadListener(new DownloadStartListener());

    WebSettings settings = getSettings();

    settings.setJavaScriptEnabled(options.javaScriptEnabled);
    settings.setJavaScriptCanOpenWindowsAutomatically(options.javaScriptCanOpenWindowsAutomatically);
    settings.setBuiltInZoomControls(options.builtInZoomControls);
    settings.setDisplayZoomControls(options.displayZoomControls);
    settings.setSupportMultipleWindows(options.supportMultipleWindows);

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
      settings.setSafeBrowsingEnabled(options.safeBrowsingEnabled);

    settings.setMediaPlaybackRequiresUserGesture(options.mediaPlaybackRequiresUserGesture);

    settings.setDatabaseEnabled(options.databaseEnabled);
    settings.setDomStorageEnabled(options.domStorageEnabled);

    if (options.userAgent != null && !options.userAgent.isEmpty())
      settings.setUserAgentString(options.userAgent);
    else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1)
      settings.setUserAgentString(WebSettings.getDefaultUserAgent(getContext()));

    if (options.applicationNameForUserAgent != null && !options.applicationNameForUserAgent.isEmpty()) {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
        String userAgent = (options.userAgent != null && !options.userAgent.isEmpty()) ? options.userAgent : WebSettings.getDefaultUserAgent(getContext());
        String userAgentWithApplicationName = userAgent + " " + options.applicationNameForUserAgent;
        settings.setUserAgentString(userAgentWithApplicationName);
      }
    }

    if (options.clearCache)
      clearAllCache();
    else if (options.clearSessionCache)
      CookieManager.getInstance().removeSessionCookie();

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
      CookieManager.getInstance().setAcceptThirdPartyCookies(this, options.thirdPartyCookiesEnabled);

    settings.setLoadWithOverviewMode(options.loadWithOverviewMode);
    settings.setUseWideViewPort(options.useWideViewPort);
    settings.setSupportZoom(options.supportZoom);
    settings.setTextZoom(options.textZoom);

    setVerticalScrollBarEnabled(!options.disableVerticalScroll && options.verticalScrollBarEnabled);
    setHorizontalScrollBarEnabled(!options.disableHorizontalScroll && options.horizontalScrollBarEnabled);

    if (options.transparentBackground)
      setBackgroundColor(Color.TRANSPARENT);

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP && options.mixedContentMode != null)
      settings.setMixedContentMode(options.mixedContentMode);

    settings.setAllowContentAccess(options.allowContentAccess);
    settings.setAllowFileAccess(options.allowFileAccess);
    settings.setAllowFileAccessFromFileURLs(options.allowFileAccessFromFileURLs);
    settings.setAllowUniversalAccessFromFileURLs(options.allowUniversalAccessFromFileURLs);
    setCacheEnabled(options.cacheEnabled);
    if (options.appCachePath != null && !options.appCachePath.isEmpty() && options.cacheEnabled) {
      // removed from Android API 33+ (https://developer.android.com/sdk/api_diff/33/changes)
      // settings.setAppCachePath(options.appCachePath);
      Util.invokeMethodIfExists(settings, "setAppCachePath", options.appCachePath);
    }
    settings.setBlockNetworkImage(options.blockNetworkImage);
    settings.setBlockNetworkLoads(options.blockNetworkLoads);
    if (options.cacheMode != null)
      settings.setCacheMode(options.cacheMode);
    settings.setCursiveFontFamily(options.cursiveFontFamily);
    settings.setDefaultFixedFontSize(options.defaultFixedFontSize);
    settings.setDefaultFontSize(options.defaultFontSize);
    settings.setDefaultTextEncodingName(options.defaultTextEncodingName);
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N && options.disabledActionModeMenuItems != null)
      settings.setDisabledActionModeMenuItems(options.disabledActionModeMenuItems);
    settings.setFantasyFontFamily(options.fantasyFontFamily);
    settings.setFixedFontFamily(options.fixedFontFamily);
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && options.forceDark != null)
      settings.setForceDark(options.forceDark);
    settings.setGeolocationEnabled(options.geolocationEnabled);
    if (options.layoutAlgorithm != null) {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT && options.layoutAlgorithm.equals(WebSettings.LayoutAlgorithm.TEXT_AUTOSIZING)) {
        settings.setLayoutAlgorithm(options.layoutAlgorithm);
      } else {
        settings.setLayoutAlgorithm(options.layoutAlgorithm);
      }
    }
    settings.setLoadsImagesAutomatically(options.loadsImagesAutomatically);
    settings.setMinimumFontSize(options.minimumFontSize);
    settings.setMinimumLogicalFontSize(options.minimumLogicalFontSize);
    setInitialScale(options.initialScale);
    settings.setNeedInitialFocus(options.needInitialFocus);
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
      settings.setOffscreenPreRaster(options.offscreenPreRaster);
    settings.setSansSerifFontFamily(options.sansSerifFontFamily);
    settings.setSerifFontFamily(options.serifFontFamily);
    settings.setStandardFontFamily(options.standardFontFamily);
    if (options.preferredContentMode != null &&
            options.preferredContentMode == PreferredContentModeOptionType.DESKTOP.toValue()) {
      setDesktopMode(true);
    }
    settings.setSaveFormData(options.saveFormData);
    if (options.incognito)
      setIncognito(true);
    if (options.hardwareAcceleration)
      setLayerType(View.LAYER_TYPE_HARDWARE, null);
    else
      setLayerType(View.LAYER_TYPE_SOFTWARE, null);
    if (options.regexToCancelSubFramesLoading != null) {
      regexToCancelSubFramesLoadingCompiled = Pattern.compile(options.regexToCancelSubFramesLoading);
    }
    setScrollBarStyle(options.scrollBarStyle);
    if (options.scrollBarDefaultDelayBeforeFade != null) {
      setScrollBarDefaultDelayBeforeFade(options.scrollBarDefaultDelayBeforeFade);
    } else {
      options.scrollBarDefaultDelayBeforeFade = getScrollBarDefaultDelayBeforeFade();
    }
    setScrollbarFadingEnabled(options.scrollbarFadingEnabled);
    if (options.scrollBarFadeDuration != null) {
      setScrollBarFadeDuration(options.scrollBarFadeDuration);
    } else {
      options.scrollBarFadeDuration = getScrollBarFadeDuration();
    }
    setVerticalScrollbarPosition(options.verticalScrollbarPosition);

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
      if (options.verticalScrollbarThumbColor != null)
        setVerticalScrollbarThumbDrawable(new ColorDrawable(Color.parseColor(options.verticalScrollbarThumbColor)));
      if (options.verticalScrollbarTrackColor != null)
        setVerticalScrollbarTrackDrawable(new ColorDrawable(Color.parseColor(options.verticalScrollbarTrackColor)));
      if (options.horizontalScrollbarThumbColor != null)
        setHorizontalScrollbarThumbDrawable(new ColorDrawable(Color.parseColor(options.horizontalScrollbarThumbColor)));
      if (options.horizontalScrollbarTrackColor != null)
        setHorizontalScrollbarTrackDrawable(new ColorDrawable(Color.parseColor(options.horizontalScrollbarTrackColor)));
    }

    setOverScrollMode(options.overScrollMode);
    if (options.networkAvailable != null) {
      setNetworkAvailable(options.networkAvailable);
    }
    if (options.rendererPriorityPolicy != null && !options.rendererPriorityPolicy.isEmpty() && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      setRendererPriorityPolicy(
              (int) options.rendererPriorityPolicy.get("rendererRequestedPriority"),
              (boolean) options.rendererPriorityPolicy.get("waivedWhenNotVisible"));
    }

    contentBlockerHandler.getRuleList().clear();
    for (Map<String, Map<String, Object>> contentBlocker : options.contentBlockers) {
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

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT && !options.useHybridComposition) {
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

        if (options.disableHorizontalScroll && options.disableVerticalScroll) {
          return (event.getAction() == MotionEvent.ACTION_MOVE);
        } else if (options.disableHorizontalScroll || options.disableVerticalScroll) {
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
              if (options.disableHorizontalScroll) {
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

      // removed from Android API 33+ (https://developer.android.com/sdk/api_diff/33/changes)
      // settings.setAppCacheEnabled(false);
      Util.invokeMethodIfExists(settings, "setAppCacheEnabled", false);

      clearHistory();
      clearCache(true);

      // No form data or autofill enabled
      clearFormData();
      settings.setSavePassword(false);
      settings.setSaveFormData(false);
    } else {
      settings.setCacheMode(WebSettings.LOAD_DEFAULT);

      // removed from Android API 33+ (https://developer.android.com/sdk/api_diff/33/changes)
      // settings.setAppCacheEnabled(true);
      Util.invokeMethodIfExists(settings, "setAppCacheEnabled", true);

      settings.setSavePassword(true);
      settings.setSaveFormData(true);
    }
  }

  public void setCacheEnabled(boolean enabled) {
    WebSettings settings = getSettings();
    if (enabled) {
      Context ctx = getContext();
      if (ctx != null) {
        // removed from Android API 33+ (https://developer.android.com/sdk/api_diff/33/changes)
        // settings.setAppCachePath(ctx.getCacheDir().getAbsolutePath());
        Util.invokeMethodIfExists(settings, "setAppCachePath", ctx.getCacheDir().getAbsolutePath());

        settings.setCacheMode(WebSettings.LOAD_DEFAULT);

        // removed from Android API 33+ (https://developer.android.com/sdk/api_diff/33/changes)
        // settings.setAppCacheEnabled(true);
        Util.invokeMethodIfExists(settings, "setAppCacheEnabled", true);
      }
    } else {
      settings.setCacheMode(WebSettings.LOAD_NO_CACHE);

      // removed from Android API 33+ (https://developer.android.com/sdk/api_diff/33/changes)
      // settings.setAppCacheEnabled(false);
      Util.invokeMethodIfExists(settings, "setAppCacheEnabled", false);
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

  public void setOptions(InAppWebViewOptions newOptions, HashMap<String, Object> newOptionsMap) {

    WebSettings settings = getSettings();

    if (newOptionsMap.get("javaScriptEnabled") != null && options.javaScriptEnabled != newOptions.javaScriptEnabled)
      settings.setJavaScriptEnabled(newOptions.javaScriptEnabled);

    if (newOptionsMap.get("useShouldInterceptAjaxRequest") != null && options.useShouldInterceptAjaxRequest != newOptions.useShouldInterceptAjaxRequest) {
      enablePluginScriptAtRuntime(
              InterceptAjaxRequestJS.FLAG_VARIABLE_FOR_SHOULD_INTERCEPT_AJAX_REQUEST_JS_SOURCE,
              newOptions.useShouldInterceptAjaxRequest,
              InterceptAjaxRequestJS.INTERCEPT_AJAX_REQUEST_JS_PLUGIN_SCRIPT
      );
    }

    if (newOptionsMap.get("useShouldInterceptFetchRequest") != null && options.useShouldInterceptFetchRequest != newOptions.useShouldInterceptFetchRequest) {
      enablePluginScriptAtRuntime(
              InterceptFetchRequestJS.FLAG_VARIABLE_FOR_SHOULD_INTERCEPT_FETCH_REQUEST_JS_SOURCE,
              newOptions.useShouldInterceptFetchRequest,
              InterceptFetchRequestJS.INTERCEPT_FETCH_REQUEST_JS_PLUGIN_SCRIPT
      );
    }

    if (newOptionsMap.get("useOnLoadResource") != null && options.useOnLoadResource != newOptions.useOnLoadResource) {
      enablePluginScriptAtRuntime(
              OnLoadResourceJS.FLAG_VARIABLE_FOR_ON_LOAD_RESOURCE_JS_SOURCE,
              newOptions.useOnLoadResource,
              OnLoadResourceJS.ON_LOAD_RESOURCE_JS_PLUGIN_SCRIPT
      );
    }

    if (newOptionsMap.get("javaScriptCanOpenWindowsAutomatically") != null && options.javaScriptCanOpenWindowsAutomatically != newOptions.javaScriptCanOpenWindowsAutomatically)
      settings.setJavaScriptCanOpenWindowsAutomatically(newOptions.javaScriptCanOpenWindowsAutomatically);

    if (newOptionsMap.get("builtInZoomControls") != null && options.builtInZoomControls != newOptions.builtInZoomControls)
      settings.setBuiltInZoomControls(newOptions.builtInZoomControls);

    if (newOptionsMap.get("displayZoomControls") != null && options.displayZoomControls != newOptions.displayZoomControls)
      settings.setDisplayZoomControls(newOptions.displayZoomControls);

    if (newOptionsMap.get("safeBrowsingEnabled") != null && options.safeBrowsingEnabled != newOptions.safeBrowsingEnabled && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
      settings.setSafeBrowsingEnabled(newOptions.safeBrowsingEnabled);

    if (newOptionsMap.get("mediaPlaybackRequiresUserGesture") != null && options.mediaPlaybackRequiresUserGesture != newOptions.mediaPlaybackRequiresUserGesture)
      settings.setMediaPlaybackRequiresUserGesture(newOptions.mediaPlaybackRequiresUserGesture);

    if (newOptionsMap.get("databaseEnabled") != null && options.databaseEnabled != newOptions.databaseEnabled)
      settings.setDatabaseEnabled(newOptions.databaseEnabled);

    if (newOptionsMap.get("domStorageEnabled") != null && options.domStorageEnabled != newOptions.domStorageEnabled)
      settings.setDomStorageEnabled(newOptions.domStorageEnabled);

    if (newOptionsMap.get("userAgent") != null && !options.userAgent.equals(newOptions.userAgent) && !newOptions.userAgent.isEmpty())
      settings.setUserAgentString(newOptions.userAgent);

    if (newOptionsMap.get("applicationNameForUserAgent") != null && !options.applicationNameForUserAgent.equals(newOptions.applicationNameForUserAgent) && !newOptions.applicationNameForUserAgent.isEmpty()) {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
        String userAgent = (newOptions.userAgent != null && !newOptions.userAgent.isEmpty()) ? newOptions.userAgent : WebSettings.getDefaultUserAgent(getContext());
        String userAgentWithApplicationName = userAgent + " " + options.applicationNameForUserAgent;
        settings.setUserAgentString(userAgentWithApplicationName);
      }
    }

    if (newOptionsMap.get("clearCache") != null && newOptions.clearCache)
      clearAllCache();
    else if (newOptionsMap.get("clearSessionCache") != null && newOptions.clearSessionCache)
      CookieManager.getInstance().removeSessionCookie();

    if (newOptionsMap.get("thirdPartyCookiesEnabled") != null && options.thirdPartyCookiesEnabled != newOptions.thirdPartyCookiesEnabled && Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
      CookieManager.getInstance().setAcceptThirdPartyCookies(this, newOptions.thirdPartyCookiesEnabled);

    if (newOptionsMap.get("useWideViewPort") != null && options.useWideViewPort != newOptions.useWideViewPort)
      settings.setUseWideViewPort(newOptions.useWideViewPort);

    if (newOptionsMap.get("supportZoom") != null && options.supportZoom != newOptions.supportZoom)
      settings.setSupportZoom(newOptions.supportZoom);

    if (newOptionsMap.get("textZoom") != null && !options.textZoom.equals(newOptions.textZoom))
      settings.setTextZoom(newOptions.textZoom);

    if (newOptionsMap.get("verticalScrollBarEnabled") != null && options.verticalScrollBarEnabled != newOptions.verticalScrollBarEnabled)
      setVerticalScrollBarEnabled(newOptions.verticalScrollBarEnabled);

    if (newOptionsMap.get("horizontalScrollBarEnabled") != null && options.horizontalScrollBarEnabled != newOptions.horizontalScrollBarEnabled)
      setHorizontalScrollBarEnabled(newOptions.horizontalScrollBarEnabled);

    if (newOptionsMap.get("transparentBackground") != null && options.transparentBackground != newOptions.transparentBackground) {
      if (newOptions.transparentBackground) {
        setBackgroundColor(Color.TRANSPARENT);
      } else {
        setBackgroundColor(Color.parseColor("#FFFFFF"));
      }
    }

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
      if (newOptionsMap.get("mixedContentMode") != null && (options.mixedContentMode == null || !options.mixedContentMode.equals(newOptions.mixedContentMode)))
        settings.setMixedContentMode(newOptions.mixedContentMode);

    if (newOptionsMap.get("supportMultipleWindows") != null && options.supportMultipleWindows != newOptions.supportMultipleWindows)
      settings.setSupportMultipleWindows(newOptions.supportMultipleWindows);

    if (newOptionsMap.get("useOnDownloadStart") != null && options.useOnDownloadStart != newOptions.useOnDownloadStart) {
      if (newOptions.useOnDownloadStart) {
        setDownloadListener(new DownloadStartListener());
      } else {
        setDownloadListener(null);
      }
    }

    if (newOptionsMap.get("allowContentAccess") != null && options.allowContentAccess != newOptions.allowContentAccess)
      settings.setAllowContentAccess(newOptions.allowContentAccess);

    if (newOptionsMap.get("allowFileAccess") != null && options.allowFileAccess != newOptions.allowFileAccess)
      settings.setAllowFileAccess(newOptions.allowFileAccess);

    if (newOptionsMap.get("allowFileAccessFromFileURLs") != null && options.allowFileAccessFromFileURLs != newOptions.allowFileAccessFromFileURLs)
      settings.setAllowFileAccessFromFileURLs(newOptions.allowFileAccessFromFileURLs);

    if (newOptionsMap.get("allowUniversalAccessFromFileURLs") != null && options.allowUniversalAccessFromFileURLs != newOptions.allowUniversalAccessFromFileURLs)
      settings.setAllowUniversalAccessFromFileURLs(newOptions.allowUniversalAccessFromFileURLs);

    if (newOptionsMap.get("cacheEnabled") != null && options.cacheEnabled != newOptions.cacheEnabled)
      setCacheEnabled(newOptions.cacheEnabled);

    if (newOptionsMap.get("appCachePath") != null && (options.appCachePath == null || !options.appCachePath.equals(newOptions.appCachePath))) {
      // removed from Android API 33+ (https://developer.android.com/sdk/api_diff/33/changes)
      // settings.setAppCachePath(newOptions.appCachePath);
      Util.invokeMethodIfExists(settings, "setAppCachePath", newOptions.appCachePath);
    }

    if (newOptionsMap.get("blockNetworkImage") != null && options.blockNetworkImage != newOptions.blockNetworkImage)
      settings.setBlockNetworkImage(newOptions.blockNetworkImage);

    if (newOptionsMap.get("blockNetworkLoads") != null && options.blockNetworkLoads != newOptions.blockNetworkLoads)
      settings.setBlockNetworkLoads(newOptions.blockNetworkLoads);

    if (newOptionsMap.get("cacheMode") != null && !options.cacheMode.equals(newOptions.cacheMode))
      settings.setCacheMode(newOptions.cacheMode);

    if (newOptionsMap.get("cursiveFontFamily") != null && !options.cursiveFontFamily.equals(newOptions.cursiveFontFamily))
      settings.setCursiveFontFamily(newOptions.cursiveFontFamily);

    if (newOptionsMap.get("defaultFixedFontSize") != null && !options.defaultFixedFontSize.equals(newOptions.defaultFixedFontSize))
      settings.setDefaultFixedFontSize(newOptions.defaultFixedFontSize);

    if (newOptionsMap.get("defaultFontSize") != null && !options.defaultFontSize.equals(newOptions.defaultFontSize))
      settings.setDefaultFontSize(newOptions.defaultFontSize);

    if (newOptionsMap.get("defaultTextEncodingName") != null && !options.defaultTextEncodingName.equals(newOptions.defaultTextEncodingName))
      settings.setDefaultTextEncodingName(newOptions.defaultTextEncodingName);

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N)
      if (newOptionsMap.get("disabledActionModeMenuItems") != null && (options.disabledActionModeMenuItems == null ||
              !options.disabledActionModeMenuItems.equals(newOptions.disabledActionModeMenuItems)))
        settings.setDisabledActionModeMenuItems(newOptions.disabledActionModeMenuItems);

    if (newOptionsMap.get("fantasyFontFamily") != null && !options.fantasyFontFamily.equals(newOptions.fantasyFontFamily))
      settings.setFantasyFontFamily(newOptions.fantasyFontFamily);

    if (newOptionsMap.get("fixedFontFamily") != null && !options.fixedFontFamily.equals(newOptions.fixedFontFamily))
      settings.setFixedFontFamily(newOptions.fixedFontFamily);

    if (newOptionsMap.get("forceDark") != null && !options.forceDark.equals(newOptions.forceDark))
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q)
        settings.setForceDark(newOptions.forceDark);

    if (newOptionsMap.get("geolocationEnabled") != null && options.geolocationEnabled != newOptions.geolocationEnabled)
      settings.setGeolocationEnabled(newOptions.geolocationEnabled);

    if (newOptionsMap.get("layoutAlgorithm") != null && options.layoutAlgorithm != newOptions.layoutAlgorithm) {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT && newOptions.layoutAlgorithm.equals(WebSettings.LayoutAlgorithm.TEXT_AUTOSIZING)) {
        settings.setLayoutAlgorithm(newOptions.layoutAlgorithm);
      } else {
        settings.setLayoutAlgorithm(newOptions.layoutAlgorithm);
      }
    }

    if (newOptionsMap.get("loadWithOverviewMode") != null && options.loadWithOverviewMode != newOptions.loadWithOverviewMode)
      settings.setLoadWithOverviewMode(newOptions.loadWithOverviewMode);

    if (newOptionsMap.get("loadsImagesAutomatically") != null && options.loadsImagesAutomatically != newOptions.loadsImagesAutomatically)
      settings.setLoadsImagesAutomatically(newOptions.loadsImagesAutomatically);

    if (newOptionsMap.get("minimumFontSize") != null && !options.minimumFontSize.equals(newOptions.minimumFontSize))
      settings.setMinimumFontSize(newOptions.minimumFontSize);

    if (newOptionsMap.get("minimumLogicalFontSize") != null && !options.minimumLogicalFontSize.equals(newOptions.minimumLogicalFontSize))
      settings.setMinimumLogicalFontSize(newOptions.minimumLogicalFontSize);

    if (newOptionsMap.get("initialScale") != null && !options.initialScale.equals(newOptions.initialScale))
      setInitialScale(newOptions.initialScale);

    if (newOptionsMap.get("needInitialFocus") != null && options.needInitialFocus != newOptions.needInitialFocus)
      settings.setNeedInitialFocus(newOptions.needInitialFocus);

    if (newOptionsMap.get("offscreenPreRaster") != null && options.offscreenPreRaster != newOptions.offscreenPreRaster)
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
        settings.setOffscreenPreRaster(newOptions.offscreenPreRaster);

    if (newOptionsMap.get("sansSerifFontFamily") != null && !options.sansSerifFontFamily.equals(newOptions.sansSerifFontFamily))
      settings.setSansSerifFontFamily(newOptions.sansSerifFontFamily);

    if (newOptionsMap.get("serifFontFamily") != null && !options.serifFontFamily.equals(newOptions.serifFontFamily))
      settings.setSerifFontFamily(newOptions.serifFontFamily);

    if (newOptionsMap.get("standardFontFamily") != null && !options.standardFontFamily.equals(newOptions.standardFontFamily))
      settings.setStandardFontFamily(newOptions.standardFontFamily);

    if (newOptionsMap.get("preferredContentMode") != null && !options.preferredContentMode.equals(newOptions.preferredContentMode)) {
      switch (fromValue(newOptions.preferredContentMode)) {
        case DESKTOP:
          setDesktopMode(true);
          break;
        case MOBILE:
        case RECOMMENDED:
          setDesktopMode(false);
          break;
      }
    }

    if (newOptionsMap.get("saveFormData") != null && options.saveFormData != newOptions.saveFormData)
      settings.setSaveFormData(newOptions.saveFormData);

    if (newOptionsMap.get("incognito") != null && options.incognito != newOptions.incognito)
      setIncognito(newOptions.incognito);

    if (newOptionsMap.get("hardwareAcceleration") != null && options.hardwareAcceleration != newOptions.hardwareAcceleration) {
      if (newOptions.hardwareAcceleration)
        setLayerType(View.LAYER_TYPE_HARDWARE, null);
      else
        setLayerType(View.LAYER_TYPE_SOFTWARE, null);
    }

    if (newOptionsMap.get("regexToCancelSubFramesLoading") != null && (options.regexToCancelSubFramesLoading == null ||
            !options.regexToCancelSubFramesLoading.equals(newOptions.regexToCancelSubFramesLoading))) {
      if (newOptions.regexToCancelSubFramesLoading == null)
        regexToCancelSubFramesLoadingCompiled = null;
      else
        regexToCancelSubFramesLoadingCompiled = Pattern.compile(options.regexToCancelSubFramesLoading);
    }

    if (newOptions.contentBlockers != null) {
      contentBlockerHandler.getRuleList().clear();
      for (Map<String, Map<String, Object>> contentBlocker : newOptions.contentBlockers) {
        // compile ContentBlockerTrigger urlFilter
        ContentBlockerTrigger trigger = ContentBlockerTrigger.fromMap(contentBlocker.get("trigger"));
        ContentBlockerAction action = ContentBlockerAction.fromMap(contentBlocker.get("action"));
        contentBlockerHandler.getRuleList().add(new ContentBlocker(trigger, action));
      }
    }

    if (newOptionsMap.get("scrollBarStyle") != null && !options.scrollBarStyle.equals(newOptions.scrollBarStyle))
      setScrollBarStyle(newOptions.scrollBarStyle);

    if (newOptionsMap.get("scrollBarDefaultDelayBeforeFade") != null && (options.scrollBarDefaultDelayBeforeFade == null ||
            !options.scrollBarDefaultDelayBeforeFade.equals(newOptions.scrollBarDefaultDelayBeforeFade)))
      setScrollBarDefaultDelayBeforeFade(newOptions.scrollBarDefaultDelayBeforeFade);

    if (newOptionsMap.get("scrollbarFadingEnabled") != null && !options.scrollbarFadingEnabled.equals(newOptions.scrollbarFadingEnabled))
      setScrollbarFadingEnabled(newOptions.scrollbarFadingEnabled);

    if (newOptionsMap.get("scrollBarFadeDuration") != null && (options.scrollBarFadeDuration == null ||
            !options.scrollBarFadeDuration.equals(newOptions.scrollBarFadeDuration)))
      setScrollBarFadeDuration(newOptions.scrollBarFadeDuration);

    if (newOptionsMap.get("verticalScrollbarPosition") != null && !options.verticalScrollbarPosition.equals(newOptions.verticalScrollbarPosition))
      setVerticalScrollbarPosition(newOptions.verticalScrollbarPosition);

    if (newOptionsMap.get("disableVerticalScroll") != null && options.disableVerticalScroll != newOptions.disableVerticalScroll)
      setVerticalScrollBarEnabled(!newOptions.disableVerticalScroll && newOptions.verticalScrollBarEnabled);

    if (newOptionsMap.get("disableHorizontalScroll") != null && options.disableHorizontalScroll != newOptions.disableHorizontalScroll)
      setHorizontalScrollBarEnabled(!newOptions.disableHorizontalScroll && newOptions.horizontalScrollBarEnabled);

    if (newOptionsMap.get("overScrollMode") != null && !options.overScrollMode.equals(newOptions.overScrollMode))
      setOverScrollMode(newOptions.overScrollMode);

    if (newOptionsMap.get("networkAvailable") != null && options.networkAvailable != newOptions.networkAvailable)
      setNetworkAvailable(newOptions.networkAvailable);

    if (newOptionsMap.get("rendererPriorityPolicy") != null && (options.rendererPriorityPolicy == null ||
            (options.rendererPriorityPolicy.get("rendererRequestedPriority") != newOptions.rendererPriorityPolicy.get("rendererRequestedPriority") ||
                    options.rendererPriorityPolicy.get("waivedWhenNotVisible") != newOptions.rendererPriorityPolicy.get("waivedWhenNotVisible"))) &&
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      setRendererPriorityPolicy(
              (int) newOptions.rendererPriorityPolicy.get("rendererRequestedPriority"),
              (boolean) newOptions.rendererPriorityPolicy.get("waivedWhenNotVisible"));
    }

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
      if (newOptionsMap.get("verticalScrollbarThumbColor") != null && !Util.objEquals(options.verticalScrollbarThumbColor, newOptions.verticalScrollbarThumbColor))
        setVerticalScrollbarThumbDrawable(new ColorDrawable(Color.parseColor(newOptions.verticalScrollbarThumbColor)));

      if (newOptionsMap.get("verticalScrollbarTrackColor") != null && !Util.objEquals(options.verticalScrollbarTrackColor, newOptions.verticalScrollbarTrackColor))
        setVerticalScrollbarTrackDrawable(new ColorDrawable(Color.parseColor(newOptions.verticalScrollbarTrackColor)));

      if (newOptionsMap.get("horizontalScrollbarThumbColor") != null && !Util.objEquals(options.horizontalScrollbarThumbColor, newOptions.horizontalScrollbarThumbColor))
        setHorizontalScrollbarThumbDrawable(new ColorDrawable(Color.parseColor(newOptions.horizontalScrollbarThumbColor)));

      if (newOptionsMap.get("horizontalScrollbarTrackColor") != null && !Util.objEquals(options.horizontalScrollbarTrackColor, newOptions.horizontalScrollbarTrackColor))
        setHorizontalScrollbarTrackDrawable(new ColorDrawable(Color.parseColor(newOptions.horizontalScrollbarTrackColor)));
    }

    options = newOptions;
  }

  public Map<String, Object> getOptions() {
    return (options != null) ? options.getRealOptions(this) : null;
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
    if (plugin != null && plugin.activity != null) {
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
      setOverScrollMode(options.overScrollMode);
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
    if (connection == null && !options.useHybridComposition && containerView != null) {
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
    if (options.useHybridComposition && !options.disableContextMenu && (contextMenu == null || contextMenu.keySet().size() == 0)) {
      return super.startActionMode(callback);
    }
    return rebuildActionMode(super.startActionMode(callback), callback);
  }

  @RequiresApi(api = Build.VERSION_CODES.M)
  @Override
  public ActionMode startActionMode(ActionMode.Callback callback, int type) {
    if (options.useHybridComposition && !options.disableContextMenu && (contextMenu == null || contextMenu.keySet().size() == 0)) {
      return super.startActionMode(callback, type);
    }
    return rebuildActionMode(super.startActionMode(callback, type), callback);
  }

  public ActionMode rebuildActionMode(
          final ActionMode actionMode,
          final ActionMode.Callback callback
  ) {
    // fix Android 10 clipboard not working properly https://github.com/pichillilorenzo/flutter_inappwebview/issues/678
    if (!options.useHybridComposition && containerView != null) {
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
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      actionMode.hide(3000);
    }
    List<MenuItem> defaultMenuItems = new ArrayList<>();
    for (int i = 0; i < actionMenu.size(); i++) {
      defaultMenuItems.add(actionMenu.getItem(i));
    }
    actionMenu.clear();
    actionMode.finish();
    if (options.disableContextMenu) {
      return actionMode;
    }

    floatingContextMenu = (LinearLayout) LayoutInflater.from(this.getContext())
            .inflate(R.layout.floating_action_mode, this, false);
    HorizontalScrollView horizontalScrollView = (HorizontalScrollView) floatingContextMenu.getChildAt(0);
    LinearLayout menuItemListLayout = (LinearLayout) horizontalScrollView.getChildAt(0);

    List<Map<String, Object>> customMenuItems = new ArrayList<>();
    ContextMenuOptions contextMenuOptions = new ContextMenuOptions();
    if (contextMenu != null) {
      customMenuItems = (List<Map<String, Object>>) contextMenu.get("menuItems");
      Map<String, Object> contextMenuOptionsMap = (Map<String, Object>) contextMenu.get("options");
      if (contextMenuOptionsMap != null) {
        contextMenuOptions.parse(contextMenuOptionsMap);
      }
    }
    customMenuItems = customMenuItems == null ? new ArrayList<Map<String, Object>>() : customMenuItems;

    if (contextMenuOptions.hideDefaultSystemContextMenuItems == null || !contextMenuOptions.hideDefaultSystemContextMenuItems) {
      for (final MenuItem menuItem : defaultMenuItems) {
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
      final int itemId = (int) menuItem.get("androidId");
      final String itemTitle = (String) menuItem.get("title");
      TextView text = (TextView) LayoutInflater.from(this.getContext())
              .inflate(R.layout.floating_action_mode_item, this, false);
      text.setText(itemTitle);
      text.setOnClickListener(new OnClickListener() {
        @Override
        public void onClick(View v) {
          hideContextMenu();

          Map<String, Object> obj = new HashMap<>();
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
