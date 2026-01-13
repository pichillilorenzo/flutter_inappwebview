#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_MANAGER_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_MANAGER_H_

#include <flutter_linux/flutter_linux.h>
#include <wpe/webkit.h>

#include <cstdint>
#include <map>
#include <memory>
#include <string>

#include "../types/url_request.h"
#include "../types/web_view_transport.h"
#include "custom_platform_view.h"
#include "in_app_webview.h"
#include "in_app_webview_settings.h"

namespace flutter_inappwebview_plugin {

class PluginInstance;

class InAppWebViewManager {
 public:
  static constexpr const char* METHOD_CHANNEL_NAME =
      "com.pichillilorenzo/flutter_inappwebview_manager";

  InAppWebViewManager(PluginInstance* plugin);
  ~InAppWebViewManager();

  PluginInstance* plugin() const { return plugin_; }
  FlPluginRegistrar* registrar() const;
  GtkWindow* gtk_window() const { return gtk_window_; }
  FlView* fl_view() const { return fl_view_; }

  CustomPlatformView* GetPlatformView(int64_t id) const;

  // Handle method calls from Flutter
  static void HandleMethodCall(FlMethodChannel* channel, FlMethodCall* method_call,
                               gpointer user_data);

  // Keep-alive management
  // Store a WebView for later reuse when widget is disposed but keepAliveId is set
  void StoreKeepAliveWebView(const std::string& keepAliveId, std::unique_ptr<CustomPlatformView> view);
  // Get a keep-alive WebView by its ID (returns nullptr if not found)
  CustomPlatformView* GetKeepAliveWebView(const std::string& keepAliveId) const;
  // Take ownership of a keep-alive WebView (removes from map and returns)
  std::unique_ptr<CustomPlatformView> TakeKeepAliveWebView(const std::string& keepAliveId);
  // Dispose a keep-alive WebView by its ID
  void DisposeKeepAlive(const std::string& keepAliveId);

 private:
  PluginInstance* plugin_ = nullptr;
  FlPluginRegistrar* registrar_ = nullptr;
  GtkWindow* gtk_window_ = nullptr;  // Cached during plugin registration
  FlView* fl_view_ = nullptr;  // Cached FlView for focus restoration
  FlMethodChannel* method_channel_ = nullptr;
  FlTextureRegistrar* texture_registrar_ = nullptr;
  FlBinaryMessenger* messenger_ = nullptr;

  // Map of texture id to CustomPlatformView instance
  std::map<int64_t, std::unique_ptr<CustomPlatformView>> platform_views_;

  // Map of keepAliveId to CustomPlatformView instance
  // These are WebViews that persist when their widget is disposed
  std::map<std::string, std::unique_ptr<CustomPlatformView>> keepAliveWebViews_;

  // Map of window id to WebViewTransport for popup windows
  // Used to track WebViews created via onCreateWindow
  std::map<int64_t, std::unique_ptr<WebViewTransport>> windowWebViews_;
  
  // Auto-incrementing ID for window webviews  
  int64_t windowAutoincrementId_ = 0;

  // Auto-incrementing ID for webviews
  int64_t next_id_ = 0;

  // Method handlers
  void HandleMethodCallImpl(FlMethodCall* method_call);
  void CreateInAppWebView(FlMethodCall* method_call);
  void DisposeWebView(int64_t texture_id);
  void ClearAllCache(FlMethodCall* method_call, bool includeDiskFiles);

 public:
  // Window webview management for multi-window support
  int64_t GetNextWindowId() { return ++windowAutoincrementId_; }
  void AddWindowWebView(int64_t windowId, std::unique_ptr<WebViewTransport> transport);
  WebViewTransport* GetWindowWebView(int64_t windowId);
  void RemoveWindowWebView(int64_t windowId);
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_MANAGER_H_
