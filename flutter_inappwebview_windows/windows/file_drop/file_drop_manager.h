#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_FILE_DROP_MANAGER_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_FILE_DROP_MANAGER_H_

#include <flutter/method_channel.h>
#include <flutter/standard_message_codec.h>
#include <string>
#include <vector>

#include "../flutter_inappwebview_windows_plugin.h"
#include "../types/channel_delegate.h"

namespace flutter_inappwebview_plugin
{
  // Reports OS file drags over the Flutter window to the host app. The webview
  // drop target owns the window's only IDropTarget, so a host that needs file
  // drops has to receive them from here rather than registering its own.
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

  private:
    void setEnabled(bool enabled);
    HWND flutterViewHwnd() const;

    bool enabled_ = false;
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_FILE_DROP_MANAGER_H_
