#ifndef FLUTTER_INAPPWEBVIEW_WEBKITGTK_MANAGER_H_
#define FLUTTER_INAPPWEBVIEW_WEBKITGTK_MANAGER_H_

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>

#include <map>
#include <memory>

#include "webkitgtk_view.h"

namespace flutter_inappwebview_webkit {

class WebKitGTKManager {
 public:
  explicit WebKitGTKManager(FlPluginRegistrar* registrar);
  ~WebKitGTKManager();

  // Disallow copy
  WebKitGTKManager(const WebKitGTKManager&) = delete;
  WebKitGTKManager& operator=(const WebKitGTKManager&) = delete;

 private:
  FlPluginRegistrar* registrar_ = nullptr;
  FlBinaryMessenger* messenger_ = nullptr;
  FlTextureRegistrar* texture_registrar_ = nullptr;
  GtkWindow* gtk_window_ = nullptr;

  FlMethodChannel* manager_channel_ = nullptr;

  // Map of texture_id → WebKitGTKView
  std::map<int64_t, std::unique_ptr<WebKitGTKView>> views_;

  // Auto-incrementing view ID
  int64_t next_id_ = 1;

  static void HandleMethodCall(FlMethodChannel* channel, FlMethodCall* method_call,
                               gpointer user_data);
  void HandleMethodCallImpl(FlMethodCall* method_call);

  void CreateInAppWebView(FlMethodCall* method_call);
  void Dispose(FlMethodCall* method_call);
};

}  // namespace flutter_inappwebview_webkit

#endif  // FLUTTER_INAPPWEBVIEW_WEBKITGTK_MANAGER_H_
