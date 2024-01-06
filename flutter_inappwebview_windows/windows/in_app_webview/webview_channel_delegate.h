#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_CHANNEL_DELEGATE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_CHANNEL_DELEGATE_H_

#include <flutter/method_channel.h>
#include <flutter/standard_message_codec.h>

#include "../types/channel_delegate.h"

namespace flutter_inappwebview_plugin
{
    class InAppWebView;

    class WebViewChannelDelegate : public ChannelDelegate
    {
    public:
        InAppWebView* webView;

        WebViewChannelDelegate(InAppWebView* webView, flutter::BinaryMessenger* messenger);
        WebViewChannelDelegate(InAppWebView* webView, flutter::BinaryMessenger* messenger, const std::string& name);
        ~WebViewChannelDelegate();

        void HandleMethodCall(
            const flutter::MethodCall<flutter::EncodableValue>& method_call,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

        void onLoadStart(const std::optional<std::string> url) const;
        void onLoadStop(const std::optional<std::string> url) const;
    };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_CHANNEL_DELEGATE_H_