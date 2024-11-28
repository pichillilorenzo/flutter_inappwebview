#include <WebView2EnvironmentOptions.h>
#include <wil/wrl.h>

#include "../utils/log.h"
#include "webview_environment.h"

#include "webview_environment_manager.h"

namespace flutter_inappwebview_plugin
{
  using namespace Microsoft::WRL;

  WebViewEnvironment::WebViewEnvironment(const FlutterInappwebviewWindowsPlugin* plugin, const std::string& id)
    : plugin(plugin), id(id),
    channelDelegate(std::make_unique<WebViewEnvironmentChannelDelegate>(this, plugin->registrar->messenger()))
  {}

  void WebViewEnvironment::create(const std::unique_ptr<WebViewEnvironmentSettings> settings, const std::function<void(HRESULT)> completionHandler)
  {
    if (!plugin) {
      if (completionHandler) {
        completionHandler(E_FAIL);
      }
      return;
    }

    auto hwnd = plugin->webViewEnvironmentManager->getHWND();
    if (!hwnd) {
      if (completionHandler) {
        completionHandler(E_FAIL);
      }
      return;
    }

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
      wil::com_ptr<ICoreWebView2EnvironmentOptions2> options2;
      if (succeededOrLog(options->QueryInterface(IID_PPV_ARGS(&options2))) && settings->exclusiveUserDataFolderAccess.has_value()) {
        options2->put_ExclusiveUserDataFolderAccess(settings->exclusiveUserDataFolderAccess.value());
      }
      wil::com_ptr<ICoreWebView2EnvironmentOptions3> options3;
      if (succeededOrLog(options->QueryInterface(IID_PPV_ARGS(&options3))) && settings->isCustomCrashReportingEnabled.has_value()) {
        options3->put_IsCustomCrashReportingEnabled(settings->isCustomCrashReportingEnabled.value());
      }
      wil::com_ptr<ICoreWebView2EnvironmentOptions4> options4;
      if (succeededOrLog(options->QueryInterface(IID_PPV_ARGS(&options4))) && settings->customSchemeRegistrations.has_value()) {
        std::vector<ICoreWebView2CustomSchemeRegistration*> registrations = {};
        for (auto& customSchemeRegistration : settings->customSchemeRegistrations.value()) {
          registrations.push_back(std::move(customSchemeRegistration->toWebView2CustomSchemeRegistration()));
        }
        options4->SetCustomSchemeRegistrations(static_cast<UINT32>(registrations.size()), registrations.data());
      }
      wil::com_ptr<ICoreWebView2EnvironmentOptions5> options5;
      if (succeededOrLog(options->QueryInterface(IID_PPV_ARGS(&options5))) && settings->enableTrackingPrevention.has_value()) {
        options5->put_EnableTrackingPrevention(settings->enableTrackingPrevention.value());
      }
      wil::com_ptr<ICoreWebView2EnvironmentOptions6> options6;
      if (succeededOrLog(options->QueryInterface(IID_PPV_ARGS(&options6))) && settings->areBrowserExtensionsEnabled.has_value()) {
        options6->put_AreBrowserExtensionsEnabled(settings->areBrowserExtensionsEnabled.value());
      }
      wil::com_ptr<ICoreWebView2EnvironmentOptions7> options7;
      if (succeededOrLog(options->QueryInterface(IID_PPV_ARGS(&options7)))) {
        if (settings->channelSearchKind.has_value()) {
          options7->put_ChannelSearchKind(static_cast<COREWEBVIEW2_CHANNEL_SEARCH_KIND>(settings->channelSearchKind.value()));
        }
        if (settings->releaseChannels.has_value()) {
          options7->put_ReleaseChannels(static_cast<COREWEBVIEW2_RELEASE_CHANNELS>(settings->releaseChannels.value()));
        }
      }
      wil::com_ptr<ICoreWebView2EnvironmentOptions8> options8;
      if (succeededOrLog(options->QueryInterface(IID_PPV_ARGS(&options8))) && settings->scrollbarStyle.has_value()) {
        options8->put_ScrollBarStyle(static_cast<COREWEBVIEW2_SCROLLBAR_STYLE>(settings->scrollbarStyle.value()));
      }
    }

    auto hr = CreateCoreWebView2EnvironmentWithOptions(
      settings && settings->browserExecutableFolder.has_value() ? utf8_to_wide(settings->browserExecutableFolder.value()).c_str() : nullptr,
      settings && settings->userDataFolder.has_value() ? utf8_to_wide(settings->userDataFolder.value()).c_str() : nullptr,
      options.Get(),
      Callback<ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler>(
        [this, hwnd, completionHandler](HRESULT result, wil::com_ptr<ICoreWebView2Environment> environment) -> HRESULT
        {
          if (succeededOrLog(result)) {
            environment_ = std::move(environment);

            auto add_NewBrowserVersionAvailable_HResult = environment_->add_NewBrowserVersionAvailable(Callback<ICoreWebView2NewBrowserVersionAvailableEventHandler>(
              [this](ICoreWebView2Environment* sender, IUnknown* args)
              {
                if (channelDelegate) {
                  channelDelegate->onNewBrowserVersionAvailable();
                }
                return S_OK;
              }
            ).Get(), &newBrowserVersionAvailableToken_);
            failedLog(add_NewBrowserVersionAvailable_HResult);

            if (auto environment5 = environment_.try_query<ICoreWebView2Environment5>()) {
              auto add_BrowserProcessExited_HResult = environment5->add_BrowserProcessExited(Callback<ICoreWebView2BrowserProcessExitedEventHandler>(
                [this](ICoreWebView2Environment* sender, ICoreWebView2BrowserProcessExitedEventArgs* args)
                {
                  if (channelDelegate) {
                    COREWEBVIEW2_BROWSER_PROCESS_EXIT_KIND exitKind;
                    std::optional<int64_t> kind = SUCCEEDED(args->get_BrowserProcessExitKind(&exitKind)) ? static_cast<int64_t>(exitKind) : std::optional<int64_t>{};

                    UINT32 pid;
                    std::optional<int64_t> processId = SUCCEEDED(args->get_BrowserProcessId(&pid)) ? static_cast<int64_t>(pid) : std::optional<int64_t>{};

                    auto browserProcessExitedDetail = std::make_shared<BrowserProcessExitedDetail>(kind, processId);
                    channelDelegate->onBrowserProcessExited(std::move(browserProcessExitedDetail));
                  }
                  return S_OK;
                }
              ).Get(), &browserProcessExitedToken_);
              failedLog(add_BrowserProcessExited_HResult);
            }

            if (auto environment8 = environment_.try_query<ICoreWebView2Environment8>()) {
              auto add_ProcessInfosChanged_HResult = environment8->add_ProcessInfosChanged(Callback<ICoreWebView2ProcessInfosChangedEventHandler>(
                [this, environment8](ICoreWebView2Environment* sender, IUnknown* args)
                {
                  if (!environment_) {
                    return S_OK;
                  }
                  if (auto environment13 = environment_.try_query<ICoreWebView2Environment13>()) {
                    auto hr = environment13->GetProcessExtendedInfos(Callback<ICoreWebView2GetProcessExtendedInfosCompletedHandler>(
                      [this](HRESULT error, wil::com_ptr<ICoreWebView2ProcessExtendedInfoCollection> processCollection) -> HRESULT
                      {
                        if (succeededOrLog(error) && processCollection) {
                          auto browserProcessInfosChangedDetail = BrowserProcessInfosChangedDetail::fromICoreWebView2ProcessExtendedInfoCollection(processCollection);
                          channelDelegate->onProcessInfosChanged(std::move(browserProcessInfosChangedDetail));
                        }
                        return S_OK;
                      }).Get());

                    if (succeededOrLog(hr)) {
                      return S_OK;
                    }
                  }
                  wil::com_ptr<ICoreWebView2ProcessInfoCollection> processCollection;
                  if (channelDelegate && succeededOrLog(environment8->GetProcessInfos(&processCollection))) {
                    auto browserProcessInfosChangedDetail = BrowserProcessInfosChangedDetail::fromICoreWebView2ProcessInfoCollection(processCollection);
                    channelDelegate->onProcessInfosChanged(std::move(browserProcessInfosChangedDetail));
                  }
                  return S_OK;
                }
              ).Get(), &processInfosChangedToken_);
              failedLog(add_ProcessInfosChanged_HResult);
            }

            completionHandler(S_OK);
          }
          else if (completionHandler) {
            completionHandler(result);
          }
          return S_OK;
        }).Get());

    if (failedAndLog(hr) && completionHandler) {
      completionHandler(hr);
    }
  }

  void WebViewEnvironment::useTempWebView(const std::function<void(wil::com_ptr<ICoreWebView2Controller>, wil::com_ptr<ICoreWebView2>)> completionHandler) const
  {
    auto hwnd = plugin->webViewEnvironmentManager->getHWND();
    if (!hwnd) {
      if (completionHandler) {
        completionHandler(nullptr, nullptr);
      }
      return;
    }

    auto hr = environment_->CreateCoreWebView2Controller(hwnd, Callback<ICoreWebView2CreateCoreWebView2ControllerCompletedHandler>(
      [this, completionHandler](HRESULT result, wil::com_ptr<ICoreWebView2Controller> controller) -> HRESULT
      {
        if (succeededOrLog(result)) {
          controller->put_IsVisible(false);

          wil::com_ptr<ICoreWebView2> webView_;
          controller->get_CoreWebView2(&webView_);

          if (completionHandler) {
            completionHandler(std::move(controller), std::move(webView_));
          }
        }
        else if (completionHandler) {
          completionHandler(nullptr, nullptr);
        }
        return S_OK;
      }).Get());

    if (failedAndLog(hr) && completionHandler) {
      completionHandler(nullptr, nullptr);
    }
  }

  bool WebViewEnvironment::isInterfaceSupported(const std::string& interfaceName) const
  {
    if (!environment_) {
      return false;
    }

    if (starts_with(interfaceName, std::string{ "ICoreWebView2Environment" })) {
      switch (string_hash(interfaceName)) {
      case string_hash("ICoreWebView2Environment"):
        return environment_.try_query<ICoreWebView2Environment>() != nullptr;
      case string_hash("ICoreWebView2Environment2"):
        return environment_.try_query<ICoreWebView2Environment2>() != nullptr;
      case string_hash("ICoreWebView2Environment3"):
        return environment_.try_query<ICoreWebView2Environment3>() != nullptr;
      case string_hash("ICoreWebView2Environment4"):
        return environment_.try_query<ICoreWebView2Environment4>() != nullptr;
      case string_hash("ICoreWebView2Environment5"):
        return environment_.try_query<ICoreWebView2Environment5>() != nullptr;
      case string_hash("ICoreWebView2Environment6"):
        return environment_.try_query<ICoreWebView2Environment6>() != nullptr;
      case string_hash("ICoreWebView2Environment7"):
        return environment_.try_query<ICoreWebView2Environment7>() != nullptr;
      case string_hash("ICoreWebView2Environment8"):
        return environment_.try_query<ICoreWebView2Environment8>() != nullptr;
      case string_hash("ICoreWebView2Environment9"):
        return environment_.try_query<ICoreWebView2Environment9>() != nullptr;
      case string_hash("ICoreWebView2Environment10"):
        return environment_.try_query<ICoreWebView2Environment10>() != nullptr;
      case string_hash("ICoreWebView2Environment11"):
        return environment_.try_query<ICoreWebView2Environment11>() != nullptr;
      case string_hash("ICoreWebView2Environment12"):
        return environment_.try_query<ICoreWebView2Environment12>() != nullptr;
      case string_hash("ICoreWebView2Environment13"):
        return environment_.try_query<ICoreWebView2Environment13>() != nullptr;
      case string_hash("ICoreWebView2Environment14"):
        return environment_.try_query<ICoreWebView2Environment14>() != nullptr;
      default:
        return false;
      }
    }

    return false;
  }

  void WebViewEnvironment::getProcessInfos(const std::function<void(std::vector<std::shared_ptr<BrowserProcessInfo>>)> completionHandler) const
  {
    if (!environment_) {
      if (completionHandler) {
        completionHandler({});
      }
      return;
    }

    if (auto environment13 = environment_.try_query<ICoreWebView2Environment13>()) {
      auto hr = environment13->GetProcessExtendedInfos(Callback<ICoreWebView2GetProcessExtendedInfosCompletedHandler>(
        [completionHandler](HRESULT error, wil::com_ptr<ICoreWebView2ProcessExtendedInfoCollection> processCollection) -> HRESULT
        {
          std::vector<std::shared_ptr<BrowserProcessInfo>> processInfos = {};
          if (succeededOrLog(error) && processCollection) {
            auto browserProcessInfosChangedDetail = BrowserProcessInfosChangedDetail::fromICoreWebView2ProcessExtendedInfoCollection(processCollection);
            processInfos = browserProcessInfosChangedDetail->infos;
          }
          if (completionHandler) {
            completionHandler(processInfos);
          }
          return S_OK;
        }).Get());

      if (succeededOrLog(hr)) {
        return;
      }
    }
    std::vector<std::shared_ptr<BrowserProcessInfo>> processInfos = {};
    if (auto environment8 = environment_.try_query<ICoreWebView2Environment8>()) {
      wil::com_ptr<ICoreWebView2ProcessInfoCollection> processCollection;
      if (succeededOrLog(environment8->GetProcessInfos(&processCollection))) {
        auto browserProcessInfosChangedDetail = BrowserProcessInfosChangedDetail::fromICoreWebView2ProcessInfoCollection(processCollection);
        processInfos = browserProcessInfosChangedDetail->infos;
      }
    }

    if (completionHandler) {
      completionHandler(processInfos);
    }
  }

  std::optional<std::string> WebViewEnvironment::getFailureReportFolderPath() const
  {
    if (!environment_) {
      return std::optional<std::string>{};
    }

    if (auto environment11 = environment_.try_query<ICoreWebView2Environment11>()) {
      wil::unique_cotaskmem_string failureReportFolderPath;
      if (succeededOrLog(environment11->get_FailureReportFolderPath(&failureReportFolderPath))) {
        return wide_to_utf8(failureReportFolderPath.get());
      }
    }

    return std::optional<std::string>{};
  }

  WebViewEnvironment::~WebViewEnvironment()
  {
    debugLog("dealloc WebViewEnvironment");
    if (environment_) {
      environment_->remove_NewBrowserVersionAvailable(newBrowserVersionAvailableToken_);
      if (auto environment5 = environment_.try_query<ICoreWebView2Environment5>()) {
        environment5->remove_BrowserProcessExited(browserProcessExitedToken_);
      }
      if (auto environment8 = environment_.try_query<ICoreWebView2Environment8>()) {
        environment8->remove_ProcessInfosChanged(processInfosChangedToken_);
      }
    }
    environment_ = nullptr;
  }
}
