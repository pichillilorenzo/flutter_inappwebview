#include "channel_delegate.h"

#include <cstring>

namespace flutter_inappwebview_plugin {

ChannelDelegate::ChannelDelegate(FlBinaryMessenger* messenger, const std::string& name)
    : messenger_(messenger) {
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  channel_ = fl_method_channel_new(messenger_, name.c_str(), FL_METHOD_CODEC(codec));

  fl_method_channel_set_method_call_handler(channel_, HandleMethodCallStatic, this, nullptr);
}

ChannelDelegate::~ChannelDelegate() {
  unregisterMethodCallHandler();
  if (channel_ != nullptr) {
    g_object_unref(channel_);
    channel_ = nullptr;
  }
  messenger_ = nullptr;
}

void ChannelDelegate::HandleMethodCallStatic(FlMethodChannel* channel, FlMethodCall* method_call,
                                             gpointer user_data) {
  auto* self = static_cast<ChannelDelegate*>(user_data);
  if (self) {
    self->HandleMethodCall(method_call);
  }
}

void ChannelDelegate::HandleMethodCall(FlMethodCall* method_call) {
  // Default implementation - subclasses should override
  fl_method_call_respond_not_implemented(method_call, nullptr);
}

void ChannelDelegate::invokeMethod(const std::string& method, FlValue* arguments) const {
  if (channel_ == nullptr) {
    return;
  }
  fl_method_channel_invoke_method(channel_, method.c_str(), arguments, nullptr, nullptr, nullptr);
}

void ChannelDelegate::invokeMethodWithResult(const std::string& method, FlValue* arguments,
                                             GAsyncReadyCallback callback,
                                             gpointer user_data) const {
  if (channel_ == nullptr) {
    return;
  }
  fl_method_channel_invoke_method(channel_, method.c_str(), arguments, nullptr, callback,
                                  user_data);
}

void ChannelDelegate::unregisterMethodCallHandler() {
  if (channel_ != nullptr) {
    fl_method_channel_set_method_call_handler(channel_, nullptr, nullptr, nullptr);
  }
}

}  // namespace flutter_inappwebview_plugin
