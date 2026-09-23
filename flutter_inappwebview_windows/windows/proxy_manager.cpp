#include <algorithm>
#include <cctype>

#include "proxy_manager.h"
#include "utils/flutter.h"
#include "utils/log.h"
#include "utils/string.h"

namespace flutter_inappwebview_plugin
{
  // === ProxySettings ===

  ProxySettings::ProxySettings(const flutter::EncodableMap& map)
  {
    if (fl_map_contains_not_null(map, "bypassRules")) {
      auto bypassList = std::get<flutter::EncodableList>(map.at(make_fl_value("bypassRules")));
      for (const auto& item : bypassList) {
        if (auto* str = std::get_if<std::string>(&item)) {
          bypassRules.push_back(*str);
        }
      }
    }

    if (fl_map_contains_not_null(map, "proxyRules")) {
      auto rulesList = std::get<flutter::EncodableList>(map.at(make_fl_value("proxyRules")));
      for (const auto& item : rulesList) {
        if (auto* ruleMap = std::get_if<flutter::EncodableMap>(&item)) {
          ProxyRule rule;
          rule.url = get_fl_map_value<std::string>(*ruleMap, "url");

          if (fl_map_contains_not_null(*ruleMap, "schemeFilter")) {
            auto schemeFilterValue = ruleMap->at(make_fl_value("schemeFilter"));
            if (auto* schemeMap = std::get_if<flutter::EncodableMap>(&schemeFilterValue)) {
              if (fl_map_contains_not_null(*schemeMap, "rawValue")) {
                rule.schemeFilter = get_fl_map_value<std::string>(*schemeMap, "rawValue");
              }
            } else if (auto* str = std::get_if<std::string>(&schemeFilterValue)) {
              rule.schemeFilter = *str;
            }
          }

          proxyRules.push_back(std::move(rule));
        }
      }
    }
  }

  std::optional<std::string> ProxySettings::toProxyServerArg() const
  {
    if (proxyRules.empty()) {
      return std::nullopt;
    }

    // WebView2 --proxy-server format:
    // Single proxy: "host:port"
    // Per-scheme: "http=proxy1:80;https=proxy2:443;socks=socks5://proxy3:1080"
    std::string defaultProxy;
    std::vector<std::string> schemeProxies;

    for (const auto& rule : proxyRules) {
      if (!rule.schemeFilter.has_value() || rule.schemeFilter.value().empty()) {
        if (defaultProxy.empty()) {
          defaultProxy = rule.url;
        }
        continue;
      }

      std::string scheme = rule.schemeFilter.value();
      std::transform(scheme.begin(), scheme.end(), scheme.begin(),
        [](unsigned char c) { return static_cast<char>(std::tolower(c)); });

      if (scheme == "*") {
        if (defaultProxy.empty()) {
          defaultProxy = rule.url;
        }
      } else {
        schemeProxies.push_back(scheme + "=" + rule.url);
      }
    }

    if (schemeProxies.empty()) {
      return defaultProxy.empty() ? std::nullopt : std::optional<std::string>(defaultProxy);
    }

    // If we have a default proxy and scheme-specific, combine them
    std::string result;
    if (!defaultProxy.empty()) {
      result = defaultProxy;
    }
    for (const auto& sp : schemeProxies) {
      if (!result.empty()) {
        result += ";";
      }
      result += sp;
    }

    return result.empty() ? std::nullopt : std::optional<std::string>(result);
  }

  std::optional<std::string> ProxySettings::toProxyBypassListArg() const
  {
    if (bypassRules.empty()) {
      return std::nullopt;
    }

    std::string result;
    for (const auto& rule : bypassRules) {
      if (!result.empty()) {
        result += ";";
      }
      result += rule;
    }

    return result;
  }

  // === ProxyManager ===

  ProxyManager::ProxyManager(const FlutterInappwebviewWindowsPlugin* plugin)
    : plugin(plugin), ChannelDelegate(plugin->registrar->messenger(), ProxyManager::METHOD_CHANNEL_NAME)
  {}

  void ProxyManager::HandleMethodCall(const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    auto& methodName = method_call.method_name();

    if (string_equals(methodName, "setProxyOverride")) {
      auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
      if (arguments && fl_map_contains_not_null(*arguments, "settings")) {
        auto settingsMap = std::get<flutter::EncodableMap>(arguments->at(make_fl_value("settings")));
        ProxySettings settings(settingsMap);
        proxyServerArg_ = settings.toProxyServerArg();
        proxyBypassListArg_ = settings.toProxyBypassListArg();
        result->Success(true);
      } else {
        result->Success(false);
      }
    }
    else if (string_equals(methodName, "clearProxyOverride")) {
      proxyServerArg_ = std::nullopt;
      proxyBypassListArg_ = std::nullopt;
      result->Success(true);
    }
    else {
      result->NotImplemented();
    }
  }

  ProxyManager::~ProxyManager()
  {
    debugLog("dealloc ProxyManager");
    plugin = nullptr;
  }
}
