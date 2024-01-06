#include "in_app_webview.h"
#include <WebView2EnvironmentOptions.h>
#include <wil/wrl.h>
#include "../utils/strconv.h"

namespace flutter_inappwebview_plugin
{
	using namespace Microsoft::WRL;

	InAppWebView::InAppWebView(FlutterInappwebviewWindowsBasePlugin* plugin, std::variant<std::string, int> id, const HWND parentWindow, const std::function<void()> completionHandler)
		: plugin(plugin), id(id), channelDelegate(std::make_unique<WebViewChannelDelegate>(this, plugin->registrar->messenger()))
	{
		createWebView(parentWindow, completionHandler);
	}

	InAppWebView::InAppWebView(FlutterInappwebviewWindowsBasePlugin* plugin, std::variant<std::string, int> id, const HWND parentWindow, const std::string& channelName, const std::function<void()> completionHandler)
		: plugin(plugin), id(id), channelDelegate(std::make_unique<WebViewChannelDelegate>(this, plugin->registrar->messenger(), channelName))
	{
		createWebView(parentWindow, completionHandler);
	}

	void InAppWebView::createWebView(const HWND parentWindow, const std::function<void()> completionHandler)
	{
		CreateCoreWebView2EnvironmentWithOptions(nullptr, nullptr, nullptr,
			Callback<ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler>(
				[parentWindow, completionHandler, this](HRESULT result, ICoreWebView2Environment* env) -> HRESULT {
					// Create a CoreWebView2Controller and get the associated CoreWebView2 whose parent is the main window hWnd
					env->CreateCoreWebView2Controller(parentWindow, Callback<ICoreWebView2CreateCoreWebView2ControllerCompletedHandler>(
						[parentWindow, completionHandler, this](HRESULT result, ICoreWebView2Controller* controller) -> HRESULT {
							if (controller != nullptr) {
								webViewController = controller;
								webViewController->get_CoreWebView2(webView.put());
							}

							// Resize WebView to fit the bounds of the parent window
							RECT bounds;
							GetClientRect(parentWindow, &bounds);
							webViewController->put_Bounds(bounds);

							registerEventHandlers();

							completionHandler();

							return S_OK;
						}).Get());
					return S_OK;
				}).Get());
	}

	void InAppWebView::registerEventHandlers()
	{
		if (!webView) {
			return;
		}

		webView->add_NavigationStarting(
			Callback<ICoreWebView2NavigationStartingEventHandler>(
				[this](ICoreWebView2* sender, ICoreWebView2NavigationStartingEventArgs* args) {
					if (channelDelegate) {
						LPWSTR uri = nullptr;
						std::optional<std::string> url = SUCCEEDED(args->get_Uri(&uri)) ? wide_to_utf8(std::wstring(uri)) : std::optional<std::string>{};
						channelDelegate->onLoadStart(url);
					}

					args->put_Cancel(false);

					return S_OK;
				}
		).Get(), nullptr);

		webView->add_NavigationCompleted(
			Callback<ICoreWebView2NavigationCompletedEventHandler>(
				[this](ICoreWebView2* sender, ICoreWebView2NavigationCompletedEventArgs* args) {
					if (channelDelegate) {
						LPWSTR uri = nullptr;
						std::optional<std::string> url = SUCCEEDED(webView->get_Source(&uri)) ? wide_to_utf8(std::wstring(uri)) : std::optional<std::string>{};
						channelDelegate->onLoadStop(url);
					}
					return S_OK;
				}
		).Get(), nullptr);
	}

	std::optional<std::string> InAppWebView::getUrl() const
	{
		LPWSTR uri = nullptr;
		return SUCCEEDED(webView->get_Source(&uri)) ? wide_to_utf8(std::wstring(uri)) : std::optional<std::string>{};
	}

	void InAppWebView::loadUrl(const URLRequest urlRequest) const
	{
		if (!webView) {
			return;
		}

		auto url = urlRequest.url.value();
		std::wstring stemp = ansi_to_wide(url);

		// Schedule an async task to navigate to Bing
		webView->Navigate(stemp.c_str());
	}

	InAppWebView::~InAppWebView()
	{
		std::cout << "dealloc InAppWebView\n";
		if (webView) {
			webView->Stop();
		}
		if (webViewController) {
			webViewController->Close();
		}
		plugin = nullptr;
	}
}