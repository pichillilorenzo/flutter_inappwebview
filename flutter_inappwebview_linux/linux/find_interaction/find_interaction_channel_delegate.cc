#include "find_interaction_channel_delegate.h"

#include <cstring>

#include "find_interaction_controller.h"
#include "../utils/flutter.h"

namespace flutter_inappwebview_plugin {

FindInteractionChannelDelegate::FindInteractionChannelDelegate(
    FindInteractionController* controller, FlBinaryMessenger* messenger,
    const std::string& channelName)
    : ChannelDelegate(messenger, channelName),
      findInteractionController_(controller) {}

FindInteractionChannelDelegate::~FindInteractionChannelDelegate() {
  findInteractionController_ = nullptr;
}

void FindInteractionChannelDelegate::HandleMethodCall(
    FlMethodCall* method_call) {
  const gchar* methodName = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);

  if (strcmp(methodName, "findAll") == 0) {
    if (findInteractionController_) {
      std::string find = get_fl_map_value<std::string>(args, "find", "");
      if (!find.empty()) {
        findInteractionController_->findAll(find);
      }
    }
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (strcmp(methodName, "findNext") == 0) {
    if (findInteractionController_) {
      bool forward = get_fl_map_value<bool>(args, "forward", true);
      findInteractionController_->findNext(forward);
    }
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (strcmp(methodName, "clearMatches") == 0) {
    if (findInteractionController_) {
      findInteractionController_->clearMatches();
    }
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (strcmp(methodName, "setSearchText") == 0) {
    if (findInteractionController_) {
      std::string searchText =
          get_fl_map_value<std::string>(args, "searchText", "");
      findInteractionController_->setSearchText(searchText);
    }
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (strcmp(methodName, "getSearchText") == 0) {
    if (findInteractionController_) {
      auto searchText = findInteractionController_->getSearchText();
      if (searchText.has_value()) {
        g_autoptr(FlValue) result = fl_value_new_string(searchText->c_str());
        fl_method_call_respond_success(method_call, result, nullptr);
      } else {
        fl_method_call_respond_success(method_call, nullptr, nullptr);
      }
    } else {
      fl_method_call_respond_success(method_call, nullptr, nullptr);
    }
    return;
  }

  if (strcmp(methodName, "getActiveFindSession") == 0) {
    if (findInteractionController_) {
      auto findSession = findInteractionController_->getActiveFindSession();
      if (findSession.has_value()) {
        g_autoptr(FlValue) result = findSession->toFlValue();
        fl_method_call_respond_success(method_call, result, nullptr);
      } else {
        fl_method_call_respond_success(method_call, nullptr, nullptr);
      }
    } else {
      fl_method_call_respond_success(method_call, nullptr, nullptr);
    }
    return;
  }

  fl_method_call_respond_not_implemented(method_call, nullptr);
}

void FindInteractionChannelDelegate::onFindResultReceived(
    int32_t activeMatchOrdinal, int32_t numberOfMatches,
    bool isDoneCounting) const {
  if (channel_ == nullptr) return;

  g_autoptr(FlValue) args = to_fl_map({
      {"activeMatchOrdinal", make_fl_value(activeMatchOrdinal)},
      {"numberOfMatches", make_fl_value(numberOfMatches)},
      {"isDoneCounting", make_fl_value(isDoneCounting)},
  });

  invokeMethod("onFindResultReceived", args);
}

}  // namespace flutter_inappwebview_plugin
