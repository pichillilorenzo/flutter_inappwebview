#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_PLATFORM_UTIL_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_PLATFORM_UTIL_H_

#include <flutter/method_channel.h>
#include <flutter/standard_message_codec.h>
#include <functional>
#include <optional>

#include "flutter_inappwebview_windows_plugin.h"
#include "types/channel_delegate.h"

namespace flutter_inappwebview_plugin
{
  class PlatformUtil : public ChannelDelegate
  {
  public:
    static inline const std::string METHOD_CHANNEL_NAME_PREFIX = "com.pichillilorenzo/flutter_inappwebview_platformutil";

    const FlutterInappwebviewWindowsPlugin* plugin;

    PlatformUtil(const FlutterInappwebviewWindowsPlugin* plugin);
    ~PlatformUtil();

    void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

    std::optional<LRESULT> PlatformUtil::HandleWindowProc(
      HWND hWnd,
      UINT message,
      WPARAM wParam,
      LPARAM lParam) noexcept;

  private:
    void PlatformUtil::_EmitEvent(std::string eventName);
    bool window_is_moving_ = false;
    bool window_start_move_sent_ = false;
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_PLATFORM_UTIL_H_