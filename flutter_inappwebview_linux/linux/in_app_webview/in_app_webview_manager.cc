#include "in_app_webview_manager.h"

#include <cstring>

#include "../utils/flutter.h"
#include "../utils/log.h"

#ifdef USE_WPE_WEBKIT
#include "in_app_webview_wpe.h"
#include "in_app_webview_settings_wpe.h"
#endif

namespace flutter_inappwebview_plugin {

InAppWebViewManager::InAppWebViewManager(FlPluginRegistrar* registrar)
    : registrar_(registrar) {
  texture_registrar_ = fl_plugin_registrar_get_texture_registrar(registrar);
  messenger_ = fl_plugin_registrar_get_messenger(registrar);

  // Create the method channel
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  method_channel_ = fl_method_channel_new(messenger_, METHOD_CHANNEL_NAME,
                                          FL_METHOD_CODEC(codec));

  fl_method_channel_set_method_call_handler(
      method_channel_, HandleMethodCall, this, nullptr);
}

InAppWebViewManager::~InAppWebViewManager() {
  // Clean up all platform views
  platform_views_.clear();

  if (method_channel_ != nullptr) {
    fl_method_channel_set_method_call_handler(method_channel_, nullptr, nullptr,
                                              nullptr);
    g_object_unref(method_channel_);
    method_channel_ = nullptr;
  }
}

CustomPlatformView* InAppWebViewManager::GetPlatformView(int64_t texture_id) const {
  auto it = platform_views_.find(texture_id);
  if (it != platform_views_.end()) {
    return it->second.get();
  }
  return nullptr;
}

void InAppWebViewManager::HandleMethodCall(FlMethodChannel* channel,
                                           FlMethodCall* method_call,
                                           gpointer user_data) {
  auto* self = static_cast<InAppWebViewManager*>(user_data);
  self->HandleMethodCallImpl(method_call);
}

void InAppWebViewManager::HandleMethodCallImpl(FlMethodCall* method_call) {
  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "createInAppWebView") == 0) {
    CreateInAppWebView(method_call);
    return;
  }

  if (strcmp(method, "dispose") == 0) {
    FlValue* args = fl_method_call_get_args(method_call);
    if (fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
      // Try "textureId" first, then "id" for backwards compatibility
      FlValue* id_value = fl_value_lookup_string(args, "textureId");
      if (id_value == nullptr) {
        id_value = fl_value_lookup_string(args, "id");
      }
      if (id_value != nullptr &&
          fl_value_get_type(id_value) == FL_VALUE_TYPE_INT) {
        int64_t texture_id = fl_value_get_int(id_value);
        DisposeWebView(texture_id);
        fl_method_call_respond_success(method_call, nullptr, nullptr);
        return;
      }
    }
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  fl_method_call_respond_not_implemented(method_call, nullptr);
}

void InAppWebViewManager::CreateInAppWebView(FlMethodCall* method_call) {
  FlValue* args = fl_method_call_get_args(method_call);

  if (fl_value_get_type(args) != FL_VALUE_TYPE_MAP) {
    fl_method_call_respond_error(method_call, "INVALID_ARGUMENTS",
                                 "Arguments must be a map", nullptr, nullptr);
    return;
  }

#ifdef USE_WPE_WEBKIT
  // WPE WebKit path
  InAppWebViewWpeCreationParams params;
  params.id = next_id_++;

  // Parse initial settings
  FlValue* initial_settings = fl_value_lookup_string(args, "initialSettings");
  if (initial_settings != nullptr &&
      fl_value_get_type(initial_settings) == FL_VALUE_TYPE_MAP) {
    params.initialSettings = std::make_shared<InAppWebViewSettingsWpe>(initial_settings);
  } else {
    params.initialSettings = std::make_shared<InAppWebViewSettingsWpe>();
  }

  // Parse initial URL request
  FlValue* initial_url_request = fl_value_lookup_string(args, "initialUrlRequest");
  if (initial_url_request != nullptr &&
      fl_value_get_type(initial_url_request) == FL_VALUE_TYPE_MAP) {
    params.initialUrlRequest = std::make_shared<URLRequest>(initial_url_request);
  }

  // Parse initial data
  FlValue* initial_data = fl_value_lookup_string(args, "initialData");
  if (initial_data != nullptr &&
      fl_value_get_type(initial_data) == FL_VALUE_TYPE_MAP) {
    FlValue* data_value = fl_value_lookup_string(initial_data, "data");
    if (data_value != nullptr &&
        fl_value_get_type(data_value) == FL_VALUE_TYPE_STRING) {
      params.initialData = std::string(fl_value_get_string(data_value));
    }
    FlValue* base_url_value = fl_value_lookup_string(initial_data, "baseUrl");
    if (base_url_value != nullptr &&
        fl_value_get_type(base_url_value) == FL_VALUE_TYPE_STRING) {
      params.initialDataBaseUrl = std::string(fl_value_get_string(base_url_value));
    }
    FlValue* mime_type_value = fl_value_lookup_string(initial_data, "mimeType");
    if (mime_type_value != nullptr &&
        fl_value_get_type(mime_type_value) == FL_VALUE_TYPE_STRING) {
      params.initialDataMimeType = std::string(fl_value_get_string(mime_type_value));
    }
    FlValue* encoding_value = fl_value_lookup_string(initial_data, "encoding");
    if (encoding_value != nullptr &&
        fl_value_get_type(encoding_value) == FL_VALUE_TYPE_STRING) {
      params.initialDataEncoding = std::string(fl_value_get_string(encoding_value));
    }
  }

  // Parse initial file
  FlValue* initial_file = fl_value_lookup_string(args, "initialFile");
  if (initial_file != nullptr &&
      fl_value_get_type(initial_file) == FL_VALUE_TYPE_STRING) {
    params.initialFile = std::string(fl_value_get_string(initial_file));
  }

  // Create the WPE-based InAppWebView
  auto webview = std::make_shared<InAppWebViewWpe>(messenger_, params.id, params);

#else
  // WebKitGTK path
  InAppWebViewCreationParams params;
  params.id = next_id_++;

  // Parse initial settings
  FlValue* initial_settings = fl_value_lookup_string(args, "initialSettings");
  if (initial_settings != nullptr &&
      fl_value_get_type(initial_settings) == FL_VALUE_TYPE_MAP) {
    params.initialSettings = std::make_shared<InAppWebViewSettings>(initial_settings);
  } else {
    params.initialSettings = std::make_shared<InAppWebViewSettings>();
  }

  // Parse initial URL request
  FlValue* initial_url_request = fl_value_lookup_string(args, "initialUrlRequest");
  if (initial_url_request != nullptr &&
      fl_value_get_type(initial_url_request) == FL_VALUE_TYPE_MAP) {
    params.initialUrlRequest = std::make_shared<URLRequest>(initial_url_request);
  }

  // Parse initial data
  FlValue* initial_data = fl_value_lookup_string(args, "initialData");
  if (initial_data != nullptr &&
      fl_value_get_type(initial_data) == FL_VALUE_TYPE_MAP) {
    FlValue* data_value = fl_value_lookup_string(initial_data, "data");
    if (data_value != nullptr &&
        fl_value_get_type(data_value) == FL_VALUE_TYPE_STRING) {
      params.initialData = std::string(fl_value_get_string(data_value));
    }
    FlValue* base_url_value = fl_value_lookup_string(initial_data, "baseUrl");
    if (base_url_value != nullptr &&
        fl_value_get_type(base_url_value) == FL_VALUE_TYPE_STRING) {
      params.initialDataBaseUrl = std::string(fl_value_get_string(base_url_value));
    }
    FlValue* mime_type_value = fl_value_lookup_string(initial_data, "mimeType");
    if (mime_type_value != nullptr &&
        fl_value_get_type(mime_type_value) == FL_VALUE_TYPE_STRING) {
      params.initialDataMimeType = std::string(fl_value_get_string(mime_type_value));
    }
    FlValue* encoding_value = fl_value_lookup_string(initial_data, "encoding");
    if (encoding_value != nullptr &&
        fl_value_get_type(encoding_value) == FL_VALUE_TYPE_STRING) {
      params.initialDataEncoding = std::string(fl_value_get_string(encoding_value));
    }
  }

  // Parse initial file
  FlValue* initial_file = fl_value_lookup_string(args, "initialFile");
  if (initial_file != nullptr &&
      fl_value_get_type(initial_file) == FL_VALUE_TYPE_STRING) {
    params.initialFile = std::string(fl_value_get_string(initial_file));
  }

  // Create the WebKitGTK-based InAppWebView
  auto webview = std::make_shared<InAppWebView>(messenger_, params.id, params);
#endif

  // Create the CustomPlatformView which handles textures and input
  auto platform_view = std::make_unique<CustomPlatformView>(
      messenger_, texture_registrar_, webview);

  int64_t texture_id = platform_view->texture_id();

  platform_views_[texture_id] = std::move(platform_view);

  // Return the texture ID to Flutter
  g_autoptr(FlValue) result = fl_value_new_int(texture_id);
  fl_method_call_respond_success(method_call, result, nullptr);
}

void InAppWebViewManager::DisposeWebView(int64_t texture_id) {
  auto it = platform_views_.find(texture_id);
  if (it != platform_views_.end()) {
    platform_views_.erase(it);
  }
}

}  // namespace flutter_inappwebview_plugin
