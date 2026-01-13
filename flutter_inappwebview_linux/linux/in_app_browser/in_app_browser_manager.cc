#include "in_app_browser_manager.h"

#include <gio/gio.h>

#include <cstring>

#include "../plugin_instance.h"
#include "../in_app_webview/in_app_webview_settings.h"
#include "../types/url_request.h"
#include "../types/user_script.h"
#include "../types/context_menu.h"
#include "../utils/flutter.h"
#include "../utils/log.h"

namespace flutter_inappwebview_plugin {

InAppBrowserManager::InAppBrowserManager(PluginInstance* plugin) : plugin_(plugin) {
  // Validate plugin
  if (plugin_ == nullptr) {
    errorLog("InAppBrowserManager: Invalid plugin instance");
    return;
  }

  registrar_ = plugin_->registrar();
  if (!FL_IS_PLUGIN_REGISTRAR(registrar_)) {
    errorLog("InAppBrowserManager: Invalid registrar");
    return;
  }

  messenger_ = plugin_->messenger();
  if (messenger_ == nullptr || !FL_IS_BINARY_MESSENGER(messenger_)) {
    errorLog("InAppBrowserManager: Failed to get messenger from plugin");
    messenger_ = nullptr;
    return;
  }

  // Keep reference to messenger to ensure it stays valid
  g_object_ref(messenger_);

  // Cache the GTK window and FlView from plugin
  gtk_window_ = plugin_->gtkWindow();
  fl_view_ = plugin_->flView();

  // Create the method channel
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  method_channel_ = fl_method_channel_new(messenger_, METHOD_CHANNEL_NAME, FL_METHOD_CODEC(codec));

  fl_method_channel_set_method_call_handler(method_channel_, HandleMethodCall, this, nullptr);
}

InAppBrowserManager::~InAppBrowserManager() {
  debugLog("dealloc InAppBrowserManager");

  // Clean up all browsers first
  browsers_.clear();

  if (method_channel_ != nullptr) {
    fl_method_channel_set_method_call_handler(method_channel_, nullptr, nullptr, nullptr);
    g_object_unref(method_channel_);
    method_channel_ = nullptr;
  }

  // Release messenger reference
  if (messenger_ != nullptr) {
    g_object_unref(messenger_);
    messenger_ = nullptr;
  }

  gtk_window_ = nullptr;
  fl_view_ = nullptr;
  registrar_ = nullptr;
  plugin_ = nullptr;
}

FlPluginRegistrar* InAppBrowserManager::registrar() const {
  return registrar_;
}

void InAppBrowserManager::HandleMethodCall(FlMethodChannel* channel, FlMethodCall* method_call,
                                           gpointer user_data) {
  auto* self = static_cast<InAppBrowserManager*>(user_data);
  self->HandleMethodCallImpl(method_call);
}

void InAppBrowserManager::HandleMethodCallImpl(FlMethodCall* method_call) {
  const gchar* method = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);

  if (strcmp(method, "open") == 0) {
    createInAppBrowser(args);
    fl_method_call_respond_success(method_call, fl_value_new_bool(true), nullptr);
    return;
  }

  if (strcmp(method, "openWithSystemBrowser") == 0) {
    auto urlOpt = get_optional_fl_map_value<std::string>(args, "url");
    if (urlOpt.has_value()) {
      openWithSystemBrowser(urlOpt.value(), method_call);
    } else {
      fl_method_call_respond_error(method_call, "INVALID_ARGUMENTS", "URL is required", nullptr,
                                   nullptr);
    }
    return;
  }

  fl_method_call_respond_not_implemented(method_call, nullptr);
}

void InAppBrowserManager::createInAppBrowser(FlValue* arguments) {
  if (arguments == nullptr || fl_value_get_type(arguments) != FL_VALUE_TYPE_MAP) {
    return;
  }

  // Parse arguments
  std::string id = get_fl_map_value<std::string>(arguments, "id", "");
  if (id.empty()) {
    debugLog("InAppBrowserManager: Missing browser ID");
    return;
  }

  // Parse URL request
  std::optional<std::shared_ptr<URLRequest>> urlRequest;
  FlValue* urlRequestValue = fl_value_lookup_string(arguments, "urlRequest");
  if (urlRequestValue != nullptr && fl_value_get_type(urlRequestValue) == FL_VALUE_TYPE_MAP) {
    urlRequest = std::make_shared<URLRequest>(urlRequestValue);
  }

  // Parse asset file path
  auto assetFilePath = get_optional_fl_map_value<std::string>(arguments, "assetFilePath");

  // Parse data
  auto data = get_optional_fl_map_value<std::string>(arguments, "data");

  // Parse settings
  FlValue* settingsValue = fl_value_lookup_string(arguments, "settings");
  auto initialSettings = std::make_shared<InAppBrowserSettings>(settingsValue);
  auto initialWebViewSettings = std::make_shared<InAppWebViewSettings>(settingsValue);

  // Parse user scripts
  std::optional<std::vector<std::shared_ptr<UserScript>>> initialUserScripts;
  FlValue* userScriptsValue = fl_value_lookup_string(arguments, "initialUserScripts");
  if (userScriptsValue != nullptr && fl_value_get_type(userScriptsValue) == FL_VALUE_TYPE_LIST) {
    std::vector<std::shared_ptr<UserScript>> scripts;
    size_t count = fl_value_get_length(userScriptsValue);
    for (size_t i = 0; i < count; i++) {
      FlValue* scriptValue = fl_value_get_list_value(userScriptsValue, i);
      if (scriptValue != nullptr && fl_value_get_type(scriptValue) == FL_VALUE_TYPE_MAP) {
        scripts.push_back(std::make_shared<UserScript>(scriptValue));
      }
    }
    if (!scripts.empty()) {
      initialUserScripts = scripts;
    }
  }

  // Parse WebView environment ID
  auto webViewEnvironmentId = get_optional_fl_map_value<std::string>(arguments, "webViewEnvironmentId");

  // Parse context menu
  std::optional<std::shared_ptr<ContextMenu>> contextMenu;
  FlValue* contextMenuValue = fl_value_lookup_string(arguments, "contextMenu");
  if (contextMenuValue != nullptr && fl_value_get_type(contextMenuValue) == FL_VALUE_TYPE_MAP) {
    contextMenu = std::make_shared<ContextMenu>(contextMenuValue);
  }

  // Parse menu items
  std::vector<InAppBrowserMenuItem> menuItems;
  FlValue* menuItemsValue = fl_value_lookup_string(arguments, "menuItems");
  if (menuItemsValue != nullptr && fl_value_get_type(menuItemsValue) == FL_VALUE_TYPE_LIST) {
    size_t count = fl_value_get_length(menuItemsValue);
    for (size_t i = 0; i < count; i++) {
      FlValue* itemValue = fl_value_get_list_value(menuItemsValue, i);
      if (itemValue != nullptr && fl_value_get_type(itemValue) == FL_VALUE_TYPE_MAP) {
        menuItems.push_back(InAppBrowserMenuItem(itemValue));
      }
    }
  }

  // Create params
  InAppBrowserCreationParams params;
  params.plugin = plugin_;
  params.id = id;
  params.urlRequest = urlRequest;
  params.assetFilePath = assetFilePath;
  params.data = data;
  params.initialSettings = initialSettings;
  params.initialWebViewSettings = initialWebViewSettings;
  params.initialUserScripts = initialUserScripts;
  params.webViewEnvironmentId = webViewEnvironmentId;
  params.contextMenu = contextMenu;
  params.menuItems = menuItems;

  // Create the browser - pass cached messenger directly
  auto browser = std::make_unique<InAppBrowser>(this, messenger_, gtk_window_, params);
  browsers_[id] = std::move(browser);
}

void InAppBrowserManager::openWithSystemBrowser(const std::string& url,
                                                FlMethodCall* method_call) {
  GError* error = nullptr;

  // Use GIO to open the URL with the default handler
  gboolean success = g_app_info_launch_default_for_uri(url.c_str(), nullptr, &error);

  if (!success) {
    std::string errorMsg = "Failed to open URL";
    if (error != nullptr) {
      errorMsg = error->message;
      g_error_free(error);
    }
    debugLog("InAppBrowserManager: " + errorMsg + " - " + url);
    fl_method_call_respond_error(method_call, "OPEN_URL_ERROR", errorMsg.c_str(), nullptr, nullptr);
    return;
  }

  fl_method_call_respond_success(method_call, fl_value_new_bool(true), nullptr);
}

void InAppBrowserManager::removeBrowser(const std::string& id) {
  auto it = browsers_.find(id);
  if (it != browsers_.end()) {
    browsers_.erase(it);
  }
}

InAppBrowser* InAppBrowserManager::getBrowser(const std::string& id) {
  auto it = browsers_.find(id);
  if (it != browsers_.end()) {
    return it->second.get();
  }
  return nullptr;
}

}  // namespace flutter_inappwebview_plugin
