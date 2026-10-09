#ifndef DRAGO_INAPPWEBVIEW_PLUGIN_CONTAINER_SESSION_CACHE_H_
#define DRAGO_INAPPWEBVIEW_PLUGIN_CONTAINER_SESSION_CACHE_H_

#include <wpe/webkit.h>

#include <filesystem>
#include <string>
#include <unordered_map>

namespace drago_inappwebview_plugin {

// Process-wide cache of WebKitNetworkSessions keyed by containerId.
//
// Each cached entry holds an extra g_object_ref so the session
// survives a WebView teardown (joining → disposing → re-joining the
// same container would otherwise abort with a thread-join error
// inside libwebkit). The cache is intentionally never released —
// sessions are cheap and the OS reclaims them on process exit.
//
// On-disk layout (created lazily by GetOrCreateContainerSession):
//   <XDG_DATA_HOME>/drago_inappwebview/containers/<id>/data
//   <XDG_CACHE_HOME>/drago_inappwebview/containers/<id>/cache
//
// Honored on WPE WebKit 2.40+ (where webkit_network_session_new
// exists). On older WPE the function is unavailable and the caller
// is expected to fall back to the default session.
//
// Three callers consume this:
//   - InAppWebView::InitWebView (joins a WebView to a container)
//   - ProxyManager (fans setProxyOverride / clearProxyOverride out
//     to every container session as well as the default one, so
//     contained sites don't silently bypass a process-wide proxy)
//   - cookie_manager (looks up a session via the WebView's
//     containerId for webViewId-scoped cookie ops)

std::unordered_map<std::string, WebKitNetworkSession*>&
container_session_cache();

std::filesystem::path container_data_root();
std::filesystem::path container_cache_root();

// Returns the cached session for `id`, creating it (and the data /
// cache directories) on first call. Returns nullptr if the runtime
// libwebkit doesn't expose webkit_network_session_new.
WebKitNetworkSession* get_or_create_container_session(const std::string& id);

}  // namespace drago_inappwebview_plugin

#endif  // DRAGO_INAPPWEBVIEW_PLUGIN_CONTAINER_SESSION_CACHE_H_
