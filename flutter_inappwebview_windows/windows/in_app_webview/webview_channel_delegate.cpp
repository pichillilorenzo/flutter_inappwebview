#include "in_app_webview.h"
#include "webview_channel_delegate.h"

#include "../utils/util.h"
#include "../utils/strconv.h"

namespace flutter_inappwebview_plugin
{
    WebViewChannelDelegate::WebViewChannelDelegate(InAppWebView* webView, flutter::BinaryMessenger* messenger)
        : webView(webView), ChannelDelegate(messenger, InAppWebView::METHOD_CHANNEL_NAME_PREFIX + variant_to_string(webView->id))
    {

    }

	WebViewChannelDelegate::WebViewChannelDelegate(InAppWebView* webView, flutter::BinaryMessenger* messenger, const std::string& name)
		: webView(webView), ChannelDelegate(messenger, name)
	{

	}

	void WebViewChannelDelegate::HandleMethodCall(const flutter::MethodCall<flutter::EncodableValue>& method_call,
		std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
	{
		if (!webView) {
			result->Success();
			return;
		}

		if (method_call.method_name().compare("getUrl") == 0) {
			std::optional<std::string> url = webView->getUrl();
			result->Success(url.has_value() ? flutter::EncodableValue(url.value()) : flutter::EncodableValue());
		}
		else {
			result->NotImplemented();
		}
	}

	void WebViewChannelDelegate::onLoadStart(const std::optional<std::string> url) const
	{
		if (!channel) {
			return;
		}

		auto arguments = std::make_unique<flutter::EncodableValue>(flutter::EncodableMap {
			{flutter::EncodableValue("url"), url.has_value() ? flutter::EncodableValue(url.value()) : flutter::EncodableValue()},
		});
		channel->InvokeMethod("onLoadStart", std::move(arguments));
	}

	void WebViewChannelDelegate::onLoadStop(const std::optional<std::string> url) const
	{
		if (!channel) {
			return;
		}

		auto arguments = std::make_unique<flutter::EncodableValue>(flutter::EncodableMap{
			{flutter::EncodableValue("url"), url.has_value() ? flutter::EncodableValue(url.value()) : flutter::EncodableValue()},
		});
		channel->InvokeMethod("onLoadStop", std::move(arguments));
	}

    WebViewChannelDelegate::~WebViewChannelDelegate()
	{
		std::cout << "dealloc WebViewChannelDelegate\n";
		webView = nullptr;
    }
}