#include "find_interaction_channel_delegate.h"

#include "find_interaction_controller.h"

#include "../in_app_webview/in_app_webview.h"

#include "../utils/flutter.h"
#include "../utils/log.h"
#include "../utils/string.h"

namespace flutter_inappwebview_plugin
{
  FindInteractionChannelDelegate::FindInteractionChannelDelegate(
    FindInteractionController* findInteractionController,
    flutter::BinaryMessenger* messenger, const std::string& channelName)
    : ChannelDelegate(messenger, channelName),
    findInteractionController_(findInteractionController)
  {}

  void FindInteractionChannelDelegate::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    if (!findInteractionController_) {
      result->Success(make_fl_value());
      return;
    }

    if (!findInteractionController_->webView || !findInteractionController_->webView->webView) {
      result->Success(make_fl_value());
      return;
    }

    flutter::EncodableMap arguments;
    if (auto args = method_call.arguments()) {
      if (std::holds_alternative<flutter::EncodableMap>(*args)) {
        arguments = std::get<flutter::EncodableMap>(*args);
      }
    }
    auto& methodName = method_call.method_name();

    if (string_equals(methodName, "findAll")) {
      auto findText = get_optional_fl_map_value<std::string>(arguments, "find");
      findInteractionController_->findAll(findText);
      result->Success(true);
    }
    else if (string_equals(methodName, "findNext")) {
      auto forward = get_fl_map_value<bool>(arguments, "forward", true);
      findInteractionController_->findNext(forward);
      result->Success(true);
    }
    else if (string_equals(methodName, "clearMatches")) {
      findInteractionController_->clearMatches();
      result->Success(true);
    }
    else if (string_equals(methodName, "setSearchText")) {
      auto searchText = get_optional_fl_map_value<std::string>(arguments, "searchText");
      findInteractionController_->setSearchText(searchText);
      result->Success(true);
    }
    else if (string_equals(methodName, "getSearchText")) {
      result->Success(make_fl_value(findInteractionController_->getSearchText()));
    }
    else if (string_equals(methodName, "getActiveFindSession")) {
      auto sessionMap = findInteractionController_->getActiveFindSessionMap();
      if (sessionMap.has_value()) {
        result->Success(make_fl_value(sessionMap.value()));
      }
      else {
        result->Success(make_fl_value());
      }
    }
    else {
      result->NotImplemented();
    }
  }

  void FindInteractionChannelDelegate::onFindResultReceived(const int32_t activeMatchOrdinal,
    const int32_t numberOfMatches, const bool isDoneCounting) const
  {
    if (!channel) {
      return;
    }

    auto arguments = std::make_unique<flutter::EncodableValue>(flutter::EncodableMap{
      {"activeMatchOrdinal", make_fl_value(activeMatchOrdinal)},
      {"numberOfMatches", make_fl_value(numberOfMatches)},
      {"isDoneCounting", make_fl_value(isDoneCounting)},
      });
    channel->InvokeMethod("onFindResultReceived", std::move(arguments));
  }

  void FindInteractionChannelDelegate::dispose()
  {
    UnregisterMethodCallHandler();
    findInteractionController_ = nullptr;
  }

  FindInteractionChannelDelegate::~FindInteractionChannelDelegate()
  {
    debugLog("dealloc FindInteractionChannelDelegate");
    findInteractionController_ = nullptr;
  }
}
