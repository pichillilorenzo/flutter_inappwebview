#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_CHANNEL_DELEGATE_WPE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_CHANNEL_DELEGATE_WPE_H_

// WPE WebKit WebView Channel Delegate
// 
// This handles the method channel communication between Dart and the WPE 
// WebKit-based InAppWebView implementation. The API is identical to the 
// WebKitGTK version since the method channel protocol is the same.
//
// For now, we use the same implementation as WebKitGTK.

#ifdef USE_WPE_WEBKIT

#include <flutter_linux/flutter_linux.h>

#include <memory>
#include <string>

#include "../types/channel_delegate.h"
#include "webview_channel_delegate.h"
#include "../types/javascript_handler_function_data.h"
#include "../types/navigation_action.h"
#include "../types/js_dialog_types.h"
#include "../types/permission_types.h"
#include "../types/http_auth_types.h"

namespace flutter_inappwebview_plugin {

class InAppWebViewWpe;

class WebViewChannelDelegateWpe : public ChannelDelegate {
 public:
  WebViewChannelDelegateWpe(InAppWebViewWpe* webView,
                            FlBinaryMessenger* messenger,
                            const std::string& channelName);
  ~WebViewChannelDelegateWpe() override;

  // Navigation events
  void onLoadStart(const std::string& url);
  void onLoadStop(const std::string& url);
  void onLoadError(const std::string& url, int errorCode, 
                   const std::string& description);
  void onProgressChanged(int progress);
  void onTitleChanged(const std::string& title);

  // JavaScript handler callback (async)
  void onCallJsHandler(const std::string& handlerName,
                       std::unique_ptr<JavaScriptHandlerFunctionData> data,
                       std::unique_ptr<WebViewChannelDelegate::CallJsHandlerCallback> callback);

  // URL loading decision (async)
  void shouldOverrideUrlLoading(
      std::shared_ptr<NavigationAction> navigationAction,
      std::unique_ptr<WebViewChannelDelegate::ShouldOverrideUrlLoadingCallback> callback);

  // JS dialogs (async)
  void onJsAlert(std::unique_ptr<JsAlertRequest> request,
                 std::unique_ptr<WebViewChannelDelegate::JsAlertCallback> callback);
  void onJsConfirm(std::unique_ptr<JsConfirmRequest> request,
                   std::unique_ptr<WebViewChannelDelegate::JsConfirmCallback> callback);
  void onJsPrompt(std::unique_ptr<JsPromptRequest> request,
                  std::unique_ptr<WebViewChannelDelegate::JsPromptCallback> callback);
  void onJsBeforeUnload(const std::optional<std::string>& url,
                        const std::optional<std::string>& message,
                        std::unique_ptr<WebViewChannelDelegate::JsBeforeUnloadCallback> callback);

  // Permission and auth (async)
  void onPermissionRequest(std::unique_ptr<PermissionRequest> request,
                           std::unique_ptr<WebViewChannelDelegate::PermissionRequestCallback> callback);
  void onReceivedHttpAuthRequest(std::unique_ptr<HttpAuthenticationChallenge> challenge,
                                 std::unique_ptr<WebViewChannelDelegate::HttpAuthRequestCallback> callback);

  // Create window (async)
  void onCreateWindow(std::unique_ptr<CreateWindowAction> createWindowAction,
                      std::unique_ptr<WebViewChannelDelegate::CreateWindowCallback> callback);

  // Window events
  void onCloseWindow();
  void onEnterFullscreen();
  void onExitFullscreen();

  // Favicon changed
  void onFaviconChanged(const std::optional<std::string>& faviconUrl);

  // Console messages (captured via JavaScript injection)
  void onConsoleMessage(const std::string& message, int64_t messageLevel);

  // Additional events (matching GTK implementation)
  void onUpdateVisitedHistory(const std::optional<std::string>& url,
                              const std::optional<bool>& isReload);
  void onPageCommitVisible(const std::optional<std::string>& url);
  void onZoomScaleChanged(double newScale, double oldScale);
  void onScrollChanged(int64_t x, int64_t y);
  void onWebViewCreated();

 protected:
  void HandleMethodCall(FlMethodCall* method_call) override;

 private:
  InAppWebViewWpe* webview_ = nullptr;

  // Method call handlers
  void HandleLoadUrl(FlMethodCall* method_call);
  void HandleLoadData(FlMethodCall* method_call);
  void HandleLoadFile(FlMethodCall* method_call);
  void HandleReload(FlMethodCall* method_call);
  void HandleGoBack(FlMethodCall* method_call);
  void HandleGoForward(FlMethodCall* method_call);
  void HandleCanGoBack(FlMethodCall* method_call);
  void HandleCanGoForward(FlMethodCall* method_call);
  void HandleStopLoading(FlMethodCall* method_call);
  void HandleIsLoading(FlMethodCall* method_call);
  void HandleGetUrl(FlMethodCall* method_call);
  void HandleGetTitle(FlMethodCall* method_call);
  void HandleGetProgress(FlMethodCall* method_call);
  void HandleEvaluateJavascript(FlMethodCall* method_call);
  void HandleInjectJavascriptFileFromUrl(FlMethodCall* method_call);
  void HandleInjectCSSCode(FlMethodCall* method_call);
  void HandleInjectCSSFileFromUrl(FlMethodCall* method_call);
  void HandleAddUserScript(FlMethodCall* method_call);
  void HandleRemoveUserScript(FlMethodCall* method_call);
  void HandleRemoveUserScriptsByGroupName(FlMethodCall* method_call);
  void HandleRemoveAllUserScripts(FlMethodCall* method_call);
  void HandleGetHtml(FlMethodCall* method_call);
  void HandleGetZoomScale(FlMethodCall* method_call);
  void HandleSetZoomScale(FlMethodCall* method_call);
  void HandleScrollTo(FlMethodCall* method_call);
  void HandleScrollBy(FlMethodCall* method_call);
  void HandleGetScrollX(FlMethodCall* method_call);
  void HandleGetScrollY(FlMethodCall* method_call);
  void HandleGetSettings(FlMethodCall* method_call);
  void HandleSetSettings(FlMethodCall* method_call);
};

}  // namespace flutter_inappwebview_plugin

#endif  // USE_WPE_WEBKIT

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_CHANNEL_DELEGATE_WPE_H_
