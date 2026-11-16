#include "flutter_inappwebview_windows_plugin.h"

#include <flutter/plugin_registrar_windows.h>

#include "cookie_manager.h"
#include "headless_in_app_webview/headless_in_app_webview_manager.h"
#include "in_app_browser/in_app_browser_manager.h"
#include "in_app_webview/in_app_webview_manager.h"
#include "platform_util.h"
#include "webview_environment/webview_environment_manager.h"


#pragma comment(lib, "Shlwapi.lib")
#pragma comment(lib, "dxgi.lib")
#pragma comment(lib, "d3d11.lib")
#pragma comment(lib, "rpcrt4.lib")  // UuidCreate - Minimum supported OS Win 2000
#pragma comment(lib, "WindowsApp.lib")

namespace flutter_inappwebview_plugin
{
  // Channels can outlive the engine dispatcher during registrar destruction.
  class PluginMessenger final : public flutter::BinaryMessenger {
  public:
    explicit PluginMessenger(flutter::BinaryMessenger* messenger) : messenger_(messenger) {}

    void Detach() { messenger_ = nullptr; }

    void Send(const std::string& channel, const uint8_t* data, size_t size,
      flutter::BinaryReply reply) const override
    {
      if (messenger_) {
        messenger_->Send(channel, data, size, std::move(reply));
      }
    }

    void SetMessageHandler(const std::string& channel, flutter::BinaryMessageHandler handler) override
    {
      if (messenger_) {
        messenger_->SetMessageHandler(channel, std::move(handler));
      }
    }

  private:
    flutter::BinaryMessenger* messenger_;
  };

  flutter::BinaryMessenger* FlutterInappwebviewWindowsPlugin::messenger() const
  {
    return messenger_.get();
  }

  // static
  void FlutterInappwebviewWindowsPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar)
  {
    auto plugin = std::make_unique<FlutterInappwebviewWindowsPlugin>(registrar);
    registrar->AddPlugin(std::move(plugin));
  }

  FlutterInappwebviewWindowsPlugin::FlutterInappwebviewWindowsPlugin(flutter::PluginRegistrarWindows* registrar)
    : messenger_(std::make_unique<PluginMessenger>(registrar->messenger())), registrar(registrar)
  {
    webViewEnvironmentManager = std::make_unique<WebViewEnvironmentManager>(this);
    inAppWebViewManager = std::make_unique<InAppWebViewManager>(this);
    inAppBrowserManager = std::make_unique<InAppBrowserManager>(this);
    headlessInAppWebViewManager = std::make_unique<HeadlessInAppWebViewManager>(this);
    cookieManager = std::make_unique<CookieManager>(this);
    platformUtil = std::make_unique<PlatformUtil>(this);

    window_proc_id = registrar->RegisterTopLevelWindowProcDelegate(
      [this](HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
      {
        return HandleWindowProc(hWnd, message, wParam, lParam);
      });
  }

  FlutterInappwebviewWindowsPlugin::~FlutterInappwebviewWindowsPlugin()
  {
    messenger_->Detach();
    if (registrar) {
      registrar->UnregisterTopLevelWindowProcDelegate(window_proc_id);
    }
    webViewEnvironmentManager = nullptr;
    inAppWebViewManager = nullptr;
    inAppBrowserManager = nullptr;
    headlessInAppWebViewManager = nullptr;
    cookieManager = nullptr;
    platformUtil = nullptr;
  }


  std::optional<LRESULT> FlutterInappwebviewWindowsPlugin::HandleWindowProc(
    HWND hWnd,
    UINT message,
    WPARAM wParam,
    LPARAM lParam)
  {
    std::optional<LRESULT> result = std::nullopt;

    if (platformUtil) {
      result = platformUtil->HandleWindowProc(hWnd, message, wParam, lParam);
    }

    return result;
  }
}