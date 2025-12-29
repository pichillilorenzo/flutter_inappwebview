// WPE WebKit User Content Controller implementation
// 
// The WPE WebKit API for user content management is identical to WebKitGTK,
// so this implementation follows the same patterns.

#include "user_content_controller_wpe.h"

#ifdef USE_WPE_WEBKIT

#include <algorithm>
#include <jsc/jsc.h>
#include <nlohmann/json.hpp>

#include "../utils/log.h"

namespace flutter_inappwebview_plugin {

using json = nlohmann::json;

namespace {
bool DebugLogEnabled() {
  static bool enabled = g_getenv("FLUTTER_INAPPWEBVIEW_LINUX_DEBUG") != nullptr;
  return enabled;
}
}  // namespace

UserContentControllerWpe::UserContentControllerWpe(WebKitWebView* webview)
    : webview_(webview) {
  if (webview_ != nullptr) {
    content_manager_ = webkit_web_view_get_user_content_manager(webview_);
  }
  
  if (DebugLogEnabled()) {
    g_message("UserContentControllerWpe: initialized (manager=%p)", 
              static_cast<void*>(content_manager_));
  }
}

UserContentControllerWpe::~UserContentControllerWpe() {
  if (DebugLogEnabled()) {
    g_message("UserContentControllerWpe: destructor");
  }
  
  // Unregister all message handlers
  for (const auto& name : registered_message_handlers_) {
    if (content_manager_ != nullptr) {
      webkit_user_content_manager_unregister_script_message_handler(
          content_manager_, name.c_str(), nullptr);
    }
  }
  registered_message_handlers_.clear();
  
  // Clear all scripts when destroyed
  if (content_manager_ != nullptr) {
    webkit_user_content_manager_remove_all_scripts(content_manager_);
  }
  
  document_start_scripts_.clear();
  document_end_scripts_.clear();
  plugin_scripts_.clear();
}

void UserContentControllerWpe::addUserScript(std::shared_ptr<UserScript> userScript) {
  if (userScript == nullptr || content_manager_ == nullptr) {
    return;
  }

  // Store in our list
  if (userScript->injectionTime == UserScriptInjectionTime::atDocumentStart) {
    document_start_scripts_.push_back(userScript);
  } else {
    document_end_scripts_.push_back(userScript);
  }

  // Create and add WebKit user script
  WebKitUserScript* wkScript = createWebKitUserScript(userScript);
  if (wkScript != nullptr) {
    webkit_user_content_manager_add_script(content_manager_, wkScript);
    webkit_user_script_unref(wkScript);
  }

  if (DebugLogEnabled()) {
    g_message("UserContentControllerWpe: added user script (time=%s)",
              userScript->injectionTime == UserScriptInjectionTime::atDocumentStart
                  ? "start" : "end");
  }
}

void UserContentControllerWpe::removeUserScriptAt(size_t index,
                                                   UserScriptInjectionTime injectionTime) {
  auto& scripts = injectionTime == UserScriptInjectionTime::atDocumentStart
                      ? document_start_scripts_
                      : document_end_scripts_;

  if (index < scripts.size()) {
    scripts.erase(scripts.begin() + index);
    rebuildScripts();
  }
}

void UserContentControllerWpe::removeUserScriptsByGroupName(const std::string& groupName) {
  auto removeFromVector = [&groupName](std::vector<std::shared_ptr<UserScript>>& scripts) {
    scripts.erase(
        std::remove_if(scripts.begin(), scripts.end(),
                       [&groupName](const std::shared_ptr<UserScript>& script) {
                         return script->groupName.has_value() &&
                                script->groupName.value() == groupName;
                       }),
        scripts.end());
  };

  removeFromVector(document_start_scripts_);
  removeFromVector(document_end_scripts_);
  rebuildScripts();
}

void UserContentControllerWpe::removeAllUserScripts() {
  document_start_scripts_.clear();
  document_end_scripts_.clear();
  
  if (content_manager_ != nullptr) {
    // Remove all scripts from WebKit (this also removes plugin scripts)
    webkit_user_content_manager_remove_all_scripts(content_manager_);
    
    // Re-add plugin scripts (they should persist)
    for (const auto& pluginScript : plugin_scripts_) {
      WebKitUserScriptInjectionTime webkitTime =
          pluginScript->injectionTime == UserScriptInjectionTime::atDocumentStart
              ? WEBKIT_USER_SCRIPT_INJECT_AT_DOCUMENT_START
              : WEBKIT_USER_SCRIPT_INJECT_AT_DOCUMENT_END;

      WebKitUserContentInjectedFrames frames =
          pluginScript->forMainFrameOnly ? WEBKIT_USER_CONTENT_INJECT_TOP_FRAME
                                         : WEBKIT_USER_CONTENT_INJECT_ALL_FRAMES;

      WebKitUserScript* wkScript = webkit_user_script_new(
          pluginScript->source.c_str(),
          frames,
          webkitTime,
          nullptr,  // allow_list
          nullptr   // block_list
      );
      if (wkScript != nullptr) {
        webkit_user_content_manager_add_script(content_manager_, wkScript);
        webkit_user_script_unref(wkScript);
      }
    }
  }

  if (DebugLogEnabled()) {
    g_message("UserContentControllerWpe: removed all user scripts (preserved %zu plugin scripts)",
              plugin_scripts_.size());
  }
}

const std::vector<std::shared_ptr<UserScript>>& 
UserContentControllerWpe::getUserScripts(UserScriptInjectionTime injectionTime) const {
  if (injectionTime == UserScriptInjectionTime::atDocumentStart) {
    return document_start_scripts_;
  }
  return document_end_scripts_;
}

void UserContentControllerWpe::setScriptMessageHandler(ScriptMessageHandler handler) {
  script_message_handler_ = handler;
}

void UserContentControllerWpe::registerScriptMessageHandler(const std::string& name) {
  if (content_manager_ == nullptr) {
    return;
  }

  // Check if already registered
  for (const auto& existing : registered_message_handlers_) {
    if (existing == name) {
      return;
    }
  }

  // Build the signal name: "script-message-received::<name>"
  std::string signalName = "script-message-received::" + name;

  // Connect the signal
  g_signal_connect(
      content_manager_,
      signalName.c_str(),
      G_CALLBACK(onScriptMessageReceived),
      this);

  // Register the handler with WebKit (WPE API since 2.40)
  gboolean success = webkit_user_content_manager_register_script_message_handler(
      content_manager_, name.c_str(), nullptr);

  if (!success) {
    g_warning("UserContentControllerWpe: Failed to register message handler %s", name.c_str());
    return;
  }

  registered_message_handlers_.push_back(name);

  if (DebugLogEnabled()) {
    g_message("UserContentControllerWpe: registered message handler '%s'", name.c_str());
  }
}

void UserContentControllerWpe::addPluginScript(std::unique_ptr<PluginScript> pluginScript) {
  if (pluginScript == nullptr || content_manager_ == nullptr) {
    return;
  }

  // Register any message handlers required by this script
  for (const auto& handlerName : pluginScript->messageHandlerNames) {
    registerScriptMessageHandler(handlerName);
  }

  // Create a UserScript from the PluginScript
  // Constructor: groupName, source, injectionTime, forMainFrameOnly, allowedOriginRules, contentWorld
  auto userScript = std::make_shared<UserScript>(
      pluginScript->groupName,
      pluginScript->source,
      pluginScript->injectionTime,
      pluginScript->forMainFrameOnly,
      pluginScript->allowedOriginRules,
      nullptr  // contentWorld
  );

  // Add the script
  WebKitUserScript* wkScript = createWebKitUserScript(userScript);
  if (wkScript != nullptr) {
    webkit_user_content_manager_add_script(content_manager_, wkScript);
    webkit_user_script_unref(wkScript);
  }

  plugin_scripts_.push_back(std::move(pluginScript));

  if (DebugLogEnabled()) {
    g_message("UserContentControllerWpe: added plugin script");
  }
}

void UserContentControllerWpe::onScriptMessageReceived(
    WebKitUserContentManager* manager,
    JSCValue* value,
    gpointer user_data) {
  auto* self = static_cast<UserContentControllerWpe*>(user_data);
  
  if (DebugLogEnabled()) {
    g_message("UserContentControllerWpe: onScriptMessageReceived called (value=%p)",
              static_cast<void*>(value));
  }
  
  if (self == nullptr || self->script_message_handler_ == nullptr) {
    if (DebugLogEnabled()) {
      g_message("UserContentControllerWpe: onScriptMessageReceived - no handler set");
    }
    return;
  }

  if (value == nullptr) {
    return;
  }

  // Convert JSC value to string (JSON)
  gchar* jsonStr = nullptr;
  
  if (jsc_value_is_object(value)) {
    // Get the context and use JSON.stringify
    JSCContext* context = jsc_value_get_context(value);
    if (context != nullptr) {
      // Evaluate JSON.stringify(value) properly
      // First, create a reference to the value in a global variable
      jsc_context_set_value(context, "__inappwebview_temp_value", value);
      
      // Then stringify it
      JSCValue* jsonResult = jsc_context_evaluate(context, 
          "JSON.stringify(__inappwebview_temp_value)", -1);
      
      if (jsonResult != nullptr && jsc_value_is_string(jsonResult)) {
        jsonStr = jsc_value_to_string(jsonResult);
      }
      
      // Clean up
      if (jsonResult != nullptr) {
        g_object_unref(jsonResult);
      }
      
      // Remove the temp variable (ignore result)
      JSCValue* deleteResult = jsc_context_evaluate(context, "delete __inappwebview_temp_value", -1);
      if (deleteResult != nullptr) {
        g_object_unref(deleteResult);
      }
    }
  } else if (jsc_value_is_string(value)) {
    jsonStr = jsc_value_to_string(value);
  }

  if (jsonStr != nullptr) {
    if (DebugLogEnabled()) {
      g_message("UserContentControllerWpe: received message: %.100s%s",
                jsonStr, strlen(jsonStr) > 100 ? "..." : "");
    }
    // The handler name is extracted from the signal name by WebKit,
    // but for our purposes we need to get it from the message body
    self->script_message_handler_("callHandler", std::string(jsonStr));
    g_free(jsonStr);
  } else {
    if (DebugLogEnabled()) {
      g_message("UserContentControllerWpe: failed to convert JSC value to string");
    }
  }
}

WebKitUserScript* UserContentControllerWpe::createWebKitUserScript(
    const std::shared_ptr<UserScript>& userScript) const {
  if (userScript == nullptr) {
    return nullptr;
  }

  WebKitUserScriptInjectionTime webkitTime =
      userScript->injectionTime == UserScriptInjectionTime::atDocumentStart
          ? WEBKIT_USER_SCRIPT_INJECT_AT_DOCUMENT_START
          : WEBKIT_USER_SCRIPT_INJECT_AT_DOCUMENT_END;

  WebKitUserContentInjectedFrames frames =
      userScript->forMainFrameOnly ? WEBKIT_USER_CONTENT_INJECT_TOP_FRAME
                                   : WEBKIT_USER_CONTENT_INJECT_ALL_FRAMES;

  return webkit_user_script_new(
      userScript->source.c_str(),
      frames,
      webkitTime,
      nullptr,  // allow_list
      nullptr   // block_list
  );
}

void UserContentControllerWpe::rebuildScripts() {
  if (content_manager_ == nullptr) {
    return;
  }

  // Remove all scripts
  webkit_user_content_manager_remove_all_scripts(content_manager_);

  // Re-add plugin scripts first (they take priority)
  for (const auto& pluginScript : plugin_scripts_) {
    WebKitUserScriptInjectionTime webkitTime =
        pluginScript->injectionTime == UserScriptInjectionTime::atDocumentStart
            ? WEBKIT_USER_SCRIPT_INJECT_AT_DOCUMENT_START
            : WEBKIT_USER_SCRIPT_INJECT_AT_DOCUMENT_END;

    WebKitUserContentInjectedFrames frames =
        pluginScript->forMainFrameOnly ? WEBKIT_USER_CONTENT_INJECT_TOP_FRAME
                                       : WEBKIT_USER_CONTENT_INJECT_ALL_FRAMES;

    WebKitUserScript* wkScript = webkit_user_script_new(
        pluginScript->source.c_str(),
        frames,
        webkitTime,
        nullptr,  // allow_list
        nullptr   // block_list
    );
    if (wkScript != nullptr) {
      webkit_user_content_manager_add_script(content_manager_, wkScript);
      webkit_user_script_unref(wkScript);
    }
  }

  // Re-add user scripts
  for (const auto& script : document_start_scripts_) {
    WebKitUserScript* wkScript = createWebKitUserScript(script);
    if (wkScript != nullptr) {
      webkit_user_content_manager_add_script(content_manager_, wkScript);
      webkit_user_script_unref(wkScript);
    }
  }
  for (const auto& script : document_end_scripts_) {
    WebKitUserScript* wkScript = createWebKitUserScript(script);
    if (wkScript != nullptr) {
      webkit_user_content_manager_add_script(content_manager_, wkScript);
      webkit_user_script_unref(wkScript);
    }
  }
}

}  // namespace flutter_inappwebview_plugin

#endif  // USE_WPE_WEBKIT
