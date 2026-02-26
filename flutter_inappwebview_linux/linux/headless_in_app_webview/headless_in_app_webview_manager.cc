#include "headless_in_app_webview_manager.h"

#include <cstring>

#include "../flutter_inappwebview_linux_plugin_private.h"
#include "../plugin_instance.h"
#include "../in_app_webview/in_app_webview_settings.h"
#include "../types/url_request.h"
#include "../utils/flutter.h"
#include "../utils/log.h"
#include "../webview_environment.h"

namespace flutter_inappwebview_plugin {

HeadlessInAppWebViewManager::HeadlessInAppWebViewManager(PluginInstance* plugin)
    : plugin_(plugin), registrar_(plugin->registrar()) {
  messenger_ = plugin->messenger();
  
  // Cache the GTK window from the plugin instance
  // This may return nullptr for headless scenarios, which is fine
  gtk_window_ = plugin->gtkWindow();

  // Create the method channel
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  method_channel_ = fl_method_channel_new(messenger_, METHOD_CHANNEL_NAME, FL_METHOD_CODEC(codec));

  fl_method_channel_set_method_call_handler(method_channel_, HandleMethodCall, this, nullptr);
}

FlPluginRegistrar* HeadlessInAppWebViewManager::registrar() const {
  return registrar_;
}

HeadlessInAppWebViewManager::~HeadlessInAppWebViewManager() {
  debugLog("dealloc HeadlessInAppWebViewManager");

  // Clean up all headless webviews
  webviews_.clear();

  if (method_channel_ != nullptr) {
    fl_method_channel_set_method_call_handler(method_channel_, nullptr, nullptr, nullptr);
    g_object_unref(method_channel_);
    method_channel_ = nullptr;
  }
}

HeadlessInAppWebView* HeadlessInAppWebViewManager::GetHeadlessWebView(
    const std::string& id) const {
  auto it = webviews_.find(id);
  if (it != webviews_.end()) {
    return it->second.get();
  }
  return nullptr;
}

void HeadlessInAppWebViewManager::RemoveHeadlessWebView(const std::string& id) {
  auto it = webviews_.find(id);
  if (it != webviews_.end()) {
    webviews_.erase(it);
  }
}

void HeadlessInAppWebViewManager::HandleMethodCall(FlMethodChannel* channel,
                                                    FlMethodCall* method_call,
                                                    gpointer user_data) {
  auto* self = static_cast<HeadlessInAppWebViewManager*>(user_data);
  self->HandleMethodCallImpl(method_call);
}

void HeadlessInAppWebViewManager::HandleMethodCallImpl(FlMethodCall* method_call) {
  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "run") == 0) {
    Run(method_call);
    return;
  }

  fl_method_call_respond_not_implemented(method_call, nullptr);
}

void HeadlessInAppWebViewManager::Run(FlMethodCall* method_call) {
  FlValue* args = fl_method_call_get_args(method_call);

  if (fl_value_get_type(args) != FL_VALUE_TYPE_MAP) {
    fl_method_call_respond_error(method_call, "INVALID_ARGUMENTS", "Arguments must be a map",
                                 nullptr, nullptr);
    return;
  }

  // Get the ID from Flutter
  auto idOpt = get_optional_fl_map_value<std::string>(args, "id");
  if (!idOpt.has_value()) {
    fl_method_call_respond_error(method_call, "INVALID_ARGUMENTS", "Missing id parameter", nullptr,
                                 nullptr);
    return;
  }
  std::string id = idOpt.value();

  // Get the params map
  FlValue* params = get_fl_map_value_raw(args, "params");
  if (params == nullptr || fl_value_get_type(params) != FL_VALUE_TYPE_MAP) {
    fl_method_call_respond_error(method_call, "INVALID_ARGUMENTS", "Missing params parameter",
                                 nullptr, nullptr);
    return;
  }

  // Parse initial size
  double initialWidth = -1;
  double initialHeight = -1;
  FlValue* initial_size = get_fl_map_value_raw(params, "initialSize");
  if (initial_size != nullptr && fl_value_get_type(initial_size) == FL_VALUE_TYPE_MAP) {
    initialWidth = get_fl_map_value<double>(initial_size, "width", -1);
    initialHeight = get_fl_map_value<double>(initial_size, "height", -1);
  }

  // Create headless params
  HeadlessInAppWebViewCreationParams headlessParams;
  headlessParams.id = id;
  headlessParams.initialWidth = initialWidth >= 0 ? initialWidth : 800;
  headlessParams.initialHeight = initialHeight >= 0 ? initialHeight : 600;

  // Create InAppWebView params
  InAppWebViewCreationParams webviewParams;
  webviewParams.id = 0;  // Not used for headless
  webviewParams.plugin = plugin_;  // Pass plugin instance for accessing managers
  webviewParams.gtkWindow = gtk_window_;  // Use cached GTK window (may be nullptr for headless)
  webviewParams.manager = nullptr;  // Not needed for headless

  // Parse initial settings
  FlValue* initial_settings = get_fl_map_value_raw(params, "initialSettings");
  if (initial_settings != nullptr && fl_value_get_type(initial_settings) == FL_VALUE_TYPE_MAP) {
    webviewParams.initialSettings = std::make_shared<InAppWebViewSettings>(initial_settings);
  } else {
    webviewParams.initialSettings = std::make_shared<InAppWebViewSettings>();
  }

  // Parse initial URL request
  FlValue* initial_url_request = get_fl_map_value_raw(params, "initialUrlRequest");
  if (initial_url_request != nullptr &&
      fl_value_get_type(initial_url_request) == FL_VALUE_TYPE_MAP) {
    webviewParams.initialUrlRequest = std::make_shared<URLRequest>(initial_url_request);
  }

  // Parse initial data
  FlValue* initial_data = get_fl_map_value_raw(params, "initialData");
  if (initial_data != nullptr && fl_value_get_type(initial_data) == FL_VALUE_TYPE_MAP) {
    webviewParams.initialData = get_fl_map_value<std::string>(initial_data, "data", "");
    webviewParams.initialDataBaseUrl = get_fl_map_value<std::string>(initial_data, "baseUrl", "");
    webviewParams.initialDataMimeType = get_fl_map_value<std::string>(initial_data, "mimeType", "");
    webviewParams.initialDataEncoding = get_fl_map_value<std::string>(initial_data, "encoding", "");
  }

  // Parse initial file
  auto initial_file = get_optional_fl_map_value<std::string>(params, "initialFile");
  if (initial_file.has_value()) {
    webviewParams.initialFile = initial_file.value();
  }

  // Parse webViewEnvironmentId and look up the custom WebKitWebContext
  auto webViewEnvironmentIdOpt = get_optional_fl_map_value<std::string>(params, "webViewEnvironmentId");
  if (webViewEnvironmentIdOpt.has_value() && !webViewEnvironmentIdOpt->empty()) {
    WebViewEnvironment* webViewEnv = plugin_ ? plugin_->webViewEnvironment : nullptr;
    WebKitWebContext* webContext = nullptr;
    if (webViewEnv != nullptr) {
      webContext = webViewEnv->getWebContext(webViewEnvironmentIdOpt.value());
    }
    if (webContext != nullptr) {
      webviewParams.webContext = webContext;
      debugLog("HeadlessInAppWebViewManager: Using custom WebKitWebContext from WebViewEnvironment id=" + webViewEnvironmentIdOpt.value());
    } else {
      debugLog("HeadlessInAppWebViewManager: WebViewEnvironment not found for id=" + webViewEnvironmentIdOpt.value());
    }
  }

  // Create the headless webview
  auto headlessWebView =
      std::make_unique<HeadlessInAppWebView>(this, headlessParams, webviewParams);

  // Store it
  webviews_[id] = std::move(headlessWebView);

  // Notify Flutter that the webview is created
  webviews_[id]->channelDelegate()->onWebViewCreated();

  // Return success
  g_autoptr(FlValue) result = make_fl_value(true);
  fl_method_call_respond_success(method_call, result, nullptr);
}

}  // namespace flutter_inappwebview_plugin
