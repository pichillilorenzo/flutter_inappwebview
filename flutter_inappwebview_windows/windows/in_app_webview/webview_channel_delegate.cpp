#include "in_app_webview.h"
#include "webview_channel_delegate.h"

#include "../utils/flutter.h"
#include "../utils/strconv.h"
#include "../types/base_callback_result.h"

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

	WebViewChannelDelegate::ShouldOverrideUrlLoadingCallback::ShouldOverrideUrlLoadingCallback() {
		decodeResult = [](const flutter::EncodableValue* value) {
			if (value->IsNull()) {
				return cancel;
			}
			auto navigationPolicy = std::get<int>(*value);
			return static_cast<NavigationActionPolicy>(navigationPolicy);
		};
	}

	void WebViewChannelDelegate::HandleMethodCall(const flutter::MethodCall<flutter::EncodableValue>& method_call,
		std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
	{
		if (!webView) {
			result->Success();
			return;
		}

		if (method_call.method_name().compare("getUrl") == 0) {
			result->Success(make_fl_value(webView->getUrl()));
		} 
		else if (method_call.method_name().compare("loadUrl") == 0) {
			auto& arguments = std::get<flutter::EncodableMap>(*method_call.arguments());
			auto urlRequest = std::make_unique<URLRequest>(get_fl_map_value<flutter::EncodableMap>(arguments, "urlRequest"));
			webView->loadUrl(*urlRequest);
			result->Success(make_fl_value(true));
		}
		else {
			result->NotImplemented();
		}
	}

	void WebViewChannelDelegate::onLoadStart(const std::optional<std::string>& url) const
	{
		if (!channel) {
			return;
		}

		auto arguments = std::make_unique<flutter::EncodableValue>(flutter::EncodableMap {
			{flutter::EncodableValue("url"), make_fl_value(url)},
		});
		channel->InvokeMethod("onLoadStart", std::move(arguments));
	}

	void WebViewChannelDelegate::onLoadStop(const std::optional<std::string>& url) const
	{
		if (!channel) {
			return;
		}

		auto arguments = std::make_unique<flutter::EncodableValue>(flutter::EncodableMap{
			{flutter::EncodableValue("url"), make_fl_value(url)},
		});
		channel->InvokeMethod("onLoadStop", std::move(arguments));
	}

	void WebViewChannelDelegate::shouldOverrideUrlLoading(std::shared_ptr<NavigationAction> navigationAction, std::unique_ptr<ShouldOverrideUrlLoadingCallback> callback) const
	{
		if (!channel) {
			return;
		}

		auto arguments = std::make_unique<flutter::EncodableValue>(navigationAction->toEncodableMap());
		channel->InvokeMethod("shouldOverrideUrlLoading", std::move(arguments), std::move(callback));
	}

	void WebViewChannelDelegate::onReceivedError(std::shared_ptr<WebResourceRequest> request, std::shared_ptr<WebResourceError> error) const
	{
		if (!channel) {
			return;
		}

		auto arguments = std::make_unique<flutter::EncodableValue>(flutter::EncodableMap{
			{flutter::EncodableValue("request"), request->toEncodableMap()},
			{flutter::EncodableValue("error"), error->toEncodableMap()},
		});
		channel->InvokeMethod("onReceivedError", std::move(arguments));
	}

	void WebViewChannelDelegate::onReceivedHttpError(std::shared_ptr<WebResourceRequest> request, std::shared_ptr<WebResourceResponse> errorResponse) const
	{
		if (!channel) {
			return;
		}

		auto arguments = std::make_unique<flutter::EncodableValue>(flutter::EncodableMap{
			{flutter::EncodableValue("request"), request->toEncodableMap()},
			{flutter::EncodableValue("errorResponse"), errorResponse->toEncodableMap()},
			});
		channel->InvokeMethod("onReceivedHttpError", std::move(arguments));
	}

    WebViewChannelDelegate::~WebViewChannelDelegate()
	{
		debugLog("dealloc WebViewChannelDelegate");
		webView = nullptr;
    }
}