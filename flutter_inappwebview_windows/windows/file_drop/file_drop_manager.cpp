#include "file_drop_manager.h"

#include "../custom_platform_view/webview_drop_target.h"
#include "../utils/flutter.h"
#include "../utils/flutter_view_hwnd.h"
#include "../in_app_webview/in_app_webview_manager.h"

namespace flutter_inappwebview_plugin
{
  FileDropManager::FileDropManager(const FlutterInappwebviewWindowsPlugin* plugin)
    : plugin(plugin), ChannelDelegate(plugin->registrar->messenger(), FileDropManager::METHOD_CHANNEL_NAME_PREFIX)
  {}

  HWND FileDropManager::flutterViewHwnd(const std::optional<int64_t>& viewId) const
  {
    return plugin ? ResolveFlutterViewHwnd(plugin->registrar, viewId) : nullptr;
  }

  void FileDropManager::setEnabled(bool enabled, const std::optional<int64_t>& viewId)
  {
    const auto key = viewId.value_or(0);
    const auto it = enabledViews_.find(key);
    if (!enabled) {
      if (it != enabledViews_.end()) {
        WebViewDropTarget::ClearFileDropSink(it->second);
        enabledViews_.erase(it);
      }
      return;
    }
    const auto hwnd = flutterViewHwnd(viewId);
    if (!hwnd || (it != enabledViews_.end() && it->second == hwnd)) {
      return;
    }
    if (it != enabledViews_.end()) {
      WebViewDropTarget::ClearFileDropSink(it->second);
    }
    enabledViews_[key] = hwnd;
    if (plugin->inAppWebViewManager) {
      plugin->inAppWebViewManager->watchFlutterView(hwnd);
    }
    WebViewDropTarget::SetFileDropSink(hwnd,
      [this, viewId](const std::string& event, const std::vector<std::string>& paths,
        double x, double y)
      {
        if (channel == nullptr) {
          return;
        }
        auto arguments = flutter::EncodableMap{
          {make_fl_value("event"), make_fl_value(event)},
          {make_fl_value("paths"), make_fl_value(paths)},
          {make_fl_value("x"), make_fl_value(x)},
          {make_fl_value("y"), make_fl_value(y)},
        };
        if (viewId.has_value()) {
          arguments[make_fl_value("viewId")] = make_fl_value(viewId.value());
        }
        channel->InvokeMethod("onFileDrop", std::make_unique<flutter::EncodableValue>(arguments));
      });
  }

  void FileDropManager::onFlutterViewDestroyed(HWND flutterViewHwnd)
  {
    for (auto it = enabledViews_.begin(); it != enabledViews_.end();) {
      if (it->second == flutterViewHwnd) {
        WebViewDropTarget::ClearFileDropSink(flutterViewHwnd);
        it = enabledViews_.erase(it);
      }
      else {
        ++it;
      }
    }
  }

  void FileDropManager::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
    const auto viewId = arguments
      ? get_optional_fl_map_value<int64_t>(*arguments, "viewId") : std::nullopt;
    if (method_call.method_name().compare("setEnabled") == 0) {
      setEnabled(arguments && get_fl_map_value<bool>(*arguments, "enabled", false), viewId);
      result->Success();
      return;
    }
    if (method_call.method_name().compare("setAccepted") == 0) {
      const auto it = enabledViews_.find(viewId.value_or(0));
      if (it != enabledViews_.end()) {
        WebViewDropTarget::SetFileDropAccepted(it->second,
          arguments && get_fl_map_value<bool>(*arguments, "accepted", false));
      }
      result->Success();
      return;
    }
    result->NotImplemented();
  }

  FileDropManager::~FileDropManager()
  {
    for (const auto& [viewId, hwnd] : enabledViews_) {
      WebViewDropTarget::ClearFileDropSink(hwnd);
    }
    enabledViews_.clear();
    plugin = nullptr;
  }
}
