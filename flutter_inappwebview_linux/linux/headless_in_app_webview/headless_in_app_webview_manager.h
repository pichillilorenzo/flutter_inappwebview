#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_HEADLESS_IN_APP_WEBVIEW_MANAGER_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_HEADLESS_IN_APP_WEBVIEW_MANAGER_H_

#include <flutter_linux/flutter_linux.h>

#include <map>
#include <memory>
#include <string>

#include "headless_in_app_webview.h"

namespace flutter_inappwebview_plugin {

class PluginInstance;

class HeadlessInAppWebViewManager {
 public:
  static constexpr const char* METHOD_CHANNEL_NAME =
      "com.pichillilorenzo/flutter_headless_inappwebview";

  HeadlessInAppWebViewManager(PluginInstance* plugin);
  ~HeadlessInAppWebViewManager();

  PluginInstance* plugin() const { return plugin_; }
  FlPluginRegistrar* registrar() const;
  FlBinaryMessenger* messenger() const { return messenger_; }

  // Get a headless webview by ID
  HeadlessInAppWebView* GetHeadlessWebView(const std::string& id) const;

  // Remove a headless webview by ID (called during dispose)
  void RemoveHeadlessWebView(const std::string& id);

 private:
  PluginInstance* plugin_ = nullptr;
  FlPluginRegistrar* registrar_ = nullptr;
  FlBinaryMessenger* messenger_ = nullptr;
  FlMethodChannel* method_channel_ = nullptr;
  GtkWindow* gtk_window_ = nullptr;  // Cached GTK window (can be null for headless)

  // Map of id to HeadlessInAppWebView instance
  std::map<std::string, std::unique_ptr<HeadlessInAppWebView>> webviews_;

  // Handle method calls from Flutter
  static void HandleMethodCall(FlMethodChannel* channel, FlMethodCall* method_call,
                               gpointer user_data);
  void HandleMethodCallImpl(FlMethodCall* method_call);
  void Run(FlMethodCall* method_call);
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_HEADLESS_IN_APP_WEBVIEW_MANAGER_H_
