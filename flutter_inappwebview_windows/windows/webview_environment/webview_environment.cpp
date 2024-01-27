#include <WebView2EnvironmentOptions.h>
#include <wil/wrl.h>

#include "../utils/log.h"
#include "webview_environment.h"

namespace flutter_inappwebview_plugin
{
  using namespace Microsoft::WRL;

  WebViewEnvironment::WebViewEnvironment(const FlutterInappwebviewWindowsPlugin* plugin, const std::string& id)
    : plugin(plugin), id(id),
    channelDelegate(std::make_unique<WebViewEnvironmentChannelDelegate>(this, plugin->registrar->messenger()))
  {}

  void WebViewEnvironment::create(const std::unique_ptr<WebViewEnvironmentSettings> settings, const std::function<void(HRESULT)> completionHandler)
  {
    auto options = Make<CoreWebView2EnvironmentOptions>();
    if (settings) {
      if (settings->additionalBrowserArguments.has_value()) {
        options->put_AdditionalBrowserArguments(utf8_to_wide(settings->additionalBrowserArguments.value()).c_str());
      }
      if (settings->allowSingleSignOnUsingOSPrimaryAccount.has_value()) {
        options->put_AllowSingleSignOnUsingOSPrimaryAccount(settings->allowSingleSignOnUsingOSPrimaryAccount.value());
      }
      if (settings->language.has_value()) {
        options->put_Language(utf8_to_wide(settings->language.value()).c_str());
      }
      if (settings->targetCompatibleBrowserVersion.has_value()) {
        options->put_TargetCompatibleBrowserVersion(utf8_to_wide(settings->targetCompatibleBrowserVersion.value()).c_str());
      }
    }

    auto hr = CreateCoreWebView2EnvironmentWithOptions(
      settings && settings->browserExecutableFolder.has_value() ? utf8_to_wide(settings->browserExecutableFolder.value()).c_str() : nullptr,
      settings && settings->userDataFolder.has_value() ? utf8_to_wide(settings->userDataFolder.value()).c_str() : nullptr,
      options.Get(),
      Callback<ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler>(
        [this, completionHandler](HRESULT result, wil::com_ptr<ICoreWebView2Environment> environment) -> HRESULT
        {
          if (succeededOrLog(result)) {
            env = std::move(environment);
          }
          if (completionHandler) {
            completionHandler(result);
          }
          return S_OK;
        }).Get());

    if (failedAndLog(hr) && completionHandler) {
      completionHandler(hr);
    }
  }

  WebViewEnvironment::~WebViewEnvironment()
  {
    debugLog("dealloc WebViewEnvironment");
  }
}