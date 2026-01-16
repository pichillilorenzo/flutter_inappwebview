#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_CHANNEL_DELEGATE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_CHANNEL_DELEGATE_H_

#include <flutter_linux/flutter_linux.h>

#include <cstdint>
#include <functional>
#include <memory>
#include <optional>
#include <string>
#include <vector>

#include "../types/base_callback_result.h"
#include "../types/channel_delegate.h"
#include "../types/client_cert_challenge.h"
#include "../types/client_cert_response.h"
#include "../types/create_window_action.h"
#include "../types/custom_scheme_response.h"
#include "../types/download_start_request.h"
#include "../types/download_start_response.h"
#include "../types/hit_test_result.h"
#include "../types/http_auth_response.h"
#include "../types/http_authentication_challenge.h"
#include "../types/javascript_handler_function_data.h"
#include "../types/server_trust_auth_response.h"
#include "../types/server_trust_challenge.h"
#include "../types/js_alert_request.h"
#include "../types/js_alert_response.h"
#include "../types/js_before_unload_response.h"
#include "../types/js_confirm_request.h"
#include "../types/js_confirm_response.h"
#include "../types/js_prompt_request.h"
#include "../types/js_prompt_response.h"
#include "../types/navigation_action.h"
#include "../types/permission_request.h"
#include "../types/permission_response.h"
#include "../types/show_file_chooser_response.h"
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
  class ShouldOverrideUrlLoadingCallback : public BaseCallbackResult<NavigationActionPolicy> {
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
  class JsBeforeUnloadCallback : public BaseCallbackResult<JsBeforeUnloadResponse> {
   public:
    JsBeforeUnloadCallback();
    ~JsBeforeUnloadCallback() = default;
  };

  /**
   * Callback for onPermissionRequest.
   */
  class PermissionRequestCallback : public BaseCallbackResult<PermissionResponse> {
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
   * Callback for onReceivedServerTrustAuthRequest.
   * Returns ServerTrustAuthResponse indicating whether to proceed or cancel.
   */
  class ServerTrustAuthRequestCallback : public BaseCallbackResult<ServerTrustAuthResponse> {
   public:
    ServerTrustAuthRequestCallback();
    ~ServerTrustAuthRequestCallback() = default;
  };

  /**
   * Callback for onReceivedClientCertRequest.
   * Returns ClientCertResponse indicating how to handle the client certificate request.
   */
  class ClientCertRequestCallback : public BaseCallbackResult<ClientCertResponse> {
   public:
    ClientCertRequestCallback();
    ~ClientCertRequestCallback() = default;
  };

  /**
   * Callback for onDownloadStarting.
   */
  class DownloadStartCallback : public BaseCallbackResult<DownloadStartResponse> {
   public:
    DownloadStartCallback();
    ~DownloadStartCallback() = default;
  };

  /**
   * Callback for onLoadResourceWithCustomScheme.
   * Returns optional CustomSchemeResponse to use for the request.
   */
  class LoadResourceWithCustomSchemeCallback
      : public BaseCallbackResult<std::shared_ptr<CustomSchemeResponse>> {
   public:
    LoadResourceWithCustomSchemeCallback();
    ~LoadResourceWithCustomSchemeCallback() = default;
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

  void shouldOverrideUrlLoading(std::shared_ptr<NavigationAction> navigationAction,
                                std::unique_ptr<ShouldOverrideUrlLoadingCallback> callback) const;

  void onReceivedError(std::shared_ptr<WebResourceRequest> request,
                       std::shared_ptr<WebResourceError> error) const;

  void onReceivedHttpError(std::shared_ptr<WebResourceRequest> request,
                           std::shared_ptr<WebResourceResponse> errorResponse) const;

  void onConsoleMessage(const std::string& message, int64_t messageLevel) const;

  void onLoadResource(const std::string& url,
                      const std::string& initiatorType,
                      double startTime,
                      double duration) const;

  void onCallJsHandler(const std::string& handlerName,
                       std::unique_ptr<JavaScriptHandlerFunctionData> data,
                       std::unique_ptr<CallJsHandlerCallback> callback) const;

  void onCloseWindow() const;

  void onPageCommitVisible(const std::optional<std::string>& url) const;

  void onZoomScaleChanged(double newScale, double oldScale) const;

  void onScrollChanged(int64_t x, int64_t y) const;

  void shouldInterceptRequest(std::shared_ptr<WebResourceRequest> request,
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

  void onReceivedHttpAuthRequest(std::unique_ptr<HttpAuthenticationChallenge> challenge,
                                 std::unique_ptr<HttpAuthRequestCallback> callback) const;

  void onReceivedServerTrustAuthRequest(std::unique_ptr<ServerTrustChallenge> challenge,
                                        std::unique_ptr<ServerTrustAuthRequestCallback> callback) const;

  void onReceivedClientCertRequest(std::unique_ptr<ClientCertChallenge> challenge,
                                   std::unique_ptr<ClientCertRequestCallback> callback) const;

  void onDownloadStarting(std::unique_ptr<DownloadStartRequest> request,
                          std::unique_ptr<DownloadStartCallback> callback) const;

  void onEnterFullscreen() const;

  void onExitFullscreen() const;

  void onFaviconChanged(const std::optional<std::string>& faviconUrl) const;

  void onRenderProcessGone(bool didCrash) const;

  void onShowFileChooser(int mode,
                         const std::vector<std::string>& acceptTypes,
                         bool isCaptureEnabled,
                         const std::optional<std::string>& title,
                         const std::optional<std::string>& filenameHint,
                         std::function<void(ShowFileChooserResponse)> callback) const;

  // Custom scheme handler callback
  void onLoadResourceWithCustomScheme(
      std::shared_ptr<WebResourceRequest> request,
      std::unique_ptr<LoadResourceWithCustomSchemeCallback> callback) const;

  // Context menu callbacks
  void onCreateContextMenu(const HitTestResult& hitTestResult) const;
  void onHideContextMenu() const;
  void onContextMenuActionItemClicked(const std::string& id, const std::string& title) const;

  // Media capture state change events
  void onCameraCaptureStateChanged(int oldState, int newState) const;
  void onMicrophoneCaptureStateChanged(int oldState, int newState) const;

  // Navigation response event (for decide-policy RESPONSE type)
  /**
   * Callback for onNavigationResponse.
   * Returns NavigationResponseAction (ALLOW=1, CANCEL=0, DOWNLOAD=2)
   */
  class NavigationResponseCallback : public BaseCallbackResult<int> {
   public:
    NavigationResponseCallback();
    ~NavigationResponseCallback() = default;
  };

  void onNavigationResponse(const std::string& url,
                            const std::optional<std::string>& mimeType,
                            int64_t contentLength,
                            int statusCode,
                            bool isForMainFrame,
                            bool canShowMimeType,
                            std::unique_ptr<NavigationResponseCallback> callback) const;

  // Print request event (for JavaScript window.print() interception)
  void onPrintRequest(const std::optional<std::string>& url) const;

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
