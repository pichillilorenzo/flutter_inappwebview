#include "headless_webview_channel_delegate.h"

#include <cstring>

#include "../utils/flutter.h"
#include "../utils/log.h"
#include "headless_in_app_webview.h"

namespace flutter_inappwebview_plugin {

HeadlessWebViewChannelDelegate::HeadlessWebViewChannelDelegate(
    HeadlessInAppWebView* headlessWebView,
    FlBinaryMessenger* messenger,
    const std::string& id)
    : ChannelDelegate(messenger, std::string(METHOD_CHANNEL_NAME_PREFIX) + id),
      headlessWebView_(headlessWebView) {
}

HeadlessWebViewChannelDelegate::~HeadlessWebViewChannelDelegate() {
  debugLog("dealloc HeadlessWebViewChannelDelegate");
  headlessWebView_ = nullptr;
}

void HeadlessWebViewChannelDelegate::HandleMethodCall(FlMethodCall* method_call) {
  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "dispose") == 0) {
    if (headlessWebView_ != nullptr) {
      headlessWebView_->dispose();
      g_autoptr(FlValue) result = fl_value_new_bool(true);
      fl_method_call_respond_success(method_call, result, nullptr);
    } else {
      g_autoptr(FlValue) result = fl_value_new_bool(false);
      fl_method_call_respond_success(method_call, result, nullptr);
    }
    return;
  }

  if (strcmp(method, "setSize") == 0) {
    if (headlessWebView_ != nullptr) {
      FlValue* args = fl_method_call_get_args(method_call);
      if (args != nullptr && fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
        FlValue* size_value = fl_value_lookup_string(args, "size");
        if (size_value != nullptr && fl_value_get_type(size_value) == FL_VALUE_TYPE_MAP) {
          double width = get_fl_map_value<double>(size_value, "width", -1);
          double height = get_fl_map_value<double>(size_value, "height", -1);
          if (width >= 0 && height >= 0) {
            headlessWebView_->setSize(width, height);
          }
        }
      }
      g_autoptr(FlValue) result = fl_value_new_bool(true);
      fl_method_call_respond_success(method_call, result, nullptr);
    } else {
      g_autoptr(FlValue) result = fl_value_new_bool(false);
      fl_method_call_respond_success(method_call, result, nullptr);
    }
    return;
  }

  if (strcmp(method, "getSize") == 0) {
    if (headlessWebView_ != nullptr) {
      double width, height;
      headlessWebView_->getSize(&width, &height);
      g_autoptr(FlValue) result =
          to_fl_map({{"width", make_fl_value(width)}, {"height", make_fl_value(height)}});
      fl_method_call_respond_success(method_call, result, nullptr);
    } else {
      fl_method_call_respond_success(method_call, fl_value_new_null(), nullptr);
    }
    return;
  }

  fl_method_call_respond_not_implemented(method_call, nullptr);
}

void HeadlessWebViewChannelDelegate::onWebViewCreated() const {
  if (channel_ == nullptr) {
    return;
  }
  g_autoptr(FlValue) args = to_fl_map({});
  invokeMethod("onWebViewCreated", args);
}

}  // namespace flutter_inappwebview_plugin
