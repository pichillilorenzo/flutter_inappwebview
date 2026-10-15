#include "file_drop_manager.h"

#include "../custom_platform_view/webview_drop_target.h"
#include "../utils/flutter.h"

namespace flutter_inappwebview_plugin
{
  FileDropManager::FileDropManager(const FlutterInappwebviewWindowsPlugin* plugin)
    : plugin(plugin), ChannelDelegate(plugin->registrar->messenger(), FileDropManager::METHOD_CHANNEL_NAME_PREFIX)
  {}

  HWND FileDropManager::flutterViewHwnd() const
  {
    const auto view = plugin && plugin->registrar ? plugin->registrar->GetView() : nullptr;
    return view ? view->GetNativeWindow() : nullptr;
  }

  void FileDropManager::setEnabled(bool enabled)
  {
    const auto hwnd = flutterViewHwnd();
    if (!hwnd || enabled == enabled_) {
      return;
    }
    enabled_ = enabled;
    if (!enabled) {
      WebViewDropTarget::ClearFileDropSink(hwnd);
      return;
    }
    WebViewDropTarget::SetFileDropSink(hwnd,
      [this](const std::string& event, const std::vector<std::string>& paths,
        double x, double y)
      {
        if (channel == nullptr) {
          return;
        }
        channel->InvokeMethod("onFileDrop", std::make_unique<flutter::EncodableValue>(
          flutter::EncodableMap{
            {make_fl_value("event"), make_fl_value(event)},
            {make_fl_value("paths"), make_fl_value(paths)},
            {make_fl_value("x"), make_fl_value(x)},
            {make_fl_value("y"), make_fl_value(y)},
          }));
      });
  }

  void FileDropManager::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
    if (method_call.method_name().compare("setEnabled") == 0) {
      setEnabled(arguments && get_fl_map_value<bool>(*arguments, "enabled", false));
      result->Success();
      return;
    }
    if (method_call.method_name().compare("setAccepted") == 0) {
      if (const auto hwnd = flutterViewHwnd()) {
        WebViewDropTarget::SetFileDropAccepted(hwnd,
          arguments && get_fl_map_value<bool>(*arguments, "accepted", false));
      }
      result->Success();
      return;
    }
    result->NotImplemented();
  }

  FileDropManager::~FileDropManager()
  {
    if (enabled_) {
      if (const auto hwnd = flutterViewHwnd()) {
        WebViewDropTarget::ClearFileDropSink(hwnd);
      }
    }
    plugin = nullptr;
  }
}
