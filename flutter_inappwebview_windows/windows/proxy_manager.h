#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_PROXY_MANAGER_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_PROXY_MANAGER_H_

#include <flutter/encodable_value.h>
#include <flutter/method_channel.h>
#include <functional>
#include <optional>
#include <string>
#include <vector>

#include "flutter_inappwebview_windows_plugin.h"
#include "types/channel_delegate.h"

namespace flutter_inappwebview_plugin
{
  struct ProxyRule
  {
    std::string url;
    std::optional<std::string> schemeFilter;
  };

  struct ProxySettings
  {
    std::vector<std::string> bypassRules;
    std::vector<ProxyRule> proxyRules;

    ProxySettings() = default;
    ProxySettings(const flutter::EncodableMap& map);

    // WebView2 --proxy-server argument (e.g. "http=proxy:80;https=proxy:443")
    std::optional<std::string> toProxyServerArg() const;
    // WebView2 --proxy-bypass-list argument (e.g. "host1;host2")
    std::optional<std::string> toProxyBypassListArg() const;
  };

  class ProxyManager : public ChannelDelegate
  {
  public:
    static inline const std::string METHOD_CHANNEL_NAME = "com.pichillilorenzo/flutter_inappwebview_proxycontroller";

    const FlutterInappwebviewWindowsPlugin* plugin;

    ProxyManager(const FlutterInappwebviewWindowsPlugin* plugin);
    ~ProxyManager();

    void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

    // Stored proxy args for use by WebViewEnvironment
    std::optional<std::string> getProxyServerArg() const { return proxyServerArg_; }
    std::optional<std::string> getProxyBypassListArg() const { return proxyBypassListArg_; }

  private:
    std::optional<std::string> proxyServerArg_;
    std::optional<std::string> proxyBypassListArg_;
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_PROXY_MANAGER_H_
