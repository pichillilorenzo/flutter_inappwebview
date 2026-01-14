#include "headless_in_app_webview.h"

#include <cstring>

#include "../utils/flutter.h"
#include "../utils/log.h"
#include "headless_in_app_webview_manager.h"

namespace flutter_inappwebview_plugin {

HeadlessInAppWebView::HeadlessInAppWebView(HeadlessInAppWebViewManager* manager,
                                           const HeadlessInAppWebViewCreationParams& params,
                                           const InAppWebViewCreationParams& webviewParams)
    : manager_(manager), id_(params.id), width_(params.initialWidth), height_(params.initialHeight) {
  debugLog("HeadlessInAppWebView::HeadlessInAppWebView id=" + id_);

  // Create the underlying InAppWebView
  // Use 0 as the numeric ID since we use string ID for headless webviews
  webview_ = std::make_shared<InAppWebView>(manager_->registrar(), manager_->messenger(), 0,
                                            webviewParams);

  // CRITICAL: Attach the method channel to the InAppWebView using the string ID.
  // This creates the channel at "com.pichillilorenzo/flutter_inappwebview_<id>"
  // which the Dart LinuxInAppWebViewController expects.
  webview_->AttachChannel(manager_->messenger(), id_, false);

  // Set the initial size
  webview_->setSize(static_cast<int>(width_), static_cast<int>(height_));

  // Attach the channel with the string-based ID from Dart for the HeadlessInAppWebView itself
  // This channel handles headless-specific methods like setSize, getSize, dispose
  std::string channel_name = METHOD_CHANNEL_NAME_PREFIX + id_;
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  channel_ = fl_method_channel_new(manager_->messenger(), channel_name.c_str(),
                                   FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel_, HandleMethodCall, this, nullptr);
}

HeadlessInAppWebView::~HeadlessInAppWebView() {
  debugLog("HeadlessInAppWebView::~HeadlessInAppWebView id=" + id_);

  if (channel_ != nullptr) {
    fl_method_channel_set_method_call_handler(channel_, nullptr, nullptr, nullptr);
    g_object_unref(channel_);
    channel_ = nullptr;
  }

  webview_.reset();
}

void HeadlessInAppWebView::setSize(double width, double height) {
  width_ = width;
  height_ = height;
  if (webview_) {
    webview_->setSize(static_cast<int>(width_), static_cast<int>(height_));
  }
}

void HeadlessInAppWebView::getSize(double* width, double* height) const {
  if (width) *width = width_;
  if (height) *height = height_;
}

void HeadlessInAppWebView::onWebViewCreated() {
  if (channel_ == nullptr) {
    return;
  }
  fl_method_channel_invoke_method(channel_, "onWebViewCreated", nullptr, nullptr, nullptr, nullptr);
}

void HeadlessInAppWebView::HandleMethodCall(FlMethodChannel* channel, FlMethodCall* method_call,
                                            gpointer user_data) {
  auto* self = static_cast<HeadlessInAppWebView*>(user_data);
  self->HandleMethodCallImpl(method_call);
}

void HeadlessInAppWebView::HandleMethodCallImpl(FlMethodCall* method_call) {
  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "dispose") == 0) {
    // Remove this headless webview from the manager
    if (manager_) {
      manager_->RemoveHeadlessWebView(id_);
    }
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  if (strcmp(method, "setSize") == 0) {
    FlValue* args = fl_method_call_get_args(method_call);
    if (args != nullptr && fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
      FlValue* size_value = get_fl_map_value_raw(args, "size");
      if (size_value != nullptr && fl_value_get_type(size_value) == FL_VALUE_TYPE_MAP) {
        double width = get_fl_map_value<double>(size_value, "width", -1);
        double height = get_fl_map_value<double>(size_value, "height", -1);
        if (width >= 0 && height >= 0) {
          setSize(width, height);
        }
      }
    }
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  if (strcmp(method, "getSize") == 0) {
    double width, height;
    getSize(&width, &height);
    g_autoptr(FlValue) result =
        to_fl_map({{"width", make_fl_value(width)}, {"height", make_fl_value(height)}});
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  fl_method_call_respond_not_implemented(method_call, nullptr);
}

}  // namespace flutter_inappwebview_plugin
