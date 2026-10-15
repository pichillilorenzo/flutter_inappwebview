#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_MANAGER_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_MANAGER_H_

#include <flutter/method_channel.h>
#include <flutter/standard_message_codec.h>
#include <cstddef>
#include <map>
#include <mutex>
#include <string>
#include <variant>
#include <wil/com.h>
#include <winrt/base.h>

#include "../custom_platform_view/custom_platform_view.h"
#include "../custom_platform_view/graphics_context.h"
#include "../custom_platform_view/util/rohelper.h"
#include "../flutter_inappwebview_windows_plugin.h"
#include "../types/channel_delegate.h"
#include "../types/lifetime_token.h"
#include "../types/new_window_requested_args.h"
#include "windows.ui.composition.h"

namespace flutter_inappwebview_plugin
{
  class InAppWebViewManager : public ChannelDelegate
  {
  public:
    static inline const std::string METHOD_CHANNEL_NAME = "com.pichillilorenzo/flutter_inappwebview_manager";

    const FlutterInappwebviewWindowsPlugin* plugin;
    std::map<uint64_t, std::unique_ptr<CustomPlatformView>> webViews;
    std::map<std::string, std::unique_ptr<CustomPlatformView>> keepAliveWebViews;
    std::map<int64_t, std::unique_ptr<NewWindowRequestedArgs>> windowWebViews;
    int64_t windowAutoincrementId = 0;

    bool isSupported() const { return valid_; }
    bool isGraphicsCaptureSessionSupported();
    GraphicsContext* graphics_context() const
    {
      return graphics_context_;
    };
    rx::RoHelper* rohelper() const { return rohelper_; }
    winrt::com_ptr<ABI::Windows::UI::Composition::ICompositor> compositor() const
    {
      winrt::com_ptr<ABI::Windows::UI::Composition::ICompositor> compositor;
      if (compositor_) {
        compositor.copy_from(compositor_);
      }
      return compositor;
    }

    InAppWebViewManager(const FlutterInappwebviewWindowsPlugin* plugin);
    ~InAppWebViewManager();

    void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

    void createInAppWebView(const flutter::EncodableMap* arguments, std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
    void disposeKeepAlive(const std::string& keepAliveId);
    void setWindowMinimized(bool minimized);
  private:
    inline static rx::RoHelper* rohelper_ = nullptr;
    inline static ABI::Windows::System::IDispatcherQueueController* dispatcher_queue_controller_ = nullptr;
    inline static GraphicsContext* graphics_context_ = nullptr;
    inline static ABI::Windows::UI::Composition::ICompositor* compositor_ = nullptr;
    WNDCLASS windowClass_ = {};
    bool windowMinimized_ = false;
    LifetimeToken alive_;
    inline static bool valid_ = false;
    inline static std::size_t instance_count_ = 0;
    inline static std::mutex shared_resources_mutex_;

    static ABI::Windows::System::IDispatcherQueueController* detachSharedResourcesForShutdown();
    static void shutdownDispatcherQueue(ABI::Windows::System::IDispatcherQueueController* dispatcherQueueController);
  };
}
#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_MANAGER_H_
