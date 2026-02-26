#include "webview_environment.h"

#include <wpe/webkit.h>

#include <cstring>
#include <sstream>

#include "plugin_instance.h"
#include "utils/flutter.h"
#include "utils/log.h"

namespace flutter_inappwebview_plugin {

namespace {
// Helper to compare method names
bool string_equals(const gchar* a, const char* b) {
  return strcmp(a, b) == 0;
}
}  // namespace

// ============================================================================
// WebViewEnvironmentInstanceChannelDelegate Implementation
// ============================================================================

WebViewEnvironmentInstanceChannelDelegate::WebViewEnvironmentInstanceChannelDelegate(
    FlBinaryMessenger* messenger,
    const std::string& id,
    std::function<void(const std::string&)> disposeCallback)
    : ChannelDelegate(messenger,
                      "com.pichillilorenzo/flutter_webview_environment_" + id),
      id_(id),
      disposeCallback_(std::move(disposeCallback)) {}

WebViewEnvironmentInstanceChannelDelegate::~WebViewEnvironmentInstanceChannelDelegate() {
  debugLog("dealloc WebViewEnvironmentInstanceChannelDelegate id=" + id_);
  if (context_ != nullptr) {
    g_object_unref(context_);
    context_ = nullptr;
  }
}

void WebViewEnvironmentInstanceChannelDelegate::HandleMethodCall(FlMethodCall* method_call) {
  const gchar* method = fl_method_call_get_name(method_call);

  if (string_equals(method, "dispose")) {
    // Dispose this instance - call the callback to remove from parent's map
    disposeCallback_(id_);
    fl_method_call_respond_success(method_call, fl_value_new_null(), nullptr);
  } else if (string_equals(method, "isSpellCheckingEnabled")) {
    bool enabled = isSpellCheckingEnabled();
    fl_method_call_respond_success(method_call, fl_value_new_bool(enabled), nullptr);
  } else if (string_equals(method, "getSpellCheckingLanguages")) {
    auto languages = getSpellCheckingLanguages();
    FlValue* list = fl_value_new_list();
    for (const auto& lang : languages) {
      fl_value_append_take(list, fl_value_new_string(lang.c_str()));
    }
    fl_method_call_respond_success(method_call, list, nullptr);
  } else if (string_equals(method, "getCacheModel")) {
    int model = getCacheModel();
    fl_method_call_respond_success(method_call, fl_value_new_int(model), nullptr);
  } else if (string_equals(method, "isAutomationAllowed")) {
    bool allowed = isAutomationAllowed();
    fl_method_call_respond_success(method_call, fl_value_new_bool(allowed), nullptr);
  } else {
    fl_method_call_respond_not_implemented(method_call, nullptr);
  }
}

bool WebViewEnvironmentInstanceChannelDelegate::isSpellCheckingEnabled() const {
  if (context_ == nullptr) {
    return false;
  }
  return webkit_web_context_get_spell_checking_enabled(context_);
}

std::vector<std::string> WebViewEnvironmentInstanceChannelDelegate::getSpellCheckingLanguages() const {
  std::vector<std::string> result;
  if (context_ == nullptr) {
    return result;
  }
  const gchar* const* languages = webkit_web_context_get_spell_checking_languages(context_);
  if (languages != nullptr) {
    for (int i = 0; languages[i] != nullptr; i++) {
      result.push_back(std::string(languages[i]));
    }
  }
  return result;
}

int WebViewEnvironmentInstanceChannelDelegate::getCacheModel() const {
  if (context_ == nullptr) {
    return 1; // Default: WEBKIT_CACHE_MODEL_WEB_BROWSER
  }
  return static_cast<int>(webkit_web_context_get_cache_model(context_));
}

bool WebViewEnvironmentInstanceChannelDelegate::isAutomationAllowed() const {
  if (context_ == nullptr) {
    return false;
  }
  return webkit_web_context_is_automation_allowed(context_);
}

// ============================================================================
// WebViewEnvironment Implementation
// ============================================================================

WebKitWebContext* WebViewEnvironment::getWebContext(const std::string& id) const {
  if (id.empty()) {
    return nullptr;
  }
  auto* delegate = getInstance(id);
  if (delegate == nullptr) {
    return nullptr;
  }
  return delegate->context();
}

WebViewEnvironment::WebViewEnvironment(PluginInstance* plugin)
    : ChannelDelegate(plugin->messenger(), METHOD_CHANNEL_NAME),
      plugin_(plugin),
      messenger_(plugin->messenger()) {}

WebViewEnvironment::~WebViewEnvironment() {
  debugLog("dealloc WebViewEnvironment");
  // Clean up all instances
  instances_.clear();
  plugin_ = nullptr;
}

void WebViewEnvironment::HandleMethodCall(FlMethodCall* method_call) {
  const gchar* method = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);

  if (string_equals(method, "getAvailableVersion")) {
    std::string version = getAvailableVersion();
    fl_method_call_respond_success(method_call, fl_value_new_string(version.c_str()), nullptr);
  } else if (string_equals(method, "create")) {
    auto id = get_fl_map_value<std::string>(args, "id", "");
    if (id.empty()) {
      fl_method_call_respond_error(method_call, "INVALID_ARGUMENT", "Missing 'id' argument",
                                   nullptr, nullptr);
      return;
    }
    FlValue* settings = fl_value_lookup_string(args, "settings");
    create(id, settings);
    fl_method_call_respond_success(method_call, fl_value_new_null(), nullptr);
  } else {
    fl_method_call_respond_not_implemented(method_call, nullptr);
  }
}

std::string WebViewEnvironment::getAvailableVersion() {
  // Get the WPE WebKit version using the webkit version functions
  guint major = webkit_get_major_version();
  guint minor = webkit_get_minor_version();
  guint micro = webkit_get_micro_version();

  std::ostringstream version;
  version << major << "." << minor << "." << micro;
  return version.str();
}

void WebViewEnvironment::create(const std::string& id, FlValue* settings) {
  debugLog("WebViewEnvironment::create id=" + id);

  // Check if we need to use a specific timezone override
  // This must be set at construction time via the time-zone-override property
  auto timeZoneOverride = get_optional_fl_map_value<std::string>(settings, "timeZoneOverride");
  
  WebKitWebContext* context = nullptr;
  if (timeZoneOverride.has_value() && !timeZoneOverride->empty()) {
    // Create WebContext with timezone override property
    context = WEBKIT_WEB_CONTEXT(g_object_new(WEBKIT_TYPE_WEB_CONTEXT,
        "time-zone-override", timeZoneOverride->c_str(),
        nullptr));
  } else {
    // Create a default WebKitWebContext
    context = webkit_web_context_new();
  }

  if (context == nullptr) {
    errorLog("WebViewEnvironment::create - Failed to create WebKitWebContext");
    return;
  }

  // Apply settings from creation params
  if (settings != nullptr && fl_value_get_type(settings) == FL_VALUE_TYPE_MAP) {
    // cacheModel
    auto cacheModel = get_optional_fl_map_value<int64_t>(settings, "cacheModel");
    if (cacheModel.has_value()) {
      webkit_web_context_set_cache_model(context, 
          static_cast<WebKitCacheModel>(cacheModel.value()));
    }

    // spellCheckingEnabled
    auto spellCheckingEnabled = get_optional_fl_map_value<bool>(settings, "spellCheckingEnabled");
    if (spellCheckingEnabled.has_value()) {
      webkit_web_context_set_spell_checking_enabled(context, spellCheckingEnabled.value());
    }

    // spellCheckingLanguages
    auto spellCheckingLanguages = get_optional_fl_map_value<std::vector<std::string>>(
        settings, "spellCheckingLanguages");
    if (spellCheckingLanguages.has_value() && !spellCheckingLanguages->empty()) {
      // Convert to null-terminated array of C strings
      std::vector<const gchar*> langs;
      for (const auto& lang : *spellCheckingLanguages) {
        langs.push_back(lang.c_str());
      }
      langs.push_back(nullptr); // Null terminate
      webkit_web_context_set_spell_checking_languages(context, langs.data());
    }

    // preferredLanguages
    auto preferredLanguages = get_optional_fl_map_value<std::vector<std::string>>(
        settings, "preferredLanguages");
    if (preferredLanguages.has_value() && !preferredLanguages->empty()) {
      std::vector<const gchar*> langs;
      for (const auto& lang : *preferredLanguages) {
        langs.push_back(lang.c_str());
      }
      langs.push_back(nullptr);
      webkit_web_context_set_preferred_languages(context, langs.data());
    }

    // automationAllowed
    auto automationAllowed = get_optional_fl_map_value<bool>(settings, "automationAllowed");
    if (automationAllowed.has_value()) {
      webkit_web_context_set_automation_allowed(context, automationAllowed.value());
    }

    // webProcessExtensionsDirectory
    auto extensionsDir = get_optional_fl_map_value<std::string>(
        settings, "webProcessExtensionsDirectory");
    if (extensionsDir.has_value() && !extensionsDir->empty()) {
      webkit_web_context_set_web_process_extensions_directory(context, extensionsDir->c_str());
    }

    // sandboxPaths
    auto sandboxPaths = get_optional_fl_map_value<std::vector<std::string>>(
        settings, "sandboxPaths");
    if (sandboxPaths.has_value()) {
      for (const auto& path : *sandboxPaths) {
        if (!path.empty()) {
          webkit_web_context_add_path_to_sandbox(context, path.c_str(), FALSE);
        }
      }
    }
  }

  // Create instance channel delegate
  auto instanceDelegate = std::make_unique<WebViewEnvironmentInstanceChannelDelegate>(
      messenger_, id,
      [this](const std::string& envId) { disposeEnvironment(envId); });
  instanceDelegate->setContext(context);

  // Store in map
  instances_[id] = std::move(instanceDelegate);
}

void WebViewEnvironment::disposeEnvironment(const std::string& id) {
  debugLog("WebViewEnvironment::disposeEnvironment id=" + id);

  auto it = instances_.find(id);
  if (it != instances_.end()) {
    // Remove from map - this will trigger destructor which cleans up context
    instances_.erase(it);
  }
}

WebViewEnvironmentInstanceChannelDelegate* WebViewEnvironment::getInstance(const std::string& id) const {
  auto it = instances_.find(id);
  if (it != instances_.end()) {
    return it->second.get();
  }
  return nullptr;
}

}  // namespace flutter_inappwebview_plugin
