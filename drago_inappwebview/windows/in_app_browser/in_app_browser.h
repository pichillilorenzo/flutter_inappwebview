#ifndef DRAGO_INAPPWEBVIEW_PLUGIN_IN_APP_BROWSER_H_
#define DRAGO_INAPPWEBVIEW_PLUGIN_IN_APP_BROWSER_H_

#include <optional>
#include <string>
#include <Windows.h>

#include "../drago_inappwebview_plugin.h"
#include "../in_app_webview/in_app_webview.h"
#include "../in_app_webview/in_app_webview_settings.h"
#include "../types/url_request.h"
#include "in_app_browser_channel_delegate.h"
#include "in_app_browser_settings.h"

namespace drago_inappwebview_plugin
{
  struct InAppBrowserCreationParams
  {
    const std::string id;
    const std::optional<std::shared_ptr<URLRequest>> urlRequest;
    const std::optional<std::string> assetFilePath;
    const std::optional<std::string> data;
    const std::shared_ptr<InAppBrowserSettings> initialSettings;
    const std::shared_ptr<InAppWebViewSettings> initialWebViewSettings;
    const std::optional<std::vector<std::shared_ptr<UserScript>>> initialUserScripts;
    const std::optional<std::string> webViewEnvironmentId;
    const std::optional<flutter::EncodableMap> contextMenu = std::nullopt;
  };

  class InAppBrowser {
  public:
    static inline const std::string METHOD_CHANNEL_NAME_PREFIX = "com.pichillilorenzo/flutter_inappbrowser_";
    static inline const wchar_t* CLASS_NAME = L"InAppBrowser";

    static LRESULT CALLBACK WndProc(HWND window,
      UINT message,
      WPARAM wparam,
      LPARAM lparam) noexcept;

    const DragoInappwebviewPlugin* plugin;
    const std::string id;
    std::unique_ptr<InAppWebView> webView;
    std::unique_ptr<InAppBrowserChannelDelegate> channelDelegate;
    std::shared_ptr<InAppBrowserSettings> settings;

    InAppBrowser(const DragoInappwebviewPlugin* plugin, const InAppBrowserCreationParams& params);
    ~InAppBrowser();

    void close() const;
    void show() const;
    void hide() const;
    bool isHidden() const;
    void setSettings(const std::shared_ptr<InAppBrowserSettings> newSettings, const flutter::EncodableMap& newSettingsMap);
    flutter::EncodableValue getSettings() const;

    void didChangeTitle(const std::optional<std::string>& title) const;
    HWND getHWND() const
    {
      return m_hWnd;
    }
  private:
    const HINSTANCE m_hInstance;
    HWND m_hWnd;
    bool destroyed_ = false;
    static InAppBrowser* GetThisFromHandle(HWND window) noexcept;
    LRESULT MessageHandler(HWND window,
      UINT message,
      WPARAM wparam,
      LPARAM lparam) noexcept;
  };
}
#endif //DRAGO_INAPPWEBVIEW_PLUGIN_IN_APP_BROWSER_H_