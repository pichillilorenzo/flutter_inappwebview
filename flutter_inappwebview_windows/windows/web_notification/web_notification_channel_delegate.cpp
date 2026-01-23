#include "web_notification_channel_delegate.h"

#include "web_notification_controller.h"

#include "../utils/flutter.h"
#include "../utils/log.h"
#include "../utils/string.h"

namespace flutter_inappwebview_plugin
{
  WebNotificationChannelDelegate::WebNotificationChannelDelegate(
    WebNotificationController* webNotificationController,
    flutter::BinaryMessenger* messenger, const std::string& channelName)
    : ChannelDelegate(messenger, channelName),
    webNotificationController_(webNotificationController)
  {}

  void WebNotificationChannelDelegate::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    if (disposed_ || !webNotificationController_) {
      result->Success(make_fl_value());
      return;
    }

    auto& methodName = method_call.method_name();

    if (string_equals(methodName, "reportShown")) {
      webNotificationController_->reportShown();
      result->Success(make_fl_value());
    }
    else if (string_equals(methodName, "reportClicked")) {
      webNotificationController_->reportClicked();
      result->Success(make_fl_value());
    }
    else if (string_equals(methodName, "reportClosed")) {
      webNotificationController_->reportClosed();
      result->Success(make_fl_value());
    }
    else if (string_equals(methodName, "dispose")) {
      webNotificationController_->dispose();
      result->Success(make_fl_value());
    }
    else {
      result->NotImplemented();
    }
  }

  void WebNotificationChannelDelegate::onClose() const
  {
    if (disposed_ || !channel) {
      return;
    }

    auto arguments = std::make_unique<flutter::EncodableValue>(flutter::EncodableMap{});
    channel->InvokeMethod("onClose", std::move(arguments));
  }

  void WebNotificationChannelDelegate::dispose()
  {
    if (disposed_) {
      return;
    }
    disposed_ = true;

    UnregisterMethodCallHandler();
    webNotificationController_ = nullptr;
  }

  WebNotificationChannelDelegate::~WebNotificationChannelDelegate()
  {
    debugLog("dealloc WebNotificationChannelDelegate");
    webNotificationController_ = nullptr;
  }
}
