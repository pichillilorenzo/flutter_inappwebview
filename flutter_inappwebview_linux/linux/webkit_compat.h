// WebKit backend compatibility header.
//
// The Linux plugin supports two WebKit ports:
//
//   * WPE WebKit (wpe-webkit-2.0, HAVE_WPE_PLATFORM / HAVE_WPE_BACKEND_LEGACY)
//     The preferred backend: offscreen rendering with DMA-BUF export.
//
//   * WebKitGTK (webkit2gtk-4.1, HAVE_WEBKITGTK)
//     Fallback backend used when WPE WebKit is not available on the system.
//     Ubuntu stopped shipping WPE WebKit packages after 22.04, but every
//     desktop Ubuntu/Debian release ships WebKitGTK (libwebkit2gtk-4.1-dev),
//     so this backend lets the plugin build with distro packages only.
//
// Both ports share the same "WebKit GLib API", but WPE uses the 2.0 API while
// webkit2gtk-4.1 exposes the older 4.1 API. The differences that matter for
// this plugin are small and are papered over here so that the shared code can
// be written against the 2.0 API names:
//
//   2.0 API (WPE)                          4.1 API (WebKitGTK)
//   ----------------------------------     -------------------------------------
//   WebKitNetworkSession                   WebKitWebContext owns the same objects
//   webkit_network_session_*()             webkit_web_context_*() /
//                                          webkit_website_data_manager_*()
//   WebKitColor                            GdkRGBA (identical layout)
//   WebKitRectangle                        GdkRectangle (identical layout)
//   register_script_message_handler(m,n,w) register_script_message_handler(m,n) /
//                                          ..._in_world(m,n,w)
//   set_web_process_extensions_directory   set_web_extensions_directory
//
// Signal signatures that differ (context-menu, show-option-menu,
// script-message-received) are handled with #ifdef HAVE_WEBKITGTK at the
// signal connection sites.
//
// Every source file that needs the WebKit API must include this header instead
// of <wpe/webkit.h> or <webkit2/webkit2.h> directly.

#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_WEBKIT_COMPAT_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_WEBKIT_COMPAT_H_

#if defined(HAVE_WEBKITGTK)

#include <gtk/gtk.h>
#include <webkit2/webkit2.h>

// --- Type aliases -----------------------------------------------------------

// In the 4.1 API the WebKitWebContext owns the cookie manager, website data
// manager, proxy settings, downloads, etc. Those responsibilities moved to
// WebKitNetworkSession in the 2.0 API, so the context is the natural stand-in.
typedef WebKitWebContext WebKitNetworkSession;

// WebKitColor (2.0 API) and GdkRGBA have the same four-double layout.
typedef GdkRGBA WebKitColor;

// WebKitRectangle (2.0 API) and GdkRectangle have the same four-int layout.
typedef GdkRectangle WebKitRectangle;

// --- WebKitNetworkSession shims --------------------------------------------

static inline WebKitNetworkSession* webkit_network_session_get_default(void) {
  return webkit_web_context_get_default();
}

static inline WebKitCookieManager* webkit_network_session_get_cookie_manager(
    WebKitNetworkSession* session) {
  return webkit_web_context_get_cookie_manager(session);
}

static inline WebKitWebsiteDataManager* webkit_network_session_get_website_data_manager(
    WebKitNetworkSession* session) {
  return webkit_web_context_get_website_data_manager(session);
}

static inline void webkit_network_session_set_proxy_settings(
    WebKitNetworkSession* session, WebKitNetworkProxyMode proxy_mode,
    WebKitNetworkProxySettings* proxy_settings) {
  WebKitWebsiteDataManager* manager = webkit_web_context_get_website_data_manager(session);
  if (manager != nullptr) {
    webkit_website_data_manager_set_network_proxy_settings(manager, proxy_mode, proxy_settings);
  }
}

static inline void webkit_network_session_set_itp_enabled(WebKitNetworkSession* session,
                                                          gboolean enabled) {
  WebKitWebsiteDataManager* manager = webkit_web_context_get_website_data_manager(session);
  if (manager != nullptr) {
    webkit_website_data_manager_set_itp_enabled(manager, enabled);
  }
}

static inline void webkit_network_session_allow_tls_certificate_for_host(
    WebKitNetworkSession* session, GTlsCertificate* certificate, const gchar* host) {
  webkit_web_context_allow_tls_certificate_for_host(session, certificate, host);
}

static inline WebKitNetworkSession* webkit_web_view_get_network_session(WebKitWebView* web_view) {
  return webkit_web_view_get_context(web_view);
}

// --- WebKitWebContext shims -------------------------------------------------

static inline void webkit_web_context_set_web_process_extensions_directory(
    WebKitWebContext* context, const gchar* directory) {
  webkit_web_context_set_web_extensions_directory(context, directory);
}

// --- WebKitColor shims ------------------------------------------------------

static inline gboolean webkit_color_parse(WebKitColor* color, const gchar* color_string) {
  return gdk_rgba_parse(color, color_string);
}

// --- WebKitUserContentManager shims -----------------------------------------
//
// The 2.0 API takes an optional world name for (un)registering script message
// handlers. The 4.1 API has separate *_in_world() functions. These C++
// overloads (the C functions have C linkage, the overloads have C++ linkage,
// which the language allows) let the shared code use the 2.0 spelling.

static inline gboolean webkit_user_content_manager_register_script_message_handler(
    WebKitUserContentManager* manager, const gchar* name, const gchar* world_name) {
  if (world_name != nullptr) {
    return webkit_user_content_manager_register_script_message_handler_in_world(manager, name,
                                                                                world_name);
  }
  return webkit_user_content_manager_register_script_message_handler(manager, name);
}

static inline void webkit_user_content_manager_unregister_script_message_handler(
    WebKitUserContentManager* manager, const gchar* name, const gchar* world_name) {
  if (world_name != nullptr) {
    webkit_user_content_manager_unregister_script_message_handler_in_world(manager, name,
                                                                           world_name);
    return;
  }
  webkit_user_content_manager_unregister_script_message_handler(manager, name);
}

#else  // WPE WebKit

#include <wpe/webkit.h>

#endif  // HAVE_WEBKITGTK

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_WEBKIT_COMPAT_H_
