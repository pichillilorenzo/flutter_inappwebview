#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_H_

#include <functional>

#include <WebView2.h>
#include <wil/com.h>
#include "../types/url_request.h"
#include "../types/navigation_action.h"
#include "webview_channel_delegate.h"
#include "../flutter_inappwebview_windows_plugin.h"

namespace flutter_inappwebview_plugin
{
	using namespace Microsoft::WRL;

	class InAppWebView
	{
	public:
		static inline const std::string METHOD_CHANNEL_NAME_PREFIX = "com.pichillilorenzo/flutter_inappwebview_";

		const FlutterInappwebviewWindowsPlugin* plugin;
		const std::variant<std::string, int> id;
		wil::com_ptr<ICoreWebView2Environment> webViewEnv;
		wil::com_ptr<ICoreWebView2Controller> webViewController;
		wil::com_ptr<ICoreWebView2> webView;
		const std::unique_ptr<WebViewChannelDelegate> channelDelegate;
		std::map<UINT64, std::shared_ptr<NavigationAction>> navigationActions = {};

		InAppWebView(FlutterInappwebviewWindowsPlugin* plugin, const std::variant<std::string, int>& id, const HWND parentWindow, const std::function<void()> completionHandler);
		InAppWebView(FlutterInappwebviewWindowsPlugin* plugin, const std::variant<std::string, int>& id, const HWND parentWindow, const std::string& channelName, const std::function<void()> completionHandler);
		~InAppWebView();

		std::optional<std::string> getUrl() const;
		void loadUrl(const URLRequest& urlRequest) const;

		static bool isSslError(const COREWEBVIEW2_WEB_ERROR_STATUS& webErrorStatus);
	private:
		bool callShouldOverrideUrlLoading = true;
		void createWebView(const HWND parentWindow, const std::function<void()> completionHandler);
		void InAppWebView::registerEventHandlers();
	};
}
#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_H_