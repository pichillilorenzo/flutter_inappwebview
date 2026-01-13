#include "proxy_manager.h"

#include <cctype>
#include <cstring>

#include "plugin_instance.h"
#include "utils/flutter.h"
#include "utils/log.h"

namespace flutter_inappwebview_plugin {

namespace {
// Helper to compare method names
bool string_equals(const gchar* a, const char* b) {
  return strcmp(a, b) == 0;
}
}  // namespace

// === ProxyRule ===

ProxyRule::ProxyRule(FlValue* map) {
  if (map == nullptr || fl_value_get_type(map) != FL_VALUE_TYPE_MAP) {
    return;
  }

  url = get_fl_map_value<std::string>(map, "url", "");
  
  // Check for schemeFilter - it may be a map with "rawValue" or a direct value
  FlValue* schemeFilterValue = get_fl_map_value_raw(map, "schemeFilter");
  if (schemeFilterValue != nullptr) {
    if (fl_value_get_type(schemeFilterValue) == FL_VALUE_TYPE_MAP) {
      // It's a map, look for "rawValue" field
      schemeFilter = get_optional_fl_map_value<std::string>(schemeFilterValue, "rawValue");
    } else if (fl_value_get_type(schemeFilterValue) == FL_VALUE_TYPE_STRING) {
      // It's a direct string
      schemeFilter = std::string(fl_value_get_string(schemeFilterValue));
    }
  }
}

// === ProxySettings ===

ProxySettings::ProxySettings(FlValue* map) {
  if (map == nullptr || fl_value_get_type(map) != FL_VALUE_TYPE_MAP) {
    return;
  }

  bypassRules = get_fl_map_value<std::vector<std::string>>(map, "bypassRules", {});

  // Parse proxyRules
  FlValue* proxyRulesValue = get_fl_map_value_raw(map, "proxyRules");
  if (proxyRulesValue != nullptr && fl_value_get_type(proxyRulesValue) == FL_VALUE_TYPE_LIST) {
    size_t length = fl_value_get_length(proxyRulesValue);
    for (size_t i = 0; i < length; i++) {
      FlValue* item = fl_value_get_list_value(proxyRulesValue, i);
      if (item != nullptr && fl_value_get_type(item) == FL_VALUE_TYPE_MAP) {
        proxyRules.emplace_back(item);
      }
    }
  }
}

// === ProxyManager ===

ProxyManager::ProxyManager(PluginInstance* plugin)
    : ChannelDelegate(plugin->messenger(), METHOD_CHANNEL_NAME),
      plugin_(plugin) {}

ProxyManager::~ProxyManager() {
  debugLog("dealloc ProxyManager");
  plugin_ = nullptr;
}

void ProxyManager::HandleMethodCall(FlMethodCall* method_call) {
  const gchar* method = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);

  if (string_equals(method, "setProxyOverride")) {
    FlValue* settingsMap = get_fl_map_value_raw(args, "settings");
    if (settingsMap == nullptr || fl_value_get_type(settingsMap) != FL_VALUE_TYPE_MAP) {
      fl_method_call_respond_success(method_call, fl_value_new_null(), nullptr);
      return;
    }

    ProxySettings settings(settingsMap);
    setProxyOverride(settings);
    fl_method_call_respond_success(method_call, fl_value_new_null(), nullptr);

  } else if (string_equals(method, "clearProxyOverride")) {
    clearProxyOverride();
    fl_method_call_respond_success(method_call, fl_value_new_null(), nullptr);

  } else {
    fl_method_call_respond_not_implemented(method_call, nullptr);
  }
}

void ProxyManager::setProxyOverride(const ProxySettings& settings) {
  WebKitNetworkSession* session = webkit_network_session_get_default();
  if (session == nullptr) {
    errorLog("ProxyManager: Failed to get default network session");
    return;
  }

  // If no proxy rules, clear the proxy
  if (settings.proxyRules.empty()) {
    clearProxyOverride();
    return;
  }

  // Build the ignore_hosts array from bypassRules
  std::vector<const char*> ignoreHostsCStrings;
  for (const auto& rule : settings.bypassRules) {
    ignoreHostsCStrings.push_back(rule.c_str());
  }
  ignoreHostsCStrings.push_back(nullptr);  // NULL-terminate the array

  // Get the default proxy URI (first proxy rule with no schemeFilter, or schemeFilter == "*")
  std::string defaultProxyUri;
  for (const auto& rule : settings.proxyRules) {
    if (!rule.schemeFilter.has_value() || rule.schemeFilter.value().empty()) {
      defaultProxyUri = rule.url;
      break;
    }

    std::string scheme = rule.schemeFilter.value();
    for (char& c : scheme) {
      c = static_cast<char>(std::tolower(static_cast<unsigned char>(c)));
    }
    if (scheme == "*") {
      defaultProxyUri = rule.url;
      break;
    }
  }

  // Collect supported scheme-specific proxy rules so we can decide whether we
  // need to force a direct default proxy to activate custom mode.
  std::vector<std::pair<std::string, std::string>> schemeSpecificProxyRules;
  schemeSpecificProxyRules.reserve(settings.proxyRules.size());
  for (const auto& rule : settings.proxyRules) {
    if (!rule.schemeFilter.has_value() || rule.schemeFilter.value().empty()) {
      continue;
    }

    std::string scheme = rule.schemeFilter.value();
    for (char& c : scheme) {
      c = static_cast<char>(std::tolower(static_cast<unsigned char>(c)));
    }

    // Treat "*" as default proxy (already handled above).
    if (scheme == "*") {
      continue;
    }

    // Accept common scheme filters.
    if (scheme != "http" && scheme != "https" && scheme != "socks" && scheme != "socks4" &&
        scheme != "socks5") {
      continue;
    }

    schemeSpecificProxyRules.emplace_back(std::move(scheme), rule.url);
  }

  // Create the proxy settings
  WebKitNetworkProxySettings* proxySettings = webkit_network_proxy_settings_new(
      defaultProxyUri.empty() ? nullptr : defaultProxyUri.c_str(),
      settings.bypassRules.empty() ? nullptr : ignoreHostsCStrings.data());

  if (proxySettings == nullptr) {
    errorLog("ProxyManager: Failed to create WebKitNetworkProxySettings");
    return;
  }

  // Add scheme-specific proxies
  for (const auto& entry : schemeSpecificProxyRules) {
    webkit_network_proxy_settings_add_proxy_for_scheme(
        proxySettings, entry.first.c_str(), entry.second.c_str());
  }

  // Apply the proxy settings to the session
  webkit_network_session_set_proxy_settings(
      session, WEBKIT_NETWORK_PROXY_MODE_CUSTOM, proxySettings);

  // Free the proxy settings
  webkit_network_proxy_settings_free(proxySettings);
}

void ProxyManager::clearProxyOverride() {
  WebKitNetworkSession* session = webkit_network_session_get_default();
  if (session == nullptr) {
    errorLog("ProxyManager: Failed to get default network session");
    return;
  }

  // Revert to system default proxy settings
  webkit_network_session_set_proxy_settings(
      session, WEBKIT_NETWORK_PROXY_MODE_DEFAULT, nullptr);
}

}  // namespace flutter_inappwebview_plugin
