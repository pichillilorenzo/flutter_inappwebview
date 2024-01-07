#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_CHANNEL_DELEGATE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_CHANNEL_DELEGATE_H_

#include <flutter/method_channel.h>
#include <flutter/standard_message_codec.h>

#include "../types/channel_delegate.h"
#include "../types/base_callback_result.h"
#include "../types/navigation_action.h"
#include "../types/web_resource_request.h"
#include "../types/web_resource_error.h"
#include "../types/web_resource_response.h"

namespace flutter_inappwebview_plugin
{
    class InAppWebView;

    enum NavigationActionPolicy {cancel = 0, allow = 1};

    class WebViewChannelDelegate : public ChannelDelegate
    {
    public:
        InAppWebView* webView;

        class ShouldOverrideUrlLoadingCallback : public BaseCallbackResult<NavigationActionPolicy> {
        public:
            ShouldOverrideUrlLoadingCallback();
            ~ShouldOverrideUrlLoadingCallback() = default;
        };

        WebViewChannelDelegate(InAppWebView* webView, flutter::BinaryMessenger* messenger);
        WebViewChannelDelegate(InAppWebView* webView, flutter::BinaryMessenger* messenger, const std::string& name);
        ~WebViewChannelDelegate();

        void HandleMethodCall(
            const flutter::MethodCall<flutter::EncodableValue>& method_call,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

        void onLoadStart(const std::optional<std::string>& url) const;
        void onLoadStop(const std::optional<std::string>& url) const;
        void shouldOverrideUrlLoading(std::shared_ptr<NavigationAction> navigationAction, std::unique_ptr<ShouldOverrideUrlLoadingCallback> callback) const;
        void WebViewChannelDelegate::onReceivedError(std::shared_ptr<WebResourceRequest> request, std::shared_ptr<WebResourceError> error) const;
        void WebViewChannelDelegate::onReceivedHttpError(std::shared_ptr<WebResourceRequest> request, std::shared_ptr<WebResourceResponse> error) const;
    };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_CHANNEL_DELEGATE_H_