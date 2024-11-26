#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_CHANNEL_DELEGATE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_CHANNEL_DELEGATE_H_

#include <flutter/standard_message_codec.h>

#include "../types/accelerator_key_pressed_detail.h"
#include "../types/base_callback_result.h"
#include "../types/channel_delegate.h"
#include "../types/client_cert_challenge.h"
#include "../types/client_cert_response.h"
#include "../types/create_window_action.h"
#include "../types/custom_scheme_response.h"
#include "../types/download_start_request.h"
#include "../types/download_start_response.h"
#include "../types/http_auth_response.h"
#include "../types/http_authentication_challenge.h"
#include "../types/javascript_handler_function_data.h"
#include "../types/navigation_action.h"
#include "../types/permission_response.h"
#include "../types/process_failed_detail.h"
#include "../types/render_process_gone_detail.h"
#include "../types/server_trust_auth_response.h"
#include "../types/server_trust_challenge.h"
#include "../types/web_resource_error.h"
#include "../types/web_resource_request.h"
#include "../types/web_resource_response.h"

namespace flutter_inappwebview_plugin
{
  class InAppWebView;

  enum class NavigationActionPolicy { cancel = 0, allow = 1 };

  class WebViewChannelDelegate : public ChannelDelegate
  {
  public:
    InAppWebView* webView;

    class ShouldOverrideUrlLoadingCallback : public BaseCallbackResult<const NavigationActionPolicy> {
    public:
      ShouldOverrideUrlLoadingCallback();
      ~ShouldOverrideUrlLoadingCallback() = default;
    };

    class CallJsHandlerCallback : public BaseCallbackResult<const flutter::EncodableValue*> {
    public:
      CallJsHandlerCallback();
      ~CallJsHandlerCallback() = default;
    };

    class CreateWindowCallback : public BaseCallbackResult<const bool> {
    public:
      CreateWindowCallback();
      ~CreateWindowCallback() = default;
    };

    class PermissionRequestCallback : public BaseCallbackResult<const std::shared_ptr<PermissionResponse>> {
    public:
      PermissionRequestCallback();
      ~PermissionRequestCallback() = default;
    };

    class ShouldInterceptRequestCallback : public BaseCallbackResult<const std::shared_ptr<WebResourceResponse>> {
    public:
      ShouldInterceptRequestCallback();
      ~ShouldInterceptRequestCallback() = default;
    };

    class LoadResourceWithCustomSchemeCallback : public BaseCallbackResult<const std::shared_ptr<CustomSchemeResponse>> {
    public:
      LoadResourceWithCustomSchemeCallback();
      ~LoadResourceWithCustomSchemeCallback() = default;
    };

    class ReceivedHttpAuthRequestCallback : public BaseCallbackResult<const std::shared_ptr<HttpAuthResponse>> {
    public:
      ReceivedHttpAuthRequestCallback();
      ~ReceivedHttpAuthRequestCallback() = default;
    };

    class ReceivedClientCertRequestCallback : public BaseCallbackResult<const std::shared_ptr<ClientCertResponse>> {
    public:
      ReceivedClientCertRequestCallback();
      ~ReceivedClientCertRequestCallback() = default;
    };

    class ReceivedServerTrustAuthRequestCallback : public BaseCallbackResult<const std::shared_ptr<ServerTrustAuthResponse>> {
    public:
      ReceivedServerTrustAuthRequestCallback();
      ~ReceivedServerTrustAuthRequestCallback() = default;
    };

    class DownloadStartRequestCallback : public BaseCallbackResult<const std::shared_ptr<DownloadStartResponse>> {
    public:
      DownloadStartRequestCallback();
      ~DownloadStartRequestCallback() = default;
    };

    WebViewChannelDelegate(InAppWebView* webView, flutter::BinaryMessenger* messenger);
    WebViewChannelDelegate(InAppWebView* webView, flutter::BinaryMessenger* messenger, const std::string& name);
    ~WebViewChannelDelegate();

    void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

    void onLoadStart(const std::optional<std::string>& url) const;
    void onLoadStop(const std::optional<std::string>& url) const;
    void onProgressChanged(const int64_t& progress) const;
    void shouldOverrideUrlLoading(std::shared_ptr<NavigationAction> navigationAction, std::unique_ptr<ShouldOverrideUrlLoadingCallback> callback) const;
    void onReceivedError(std::shared_ptr<WebResourceRequest> request, std::shared_ptr<WebResourceError> error) const;
    void onReceivedHttpError(std::shared_ptr<WebResourceRequest> request, std::shared_ptr<WebResourceResponse> error) const;
    void onTitleChanged(const std::optional<std::string>& title) const;
    void onUpdateVisitedHistory(const std::optional<std::string>& url, const std::optional<bool>& isReload) const;
    void onCallJsHandler(const std::string& handlerName, const std::unique_ptr<JavaScriptHandlerFunctionData> data, std::unique_ptr<CallJsHandlerCallback> callback) const;
    void onConsoleMessage(const std::string& message, const int64_t& messageLevel) const;
    void onDevToolsProtocolEventReceived(const std::string& eventName, const std::string& data) const;
    void onCreateWindow(std::shared_ptr<CreateWindowAction> createWindowAction, std::unique_ptr<CreateWindowCallback> callback) const;
    void onCloseWindow() const;
    void onPermissionRequest(const std::string& origin, const std::vector<int64_t>& resources, std::unique_ptr<PermissionRequestCallback> callback) const;
    void shouldInterceptRequest(std::shared_ptr<WebResourceRequest> request, std::unique_ptr<ShouldInterceptRequestCallback> callback) const;
    void onLoadResourceWithCustomScheme(std::shared_ptr<WebResourceRequest> request, std::unique_ptr<LoadResourceWithCustomSchemeCallback> callback) const;
    void onReceivedHttpAuthRequest(std::shared_ptr<HttpAuthenticationChallenge> challenge, std::unique_ptr<ReceivedHttpAuthRequestCallback> callback) const;
    void onReceivedClientCertRequest(std::shared_ptr<ClientCertChallenge> challenge, std::unique_ptr<ReceivedClientCertRequestCallback> callback) const;
    void onReceivedServerTrustAuthRequest(std::shared_ptr<ServerTrustChallenge> challenge, std::unique_ptr<ReceivedServerTrustAuthRequestCallback> callback) const;
    void onRenderProcessGone(const std::shared_ptr<RenderProcessGoneDetail> detail) const;
    void onRenderProcessUnresponsive(const std::optional<std::string>& url) const;
    void onWebContentProcessDidTerminate() const;
    void onProcessFailed(const std::shared_ptr<ProcessFailedDetail> detail) const;
    void onDownloadStarting(std::shared_ptr<DownloadStartRequest> request, std::unique_ptr<DownloadStartRequestCallback> callback) const;
    void onAcceleratorKeyPressed(std::shared_ptr<AcceleratorKeyPressedDetail> detail) const;
    void onZoomScaleChanged(const double& oldScale, const double& newScale) const;
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_CHANNEL_DELEGATE_H_