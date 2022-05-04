package com.pichillilorenzo.flutter_inappwebview.in_app_webview;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.pichillilorenzo.flutter_inappwebview.Util;
import com.pichillilorenzo.flutter_inappwebview.types.BaseCallbackResultImpl;
import com.pichillilorenzo.flutter_inappwebview.types.ClientCertChallenge;
import com.pichillilorenzo.flutter_inappwebview.types.ClientCertResponse;
import com.pichillilorenzo.flutter_inappwebview.types.CreateWindowAction;
import com.pichillilorenzo.flutter_inappwebview.types.CustomSchemeResponse;
import com.pichillilorenzo.flutter_inappwebview.types.DownloadStartRequest;
import com.pichillilorenzo.flutter_inappwebview.types.GeolocationPermissionShowPromptResponse;
import com.pichillilorenzo.flutter_inappwebview.types.HitTestResult;
import com.pichillilorenzo.flutter_inappwebview.types.HttpAuthResponse;
import com.pichillilorenzo.flutter_inappwebview.types.HttpAuthenticationChallenge;
import com.pichillilorenzo.flutter_inappwebview.types.JsAlertResponse;
import com.pichillilorenzo.flutter_inappwebview.types.JsBeforeUnloadResponse;
import com.pichillilorenzo.flutter_inappwebview.types.JsConfirmResponse;
import com.pichillilorenzo.flutter_inappwebview.types.JsPromptResponse;
import com.pichillilorenzo.flutter_inappwebview.types.NavigationAction;
import com.pichillilorenzo.flutter_inappwebview.types.NavigationActionPolicy;
import com.pichillilorenzo.flutter_inappwebview.types.PermissionResponse;
import com.pichillilorenzo.flutter_inappwebview.types.SafeBrowsingResponse;
import com.pichillilorenzo.flutter_inappwebview.types.ServerTrustAuthResponse;
import com.pichillilorenzo.flutter_inappwebview.types.ServerTrustChallenge;
import com.pichillilorenzo.flutter_inappwebview.types.SyncBaseCallbackResultImpl;
import com.pichillilorenzo.flutter_inappwebview.types.WebResourceErrorExt;
import com.pichillilorenzo.flutter_inappwebview.types.WebResourceRequestExt;
import com.pichillilorenzo.flutter_inappwebview.types.WebResourceResponseExt;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class EventChannelDelegate {
  @Nullable
  private MethodChannel channel;

  public EventChannelDelegate(@Nullable MethodChannel channel) {
    this.channel = channel;
  }

  public void onFindResultReceived(int activeMatchOrdinal, int numberOfMatches, boolean isDoneCounting) {
    if (channel == null) return;
    Map<String, Object> obj = new HashMap<>();
    obj.put("activeMatchOrdinal", activeMatchOrdinal);
    obj.put("numberOfMatches", numberOfMatches);
    obj.put("isDoneCounting", isDoneCounting);
    channel.invokeMethod("onFindResultReceived", obj);
  }
  
  public void onLongPressHitTestResult(HitTestResult hitTestResult) {
    if (channel == null) return;
    channel.invokeMethod("onLongPressHitTestResult", hitTestResult.toMap());
  }

  public void onScrollChanged(int x, int y) {
    if (channel == null) return;
    Map<String, Object> obj = new HashMap<>();
    obj.put("x", x);
    obj.put("y", y);
    channel.invokeMethod("onScrollChanged", obj);
  }

  public void onDownloadStartRequest(DownloadStartRequest downloadStartRequest) {
    if (channel == null) return;
    channel.invokeMethod("onDownloadStartRequest", downloadStartRequest.toMap());
  }

  public void onCreateContextMenu(HitTestResult hitTestResult) {
    if (channel == null) return;
    channel.invokeMethod("onCreateContextMenu", hitTestResult.toMap());
  }

  public void onOverScrolled(int scrollX, int scrollY, boolean clampedX, boolean clampedY) {
    if (channel == null) return;
    Map<String, Object> obj = new HashMap<>();
    obj.put("x", scrollX);
    obj.put("y", scrollY);
    obj.put("clampedX", clampedX);
    obj.put("clampedY", clampedY);
    channel.invokeMethod("onOverScrolled", obj);
  }

  public void onContextMenuActionItemClicked(int itemId, String itemTitle) {
    if (channel == null) return;
    Map<String, Object> obj = new HashMap<>();
    obj.put("id", itemId);
    obj.put("androidId", itemId);
    obj.put("iosId", null);
    obj.put("title", itemTitle);
    channel.invokeMethod("onContextMenuActionItemClicked", obj);
  }

  public void onHideContextMenu() {
    if (channel == null) return;
    Map<String, Object> obj = new HashMap<>();
    channel.invokeMethod("onHideContextMenu", obj);
  }

  public void onEnterFullscreen() {
    if (channel == null) return;
    Map<String, Object> obj = new HashMap<>();
    channel.invokeMethod("onEnterFullscreen", obj);
  }

  public void onExitFullscreen() {
    if (channel == null) return;
    Map<String, Object> obj = new HashMap<>();
    channel.invokeMethod("onExitFullscreen", obj);
  }

  public static class JsAlertCallback extends BaseCallbackResultImpl<JsAlertResponse> {
    @Nullable
    @Override
    public JsAlertResponse decodeResult(@Nullable Object obj) {
      return JsAlertResponse.fromMap((Map<String, Object>) obj);
    }
  }
  
  public void onJsAlert(String url, String message, Boolean isMainFrame, @NonNull JsAlertCallback callback) {
    if (channel == null) {
      callback.defaultBehaviour(null);
      return;
    }
    Map<String, Object> obj = new HashMap<>();
    obj.put("url", url);
    obj.put("message", message);
    obj.put("isMainFrame", isMainFrame);
    channel.invokeMethod("onJsAlert", obj, callback);
  }

  public static class JsConfirmCallback extends BaseCallbackResultImpl<JsConfirmResponse> {
    @Nullable
    @Override
    public JsConfirmResponse decodeResult(@Nullable Object obj) {
      return JsConfirmResponse.fromMap((Map<String, Object>) obj);
    }
  }

  public void onJsConfirm(String url, String message, Boolean isMainFrame, @NonNull JsConfirmCallback callback) {
    if (channel == null) {
      callback.defaultBehaviour(null);
      return;
    }
    Map<String, Object> obj = new HashMap<>();
    obj.put("url", url);
    obj.put("message", message);
    obj.put("isMainFrame", isMainFrame);
    channel.invokeMethod("onJsConfirm", obj, callback);
  }

  public static class JsPromptCallback extends BaseCallbackResultImpl<JsPromptResponse> {
    @Nullable
    @Override
    public JsPromptResponse decodeResult(@Nullable Object obj) {
      return JsPromptResponse.fromMap((Map<String, Object>) obj);
    }
  }

  public void onJsPrompt(String url, String message, String defaultValue, Boolean isMainFrame, @NonNull JsPromptCallback callback) {
    if (channel == null) {
      callback.defaultBehaviour(null);
      return;
    }
    Map<String, Object> obj = new HashMap<>();
    obj.put("url", url);
    obj.put("message", message);
    obj.put("defaultValue", defaultValue);
    obj.put("isMainFrame", isMainFrame);
    channel.invokeMethod("onJsPrompt", obj, callback);
  }

  public static class JsBeforeUnloadCallback extends BaseCallbackResultImpl<JsBeforeUnloadResponse> {
    @Nullable
    @Override
    public JsBeforeUnloadResponse decodeResult(@Nullable Object obj) {
      return JsBeforeUnloadResponse.fromMap((Map<String, Object>) obj);
    }
  }

  public void onJsBeforeUnload(String url, String message, @NonNull JsBeforeUnloadCallback callback) {
    if (channel == null) {
      callback.defaultBehaviour(null);
      return;
    }
    Map<String, Object> obj = new HashMap<>();
    obj.put("url", url);
    obj.put("message", message);
    channel.invokeMethod("onJsBeforeUnload", obj, callback);
  }

  public static class CreateWindowCallback extends BaseCallbackResultImpl<Boolean> {
    @Nullable
    @Override
    public Boolean decodeResult(@Nullable Object obj) {
      return (obj instanceof Boolean) && (boolean) obj;
    }
  }

  public void onCreateWindow(CreateWindowAction createWindowAction, @NonNull CreateWindowCallback callback) {
    if (channel == null) {
      callback.defaultBehaviour(null);
      return;
    }
    channel.invokeMethod("onCreateWindow", createWindowAction.toMap(), callback);
  }

  public void onCloseWindow() {
    if (channel == null) return;
    Map<String, Object> obj = new HashMap<>();
    channel.invokeMethod("onCloseWindow", obj);
  }

  public static class GeolocationPermissionsShowPromptCallback extends BaseCallbackResultImpl<GeolocationPermissionShowPromptResponse> {
    @Nullable
    @Override
    public GeolocationPermissionShowPromptResponse decodeResult(@Nullable Object obj) {
      return GeolocationPermissionShowPromptResponse.fromMap((Map<String, Object>) obj);
    }
  }

  public void onGeolocationPermissionsShowPrompt(String origin, @NonNull GeolocationPermissionsShowPromptCallback callback) {
    if (channel == null) {
      callback.defaultBehaviour(null);
      return;
    }
    Map<String, Object> obj = new HashMap<>();
    obj.put("origin", origin);
    channel.invokeMethod("onGeolocationPermissionsShowPrompt", obj, callback);
  }

  public void onGeolocationPermissionsHidePrompt() {
    if (channel == null) return;
    Map<String, Object> obj = new HashMap<>();
    channel.invokeMethod("onGeolocationPermissionsHidePrompt", obj);
  }

  public void onConsoleMessage(String message, int messageLevel) {
    if (channel == null) return;
    Map<String, Object> obj = new HashMap<>();
    obj.put("message", message);
    obj.put("messageLevel", messageLevel);
    channel.invokeMethod("onConsoleMessage", obj);
  }

  public void onProgressChanged(int progress) {
    if (channel == null) return;
    Map<String, Object> obj = new HashMap<>();
    obj.put("progress", progress);
    channel.invokeMethod("onProgressChanged", obj);
  }

  public void onTitleChanged(String title) {
    if (channel == null) return;
    Map<String, Object> obj = new HashMap<>();
    obj.put("title", title);
    channel.invokeMethod("onTitleChanged", obj);
  }

  public void onReceivedIcon(byte[] icon) {
    if (channel == null) return;
    Map<String, Object> obj = new HashMap<>();
    obj.put("icon", icon);
    channel.invokeMethod("onReceivedIcon", obj);
  }

  public void onReceivedTouchIconUrl(String url, boolean precomposed) {
    if (channel == null) return;
    Map<String, Object> obj = new HashMap<>();
    obj.put("url", url);
    obj.put("precomposed", precomposed);
    channel.invokeMethod("onReceivedTouchIconUrl", obj);
  }

  public static class PermissionRequestCallback extends BaseCallbackResultImpl<PermissionResponse> {
    @Nullable
    @Override
    public PermissionResponse decodeResult(@Nullable Object obj) {
      return PermissionResponse.fromMap((Map<String, Object>) obj);
    }
  }

  public void onPermissionRequest(String origin, List<String> resources, Object frame, @NonNull PermissionRequestCallback callback) {
    if (channel == null) {
      callback.defaultBehaviour(null);
      return;
    }
    Map<String, Object> obj = new HashMap<>();
    obj.put("origin", origin);
    obj.put("resources", resources);
    obj.put("frame", frame);
    channel.invokeMethod("onPermissionRequest", obj, callback);
  }

  public static class ShouldOverrideUrlLoadingCallback extends BaseCallbackResultImpl<NavigationActionPolicy> {
    @Nullable
    @Override
    public NavigationActionPolicy decodeResult(@Nullable Object obj) {
      Integer action = Util.<Integer>getOrDefault((Map<String, Object>) obj, 
              "action", NavigationActionPolicy.CANCEL.rawValue());
      return NavigationActionPolicy.fromValue(action);
    }
  }

  public void shouldOverrideUrlLoading(NavigationAction navigationAction, @NonNull ShouldOverrideUrlLoadingCallback callback) {
    if (channel == null) {
      callback.defaultBehaviour(null);
      return;
    }
    channel.invokeMethod("shouldOverrideUrlLoading", navigationAction.toMap(), callback);
  }

  public void onLoadStart(String url) {
    if (channel == null) return;
    Map<String, Object> obj = new HashMap<>();
    obj.put("url", url);
    channel.invokeMethod("onLoadStart", obj);
  }

  public void onLoadStop(String url) {
    if (channel == null) return;
    Map<String, Object> obj = new HashMap<>();
    obj.put("url", url);
    channel.invokeMethod("onLoadStop", obj);
  }

  public void onUpdateVisitedHistory(String url, boolean isReload) {
    if (channel == null) return;
    Map<String, Object> obj = new HashMap<>();
    obj.put("url", url);
    obj.put("isReload", isReload);
    channel.invokeMethod("onUpdateVisitedHistory", obj);
  }

  public void onReceivedError(WebResourceRequestExt request, WebResourceErrorExt error) {
    if (channel == null) return;
    Map<String, Object> obj = new HashMap<>();
    obj.put("request", request.toMap());
    obj.put("error", error.toMap());
    channel.invokeMethod("onReceivedError", obj);
  }

  public void onReceivedHttpError(WebResourceRequestExt request, WebResourceResponseExt errorResponse) {
    if (channel == null) return;
    Map<String, Object> obj = new HashMap<>();
    obj.put("request", request.toMap());
    obj.put("errorResponse", errorResponse.toMap());
    channel.invokeMethod("onReceivedHttpError", obj);
  }

  public static class ReceivedHttpAuthRequestCallback extends BaseCallbackResultImpl<HttpAuthResponse> {
    @Nullable
    @Override
    public HttpAuthResponse decodeResult(@Nullable Object obj) {
      return HttpAuthResponse.fromMap((Map<String, Object>) obj);
    }
  }

  public void onReceivedHttpAuthRequest(HttpAuthenticationChallenge challenge, @NonNull ReceivedHttpAuthRequestCallback callback) {
    if (channel == null) {
      callback.defaultBehaviour(null);
      return;
    }
    channel.invokeMethod("onReceivedHttpAuthRequest", challenge.toMap(), callback);
  }

  public static class ReceivedServerTrustAuthRequestCallback extends BaseCallbackResultImpl<ServerTrustAuthResponse> {
    @Nullable
    @Override
    public ServerTrustAuthResponse decodeResult(@Nullable Object obj) {
      return ServerTrustAuthResponse.fromMap((Map<String, Object>) obj);
    }
  }

  public void onReceivedServerTrustAuthRequest(ServerTrustChallenge challenge, @NonNull ReceivedServerTrustAuthRequestCallback callback) {
    if (channel == null) {
      callback.defaultBehaviour(null);
      return;
    }
    channel.invokeMethod("onReceivedServerTrustAuthRequest", challenge.toMap(), callback);
  }

  public static class ReceivedClientCertRequestCallback extends BaseCallbackResultImpl<ClientCertResponse> {
    @Nullable
    @Override
    public ClientCertResponse decodeResult(@Nullable Object obj) {
      return ClientCertResponse.fromMap((Map<String, Object>) obj);
    }
  }

  public void onReceivedClientCertRequest(ClientCertChallenge challenge, @NonNull ReceivedClientCertRequestCallback callback) {
    if (channel == null) {
      callback.defaultBehaviour(null);
      return;
    }
    channel.invokeMethod("onReceivedClientCertRequest", challenge.toMap(), callback);
  }

  public void onZoomScaleChanged(float oldScale, float newScale) {
    if (channel == null) return;
    Map<String, Object> obj = new HashMap<>();
    obj.put("oldScale", oldScale);
    obj.put("newScale", newScale);
    channel.invokeMethod("onZoomScaleChanged", obj);
  }

  public static class SafeBrowsingHitCallback extends BaseCallbackResultImpl<SafeBrowsingResponse> {
    @Nullable
    @Override
    public SafeBrowsingResponse decodeResult(@Nullable Object obj) {
      return SafeBrowsingResponse.fromMap((Map<String, Object>) obj);
    }
  }

  public void onSafeBrowsingHit(String url, int threatType, @NonNull SafeBrowsingHitCallback callback) {
    if (channel == null) {
      callback.defaultBehaviour(null);
      return;
    }
    Map<String, Object> obj = new HashMap<>();
    obj.put("url", url);
    obj.put("threatType", threatType);
    channel.invokeMethod("onSafeBrowsingHit", obj, callback);
  }

  public static class FormResubmissionCallback extends BaseCallbackResultImpl<Integer> {
    @Nullable
    @Override
    public Integer decodeResult(@Nullable Object obj) {
      return obj != null ? (Integer) ((Map<String, Object>) obj).get("action") : null;
    }
  }

  public void onFormResubmission(String url, @NonNull FormResubmissionCallback callback) {
    if (channel == null) {
      callback.defaultBehaviour(null);
      return;
    }
    Map<String, Object> obj = new HashMap<>();
    obj.put("url", url);
    channel.invokeMethod("onFormResubmission", obj, callback);
  }

  public void onPageCommitVisible(String url) {
    if (channel == null) return;
    Map<String, Object> obj = new HashMap<>();
    obj.put("url", url);
    channel.invokeMethod("onPageCommitVisible", obj);
  }

  public void onRenderProcessGone(boolean didCrash, int rendererPriorityAtExit) {
    if (channel == null) return;
    Map<String, Object> obj = new HashMap<>();
    obj.put("didCrash", didCrash);
    obj.put("rendererPriorityAtExit", rendererPriorityAtExit);
    channel.invokeMethod("onRenderProcessGone", obj);
  }

  public void onReceivedLoginRequest(String realm, String account, String args) {
    if (channel == null) return;
    Map<String, Object> obj = new HashMap<>();
    obj.put("realm", realm);
    obj.put("account", account);
    obj.put("args", args);
    channel.invokeMethod("onReceivedLoginRequest", obj);
  }

  public static class LoadResourceCustomSchemeCallback extends BaseCallbackResultImpl<CustomSchemeResponse> {
    @Nullable
    @Override
    public CustomSchemeResponse decodeResult(@Nullable Object obj) {
      return CustomSchemeResponse.fromMap((Map<String, Object>) obj);
    }
  }

  public void onLoadResourceCustomScheme(String url, @NonNull LoadResourceCustomSchemeCallback callback) {
    if (channel == null) return;
    Map<String, Object> obj = new HashMap<>();
    obj.put("url", url);
    channel.invokeMethod("onLoadResourceCustomScheme", obj, callback);
  }

  public static class SyncLoadResourceCustomSchemeCallback extends SyncBaseCallbackResultImpl<CustomSchemeResponse> {
    @Nullable
    @Override
    public CustomSchemeResponse decodeResult(@Nullable Object obj) {
      return (new LoadResourceCustomSchemeCallback()).decodeResult(obj);
    }
  }
  
  @Nullable
  public CustomSchemeResponse onLoadResourceCustomScheme(String url) throws InterruptedException {
    if (channel == null) return null;
    final Map<String, Object> obj = new HashMap<>();
    obj.put("url", url);
    final SyncLoadResourceCustomSchemeCallback callback = new SyncLoadResourceCustomSchemeCallback();
    return Util.invokeMethodAndWaitResult(channel, "onLoadResourceCustomScheme", obj, callback);
  }

  public static class ShouldInterceptRequestCallback extends BaseCallbackResultImpl<WebResourceResponseExt> {
    @Nullable
    @Override
    public WebResourceResponseExt decodeResult(@Nullable Object obj) {
      return WebResourceResponseExt.fromMap((Map<String, Object>) obj);
    }
  }

  public void shouldInterceptRequest(WebResourceRequestExt request, @NonNull ShouldInterceptRequestCallback callback) {
    if (channel == null) return;
    channel.invokeMethod("shouldInterceptRequest", request.toMap(), callback);
  }

  public static class SyncShouldInterceptRequestCallback extends SyncBaseCallbackResultImpl<WebResourceResponseExt> {
    @Nullable
    @Override
    public WebResourceResponseExt decodeResult(@Nullable Object obj) {
      return (new ShouldInterceptRequestCallback()).decodeResult(obj);
    }
  }

  @Nullable
  public WebResourceResponseExt shouldInterceptRequest(WebResourceRequestExt request) throws InterruptedException {
    if (channel == null) return null;
    final SyncShouldInterceptRequestCallback callback = new SyncShouldInterceptRequestCallback();
    return Util.invokeMethodAndWaitResult(channel, "shouldInterceptRequest", request.toMap(), callback);
  }

  public static class RenderProcessUnresponsiveCallback extends BaseCallbackResultImpl<Integer> {
    @Nullable
    @Override
    public Integer decodeResult(@Nullable Object obj) {
      return obj != null ? (Integer) ((Map<String, Object>) obj).get("action") : null;
    }
  }

  public void onRenderProcessUnresponsive(String url, @NonNull RenderProcessUnresponsiveCallback callback) {
    if (channel == null) {
      callback.defaultBehaviour(null);
      return;
    }
    Map<String, Object> obj = new HashMap<>();
    obj.put("url", url);
    channel.invokeMethod("onRenderProcessUnresponsive", obj, callback);
  }

  public static class RenderProcessResponsiveCallback extends BaseCallbackResultImpl<Integer> {
    @Nullable
    @Override
    public Integer decodeResult(@Nullable Object obj) {
      return obj != null ? (Integer) ((Map<String, Object>) obj).get("action") : null;
    }
  }

  public void onRenderProcessResponsive(String url, @NonNull RenderProcessResponsiveCallback callback) {
    if (channel == null) {
      callback.defaultBehaviour(null);
      return;
    }
    Map<String, Object> obj = new HashMap<>();
    obj.put("url", url);
    channel.invokeMethod("onRenderProcessResponsive", obj, callback);
  }
  
  public void dispose() {
    channel = null;
  }
}
