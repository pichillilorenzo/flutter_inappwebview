#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_H_

#include <functional>

#include <WebView2.h>
#include <wil/com.h>
#include "../types/url_request.h"
#include "webview_channel_delegate.h"
#include "../flutter_inappwebview_windows_base_plugin.h"

namespace flutter_inappwebview_plugin
{
	using namespace Microsoft::WRL;

	class InAppWebView
	{
	public:
		static inline const std::string METHOD_CHANNEL_NAME_PREFIX = "com.pichillilorenzo/flutter_inappwebview_";

		FlutterInappwebviewWindowsBasePlugin* plugin;
		std::variant<std::string, int> id;
		wil::com_ptr<ICoreWebView2Controller> webViewController;
		wil::com_ptr<ICoreWebView2> webView;
		std::unique_ptr<WebViewChannelDelegate> channelDelegate;

		InAppWebView(FlutterInappwebviewWindowsBasePlugin* plugin, std::variant<std::string, int> id, const HWND parentWindow, const std::function<void()> completionHandler);
		InAppWebView(FlutterInappwebviewWindowsBasePlugin* plugin, std::variant<std::string, int> id, const HWND parentWindow, const std::string& channelName, const std::function<void()> completionHandler);
		~InAppWebView();

		std::optional<std::string> getUrl() const;
		void loadUrl(const URLRequest urlRequest) const;

	private:
		void createWebView(const HWND parentWindow, const std::function<void()> completionHandler);
		void InAppWebView::registerEventHandlers();
	};
}
#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_H_