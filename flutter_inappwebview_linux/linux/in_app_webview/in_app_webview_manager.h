#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_MANAGER_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_MANAGER_H_

#include <flutter_linux/flutter_linux.h>

#include <cstdint>
#include <map>
#include <memory>
#include <string>

#include "../types/url_request.h"
#include "custom_platform_view.h"
#include "in_app_webview.h"
#include "in_app_webview_settings.h"

namespace flutter_inappwebview_plugin {

class InAppWebViewManager {
 public:
  static constexpr const char* METHOD_CHANNEL_NAME =
      "com.pichillilorenzo/flutter_inappwebview_manager";

  InAppWebViewManager(FlPluginRegistrar* registrar);
  ~InAppWebViewManager();

  FlPluginRegistrar* registrar() const { return registrar_; }

  CustomPlatformView* GetPlatformView(int64_t id) const;

  // Handle method calls from Flutter
  static void HandleMethodCall(FlMethodChannel* channel, FlMethodCall* method_call,
                               gpointer user_data);

 private:
  FlPluginRegistrar* registrar_ = nullptr;
  FlMethodChannel* method_channel_ = nullptr;
  FlTextureRegistrar* texture_registrar_ = nullptr;
  FlBinaryMessenger* messenger_ = nullptr;

  // Map of texture id to CustomPlatformView instance
  std::map<int64_t, std::unique_ptr<CustomPlatformView>> platform_views_;

  // Auto-incrementing ID for webviews
  int64_t next_id_ = 0;

  // Method handlers
  void HandleMethodCallImpl(FlMethodCall* method_call);
  void CreateInAppWebView(FlMethodCall* method_call);
  void DisposeWebView(int64_t texture_id);
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_MANAGER_H_
