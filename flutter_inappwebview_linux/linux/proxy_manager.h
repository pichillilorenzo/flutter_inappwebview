#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_PROXY_MANAGER_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_PROXY_MANAGER_H_

#include <flutter_linux/flutter_linux.h>
#include <wpe/webkit.h>

#include <memory>
#include <optional>
#include <string>
#include <unordered_map>
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

/**
 * Applies the active process-wide proxy override, if any, to a single
 * network session.
 *
 * setProxyOverride can only reach the sessions that exist when it runs, but
 * a container session is created lazily, the first time a WebView joins
 * that container. A session created afterwards starts in
 * WEBKIT_NETWORK_PROXY_MODE_DEFAULT (system proxy), so without this hook the
 * contained WebView would silently bypass the proxy the caller asked the
 * platform to apply process-wide. Called by get_or_create_container_session.
 */
void apply_active_proxy_override(WebKitNetworkSession* session);

/**
 * Per-container proxies ("pins"), keyed by containerId.
 *
 * WPE applies a proxy to one `WebKitNetworkSession`, and every container owns
 * one, so two containers really can hold two different proxies at the same
 * time. ProxyController.setProxyOverride(containerId:) and a WebView's
 * proxySettings both set a container's pin; the process-wide override leaves
 * pinned containers alone. A pin ends only with
 * clearProxyOverride(containerId:), which hands the session back to the
 * process-wide override; a WebView naming no proxy does not change it.
 */
std::unordered_map<std::string, ProxySettings>& container_proxy_pins();

/**
 * Pin `id`'s session to `settings` and apply it if that session already
 * exists. A rule set with no usable proxy is not pinned; returns whether it
 * was. Called by setProxyOverride with a containerId, and at WebView
 * construction, before the session is created, so the proxy is in place
 * before the container's first request.
 */
bool pin_container_proxy(const std::string& id, const ProxySettings& settings);

/**
 * Drop `id`'s pin and hand its session back to whatever it would follow
 * without one: the process-wide override, or the system proxy when none is
 * active. Called by clearProxyOverride with a containerId.
 */
void unpin_container_proxy(const std::string& id);

/**
 * An incognito WebView's ephemeral session, which has no id to address it
 * by. With `own` naming a usable proxy it keeps that one; otherwise it
 * follows the process-wide override, changes included. Called at WebView
 * construction; the session is forgotten when it is finalized.
 */
void bind_private_session(WebKitNetworkSession* session,
                          const std::optional<ProxySettings>& own);

/**
 * Apply whichever proxy `id` should be on: its own pin if it has one, else
 * the process-wide override. Called by get_or_create_container_session.
 */
void apply_container_proxy(const std::string& id,
                           WebKitNetworkSession* session);

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_PROXY_MANAGER_H_
