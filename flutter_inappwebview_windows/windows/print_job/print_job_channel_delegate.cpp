#include "print_job_channel_delegate.h"

#include "print_job_controller.h"
#include "print_job_info.h"
#include "../utils/flutter.h"
#include "../utils/log.h"
#include "../utils/string.h"

namespace flutter_inappwebview_plugin
{
  PrintJobChannelDelegate::PrintJobChannelDelegate(
    PrintJobController* printJobController,
    flutter::BinaryMessenger* messenger, const std::string& channelName)
    : ChannelDelegate(messenger, channelName),
    printJobController_(printJobController)
  {}

  void PrintJobChannelDelegate::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    if (disposed_ || !printJobController_) {
      result->Success(make_fl_value());
      return;
    }

    auto& methodName = method_call.method_name();

    if (string_equals(methodName, "getInfo")) {
      auto info = printJobController_->getInfo();
      result->Success(make_fl_value(info ? info->toEncodableMap() : flutter::EncodableMap{}));
    }
    else if (string_equals(methodName, "dispose")) {
      printJobController_->dispose();
      result->Success(make_fl_value());
    }
    else {
      result->NotImplemented();
    }
  }

  void PrintJobChannelDelegate::onComplete(const bool completed, const std::optional<std::string>& error) const
  {
    if (disposed_ || !channel) {
      return;
    }

    auto arguments = flutter::EncodableMap{};
    arguments.insert({ make_fl_value("completed"), make_fl_value(completed) });
    arguments.insert({ make_fl_value("error"), make_fl_value(error) });
    channel->InvokeMethod("onComplete", std::make_unique<flutter::EncodableValue>(arguments));
  }

  void PrintJobChannelDelegate::dispose()
  {
    if (disposed_) {
      return;
    }
    disposed_ = true;

    UnregisterMethodCallHandler();
    printJobController_ = nullptr;
  }

  PrintJobChannelDelegate::~PrintJobChannelDelegate()
  {
    debugLog("dealloc PrintJobChannelDelegate");
    printJobController_ = nullptr;
  }
}
