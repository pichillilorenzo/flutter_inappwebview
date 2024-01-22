#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_MANAGER_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_MANAGER_H_

#include <flutter/method_channel.h>
#include <flutter/standard_message_codec.h>
#include <map>
#include <string>
#include <wil/com.h>
#include <winrt/base.h>

#include "../custom_platform_view/custom_platform_view.h"
#include "../custom_platform_view/graphics_context.h"
#include "../custom_platform_view/util/rohelper.h"
#include "../flutter_inappwebview_windows_plugin.h"
#include "../types/channel_delegate.h"
#include "windows.ui.composition.h"

namespace flutter_inappwebview_plugin
{
  class InAppWebViewManager : public ChannelDelegate
  {
  public:
    static inline const std::string METHOD_CHANNEL_NAME = "com.pichillilorenzo/flutter_inappwebview";

    const FlutterInappwebviewWindowsPlugin* plugin;
    std::map<uint64_t, std::unique_ptr<CustomPlatformView>> webViews;

    bool isSupported() const { return valid_; }
    bool isGraphicsCaptureSessionSupported();
    GraphicsContext* graphics_context() const
    {
      return graphics_context_.get();
    };
    rx::RoHelper* rohelper() const { return rohelper_.get(); }
    winrt::com_ptr<ABI::Windows::UI::Composition::ICompositor> compositor() const
    {
      return compositor_;
    }

    InAppWebViewManager(const FlutterInappwebviewWindowsPlugin* plugin);
    ~InAppWebViewManager();

    void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

    void createInAppWebView(const flutter::EncodableMap* arguments, std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
  private:
    std::unique_ptr<rx::RoHelper> rohelper_;
    winrt::com_ptr<ABI::Windows::System::IDispatcherQueueController>
      dispatcher_queue_controller_;
    std::unique_ptr<GraphicsContext> graphics_context_;
    winrt::com_ptr<ABI::Windows::UI::Composition::ICompositor> compositor_;
    WNDCLASS windowClass_ = {};
    bool valid_ = false;
  };
}
#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_MANAGER_H_