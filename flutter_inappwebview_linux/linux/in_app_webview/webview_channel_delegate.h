#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_CHANNEL_DELEGATE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_CHANNEL_DELEGATE_H_

#include <flutter_linux/flutter_linux.h>

#include <cstdint>
#include <memory>
#include <optional>
#include <string>
#include <vector>

#include "../types/base_callback_result.h"
#include "../types/channel_delegate.h"
#include "../types/create_window_action.h"
#include "../types/download_start_request.h"
#include "../types/download_start_response.h"
#include "../types/http_auth_types.h"
#include "../types/javascript_handler_function_data.h"
#include "../types/js_dialog_types.h"
#include "../types/navigation_action.h"
#include "../types/permission_types.h"
#include "../types/web_resource_error.h"
#include "../types/web_resource_request.h"
#include "../types/web_resource_response.h"

namespace flutter_inappwebview_plugin {

class InAppWebView;

enum class NavigationActionPolicy { cancel = 0, allow = 1 };

class WebViewChannelDelegate : public ChannelDelegate {
 public:
  InAppWebView* webView;

  // === Callback Classes ===

  /**
   * Callback for shouldOverrideUrlLoading.
   * Decodes the integer result to NavigationActionPolicy.
   */
  class ShouldOverrideUrlLoadingCallback
      : public BaseCallbackResult<NavigationActionPolicy> {
   public:
    ShouldOverrideUrlLoadingCallback();
    ~ShouldOverrideUrlLoadingCallback() = default;
  };

  /**
   * Callback for onCallJsHandler.
   * Returns the raw FlValue result.
   */
  class CallJsHandlerCallback : public BaseCallbackResult<FlValue*> {
   public:
    CallJsHandlerCallback();
    ~CallJsHandlerCallback() = default;
  };

  /**
   * Callback for onCreateWindow.
   * Returns whether the window was handled by the client.
   */
  class CreateWindowCallback : public BaseCallbackResult<bool> {
   public:
    CreateWindowCallback();
    ~CreateWindowCallback() = default;
  };

  /**
   * Callback for shouldInterceptRequest.
   * Returns optional WebResourceResponse to use for the request.
   */
  class ShouldInterceptRequestCallback
      : public BaseCallbackResult<std::shared_ptr<WebResourceResponse>> {
   public:
    ShouldInterceptRequestCallback();
    ~ShouldInterceptRequestCallback() = default;
  };

  /**
   * Callback for onJsAlert.
   */
  class JsAlertCallback : public BaseCallbackResult<JsAlertResponse> {
   public:
    JsAlertCallback();
    ~JsAlertCallback() = default;
  };

  /**
   * Callback for onJsConfirm.
   */
  class JsConfirmCallback : public BaseCallbackResult<JsConfirmResponse> {
   public:
    JsConfirmCallback();
    ~JsConfirmCallback() = default;
  };

  /**
   * Callback for onJsPrompt.
   */
  class JsPromptCallback : public BaseCallbackResult<JsPromptResponse> {
   public:
    JsPromptCallback();
    ~JsPromptCallback() = default;
  };

  /**
   * Callback for onJsBeforeUnload.
   */
  class JsBeforeUnloadCallback
      : public BaseCallbackResult<JsBeforeUnloadResponse> {
   public:
    JsBeforeUnloadCallback();
    ~JsBeforeUnloadCallback() = default;
  };

  /**
   * Callback for onPermissionRequest.
   */
  class PermissionRequestCallback
      : public BaseCallbackResult<PermissionResponse> {
   public:
    PermissionRequestCallback();
    ~PermissionRequestCallback() = default;
  };

  /**
   * Callback for onReceivedHttpAuthRequest.
   */
  class HttpAuthRequestCallback : public BaseCallbackResult<HttpAuthResponse> {
   public:
    HttpAuthRequestCallback();
    ~HttpAuthRequestCallback() = default;
  };

  /**
   * Callback for onDownloadStarting.
   */
  class DownloadStartCallback
      : public BaseCallbackResult<DownloadStartResponse> {
   public:
    DownloadStartCallback();
    ~DownloadStartCallback() = default;
  };

  // === Constructors/Destructor ===

  WebViewChannelDelegate(InAppWebView* webView, FlBinaryMessenger* messenger);
  WebViewChannelDelegate(InAppWebView* webView, FlBinaryMessenger* messenger,
                         const std::string& name);
  ~WebViewChannelDelegate() override;

  void HandleMethodCall(FlMethodCall* method_call) override;

  // === Events to send to Dart ===

  void onLoadStart(const std::optional<std::string>& url) const;
  void onLoadStop(const std::optional<std::string>& url) const;
  void onProgressChanged(int64_t progress) const;
  void onTitleChanged(const std::optional<std::string>& title) const;
  void onUpdateVisitedHistory(const std::optional<std::string>& url,
                              const std::optional<bool>& isReload) const;

  void shouldOverrideUrlLoading(
      std::shared_ptr<NavigationAction> navigationAction,
      std::unique_ptr<ShouldOverrideUrlLoadingCallback> callback) const;

  void onReceivedError(std::shared_ptr<WebResourceRequest> request,
                       std::shared_ptr<WebResourceError> error) const;

  void onReceivedHttpError(
      std::shared_ptr<WebResourceRequest> request,
      std::shared_ptr<WebResourceResponse> errorResponse) const;

  void onConsoleMessage(const std::string& message, int64_t messageLevel) const;

  void onCallJsHandler(
      const std::string& handlerName,
      std::unique_ptr<JavaScriptHandlerFunctionData> data,
      std::unique_ptr<CallJsHandlerCallback> callback) const;

  void onCloseWindow() const;

  void onPageCommitVisible(const std::optional<std::string>& url) const;

  void onZoomScaleChanged(double newScale, double oldScale) const;

  void onScrollChanged(int64_t x, int64_t y) const;

  void shouldInterceptRequest(
      std::shared_ptr<WebResourceRequest> request,
      std::unique_ptr<ShouldInterceptRequestCallback> callback) const;

  void onWebViewCreated() const;

  void onContentSizeChanged(int64_t width, int64_t height) const;

  void onCreateWindow(std::unique_ptr<CreateWindowAction> createWindowAction,
                      std::unique_ptr<CreateWindowCallback> callback) const;

  void onJsAlert(std::unique_ptr<JsAlertRequest> request,
                 std::unique_ptr<JsAlertCallback> callback) const;

  void onJsConfirm(std::unique_ptr<JsConfirmRequest> request,
                   std::unique_ptr<JsConfirmCallback> callback) const;

  void onJsPrompt(std::unique_ptr<JsPromptRequest> request,
                  std::unique_ptr<JsPromptCallback> callback) const;

  void onJsBeforeUnload(const std::optional<std::string>& url,
                        const std::optional<std::string>& message,
                        std::unique_ptr<JsBeforeUnloadCallback> callback) const;

  void onPermissionRequest(std::unique_ptr<PermissionRequest> request,
                           std::unique_ptr<PermissionRequestCallback> callback) const;

  void onReceivedHttpAuthRequest(
      std::unique_ptr<HttpAuthenticationChallenge> challenge,
      std::unique_ptr<HttpAuthRequestCallback> callback) const;

  void onDownloadStarting(std::unique_ptr<DownloadStartRequest> request,
                          std::unique_ptr<DownloadStartCallback> callback) const;

  void onEnterFullscreen() const;

  void onExitFullscreen() const;

  void onFaviconChanged(const std::optional<std::string>& faviconUrl) const;

  // Context menu callbacks
  void onCreateContextMenu(const std::string& hitTestResultType,
                           const std::string& extra) const;
  void onHideContextMenu() const;
  void onContextMenuActionItemClicked(const std::string& id,
                                      const std::string& title) const;

 private:
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

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_CHANNEL_DELEGATE_H_
