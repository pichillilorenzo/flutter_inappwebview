#include "container_session_cache.h"

#include <cstdlib>
#include <system_error>

namespace drago_inappwebview_plugin {

std::unordered_map<std::string, WebKitNetworkSession*>&
container_session_cache() {
  static std::unordered_map<std::string, WebKitNetworkSession*> cache;
  return cache;
}

std::filesystem::path container_data_root() {
  const char* xdg = std::getenv("XDG_DATA_HOME");
  if (xdg && *xdg) {
    return std::filesystem::path(xdg) / "drago_inappwebview" / "containers";
  }
  const char* home = std::getenv("HOME");
  return std::filesystem::path(home ? home : "/tmp") / ".local" / "share" /
         "drago_inappwebview" / "containers";
}

std::filesystem::path container_cache_root() {
  const char* xdg = std::getenv("XDG_CACHE_HOME");
  if (xdg && *xdg) {
    return std::filesystem::path(xdg) / "drago_inappwebview" / "containers";
  }
  const char* home = std::getenv("HOME");
  return std::filesystem::path(home ? home : "/tmp") / ".cache" /
         "drago_inappwebview" / "containers";
}

WebKitNetworkSession* get_or_create_container_session(const std::string& id) {
  auto& cache = container_session_cache();
  auto it = cache.find(id);
  if (it != cache.end()) return it->second;

  const auto data_dir = container_data_root() / id / "data";
  const auto cache_dir = container_cache_root() / id / "cache";
  std::error_code ec;
  std::filesystem::create_directories(data_dir, ec);
  std::filesystem::create_directories(cache_dir, ec);

  WebKitNetworkSession* session =
      webkit_network_session_new(data_dir.c_str(), cache_dir.c_str());
  if (session == nullptr) return nullptr;

  // The cache holds the canonical reference. Each call site that uses
  // the returned session takes its own ref via g_object_new's
  // "network-session" property handling.
  cache.emplace(id, session);
  return session;
}

}  // namespace drago_inappwebview_plugin
