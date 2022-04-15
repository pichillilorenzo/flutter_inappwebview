package com.pichillilorenzo.flutter_inappwebview.in_app_geckoview;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Point;
import android.net.Uri;
import android.net.http.SslCertificate;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.util.Log;
import android.view.MotionEvent;
import android.webkit.ValueCallback;
import android.webkit.WebMessage;
import android.webkit.WebView;

import androidx.annotation.Nullable;

import com.pichillilorenzo.flutter_inappwebview.InAppWebViewFlutterPlugin;
import com.pichillilorenzo.flutter_inappwebview.Util;
import com.pichillilorenzo.flutter_inappwebview.in_app_browser.InAppBrowserDelegate;
import com.pichillilorenzo.flutter_inappwebview.in_app_webview.InAppWebViewChromeClient;
import com.pichillilorenzo.flutter_inappwebview.in_app_webview.InAppWebViewOptions;
import com.pichillilorenzo.flutter_inappwebview.plugin_scripts_js.JavaScriptBridgeJS;
import com.pichillilorenzo.flutter_inappwebview.types.ContentWorld;
import com.pichillilorenzo.flutter_inappwebview.types.HitTestResult;
import com.pichillilorenzo.flutter_inappwebview.types.InAppWebViewInterface;
import com.pichillilorenzo.flutter_inappwebview.types.PreferredContentModeOptionType;
import com.pichillilorenzo.flutter_inappwebview.types.URLRequest;
import com.pichillilorenzo.flutter_inappwebview.types.UserContentController;
import com.pichillilorenzo.flutter_inappwebview.types.UserScript;
import com.pichillilorenzo.flutter_inappwebview.types.WebMessageChannel;
import com.pichillilorenzo.flutter_inappwebview.types.WebMessageListener;
import com.pichillilorenzo.flutter_inappwebview.types.WebMessagePort;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.mozilla.geckoview.GeckoResult;
import org.mozilla.geckoview.GeckoSession;
import org.mozilla.geckoview.GeckoSessionSettings;
import org.mozilla.geckoview.GeckoView;
import org.mozilla.geckoview.PanZoomController;
import org.mozilla.geckoview.ScreenLength;
import org.mozilla.geckoview.StorageController;
import org.mozilla.geckoview.WebExtension;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URI;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import io.flutter.plugin.common.MethodChannel;

public class InAppGeckoView extends GeckoView implements InAppWebViewInterface {

  static final String LOG_TAG = "InAppGeckoView";

  @Nullable
  public InAppWebViewFlutterPlugin plugin;
  @Nullable
  public InAppBrowserDelegate inAppBrowserDelegate;
  public MethodChannel channel;
  public Object id;
  @Nullable
  public Integer windowId;
  public InAppWebViewOptions options;
  @Nullable
  public Map<String, Object> contextMenu = null;
  public UserContentController userContentController = new UserContentController();
  public Map<String, ValueCallback<String>> callAsyncJavaScriptCallbacks = new HashMap<>();
  public Map<String, ValueCallback<String>> evaluateJavaScriptContentWorldCallbacks = new HashMap<>();
  public boolean isLoading = false;
  public float zoomScale = 1.0f;
  public boolean canGoBack = false;
  public boolean canGoForward = false;
  public int progress = 0;
  @Nullable
  public String currentUrl;
  @Nullable
  public String currentOriginalUrl;
  @Nullable
  public String currentTitle;
  @Nullable
  public GeckoSession.HistoryDelegate.HistoryList historyList;
  @Nullable
  public String lastSearchString;
  @Nullable
  public Point lastTouchPoint;
  @Nullable
  public JSONObject lastImageTouched;
  @Nullable
  public JSONObject lastAnchorOrImageTouched;
  @Nullable
  public SslCertificate sslCertificate;
  public boolean secureContext;

  // Used to manage pauseTimers() and resumeTimers()
  public boolean isPausedTimers = false;
  @Nullable
  public GeckoSession.PromptDelegate.PromptResponse isPausedTimersPromptResponse;
  @Nullable
  public GeckoResult<GeckoSession.PromptDelegate.PromptResponse> isPausedTimersGeckoResult;

  public Map<String, WebMessageChannel> webMessageChannels = new HashMap<>();
  public List<WebMessageListener> webMessageListeners = new ArrayList<>();
  @Nullable
  public EvaluateJavaScriptDelegate evaluateJavaScriptDelegate;
  @Nullable
  public JavascriptBridgeDelegate javascriptBridgeDelegate;
  public Handler mainLooperHandler = new Handler(Looper.getMainLooper());

  public InAppGeckoView(Context context) {
    super(context);
  }

  public InAppGeckoView(Context context, AttributeSet attrs) {
    super(context, attrs);
  }

  public InAppGeckoView(Context context, InAppWebViewFlutterPlugin plugin,
                      MethodChannel channel, Object id,
                      @Nullable Integer windowId, InAppWebViewOptions options,
                      @Nullable Map<String, Object> contextMenu,
                      List<UserScript> userScripts) {
    super(context);
    this.plugin = plugin;
    this.channel = channel;
    this.id = id;
    this.windowId = windowId;
    this.options = options;
    this.contextMenu = contextMenu;
    this.userContentController.addUserOnlyScripts(userScripts);
    plugin.activity.registerForContextMenu(this);
  }

  public void prepare() {
//    userContentController.addPluginScript(JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_JS_PLUGIN_SCRIPT);
//    userContentController.addPluginScript(ConsoleLogJS.CONSOLE_LOG_JS_PLUGIN_SCRIPT);
//    userContentController.addPluginScript(PrintJS.PRINT_JS_PLUGIN_SCRIPT);
//    userContentController.addPluginScript(OnWindowBlurEventJS.ON_WINDOW_BLUR_EVENT_JS_PLUGIN_SCRIPT);
//    userContentController.addPluginScript(OnWindowFocusEventJS.ON_WINDOW_FOCUS_EVENT_JS_PLUGIN_SCRIPT);
//    if (options.useShouldInterceptAjaxRequest) {
//      userContentController.addPluginScript(InterceptAjaxRequestJS.INTERCEPT_AJAX_REQUEST_JS_PLUGIN_SCRIPT);
//    }
//    if (options.useShouldInterceptFetchRequest) {
//      userContentController.addPluginScript(InterceptFetchRequestJS.INTERCEPT_FETCH_REQUEST_JS_PLUGIN_SCRIPT);
//    }
//    if (options.useOnLoadResource) {
//      userContentController.addPluginScript(OnLoadResourceJS.ON_LOAD_RESOURCE_JS_PLUGIN_SCRIPT);
//    }
//    JSONObject documentStartPluginScripts = new JSONObject();
//    try {
//      documentStartPluginScripts.put("js", new JSONArray() {
//        {
//          put(new JSONObject() {
//            {
////              put("code", "var window = window.wrappedJSObject; window.flutter_inappwebview = cloneInto({'asd': 4}, window, {cloneFunctions: true}); exportFunction(function(){console.log('lol test asda');}, window, {defineAs:'alert'}); window.test = 5;");
//              put("code", JavaScriptBridgeJS.JAVASCRIPT_GECKO_VIEW_BEFORE_JS_SOURCE + userContentController.generatePluginScriptsCodeAt(UserScriptInjectionTime.AT_DOCUMENT_START) + JavaScriptBridgeJS.JAVASCRIPT_GECKO_VIEW_AFTER_JS_SOURCE);
//            }
//          });
//        }
//      });
//      documentStartPluginScripts.put("matches", new JSONArray() {
//        {
//          put("<all_urls>");
//        }
//      });
//      documentStartPluginScripts.put("runAt", "document_start");
//      documentStartPluginScripts.put("matchAboutBlank", true);
//      documentStartPluginScripts.put("allFrames", true);
//    } catch (JSONException e) {
//      e.printStackTrace();
//    }
    
    GeckoSessionSettings.Builder sessionSettingsBuilder = new GeckoSessionSettings.Builder();
    sessionSettingsBuilder.allowJavascript(options.javaScriptEnabled);
    sessionSettingsBuilder.usePrivateMode(options.incognito);
    if (options.preferredContentMode != PreferredContentModeOptionType.RECOMMENDED.toValue()) {
      PreferredContentModeOptionType contentMode = PreferredContentModeOptionType.fromValue(options.preferredContentMode);
      switch (contentMode) {
        case MOBILE:
          sessionSettingsBuilder.userAgentMode(GeckoSessionSettings.USER_AGENT_MODE_MOBILE);
          sessionSettingsBuilder.viewportMode(GeckoSessionSettings.VIEWPORT_MODE_MOBILE);
          break;
        case DESKTOP:
          sessionSettingsBuilder.userAgentMode(GeckoSessionSettings.USER_AGENT_MODE_DESKTOP);
          sessionSettingsBuilder.viewportMode(GeckoSessionSettings.VIEWPORT_MODE_DESKTOP);
      }
    }
    if (options.userAgent != null && !options.userAgent.isEmpty())
      sessionSettingsBuilder.userAgentOverride(options.userAgent);

    final GeckoSession session = new GeckoSession(sessionSettingsBuilder.build());

    session.setProgressDelegate(new InAppGeckoViewProgressDelegate(this, this.channel, this.inAppBrowserDelegate));
    session.setNavigationDelegate(new InAppGeckoViewNavigationDelegate(this, this.channel, this.inAppBrowserDelegate));
    session.setHistoryDelegate(new InAppGeckoViewHistoryDelegate(this, this.channel));
    session.setContentDelegate(new InAppGeckoViewContentDelegate(this, this.channel, this.inAppBrowserDelegate));
    session.setPromptDelegate(new InAppGeckoViewPromptDelegate(this, this.channel));

    setSession(session);
    
    session.open(InAppWebViewFlutterPlugin.geckoRuntime);

    evaluateJavaScriptDelegate = new EvaluateJavaScriptDelegate();
    WebExtension evaluateJavascriptWebExtension = GeckoRuntimeManager.defaultWebExtensions.get(GeckoRuntimeManager.EVALUATE_JAVASCRIPT_WEB_EXT_ID);
    if (evaluateJavascriptWebExtension != null) {
      session.getWebExtensionController().setMessageDelegate(evaluateJavascriptWebExtension, evaluateJavaScriptDelegate, "evaluateJavascript");
    }

    javascriptBridgeDelegate = new JavascriptBridgeDelegate(this);
    WebExtension javascriptBridgeDelegateWebExtension = GeckoRuntimeManager.defaultWebExtensions.get(GeckoRuntimeManager.JAVASCRIPT_BRIDGE_WEB_EXT_ID);
    if (javascriptBridgeDelegateWebExtension != null) {
      session.getWebExtensionController().setMessageDelegate(javascriptBridgeDelegateWebExtension, javascriptBridgeDelegate, "javascriptBridge");
    }
  }

  @Override
  public boolean onTouchEvent(MotionEvent ev) {
    float pixelDensity = Util.getPixelDensity(getContext());
    lastTouchPoint = new Point((int) (ev.getX()/pixelDensity), (int) (ev.getY()/pixelDensity));
    
    return super.onTouchEvent(ev);
  }

  @Nullable
  @Override
  public String getUrl() {
    return currentUrl;
  }

  @Nullable
  @Override
  public String getTitle() {
    return currentTitle;
  }

  @Override
  public int getProgress() {
    return progress;
  }

  @Override
  public void loadUrl(URLRequest urlRequest) {
    GeckoSession session = getSession();
    if (session == null) {
      return;
    }
    
    String url = urlRequest.getUrl();
    String method = urlRequest.getMethod();
    if (method != null && method.equals("POST")) {
      byte[] postData = urlRequest.getBody();
      postUrl(url, postData);
      return;
    }
    Map<String, String> headers = urlRequest.getHeaders();
    if (headers != null) {
      GeckoSession.Loader loader = new GeckoSession.Loader()
              .uri(url)
              .additionalHeaders(headers);
      session.load(loader);
      return;
    }
    loadUrl(url);
  }

  public void loadUrl(String url) {GeckoSession session = getSession();
    if (session == null) {
      return;
    }

    GeckoSession.Loader loader = new GeckoSession.Loader()
            .uri(url);
    session.load(loader);
  }

  @Override
  public void postUrl(String url, byte[] postData) {
    GeckoSession session = getSession();
    if (session == null) {
      return;
    }

    try {
      String data = new String(postData, "UTF-8");
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
    } catch (UnsupportedEncodingException e) {
      e.printStackTrace();
    }
  }

  @Override
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

  @Override
  public void loadFile(String assetFilePath) throws IOException {
    if (plugin == null) {
      return;
    }

    loadUrl(Util.getUrlAsset(plugin, assetFilePath, true));
  }

  public void injectDeferredObject(String source, @Nullable final ContentWorld contentWorld, String jsWrapper, @Nullable final ValueCallback<String> resultCallback) {
    final String resultUuid = contentWorld != null && !contentWorld.equals(ContentWorld.PAGE) ? UUID.randomUUID().toString() : null;
    String scriptToInject = source;
    if (jsWrapper != null) {
      JSONArray jsonEsc = new JSONArray();
      jsonEsc.put(source);
      String jsonRepr = jsonEsc.toString();
      String jsonSourceString = jsonRepr.substring(1, jsonRepr.length() - 1);
      scriptToInject = String.format(jsWrapper, jsonSourceString);
    }
    if (resultUuid != null && resultCallback != null) {
      evaluateJavaScriptContentWorldCallbacks.put(resultUuid, resultCallback);
      // TODO: implement
//      scriptToInject = Util.replaceAll(PluginScriptsUtil.EVALUATE_JAVASCRIPT_WITH_CONTENT_WORLD_WRAPPER_JS_SOURCE,
//              PluginScriptsUtil.VAR_RANDOM_NAME, "_" + JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_NAME + "_" + Math.round(Math.random() * 1000000))
//              .replace(PluginScriptsUtil.VAR_PLACEHOLDER_VALUE, UserContentController.escapeCode(source))
//              .replace(PluginScriptsUtil.VAR_RESULT_UUID, resultUuid);
    }
    final String finalScriptToInject = scriptToInject;
    mainLooperHandler.post(new Runnable() {
      @Override
      public void run() {
        String scriptToInject = userContentController.generateCodeForScriptEvaluation(finalScriptToInject, contentWorld);
        if (evaluateJavaScriptDelegate != null)
          evaluateJavaScriptDelegate.evaluate(scriptToInject, contentWorld, resultCallback);
      }
    });
  }


  @Override
  public void evaluateJavascript(String source, @Nullable ContentWorld contentWorld, @Nullable ValueCallback<String> resultCallback) {
    injectDeferredObject(source, contentWorld, null, resultCallback);
  }

  @Override
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
            " script.src = %s; d.body.appendChild(script); })(document);";
    injectDeferredObject(urlFile, null, jsWrapper, null);
  }

  @Override
  public void injectCSSCode(String source) {
    String jsWrapper = "(function(d) { var style = d.createElement('style'); style.innerHTML = %s; d.head.appendChild(style); })(document);";
    injectDeferredObject(source, null, jsWrapper, null);
  }

  @Override
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
            cssLinkAttributes + " link.href = %s; d.head.appendChild(link); })(document);";
    injectDeferredObject(urlFile, null, jsWrapper, null);
  }

  @Override
  public void reload() {
    GeckoSession session = getSession();
    if (session == null) {
      return;
    }

    session.reload();
  }

  @Override
  public void goBack() {
    GeckoSession session = getSession();
    if (session == null) {
      return;
    }

    session.goBack();
  }

  @Override
  public boolean canGoBack() {
    return canGoBack;
  }

  @Override
  public void goForward() {
    GeckoSession session = getSession();
    if (session == null) {
      return;
    }

    session.goForward();
  }

  @Override
  public boolean canGoForward() {
    return canGoForward;
  }

  @Override
  public void goBackOrForward(int steps) {
    if (historyList == null) {
      return;
    }

    GeckoSession session = getSession();
    if (session == null) {
      return;
    }

    int currentIndex = historyList.getCurrentIndex();
    session.gotoHistoryIndex(currentIndex + steps);
  }

  @Override
  public boolean canGoBackOrForward(int steps) {
    if (historyList == null || historyList.size() > 0) {
      return false;
    }

    if (steps < 0) {
      return historyList.getCurrentIndex() - steps >= 0;
    }
    return historyList.getCurrentIndex() + steps <= historyList.size() - 1;
  }

  @Override
  public void stopLoading() {
    GeckoSession session = getSession();
    if (session == null) {
      return;
    }

    session.stop();
  }

  @Override
  public boolean isLoading() {
    return isLoading;
  }

  @Override
  public void takeScreenshot(final Map<String, Object> screenshotConfiguration, final MethodChannel.Result result) {

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
              mainLooperHandler.post(new Runnable() {
                @Override
                public void run() {
                  result.success(byteArrayOutputStream.toByteArray());
                }
              });
            }
          }, new GeckoResult.Consumer<Throwable>() {
            @Override
            public void accept(@Nullable Throwable throwable) {
              if (throwable != null)
                throwable.printStackTrace();

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

  @Override
  public void setOptions(InAppWebViewOptions newOptions, HashMap<String, Object> newOptionsMap) {
    // TODO: implement
  }

  @Override
  public Map<String, Object> getOptions() {
    return (options != null) ? options.getRealOptions(this) : null;
  }

  @Nullable
  @Override
  public HashMap<String, Object> getCopyBackForwardList() {
    if (historyList == null) {
      return null;
    }

    int currentIndex = historyList.getCurrentIndex();

    List<HashMap<String, String>> history = new ArrayList<HashMap<String, String>>();

    for (GeckoSession.HistoryDelegate.HistoryItem historyItem : historyList) {
      HashMap<String, String> historyItemMap = new HashMap<>();

      historyItemMap.put("originalUrl", historyItem.getUri());
      historyItemMap.put("title", historyItem.getTitle());
      historyItemMap.put("url", historyItem.getUri());

      history.add(historyItemMap);
    }

    HashMap<String, Object> result = new HashMap<>();

    result.put("history", history);
    result.put("currentIndex", currentIndex);

    return result;
  }

  @Override
  public void clearAllCache() {
    if (InAppWebViewFlutterPlugin.geckoRuntime != null) {
      InAppWebViewFlutterPlugin.geckoRuntime.getStorageController().clearData(StorageController.ClearFlags.ALL);
    }
  }

  @Override
  public void clearSslPreferences() {
    // empty, no implementation available for Mozilla's GeckoView
  }

  @Override
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
          Map<String, Object> obj = new HashMap<>();
          obj.put("activeMatchOrdinal", finderResult.current - 1);
          obj.put("numberOfMatches", finderResult.total);
          obj.put("isDoneCounting", finderResult.current == finderResult.total);
          // TODO: add finderResult.linkUri and other fields
          channel.invokeMethod("onFindResultReceived", obj);
        }
      }
    }, new GeckoResult.Consumer<Throwable>() {
      @Override
      public void accept(@Nullable Throwable throwable) {
        if (throwable != null) {
          throwable.printStackTrace();
        }
      }
    });
  }

  @Override
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
          Map<String, Object> obj = new HashMap<>();
          obj.put("activeMatchOrdinal", finderResult.current - 1);
          obj.put("numberOfMatches", finderResult.total);
          obj.put("isDoneCounting", finderResult.current == finderResult.total);
          // TODO: add finderResult.linkUri and other fields
          channel.invokeMethod("onFindResultReceived", obj);
        }
      }
    }, new GeckoResult.Consumer<Throwable>() {
      @Override
      public void accept(@Nullable Throwable throwable) {
        if (throwable != null) {
          throwable.printStackTrace();
        }
      }
    });
  }

  @Override
  public void clearMatches() {
    GeckoSession session = getSession();
    if (session == null) {
      return;
    }

    session.getFinder().clear();
  }

  @Override
  public void scrollTo(Integer x, Integer y, Boolean animated) {
    getPanZoomController().scrollTo(ScreenLength.fromPixels(x),
            ScreenLength.fromPixels(y),
            animated ? PanZoomController.SCROLL_BEHAVIOR_SMOOTH : PanZoomController.SCROLL_BEHAVIOR_AUTO);
  }

  @Override
  public void scrollBy(Integer x, Integer y, Boolean animated) {
    getPanZoomController().scrollBy(ScreenLength.fromPixels(x),
            ScreenLength.fromPixels(y),
            animated ? PanZoomController.SCROLL_BEHAVIOR_SMOOTH : PanZoomController.SCROLL_BEHAVIOR_AUTO);
  }

  @Override
  public void onPause() {
    // empty, no implementation available for Mozilla's GeckoView
  }

  @Override
  public void onResume() {
    // empty, no implementation available for Mozilla's GeckoView
  }

  @Override
  public void pauseTimers() {
    if (!isPausedTimers) {
      isPausedTimers = true;
      String script = "alert();";
      evaluateJavascript(script, null, null);
    }
  }

  @Override
  public void resumeTimers() {
    if (isPausedTimers) {
      if (isPausedTimersGeckoResult != null && isPausedTimersPromptResponse != null) {
        isPausedTimersGeckoResult.complete(isPausedTimersPromptResponse);
        isPausedTimersGeckoResult = null;
        isPausedTimersPromptResponse = null;
      }
      isPausedTimers = false;
    }
  }

  @Override
  public void printCurrentPage() {
    // empty, no implementation available for Mozilla's GeckoView
  }

  @Override
  public int getContentHeight() {
    throw new UnsupportedOperationException();
  }

  @Override
  public void getContentHeight(final ValueCallback<Integer> callback) {
    GeckoSession session = getSession();
    if (session == null) {
      callback.onReceiveValue(getHeight());
      return;
    }

    if (session.getSettings().getAllowJavascript()) {
      evaluateJavascript("document.documentElement.scrollHeight", null, new ValueCallback<String>() {
        @Override
        public void onReceiveValue(String value) {
          if (value != null && !value.equalsIgnoreCase("null") && !value.isEmpty()) {
            try {
              callback.onReceiveValue(Integer.valueOf(value));
            } catch (Exception e) {
              callback.onReceiveValue(getHeight());
            }
          } else {
            callback.onReceiveValue(getHeight());
          }
        }
      });
    } else {
      callback.onReceiveValue(getHeight());
    }
  }

  @Override
  public void zoomBy(float zoomFactor) {
    // empty, no implementation available for Mozilla's GeckoView
  }

  @Nullable
  @Override
  public String getOriginalUrl() {
    return this.currentOriginalUrl;
  }

  @Override
  public void getSelectedText(final ValueCallback<String> callback) {
    GeckoSession session = getSession();
    if (session == null) {
      callback.onReceiveValue(null);
      return;
    }

    if (session.getSettings().getAllowJavascript()) {
      evaluateJavascript("window.getSelection().toString()", null, new ValueCallback<String>() {
        @Override
        public void onReceiveValue(String value) {
          value = (value != null && !value.equalsIgnoreCase("null")) ? value : null;
          callback.onReceiveValue(value);
        }
      });
    } else {
      callback.onReceiveValue(null);
    }
  }

  @Override
  public WebView.HitTestResult getHitTestResult() {
    throw new UnsupportedOperationException();
  }

  @Override
  public void getHitTestResult(final ValueCallback<HitTestResult> callback) {
    final HitTestResult hitTestResult = new HitTestResult(WebView.HitTestResult.UNKNOWN_TYPE, null);

    GeckoSession session = getSession();
    if (session == null) {
      callback.onReceiveValue(hitTestResult);
      return;
    }
    
    if (lastTouchPoint != null && session.getSettings().getAllowJavascript()) {
      evaluateJavascript("(window.wrappedJSObject != null ? window.wrappedJSObject : window)." + JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_NAME + "._findElementsAtPoint(" + lastTouchPoint.x + ", " + lastTouchPoint.y + ");",
              null, new ValueCallback<String>() {
        @Override
        public void onReceiveValue(String value) {
          if (value != null && !value.equalsIgnoreCase("null") && !value.isEmpty()) {
            try {
              JSONObject jsonObject = new JSONObject(value);
              hitTestResult.setType(jsonObject.getInt("type"));
              hitTestResult.setExtra(jsonObject.getString("extra"));
              callback.onReceiveValue(hitTestResult);
            } catch (JSONException e) {
              e.printStackTrace();
              callback.onReceiveValue(hitTestResult);
            }
          } else {
            callback.onReceiveValue(hitTestResult);
          }
        }
      });
    } else {
      callback.onReceiveValue(hitTestResult);
    }
  }

  @Override
  public boolean pageDown(boolean bottom) {
    return false;
  }

  @Override
  public boolean pageUp(boolean top) {
    return false;
  }

  @Override
  public void saveWebArchive(String basename, boolean autoname, ValueCallback<String> callback) {
    // empty, no implementation available for Mozilla's GeckoView
    callback.onReceiveValue(null);
  }

  @Override
  public boolean zoomIn() {
    // empty, no implementation available for Mozilla's GeckoView
    return false;
  }

  @Override
  public boolean zoomOut() {
    // empty, no implementation available for Mozilla's GeckoView
    return false;
  }

  @Override
  public Map<String, Object> requestFocusNodeHref() {
    GeckoSession session = getSession();
    if (session == null || !session.getSettings().getAllowJavascript() || lastAnchorOrImageTouched == null) {
      return null;
    }

    try {
      Map<String, Object> obj = new HashMap<>();
      obj.put("src", lastAnchorOrImageTouched.getString("src"));
      obj.put("url", lastAnchorOrImageTouched.getString("url"));
      obj.put("title", lastAnchorOrImageTouched.getString("title"));
      return obj;
    } catch (JSONException e) {
      e.printStackTrace();
    }

    return null;
  }

  @Override
  public Map<String, Object> requestImageRef() {
    GeckoSession session = getSession();
    if (session == null || !session.getSettings().getAllowJavascript() || lastImageTouched == null) {
      return null;
    }

    try {
      Map<String, Object> obj = new HashMap<>();
      obj.put("url", lastImageTouched.getString("url"));
      return obj;
    } catch (JSONException e) {
      e.printStackTrace();
    }

    return null;
  }

  @Override
  public SslCertificate getCertificate() {
    return sslCertificate;
  }

  @Override
  public void clearHistory() {
    GeckoSession session = getSession();
    if (session != null) {
      session.purgeHistory();
    }
  }

  @Override
  public void callAsyncJavaScript(String functionBody, Map<String, Object> arguments, ContentWorld contentWorld, ValueCallback<String> resultCallback) {

  }

  @Override
  public void isSecureContext(ValueCallback<Boolean> resultCallback) {
    resultCallback.onReceiveValue(secureContext);
  }

  @Override
  public WebMessageChannel createCompatWebMessageChannel() {
    throw new UnsupportedOperationException();
  }

  @Override
  public WebMessageChannel createWebMessageChannel(ValueCallback<WebMessageChannel> callback) {
    String id = UUID.randomUUID().toString();
    WebMessageChannel webMessageChannel = new WebMessageChannel(id, this);
    webMessageChannel.initJsInstance(this, callback);
    webMessageChannels.put(id, webMessageChannel);
    return webMessageChannel;
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
  public void postWebMessage(WebMessage message, Uri targetOrigin) {
    throw new UnsupportedOperationException();
  }

  @Override
  public void postWebMessage(com.pichillilorenzo.flutter_inappwebview.types.WebMessage message, Uri targetOrigin, ValueCallback<String> callback) throws Exception {
    String portsString = "null";
    List<WebMessagePort> ports = message.ports;
    if (ports != null) {
      List<String> portArrayString = new ArrayList<>();
      for (WebMessagePort port : ports) {
        if (port.isStarted) {
          throw new Exception("Port is already started");
        }
        if (port.isClosed || port.isTransferred) {
          throw new Exception("Port is already closed or transferred");
        }
        port.isTransferred = true;
        portArrayString.add(JavaScriptBridgeJS.WEB_MESSAGE_CHANNELS_VARIABLE_NAME + "['" + port.webMessageChannel.id + "']." + port.name);
      }
      portsString = "[" + TextUtils.join(", ", portArrayString) + "]";
    }
    String data = message.data != null ? Util.replaceAll(message.data, "\'", "\\'") : "null";
    String url = targetOrigin != null ? targetOrigin.toString() : "*";
    String source = "(function() {" +
            "  window.postMessage('" + data + "', '" + url + "', " + portsString  + ");" +
            "})();";
    evaluateJavascript(source, ContentWorld.PAGE, callback);
    message.dispose();
  }

  @Override
  public void addWebMessageListener(WebMessageListener webMessageListener) throws Exception {
    for (WebMessageListener listener : webMessageListeners) {
      if (listener.jsObjectName.equals(webMessageListener.jsObjectName)) {
        throw new Exception("jsObjectName " + webMessageListener.jsObjectName + " was already added.");
      }
    }
    webMessageListener.assertOriginRulesValid();
    webMessageListener.initJsInstance();
    webMessageListeners.add(webMessageListener);
  }

  @Override
  public boolean canScrollVertically() {
    return false;
  }

  @Override
  public boolean canScrollHorizontally() {
    return false;
  }

  @Override
  public float getZoomScale() {
    throw new UnsupportedOperationException();
  }

  @Override
  public void getZoomScale(final ValueCallback<Float> callback) {
    evaluateJavascript("(window.wrappedJSObject != null ? window.wrappedJSObject : window).visualViewport.scale;", null, new ValueCallback<String>() {
      @Override
      public void onReceiveValue(String value) {
        if (value != null && !value.equalsIgnoreCase("null") && !value.isEmpty()) {
          try {
            callback.onReceiveValue(Float.valueOf(value));
          } catch (Exception e) {
            callback.onReceiveValue(1.0f);
          }
        } else {
          callback.onReceiveValue(1.0f);
        }
      }
    });
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

  public void dispose() {
    resumeTimers();
    stopLoading();

    if (windowId != null) {
      InAppWebViewChromeClient.windowWebViewMessages.remove(windowId);
    }

    GeckoSession session = releaseSession();
    
    InAppGeckoViewProgressDelegate progressDelegate = (InAppGeckoViewProgressDelegate) session.getProgressDelegate();
    assert progressDelegate != null;
    progressDelegate.dispose();
    session.setProgressDelegate(null);

    InAppGeckoViewNavigationDelegate navigationDelegate = (InAppGeckoViewNavigationDelegate) session.getNavigationDelegate();
    assert navigationDelegate != null;
    navigationDelegate.dispose();
    session.setNavigationDelegate(null);

    InAppGeckoViewHistoryDelegate historyDelegate = (InAppGeckoViewHistoryDelegate) session.getHistoryDelegate();
    assert historyDelegate != null;
    historyDelegate.dispose();
    session.setHistoryDelegate(null);

    InAppGeckoViewContentDelegate contentDelegate = (InAppGeckoViewContentDelegate) session.getContentDelegate();
    assert contentDelegate != null;
    contentDelegate.dispose();
    session.setContentDelegate(null);

    InAppGeckoViewPromptDelegate promptDelegate = (InAppGeckoViewPromptDelegate) session.getPromptDelegate();
    assert promptDelegate != null;
    promptDelegate.dispose();
    session.setPromptDelegate(null);

    session.close();

    assert evaluateJavaScriptDelegate != null;
    evaluateJavaScriptDelegate.dispose();
    evaluateJavaScriptDelegate = null;

    assert javascriptBridgeDelegate != null;
    javascriptBridgeDelegate.dispose();
    javascriptBridgeDelegate = null;

    historyList = null;

    disposeWebMessageChannels();
    disposeWebMessageListeners();
    removeAllViews();
    mainLooperHandler.removeCallbacksAndMessages(null);
//    callAsyncJavaScriptCallbacks.clear();
//    evaluateJavaScriptContentWorldCallbacks.clear();
    inAppBrowserDelegate = null;
//    inAppWebViewChromeClient = null;
//    inAppWebViewClient = null;
//    javaScriptBridgeInterface = null;
//    inAppWebViewRenderProcessClient = null;
    plugin = null;
  }
}
