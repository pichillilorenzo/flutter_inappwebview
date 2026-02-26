#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_PROXY_MANAGER_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_PROXY_MANAGER_H_

#include <flutter_linux/flutter_linux.h>
#include <wpe/webkit.h>

#include <memory>
#include <optional>
#include <string>
#include <vector>

#include "types/channel_delegate.h"

namespace flutter_inappwebview_plugin {

class PluginInstance;

/**
 * Represents a proxy rule with URL and optional scheme filter.
 */
struct ProxyRule {
  std::string url;
  std::optional<std::string> schemeFilter;  // "HTTP", "HTTPS", or nullopt for all

  ProxyRule() = default;
  ProxyRule(const std::string& url, std::optional<std::string> schemeFilter = std::nullopt)
      : url(url), schemeFilter(schemeFilter) {}
  ProxyRule(FlValue* map);
};

/**
 * Represents proxy settings configuration.
 */
struct ProxySettings {
  std::vector<std::string> bypassRules;
  std::vector<ProxyRule> proxyRules;

  ProxySettings() = default;
  ProxySettings(FlValue* map);
};

/**
 * Manages proxy settings for WPE WebKit.
 * Uses WebKitNetworkProxySettings and WebKitNetworkSession for proxy configuration.
 */
class ProxyManager : public ChannelDelegate {
 public:
  static constexpr const char* METHOD_CHANNEL_NAME =
      "com.pichillilorenzo/flutter_inappwebview_proxycontroller";

  ProxyManager(PluginInstance* plugin);
  ~ProxyManager() override;

  /// Get the plugin instance
  PluginInstance* plugin() const { return plugin_; }

  void HandleMethodCall(FlMethodCall* method_call) override;

  /**
   * Set proxy override with the given settings.
   * This applies proxy settings to the default network session.
   */
  void setProxyOverride(const ProxySettings& settings);

  /**
   * Clear proxy override and revert to system defaults.
   */
  void clearProxyOverride();

 private:
  PluginInstance* plugin_ = nullptr;
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_PROXY_MANAGER_H_
