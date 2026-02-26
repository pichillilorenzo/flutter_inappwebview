#include "in_app_webview_manager.h"

#include <cstring>
#include <set>

#include "../flutter_inappwebview_linux_plugin_private.h"
#include "../plugin_instance.h"
#include "../plugin_scripts_js/javascript_bridge_js.h"
#include "../types/context_menu.h"
#include "../utils/flutter.h"
#include "../utils/log.h"
#include "../webview_environment.h"
#include "in_app_webview.h"
#include "in_app_webview_settings.h"

namespace flutter_inappwebview_plugin {

InAppWebViewManager::InAppWebViewManager(PluginInstance* plugin)
    : plugin_(plugin), registrar_(plugin->registrar()) {
  texture_registrar_ = plugin->textureRegistrar();
  messenger_ = plugin->messenger();

  gtk_window_ = plugin->gtkWindow();
  fl_view_ = plugin->flView();

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  method_channel_ = fl_method_channel_new(messenger_, METHOD_CHANNEL_NAME, FL_METHOD_CODEC(codec));

  fl_method_channel_set_method_call_handler(method_channel_, HandleMethodCall, this, nullptr);
}

FlPluginRegistrar* InAppWebViewManager::registrar() const {
  return registrar_;
}

InAppWebViewManager::~InAppWebViewManager() {
  platform_views_.clear();
  
  keepAliveWebViews_.clear();
  
  windowWebViews_.clear();

  if (method_channel_ != nullptr) {
    fl_method_channel_set_method_call_handler(method_channel_, nullptr, nullptr, nullptr);
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

void InAppWebViewManager::HandleMethodCall(FlMethodChannel* channel, FlMethodCall* method_call,
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
      auto textureIdOpt = get_optional_fl_map_value<int64_t>(args, "textureId");
      auto idOpt = get_optional_fl_map_value<int64_t>(args, "id");
      if (textureIdOpt.has_value()) {
        DisposeWebView(textureIdOpt.value());
        fl_method_call_respond_success(method_call, nullptr, nullptr);
        return;
      }
      if (idOpt.has_value()) {
        DisposeWebView(idOpt.value());
        fl_method_call_respond_success(method_call, nullptr, nullptr);
        return;
      }
    }
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  if (strcmp(method, "clearAllCache") == 0) {
    FlValue* args = fl_method_call_get_args(method_call);
    bool includeDiskFiles = get_fl_map_value<bool>(args, "includeDiskFiles", true);
    ClearAllCache(method_call, includeDiskFiles);
    return;
  }

  if (strcmp(method, "setJavaScriptBridgeName") == 0) {
    FlValue* args = fl_method_call_get_args(method_call);
    auto bridgeNameOpt = get_optional_fl_map_value<std::string>(args, "bridgeName");
    if (bridgeNameOpt.has_value()) {
      JavaScriptBridgeJS::set_JAVASCRIPT_BRIDGE_NAME(bridgeNameOpt.value());
    }
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  if (strcmp(method, "getJavaScriptBridgeName") == 0) {
    std::string bridgeName = JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME();
    g_autoptr(FlValue) result = make_fl_value(bridgeName);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (strcmp(method, "disposeKeepAlive") == 0) {
    FlValue* args = fl_method_call_get_args(method_call);
    auto keepAliveIdOpt = get_optional_fl_map_value<std::string>(args, "keepAliveId");
    if (keepAliveIdOpt.has_value()) {
      // Find and dispose the WebView with this keep-alive ID
      DisposeKeepAlive(keepAliveIdOpt.value());
    }
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  if (strcmp(method, "handlesURLScheme") == 0) {
    FlValue* args = fl_method_call_get_args(method_call);
    bool handles = false;
    auto urlSchemeOpt = get_optional_fl_map_value<std::string>(args, "urlScheme");
    if (urlSchemeOpt.has_value()) {
      const std::string& urlScheme = urlSchemeOpt.value();

      // Built-in schemes that WebKit handles natively
      // These cannot be overridden - WPE WebKit explicitly prohibits it
      static const std::set<std::string> builtInSchemes = {
        "http", "https", "file", "ftp", "data", "blob", "about", "javascript", "ws", "wss"
      };

      // iOS-style behavior: return true only for built-in schemes
      handles = builtInSchemes.find(urlScheme) != builtInSchemes.end();
    }
    g_autoptr(FlValue) result = make_fl_value(handles);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  fl_method_call_respond_not_implemented(method_call, nullptr);
}

void InAppWebViewManager::CreateInAppWebView(FlMethodCall* method_call) {
  FlValue* args = fl_method_call_get_args(method_call);

  if (fl_value_get_type(args) != FL_VALUE_TYPE_MAP) {
    fl_method_call_respond_error(method_call, "INVALID_ARGUMENTS", "Arguments must be a map",
                                 nullptr, nullptr);
    return;
  }

  std::string keepAliveId;
  auto keepAliveIdOpt = get_optional_fl_map_value<std::string>(args, "keepAliveId");
  if (keepAliveIdOpt.has_value()) {
    keepAliveId = keepAliveIdOpt.value();
  }

  if (!keepAliveId.empty()) {
    auto existingView = TakeKeepAliveWebView(keepAliveId);
    if (existingView != nullptr) {
      int64_t texture_id = existingView->texture_id();
      platform_views_[texture_id] = std::move(existingView);
      
      g_autoptr(FlValue) result = make_fl_value(texture_id);
      fl_method_call_respond_success(method_call, result, nullptr);
      return;
    }
  }

  InAppWebViewCreationParams params;
  params.id = next_id_++;
  params.plugin = plugin_;  // Pass plugin instance for accessing managers
  params.gtkWindow = gtk_window_;  // Pass the cached GTK window
  params.flView = fl_view_;  // Pass the cached FlView for focus restoration
  params.manager = this;  // Pass manager for multi-window support

  FlValue* initial_settings = fl_value_lookup_string(args, "initialSettings");
  if (initial_settings != nullptr && fl_value_get_type(initial_settings) == FL_VALUE_TYPE_MAP) {
    params.initialSettings = std::make_shared<InAppWebViewSettings>(initial_settings);
  } else {
    params.initialSettings = std::make_shared<InAppWebViewSettings>();
  }

  FlValue* initial_url_request = fl_value_lookup_string(args, "initialUrlRequest");
  if (initial_url_request != nullptr &&
      fl_value_get_type(initial_url_request) == FL_VALUE_TYPE_MAP) {
    params.initialUrlRequest = std::make_shared<URLRequest>(initial_url_request);
  }

  FlValue* initial_data = fl_value_lookup_string(args, "initialData");
  if (initial_data != nullptr && fl_value_get_type(initial_data) == FL_VALUE_TYPE_MAP) {
    params.initialData = get_fl_map_value<std::string>(initial_data, "data", "");
    params.initialDataBaseUrl = get_fl_map_value<std::string>(initial_data, "baseUrl", "");
    params.initialDataMimeType = get_fl_map_value<std::string>(initial_data, "mimeType", "");
    params.initialDataEncoding = get_fl_map_value<std::string>(initial_data, "encoding", "");
  }

  FlValue* initial_file = fl_value_lookup_string(args, "initialFile");
  if (initial_file != nullptr && fl_value_get_type(initial_file) == FL_VALUE_TYPE_STRING) {
    params.initialFile = std::string(fl_value_get_string(initial_file));
  }

  FlValue* context_menu = fl_value_lookup_string(args, "contextMenu");
  if (context_menu != nullptr && fl_value_get_type(context_menu) == FL_VALUE_TYPE_MAP) {
    params.contextMenu = std::make_shared<ContextMenu>(context_menu);
  }

  FlValue* initial_user_scripts = fl_value_lookup_string(args, "initialUserScripts");
  if (initial_user_scripts != nullptr && fl_value_get_type(initial_user_scripts) == FL_VALUE_TYPE_LIST) {
    size_t count = fl_value_get_length(initial_user_scripts);
    for (size_t i = 0; i < count; i++) {
      FlValue* script_value = fl_value_get_list_value(initial_user_scripts, i);
      if (script_value != nullptr && fl_value_get_type(script_value) == FL_VALUE_TYPE_MAP) {
        params.initialUserScripts.push_back(std::make_shared<UserScript>(script_value));
      }
    }
  }

  auto webViewEnvironmentIdOpt = get_optional_fl_map_value<std::string>(args, "webViewEnvironmentId");
  if (webViewEnvironmentIdOpt.has_value() && !webViewEnvironmentIdOpt->empty()) {
    WebViewEnvironment* webViewEnv = plugin_ ? plugin_->webViewEnvironment : nullptr;
    WebKitWebContext* webContext = nullptr;
    if (webViewEnv != nullptr) {
      webContext = webViewEnv->getWebContext(webViewEnvironmentIdOpt.value());
    }
    if (webContext != nullptr) {
      params.webContext = webContext;
      debugLog("InAppWebViewManager: Using custom WebKitWebContext from WebViewEnvironment id=" + webViewEnvironmentIdOpt.value());
    } else {
      debugLog("InAppWebViewManager: WebViewEnvironment not found for id=" + webViewEnvironmentIdOpt.value());
    }
  }

  auto webview = std::make_shared<InAppWebView>(registrar_, messenger_, params.id, params);

  auto platform_view =
      std::make_unique<CustomPlatformView>(messenger_, texture_registrar_, webview);

  int64_t texture_id = platform_view->texture_id();

  if (!keepAliveId.empty()) {
    platform_view->set_keep_alive_id(keepAliveId);
  }

  platform_views_[texture_id] = std::move(platform_view);

  g_autoptr(FlValue) result = make_fl_value(texture_id);
  fl_method_call_respond_success(method_call, result, nullptr);
}

void InAppWebViewManager::DisposeWebView(int64_t texture_id) {
  auto it = platform_views_.find(texture_id);
  if (it != platform_views_.end()) {
    auto& view = it->second;
    if (view && view->has_keep_alive_id()) {
      std::string keepAliveId = view->keep_alive_id();
      StoreKeepAliveWebView(keepAliveId, std::move(view));
      platform_views_.erase(it);
      return;
    }
    platform_views_.erase(it);
  }
}

void InAppWebViewManager::AddWindowWebView(int64_t windowId, 
                                           std::unique_ptr<WebViewTransport> transport) {
  windowWebViews_[windowId] = std::move(transport);
}

WebViewTransport* InAppWebViewManager::GetWindowWebView(int64_t windowId) {
  auto it = windowWebViews_.find(windowId);
  if (it != windowWebViews_.end()) {
    return it->second.get();
  }
  return nullptr;
}

void InAppWebViewManager::RemoveWindowWebView(int64_t windowId) {
  auto it = windowWebViews_.find(windowId);
  if (it != windowWebViews_.end()) {
    windowWebViews_.erase(it);
  }
}

void InAppWebViewManager::ClearAllCache(FlMethodCall* method_call, bool includeDiskFiles) {
  WebKitNetworkSession* session = webkit_network_session_get_default();
  if (session == nullptr) {
    fl_method_call_respond_success(method_call, fl_value_new_bool(FALSE), nullptr);
    return;
  }

  WebKitWebsiteDataManager* data_manager = webkit_network_session_get_website_data_manager(session);
  if (data_manager == nullptr) {
    fl_method_call_respond_success(method_call, fl_value_new_bool(FALSE), nullptr);
    return;
  }

  WebKitWebsiteDataTypes types = WEBKIT_WEBSITE_DATA_MEMORY_CACHE;
  if (includeDiskFiles) {
    types = static_cast<WebKitWebsiteDataTypes>(types | WEBKIT_WEBSITE_DATA_DISK_CACHE);
    types = static_cast<WebKitWebsiteDataTypes>(types | WEBKIT_WEBSITE_DATA_OFFLINE_APPLICATION_CACHE);
  }

  g_object_ref(method_call);

  webkit_website_data_manager_clear(
      data_manager,
      types,
      0,  // timespan = 0 means clear all data
      nullptr,  // GCancellable
      [](GObject* source_object, GAsyncResult* res, gpointer user_data) {
        auto* method_call = static_cast<FlMethodCall*>(user_data);
        auto* data_manager = WEBKIT_WEBSITE_DATA_MANAGER(source_object);

        GError* error = nullptr;
        gboolean success = webkit_website_data_manager_clear_finish(
            data_manager, res, &error);

        if (error != nullptr) {
          fl_method_call_respond_error(
              method_call, "CLEAR_CACHE_ERROR", error->message, nullptr, nullptr);
          g_error_free(error);
        } else {
          fl_method_call_respond_success(method_call, fl_value_new_bool(success), nullptr);
        }

        g_object_unref(method_call);
      },
      method_call);
}

// Keep-alive management methods

void InAppWebViewManager::StoreKeepAliveWebView(const std::string& keepAliveId, 
                                                  std::unique_ptr<CustomPlatformView> view) {
  if (!keepAliveId.empty() && view != nullptr) {
    keepAliveWebViews_[keepAliveId] = std::move(view);
  }
}

CustomPlatformView* InAppWebViewManager::GetKeepAliveWebView(const std::string& keepAliveId) const {
  auto it = keepAliveWebViews_.find(keepAliveId);
  if (it != keepAliveWebViews_.end()) {
    return it->second.get();
  }
  return nullptr;
}

std::unique_ptr<CustomPlatformView> InAppWebViewManager::TakeKeepAliveWebView(const std::string& keepAliveId) {
  auto it = keepAliveWebViews_.find(keepAliveId);
  if (it != keepAliveWebViews_.end()) {
    auto view = std::move(it->second);
    keepAliveWebViews_.erase(it);
    return view;
  }
  return nullptr;
}

void InAppWebViewManager::DisposeKeepAlive(const std::string& keepAliveId) {
  auto it = keepAliveWebViews_.find(keepAliveId);
  if (it != keepAliveWebViews_.end()) {
    keepAliveWebViews_.erase(it);
  }
  
  // Also check if the view is currently active in platform_views_
  // and clear its keepAliveId so it will be destroyed on next dispose
  for (auto& pair : platform_views_) {
    if (pair.second && pair.second->keep_alive_id() == keepAliveId) {
      pair.second->set_keep_alive_id("");
      break;
    }
  }
}

}  // namespace flutter_inappwebview_plugin
