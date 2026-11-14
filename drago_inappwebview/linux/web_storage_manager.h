#ifndef DRAGO_INAPPWEBVIEW_LINUX_WEB_STORAGE_MANAGER_H_
#define DRAGO_INAPPWEBVIEW_LINUX_WEB_STORAGE_MANAGER_H_

#include <flutter_linux/flutter_linux.h>
#include <wpe/webkit.h>

#include <string>
#include <vector>

namespace drago_inappwebview_plugin {

class PluginInstance;

/// WebStorageManager handles website data management using WPE WebKit's
/// WebKitWebsiteDataManager API.
class WebStorageManager {
 public:
  /// Creates a new WebStorageManager.
  /// @param plugin The plugin instance for accessing messenger.
  explicit WebStorageManager(PluginInstance* plugin);
  ~WebStorageManager();

  /// Get the plugin instance
  PluginInstance* plugin() const { return plugin_; }

  // Prevent copying
  WebStorageManager(const WebStorageManager&) = delete;
  WebStorageManager& operator=(const WebStorageManager&) = delete;

 private:
  PluginInstance* plugin_ = nullptr;

  /// Handle method calls from Flutter.
  static void HandleMethodCall(FlMethodChannel* channel,
                               FlMethodCall* method_call,
                               gpointer user_data);

  /// Fetch website data records.
  void fetchDataRecords(FlMethodCall* method_call);

  /// Remove data for specific records.
  void removeDataFor(FlMethodCall* method_call);

  /// Remove data modified since a specific date.
  void removeDataModifiedSince(FlMethodCall* method_call);

  /// Convert string list to WebKitWebsiteDataTypes bitmask.
  static WebKitWebsiteDataTypes parseDataTypes(FlValue* dataTypesValue);

  /// Convert WebKitWebsiteDataTypes bitmask to string list.
  static FlValue* dataTypesToFlValue(WebKitWebsiteDataTypes types);

  /// The Flutter method channel.
  FlMethodChannel* channel_;

  /// The website data manager.
  WebKitWebsiteDataManager* data_manager_;
};

}  // namespace drago_inappwebview_plugin

#endif  // DRAGO_INAPPWEBVIEW_LINUX_WEB_STORAGE_MANAGER_H_
