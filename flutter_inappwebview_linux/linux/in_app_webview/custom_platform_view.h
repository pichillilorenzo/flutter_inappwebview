#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_CUSTOM_PLATFORM_VIEW_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_CUSTOM_PLATFORM_VIEW_H_

#include <flutter_linux/flutter_linux.h>

#include <memory>
#include <string>

#include "in_app_webview.h"
#include "inappwebview_egl_texture.h"

namespace flutter_inappwebview_plugin {

using WebViewType = InAppWebView;

/// CustomPlatformView handles the method channel communication for
/// pointer/mouse events, sizing, and other platform view operations.
/// This is similar to the Windows implementation.
class CustomPlatformView {
 public:
  CustomPlatformView(FlBinaryMessenger* messenger, FlTextureRegistrar* texture_registrar,
                     std::shared_ptr<WebViewType> webview);
  ~CustomPlatformView();

  int64_t texture_id() const { return texture_id_; }
  WebViewType* webview() const { return webview_.get(); }

  // Keep-alive ID management
  // When set, this WebView should be preserved when disposed and stored in keepAliveWebViews_
  void set_keep_alive_id(const std::string& id) { keepAliveId_ = id; }
  const std::string& keep_alive_id() const { return keepAliveId_; }
  bool has_keep_alive_id() const { return !keepAliveId_.empty(); }

  void MarkTextureFrameAvailable();

 private:
  std::shared_ptr<WebViewType> webview_;
  FlTextureRegistrar* texture_registrar_;
  FlTexture* texture_ = nullptr;
  InAppWebViewEGLTexture* egl_texture_ = nullptr;  // Pointer to EGL texture if using zero-copy mode
  int64_t texture_id_ = -1;
  std::string keepAliveId_;  // Keep-alive ID for preserving WebView across widget disposal

  FlMethodChannel* method_channel_ = nullptr;
  FlEventChannel* event_channel_ = nullptr;
  bool event_sink_active_ = false;

  // Method call handler
  static void HandleMethodCall(FlMethodChannel* channel, FlMethodCall* method_call,
                               gpointer user_data);
  void HandleMethodCallImpl(FlMethodCall* method_call);

  // Event channel handlers
  static FlMethodErrorResponse* OnListen(FlEventChannel* channel, FlValue* args,
                                         gpointer user_data);
  static FlMethodErrorResponse* OnCancel(FlEventChannel* channel, FlValue* args,
                                         gpointer user_data);

  void EmitCursorChanged(const std::string& cursor_name);
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_CUSTOM_PLATFORM_VIEW_H_
