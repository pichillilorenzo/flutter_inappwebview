#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_COOKIE_MANAGER_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_COOKIE_MANAGER_H_

#include <flutter_linux/flutter_linux.h>
#include <wpe/webkit.h>

#include <functional>
#include <memory>
#include <optional>
#include <string>
#include <vector>

#include "types/channel_delegate.h"

namespace flutter_inappwebview_plugin {

class PluginInstance;

/**
 * Represents a cookie.
 */
class Cookie {
 public:
  std::string name;
  std::string value;
  std::optional<std::string> domain;
  std::optional<std::string> path;
  std::optional<int64_t> expiresDate;  // Unix timestamp in milliseconds
  bool isSecure;
  bool isHttpOnly;
  std::optional<std::string> sameSite;

  Cookie();
  Cookie(const std::string& name, const std::string& value);
  Cookie(SoupCookie* soupCookie);
  Cookie(FlValue* map);
  ~Cookie() = default;

  SoupCookie* toSoupCookie(const std::string& url) const;
  FlValue* toFlValue() const;
};

/**
 * Manages cookies for WebKitGTK.
 * Uses WebKitCookieManager and libsoup for cookie operations.
 */
class CookieManager : public ChannelDelegate {
 public:
  static constexpr const char* METHOD_CHANNEL_NAME =
      "com.pichillilorenzo/flutter_inappwebview_cookiemanager";

  CookieManager(PluginInstance* plugin);
  ~CookieManager() override;

  /// Get the plugin instance
  PluginInstance* plugin() const { return plugin_; }

  void HandleMethodCall(FlMethodCall* method_call) override;

  // Cookie operations
  void setCookie(const std::string& url, const Cookie& cookie, std::function<void(bool)> callback);

  void getCookies(const std::string& url, std::function<void(std::vector<Cookie>)> callback);

  void getCookie(const std::string& url, const std::string& name,
                 std::function<void(std::optional<Cookie>)> callback);

  void deleteCookie(const std::string& url, const std::string& name, const std::string& domain,
                    const std::string& path, std::function<void(bool)> callback);

  void deleteCookies(const std::string& url, const std::string& domain, const std::string& path,
                     std::function<void(bool)> callback);

  void deleteAllCookies(std::function<void(bool)> callback);

  void getAllCookies(std::function<void(std::vector<Cookie>)> callback);

 private:
  PluginInstance* plugin_ = nullptr;
  WebKitCookieManager* cookie_manager_;

  WebKitCookieManager* getCookieManager();
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_COOKIE_MANAGER_H_
