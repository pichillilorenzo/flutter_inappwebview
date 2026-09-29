#include "proxy_manager.h"

#include <cctype>
#include <cstring>
#include <optional>
#include <utility>
#include <vector>

#include "container_session_cache.h"
#include "plugin_instance.h"
#include "utils/flutter.h"
#include "utils/log.h"

namespace flutter_inappwebview_plugin {

namespace {
// Helper to compare method names
bool string_equals(const gchar* a, const char* b) {
  return strcmp(a, b) == 0;
}

// Incognito sessions and their own proxy, or none to follow the process-wide
// override. Entries go when the session is finalized.
std::unordered_map<WebKitNetworkSession*, std::optional<ProxySettings>>&
private_sessions() {
  static std::unordered_map<WebKitNetworkSession*, std::optional<ProxySettings>>
      sessions;
  return sessions;
}

void on_private_session_finalized(gpointer, GObject* session) {
  private_sessions().erase(reinterpret_cast<WebKitNetworkSession*>(session));
}

// Sessions that setProxyOverride / clearProxyOverride should touch:
// the default session plus every cached container session. Without
// the fan-out, contained WebViews use a per-container session that
// never sees the override, so they'd silently bypass the proxy the
// caller asked the platform to apply process-wide.
// A container that pinned its own proxy is excluded: its session carries the
// site's choice, and a process-wide override must not overwrite it. That is
// the whole point of the pin -- without this, the last site activated would
// decide every container's proxy.
std::vector<WebKitNetworkSession*> sessions_to_apply_proxy_to() {
  std::vector<WebKitNetworkSession*> sessions;
  WebKitNetworkSession* defaultSession = webkit_network_session_get_default();
  if (defaultSession != nullptr) {
    sessions.push_back(defaultSession);
  }
  const auto& pins = container_proxy_pins();
  for (const auto& entry : container_session_cache()) {
    if (entry.second == nullptr || entry.second == defaultSession) continue;
    if (pins.find(entry.first) != pins.end()) continue;
    sessions.push_back(entry.second);
  }
  // Incognito sessions that named no proxy of their own.
  for (const auto& entry : private_sessions()) {
    if (!entry.second.has_value()) {
      sessions.push_back(entry.first);
    }
  }
  return sessions;
}

// Sets one session's proxy from `settings`. A null build result means the
// settings named no usable proxy; leaving the session alone is right there,
// because the caller's fail-closed path decides what to do about it.
void apply_proxy_to_session(WebKitNetworkSession* session,
                            const ProxySettings& settings);

// The override the Dart side last asked for, or nullopt when none is active
// (never set, or cleared). Sessions outlive no one: container sessions are
// created lazily, long after setProxyOverride may have run, so the intent has
// to be remembered rather than only applied to the session list of the moment.
std::optional<ProxySettings>& active_proxy_override() {
  static std::optional<ProxySettings> override;
  return override;
}

// A rule URL may leave out its scheme, as Android's [scheme://]host[:port]
// allows. WebKit needs a full URI and treats a scheme-less one as naming no
// proxy, sending requests direct, so default to http:// the way Android does.
std::string proxy_uri(const std::string& url) {
  if (url.empty() || url.find("://") != std::string::npos) {
    return url;
  }
  return "http://" + url;
}

// Translates `settings` into a WebKitNetworkProxySettings, or nullptr when
// WebKit refuses to allocate one. The caller owns the result and frees it with
// webkit_network_proxy_settings_free.
WebKitNetworkProxySettings* build_proxy_settings(const ProxySettings& settings) {
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
      defaultProxyUri = proxy_uri(rule.url);
      break;
    }

    std::string scheme = rule.schemeFilter.value();
    for (char& c : scheme) {
      c = static_cast<char>(std::tolower(static_cast<unsigned char>(c)));
    }
    if (scheme == "*") {
      defaultProxyUri = proxy_uri(rule.url);
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

    schemeSpecificProxyRules.emplace_back(std::move(scheme), proxy_uri(rule.url));
  }

  // A rule set that named no usable proxy is refused rather than applied.
  // webkit_network_proxy_settings_new(nullptr, ...) with no scheme entries is
  // not a no-op: it puts the session in WEBKIT_NETWORK_PROXY_MODE_CUSTOM with
  // nothing in it, so every request goes direct. Silently unproxying is the
  // one outcome a caller asking for a proxy must never get.
  if (defaultProxyUri.empty() && schemeSpecificProxyRules.empty()) {
    errorLog("ProxyManager: no usable proxy in the rule set; leaving the current proxy alone");
    return nullptr;
  }

  // Create the proxy settings
  WebKitNetworkProxySettings* proxySettings = webkit_network_proxy_settings_new(
      defaultProxyUri.empty() ? nullptr : defaultProxyUri.c_str(),
      settings.bypassRules.empty() ? nullptr : ignoreHostsCStrings.data());

  if (proxySettings == nullptr) {
    errorLog("ProxyManager: Failed to create WebKitNetworkProxySettings");
    return nullptr;
  }

  // Add scheme-specific proxies
  for (const auto& entry : schemeSpecificProxyRules) {
    webkit_network_proxy_settings_add_proxy_for_scheme(
        proxySettings, entry.first.c_str(), entry.second.c_str());
  }

  return proxySettings;
}
void apply_proxy_to_session(WebKitNetworkSession* session,
                            const ProxySettings& settings) {
  WebKitNetworkProxySettings* proxySettings = build_proxy_settings(settings);
  if (proxySettings == nullptr) {
    return;
  }
  webkit_network_session_set_proxy_settings(
      session, WEBKIT_NETWORK_PROXY_MODE_CUSTOM, proxySettings);
  webkit_network_proxy_settings_free(proxySettings);
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

  // A containerId scopes the call to that container, the entry a WebView's
  // proxySettings writes too. An empty one names no container.
  std::string containerId = get_fl_map_value<std::string>(args, "containerId", "");

  if (string_equals(method, "setProxyOverride")) {
    FlValue* settingsMap = get_fl_map_value_raw(args, "settings");
    if (settingsMap == nullptr || fl_value_get_type(settingsMap) != FL_VALUE_TYPE_MAP) {
      fl_method_call_respond_success(method_call, fl_value_new_null(), nullptr);
      return;
    }

    ProxySettings settings(settingsMap);
    if (containerId.empty()) {
      setProxyOverride(settings);
    } else {
      pin_container_proxy(containerId, settings);
    }
    fl_method_call_respond_success(method_call, fl_value_new_null(), nullptr);

  } else if (string_equals(method, "clearProxyOverride")) {
    if (containerId.empty()) {
      clearProxyOverride();
    } else {
      unpin_container_proxy(containerId);
    }
    fl_method_call_respond_success(method_call, fl_value_new_null(), nullptr);

  } else {
    fl_method_call_respond_not_implemented(method_call, nullptr);
  }
}

void ProxyManager::setProxyOverride(const ProxySettings& settings) {
  // Built first: a rule set that names no usable proxy -- including one with
  // no proxy rules at all -- is refused outright,
  // and refusing must not leave the override remembered -- a later container
  // would replay an intent that resolves to nothing.
  WebKitNetworkProxySettings* proxySettings = build_proxy_settings(settings);
  if (proxySettings == nullptr) {
    return;
  }

  // Remembered before touching any session: it is a process-wide intent, not a
  // property of the sessions that happen to exist right now.
  // get_or_create_container_session replays it onto each container session it
  // creates later.
  active_proxy_override() = settings;

  std::vector<WebKitNetworkSession*> sessions = sessions_to_apply_proxy_to();
  if (sessions.empty()) {
    errorLog("ProxyManager: No network sessions available");
    webkit_network_proxy_settings_free(proxySettings);
    return;
  }

  // Apply the proxy settings to every session (default + each cached
  // container) so a process-wide override actually applies process-wide.
  for (WebKitNetworkSession* s : sessions) {
    webkit_network_session_set_proxy_settings(
        s, WEBKIT_NETWORK_PROXY_MODE_CUSTOM, proxySettings);
  }

  // Free the proxy settings
  webkit_network_proxy_settings_free(proxySettings);
}

void ProxyManager::clearProxyOverride() {
  // Forget the override first: a session created after this point must come up
  // on the system proxy, not on the one we just revoked.
  active_proxy_override().reset();

  std::vector<WebKitNetworkSession*> sessions = sessions_to_apply_proxy_to();
  if (sessions.empty()) {
    errorLog("ProxyManager: No network sessions available");
    return;
  }

  // Revert to system default proxy settings on every session.
  for (WebKitNetworkSession* s : sessions) {
    webkit_network_session_set_proxy_settings(
        s, WEBKIT_NETWORK_PROXY_MODE_DEFAULT, nullptr);
  }
}

void apply_active_proxy_override(WebKitNetworkSession* session) {
  if (session == nullptr) {
    return;
  }

  const std::optional<ProxySettings>& active = active_proxy_override();
  if (!active.has_value()) {
    return;
  }

  apply_proxy_to_session(session, active.value());
}

std::unordered_map<std::string, ProxySettings>& container_proxy_pins() {
  static std::unordered_map<std::string, ProxySettings> pins;
  return pins;
}

bool pin_container_proxy(const std::string& id, const ProxySettings& settings) {
  if (id.empty()) {
    return false;
  }
  // A rule set with no usable proxy is not pinned: the pin would exempt the
  // container from the process-wide override while applying nothing itself.
  WebKitNetworkProxySettings* proxySettings = build_proxy_settings(settings);
  if (proxySettings == nullptr) {
    return false;
  }
  container_proxy_pins()[id] = settings;

  // The session may not exist yet, and apply_container_proxy picks the pin up
  // when it is created. But a container that already has one -- a second
  // WebView on the same site, or ProxyController changing the proxy of a
  // container in use -- gets no new session, so the pin has to reach the
  // live one here.
  auto& cache = container_session_cache();
  auto it = cache.find(id);
  if (it != cache.end() && it->second != nullptr) {
    webkit_network_session_set_proxy_settings(
        it->second, WEBKIT_NETWORK_PROXY_MODE_CUSTOM, proxySettings);
  }
  webkit_network_proxy_settings_free(proxySettings);
  return true;
}

void unpin_container_proxy(const std::string& id) {
  if (id.empty()) {
    return;
  }
  if (container_proxy_pins().erase(id) == 0) {
    return;
  }

  auto& cache = container_session_cache();
  auto it = cache.find(id);
  if (it == cache.end() || it->second == nullptr) {
    return;
  }

  // Hand the live session back to what an unpinned container follows.
  const auto& active = active_proxy_override();
  if (active.has_value()) {
    apply_proxy_to_session(it->second, active.value());
    return;
  }
  webkit_network_session_set_proxy_settings(
      it->second, WEBKIT_NETWORK_PROXY_MODE_DEFAULT, nullptr);
}

void apply_container_proxy(const std::string& id,
                           WebKitNetworkSession* session) {
  if (session == nullptr) {
    return;
  }
  const auto& pins = container_proxy_pins();
  auto it = pins.find(id);
  if (it != pins.end()) {
    apply_proxy_to_session(session, it->second);
    return;
  }
  apply_active_proxy_override(session);
}

void bind_private_session(WebKitNetworkSession* session,
                          const std::optional<ProxySettings>& own) {
  if (session == nullptr) {
    return;
  }
  std::optional<ProxySettings> usable;
  if (own.has_value()) {
    WebKitNetworkProxySettings* proxySettings = build_proxy_settings(own.value());
    if (proxySettings != nullptr) {
      webkit_network_proxy_settings_free(proxySettings);
      usable = own;
    }
  }
  auto& sessions = private_sessions();
  if (sessions.find(session) == sessions.end()) {
    g_object_weak_ref(G_OBJECT(session), on_private_session_finalized, nullptr);
  }
  sessions[session] = usable;
  if (usable.has_value()) {
    apply_proxy_to_session(session, usable.value());
  } else {
    apply_active_proxy_override(session);
  }
}

}  // namespace flutter_inappwebview_plugin
