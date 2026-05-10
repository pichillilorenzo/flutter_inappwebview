#include "webkitgtk_manager.h"

#include <cstring>

namespace flutter_inappwebview_webkit {

WebKitGTKManager::WebKitGTKManager(FlPluginRegistrar* registrar) : registrar_(registrar) {
  messenger_ = fl_plugin_registrar_get_messenger(registrar_);
  texture_registrar_ = fl_plugin_registrar_get_texture_registrar(registrar_);

  // Retrieve the parent GtkWindow
  FlView* fl_view = fl_plugin_registrar_get_view(registrar_);
  if (fl_view) {
    GtkWidget* toplevel = gtk_widget_get_toplevel(GTK_WIDGET(fl_view));
    if (GTK_IS_WINDOW(toplevel)) {
      gtk_window_ = GTK_WINDOW(toplevel);
    }
  }

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  manager_channel_ = fl_method_channel_new(
      messenger_, "com.pichillilorenzo/flutter_inappwebview_manager", FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(manager_channel_, HandleMethodCall, this, nullptr);
}

WebKitGTKManager::~WebKitGTKManager() {
  views_.clear();

  if (manager_channel_) {
    fl_method_channel_set_method_call_handler(manager_channel_, nullptr, nullptr, nullptr);
    g_object_unref(manager_channel_);
    manager_channel_ = nullptr;
  }
}

// static
void WebKitGTKManager::HandleMethodCall(FlMethodChannel* /*channel*/, FlMethodCall* method_call,
                                        gpointer user_data) {
  auto* self = static_cast<WebKitGTKManager*>(user_data);
  self->HandleMethodCallImpl(method_call);
}

void WebKitGTKManager::HandleMethodCallImpl(FlMethodCall* method_call) {
  const char* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "createInAppWebView") == 0) {
    CreateInAppWebView(method_call);
  } else if (strcmp(method, "dispose") == 0) {
    Dispose(method_call);
  } else if (strcmp(method, "clearAllCache") == 0) {
    // WebKitGTK: clear all cache
    // website_data_manager = webkit_web_context_get_website_data_manager(...)
    // We do a best-effort clear here
    WebKitWebContext* ctx = webkit_web_context_get_default();
    WebKitWebsiteDataManager* dm = webkit_web_context_get_website_data_manager(ctx);
    webkit_website_data_manager_clear(
        dm,
        static_cast<WebKitWebsiteDataTypes>(WEBKIT_WEBSITE_DATA_DISK_CACHE |
                                            WEBKIT_WEBSITE_DATA_MEMORY_CACHE |
                                            WEBKIT_WEBSITE_DATA_OFFLINE_APPLICATION_CACHE),
        0, nullptr, nullptr, nullptr);
    fl_method_call_respond_success(method_call, nullptr, nullptr);
  } else if (strcmp(method, "setJavaScriptBridgeName") == 0 ||
             strcmp(method, "getJavaScriptBridgeName") == 0 ||
             strcmp(method, "disposeKeepAlive") == 0) {
    // Stub – return success / empty
    fl_method_call_respond_success(method_call, nullptr, nullptr);
  } else {
    fl_method_call_respond_not_implemented(method_call, nullptr);
  }
}

void WebKitGTKManager::CreateInAppWebView(FlMethodCall* method_call) {
  int64_t id = next_id_++;

  auto view = std::make_unique<WebKitGTKView>(id, messenger_, texture_registrar_, gtk_window_);

  int64_t texture_id = view->texture_id();

  // Handle initial URL / data if provided in args
  FlValue* args = fl_method_call_get_args(method_call);
  if (fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
    FlValue* url_req = fl_value_lookup_string(args, "initialUrlRequest");
    if (url_req && fl_value_get_type(url_req) == FL_VALUE_TYPE_MAP) {
      FlValue* url_val = fl_value_lookup_string(url_req, "url");
      if (url_val && fl_value_get_type(url_val) == FL_VALUE_TYPE_STRING) {
        view->LoadUrl(fl_value_get_string(url_val));
      }
    }

    FlValue* initial_data = fl_value_lookup_string(args, "initialData");
    if (initial_data && fl_value_get_type(initial_data) == FL_VALUE_TYPE_MAP) {
      FlValue* data_val = fl_value_lookup_string(initial_data, "data");
      FlValue* mime_val = fl_value_lookup_string(initial_data, "mimeType");
      FlValue* base_val = fl_value_lookup_string(initial_data, "baseUrl");
      const char* data_str = data_val && fl_value_get_type(data_val) == FL_VALUE_TYPE_STRING
                                 ? fl_value_get_string(data_val)
                                 : nullptr;
      const char* mime_str = mime_val && fl_value_get_type(mime_val) == FL_VALUE_TYPE_STRING
                                 ? fl_value_get_string(mime_val)
                                 : "text/html";
      const char* base_str = base_val && fl_value_get_type(base_val) == FL_VALUE_TYPE_STRING
                                 ? fl_value_get_string(base_val)
                                 : "about:blank";
      if (data_str) {
        view->LoadData(data_str, mime_str, base_str);
      }
    }

    // Apply initial settings if provided
    FlValue* settings = fl_value_lookup_string(args, "initialSettings");
    // (settings handled inside the view on method calls)
    (void)settings;
  }

  views_[texture_id] = std::move(view);

  g_autoptr(FlValue) result = fl_value_new_int(texture_id);
  fl_method_call_respond_success(method_call, result, nullptr);
}

void WebKitGTKManager::Dispose(FlMethodCall* method_call) {
  FlValue* args = fl_method_call_get_args(method_call);
  int64_t texture_id = -1;

  if (fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
    FlValue* id_val = fl_value_lookup_string(args, "id");
    if (!id_val)
      id_val = fl_value_lookup_string(args, "textureId");
    if (id_val && fl_value_get_type(id_val) == FL_VALUE_TYPE_INT)
      texture_id = fl_value_get_int(id_val);
  } else if (fl_value_get_type(args) == FL_VALUE_TYPE_INT) {
    texture_id = fl_value_get_int(args);
  }

  if (texture_id >= 0) {
    views_.erase(texture_id);
  }

  fl_method_call_respond_success(method_call, nullptr, nullptr);
}

}  // namespace flutter_inappwebview_webkit
