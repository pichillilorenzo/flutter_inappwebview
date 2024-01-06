#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_BROWSER_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_BROWSER_H_

#include <Windows.h>
#include <string>
#include <optional>

#include <wil/com.h>
#include "../flutter_inappwebview_windows_base_plugin.h"
#include "../in_app_webview/in_app_webview.h"
#include "../types/url_request.h"
#include "in_app_browser_channel_delegate.h"

namespace flutter_inappwebview_plugin
{
	struct InAppBrowserCreationParams
	{
		std::string id;
		std::optional<URLRequest> urlRequest;
	};

	class InAppBrowser {
	public:
		static inline const std::string METHOD_CHANNEL_NAME_PREFIX = "com.pichillilorenzo/flutter_inappbrowser_";

		static LRESULT CALLBACK WndProc(HWND window,
			UINT message,
			WPARAM wparam,
			LPARAM lparam) noexcept;

		FlutterInappwebviewWindowsBasePlugin* plugin;
		std::string id;
		std::optional<URLRequest> initialUrlRequest;
		std::unique_ptr<InAppWebView> webView;
		std::unique_ptr<InAppBrowserChannelDelegate> channelDelegate;

		InAppBrowser(FlutterInappwebviewWindowsBasePlugin* plugin, const InAppBrowserCreationParams& params);
		~InAppBrowser();

	private:
		HINSTANCE m_hInstance;
		HWND m_hWnd;
		bool destroyed_ = false;
		static InAppBrowser* GetThisFromHandle(HWND window) noexcept;
		LRESULT MessageHandler(HWND window,
			UINT message,
			WPARAM wparam,
			LPARAM lparam) noexcept;
	};
}
#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_BROWSER_H_