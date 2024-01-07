#pragma comment(lib, "Shlwapi.lib")

#include "in_app_webview.h"
#include <WebView2EnvironmentOptions.h>
#include <wil/wrl.h>
#include <Shlwapi.h>
#include "../utils/strconv.h"
#include "../utils/util.h"

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
					webViewEnv = env;
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
					if (!channelDelegate) {
						args->put_Cancel(false);
						return S_OK;
					}
					
					wil::unique_cotaskmem_string uri = nullptr;
					std::optional<std::string> url = SUCCEEDED(args->get_Uri(&uri)) ? wide_to_utf8(std::wstring(uri.get())) : std::optional<std::string>{};

					wil::unique_cotaskmem_string method = nullptr;
					wil::com_ptr<ICoreWebView2HttpRequestHeaders> requestHeaders = nullptr;
					std::optional<std::map<std::string, std::string>> headers = std::optional<std::map<std::string, std::string>>{};
					if (SUCCEEDED(args->get_RequestHeaders(&requestHeaders))) {
						headers = std::make_optional<std::map<std::string, std::string>>({});
						wil::com_ptr<ICoreWebView2HttpHeadersCollectionIterator> iterator;
						requestHeaders->GetIterator(&iterator);
						BOOL hasCurrent = FALSE;
						while (SUCCEEDED(iterator->get_HasCurrentHeader(&hasCurrent)) && hasCurrent)
						{
							wil::unique_cotaskmem_string name;
							wil::unique_cotaskmem_string value;

							if (SUCCEEDED(iterator->GetCurrentHeader(&name, &value))) {
								headers->insert({ wide_to_utf8(std::wstring(name.get())), wide_to_utf8(std::wstring(value.get())) });
							}

							BOOL hasNext = FALSE;
							iterator->MoveNext(&hasNext);
						}

						requestHeaders->GetHeader(L"Flutter-InAppWebView-Request-Method", &method);
						requestHeaders->RemoveHeader(L"Flutter-InAppWebView-Request-Method");
					}

					if (callShouldOverrideUrlLoading && method == nullptr) {
						// for some reason, we can't cancel and load an URL with other HTTP methods other than GET,
						// so ignore the shouldOverrideUrlLoading event.

						auto urlRequest = std::make_shared<URLRequest>(url, std::nullopt, headers, std::nullopt);
						auto navigationAction = std::make_unique<NavigationAction>(
							urlRequest,
							true
						);
						
						auto callback = std::make_unique<WebViewChannelDelegate::ShouldOverrideUrlLoadingCallback>();
						callback->nonNullSuccess = [this, urlRequest](const NavigationActionPolicy actionPolicy) {
								callShouldOverrideUrlLoading = false;
								if (actionPolicy == allow) {
									loadUrl(*urlRequest);
								}
								return false;
							};
						auto defaultBehaviour = [this, urlRequest](const std::optional<NavigationActionPolicy> actionPolicy) {
								callShouldOverrideUrlLoading = false;
								loadUrl(*urlRequest);
							};
						callback->defaultBehaviour = defaultBehaviour;
						callback->error = [defaultBehaviour](const std::string& error_code, const std::string& error_message, const flutter::EncodableValue* error_details) {
								debugLog(error_code + ", " + error_message);
								defaultBehaviour(std::nullopt);
							};
						channelDelegate->shouldOverrideUrlLoading(std::move(navigationAction), std::move(callback));
						args->put_Cancel(true);
					}
					else {
						callShouldOverrideUrlLoading = true;
						channelDelegate->onLoadStart(url);
						args->put_Cancel(false);
					}

					return S_OK;
				}
		).Get(), nullptr);

		webView->add_NavigationCompleted(
			Callback<ICoreWebView2NavigationCompletedEventHandler>(
				[this](ICoreWebView2* sender, ICoreWebView2NavigationCompletedEventArgs* args) {
					COREWEBVIEW2_WEB_ERROR_STATUS web_error_status;
					args->get_WebErrorStatus(&web_error_status);
					debugLog("WebErrorStatus " + std::to_string(web_error_status) + "\n");

					BOOL isSuccess;
					args->get_IsSuccess(&isSuccess);

					if (channelDelegate) {
						LPWSTR uri = nullptr;
						std::optional<std::string> url = SUCCEEDED(webView->get_Source(&uri)) ? wide_to_utf8(std::wstring(uri)) : std::optional<std::string>{};
						if (isSuccess) {
							channelDelegate->onLoadStop(url);
						}
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
		if (!webView || !urlRequest.url.has_value()) {
			return;
		}

		std::wstring url = ansi_to_wide(urlRequest.url.value());

		wil::com_ptr<ICoreWebView2Environment2> webViewEnv2;
		wil::com_ptr<ICoreWebView2_2> webView2;
		if (SUCCEEDED(webViewEnv->QueryInterface(IID_PPV_ARGS(&webViewEnv2))) && SUCCEEDED(webView->QueryInterface(IID_PPV_ARGS(&webView2)))) {
			wil::com_ptr<ICoreWebView2WebResourceRequest> webResourceRequest;
			std::wstring method = urlRequest.method.has_value() ? ansi_to_wide(urlRequest.method.value()) : L"GET";
			
			wil::com_ptr<IStream> postDataStream = nullptr;
			if (urlRequest.body.has_value()) {
				auto postData = std::string(urlRequest.body->begin(), urlRequest.body->end());
				postDataStream = SHCreateMemStream(
					reinterpret_cast<const BYTE*>(postData.data()), static_cast<UINT>(postData.length()));
			}
			webViewEnv2->CreateWebResourceRequest(
				url.c_str(),
				method.c_str(),
				postDataStream.get(),
				L"",
				&webResourceRequest
			);
			wil::com_ptr<ICoreWebView2HttpRequestHeaders> requestHeaders;
			if (SUCCEEDED(webResourceRequest->get_Headers(&requestHeaders))) {
				if (urlRequest.method.has_value() && urlRequest.method.value().compare("GET") != 0) {
					requestHeaders->SetHeader(L"Flutter-InAppWebView-Request-Method", method.c_str());
				}
				if (urlRequest.headers.has_value()) {
					auto& headers = urlRequest.headers.value();
					for (auto const& [key, val] : headers) {
						requestHeaders->SetHeader(ansi_to_wide(key).c_str(), ansi_to_wide(val).c_str());
					}
				}
			}
			webView2->NavigateWithWebResourceRequest(webResourceRequest.get());
		}
		else {
			webView->Navigate(url.c_str());
		}
	}

	InAppWebView::~InAppWebView()
	{
		debugLog("dealloc InAppWebView");
		if (webView) {
			webView->Stop();
		}
		if (webViewController) {
			webViewController->Close();
		}
		plugin = nullptr;
	}
}