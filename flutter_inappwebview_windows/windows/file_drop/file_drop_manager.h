#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_FILE_DROP_MANAGER_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_FILE_DROP_MANAGER_H_

#include <flutter/method_channel.h>
#include <flutter/standard_message_codec.h>
#include <cstdint>
#include <map>
#include <optional>
#include <string>
#include <vector>

#include "../flutter_inappwebview_windows_plugin.h"
#include "../types/channel_delegate.h"

namespace flutter_inappwebview_plugin
{
  // Reports OS file drags over the Flutter window to the host app. The webview
  // drop target owns the window's only IDropTarget, so a host that needs file
  // drops has to receive them from here rather than registering its own.
  // Each Flutter view is enabled separately; calls without a viewId use the
  // implicit view.
  class FileDropManager : public ChannelDelegate
  {
  public:
    static inline const std::string METHOD_CHANNEL_NAME_PREFIX = "com.pichillilorenzo/flutter_inappwebview_filedrop";

    const FlutterInappwebviewWindowsPlugin* plugin;

    FileDropManager(const FlutterInappwebviewWindowsPlugin* plugin);
    ~FileDropManager();

    void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) override;

    // Drops the sink of a Flutter view whose window is being destroyed.
    void onFlutterViewDestroyed(HWND flutterViewHwnd);

  private:
    void setEnabled(bool enabled, const std::optional<int64_t>& viewId);
    HWND flutterViewHwnd(const std::optional<int64_t>& viewId) const;

    // Enabled views by id (the implicit view is 0) and their window.
    std::map<int64_t, HWND> enabledViews_;
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_FILE_DROP_MANAGER_H_
