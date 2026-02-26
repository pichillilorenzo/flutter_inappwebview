// WPE WebKit User Content Controller implementation
//
// The WPE WebKit API for user content management is identical to WebKitGTK,
// so this implementation follows the same patterns.

#include "user_content_controller.h"

#include <jsc/jsc.h>

#include <algorithm>
#include <nlohmann/json.hpp>

#include "../utils/log.h"

namespace flutter_inappwebview_plugin {

using json = nlohmann::json;

UserContentController::UserContentController(WebKitWebView* webview) : webview_(webview) {
  if (webview_ != nullptr) {
    content_manager_ = webkit_web_view_get_user_content_manager(webview_);
  }
}

UserContentController::~UserContentController() {
  // Check if webview is still valid - the content manager becomes invalid
  // when the webview is destroyed
  bool manager_valid = content_manager_ != nullptr && webview_ != nullptr &&
                       WEBKIT_IS_WEB_VIEW(webview_) &&
                       WEBKIT_IS_USER_CONTENT_MANAGER(content_manager_);

  // Unregister all message handlers
  if (manager_valid) {
    for (const auto& name : registered_message_handlers_) {
      webkit_user_content_manager_unregister_script_message_handler(content_manager_, name.c_str(),
                                                                    nullptr);
    }
    for (const auto& name : registered_message_handlers_with_reply_) {
      webkit_user_content_manager_unregister_script_message_handler(content_manager_, name.c_str(),
                                                                    nullptr);
    }
  }
  registered_message_handlers_.clear();
  registered_message_handlers_with_reply_.clear();
  script_message_with_reply_handlers_.clear();

  // Clear all scripts when destroyed
  if (manager_valid) {
    webkit_user_content_manager_remove_all_scripts(content_manager_);
  }

  document_start_scripts_.clear();
  document_end_scripts_.clear();
  plugin_scripts_.clear();
}

void UserContentController::addUserScript(std::shared_ptr<UserScript> userScript) {
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
}

void UserContentController::removeUserScriptAt(size_t index,
                                               UserScriptInjectionTime injectionTime) {
  auto& scripts = injectionTime == UserScriptInjectionTime::atDocumentStart
                      ? document_start_scripts_
                      : document_end_scripts_;

  if (index < scripts.size()) {
    scripts.erase(scripts.begin() + index);
    rebuildScripts();
  }
}

void UserContentController::removeUserScriptsByGroupName(const std::string& groupName) {
  auto removeFromVector = [&groupName](std::vector<std::shared_ptr<UserScript>>& scripts) {
    scripts.erase(std::remove_if(scripts.begin(), scripts.end(),
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

void UserContentController::removeAllUserScripts() {
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

      WebKitUserContentInjectedFrames frames = pluginScript->forMainFrameOnly
                                                   ? WEBKIT_USER_CONTENT_INJECT_TOP_FRAME
                                                   : WEBKIT_USER_CONTENT_INJECT_ALL_FRAMES;

      WebKitUserScript* wkScript =
          webkit_user_script_new(pluginScript->source.c_str(), frames, webkitTime,
                                 nullptr,  // allow_list
                                 nullptr   // block_list
          );
      if (wkScript != nullptr) {
        webkit_user_content_manager_add_script(content_manager_, wkScript);
        webkit_user_script_unref(wkScript);
      }
    }
  }
}

const std::vector<std::shared_ptr<UserScript>>& UserContentController::getUserScripts(
    UserScriptInjectionTime injectionTime) const {
  if (injectionTime == UserScriptInjectionTime::atDocumentStart) {
    return document_start_scripts_;
  }
  return document_end_scripts_;
}

void UserContentController::setScriptMessageHandler(ScriptMessageHandler handler) {
  script_message_handler_ = handler;
}

void UserContentController::registerScriptMessageHandler(const std::string& name) {
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
  g_signal_connect(content_manager_, signalName.c_str(), G_CALLBACK(onScriptMessageReceived), this);

  // Register the handler with WebKit (WPE API since 2.40)
  gboolean success = webkit_user_content_manager_register_script_message_handler(
      content_manager_, name.c_str(), nullptr);

  if (!success) {
    errorLog("UserContentController: Failed to register message handler " + name);
    return;
  }

  registered_message_handlers_.push_back(name);
}

void UserContentController::setScriptMessageWithReplyHandler(const std::string& name,
                                                             ScriptMessageWithReplyHandler handler) {
  script_message_with_reply_handlers_[name] = handler;
}

void UserContentController::registerScriptMessageHandlerWithReply(const std::string& name) {
  if (content_manager_ == nullptr) {
    return;
  }

  // Check if already registered
  for (const auto& existing : registered_message_handlers_with_reply_) {
    if (existing == name) {
      return;
    }
  }

  // Build the signal name: "script-message-with-reply-received::<name>"
  std::string signalName = "script-message-with-reply-received::" + name;

  // Connect the signal
  g_signal_connect(content_manager_, signalName.c_str(),
                   G_CALLBACK(onScriptMessageWithReplyReceived), this);

  // Register the handler with WebKit's with_reply API (WPE API since 2.40)
  gboolean success = webkit_user_content_manager_register_script_message_handler_with_reply(
      content_manager_, name.c_str(), nullptr);

  if (!success) {
    errorLog("UserContentController: Failed to register message handler with reply: " + name);
    return;
  }

  registered_message_handlers_with_reply_.push_back(name);
}

void UserContentController::addPluginScript(std::unique_ptr<PluginScript> pluginScript) {
  if (pluginScript == nullptr || content_manager_ == nullptr) {
    return;
  }

  // Register any message handlers required by this script using with_reply API
  // The with_reply API allows proper Promise resolution in iframes
  for (const auto& handlerName : pluginScript->messageHandlerNames) {
    registerScriptMessageHandlerWithReply(handlerName);
  }

  // Create a UserScript from the PluginScript
  // Constructor: groupName, source, injectionTime, forMainFrameOnly, allowedOriginRules,
  // contentWorld
  auto userScript = std::make_shared<UserScript>(
      pluginScript->groupName, pluginScript->source, pluginScript->injectionTime,
      pluginScript->forMainFrameOnly, pluginScript->allowedOriginRules,
      nullptr  // contentWorld
  );

  // Add the script
  WebKitUserScript* wkScript = createWebKitUserScript(userScript);
  if (wkScript != nullptr) {
    webkit_user_content_manager_add_script(content_manager_, wkScript);
    webkit_user_script_unref(wkScript);
  }

  plugin_scripts_.push_back(std::move(pluginScript));
}

void UserContentController::onScriptMessageReceived(WebKitUserContentManager* manager,
                                                    JSCValue* value, gpointer user_data) {
  auto* self = static_cast<UserContentController*>(user_data);

  if (self == nullptr || self->script_message_handler_ == nullptr) {
    return;
  }

  if (value == nullptr) {
    return;
  }

  // Get the JSCContext from the value - this is the context of the frame that sent the message
  // (for iframe support). Must be extracted before any scope issues.
  JSCContext* jscContext = jsc_value_get_context(value);

  // Convert JSC value to string (JSON)
  gchar* jsonStr = nullptr;

  if (jsc_value_is_object(value)) {
    // Get the context and use JSON.stringify
    if (jscContext != nullptr) {
      // Evaluate JSON.stringify(value) properly
      // First, create a reference to the value in a global variable
      jsc_context_set_value(jscContext, "__inappwebview_temp_value", value);

      // Then stringify it
      JSCValue* jsonResult =
          jsc_context_evaluate(jscContext, "JSON.stringify(__inappwebview_temp_value)", -1);

      if (jsonResult != nullptr && jsc_value_is_string(jsonResult)) {
        jsonStr = jsc_value_to_string(jsonResult);
      }

      // Clean up
      if (jsonResult != nullptr) {
        g_object_unref(jsonResult);
      }

      // Remove the temp variable (ignore result)
      JSCValue* deleteResult =
          jsc_context_evaluate(jscContext, "delete __inappwebview_temp_value", -1);
      if (deleteResult != nullptr) {
        g_object_unref(deleteResult);
      }
    }
  } else if (jsc_value_is_string(value)) {
    jsonStr = jsc_value_to_string(value);
  }

  if (jsonStr != nullptr) {
    // The handler name is extracted from the signal name by WebKit,
    // but for our purposes we need to get it from the message body
    // Pass the JSCContext so internal handlers can resolve Promises in the correct frame (iframe support)
    self->script_message_handler_("callHandler", std::string(jsonStr), jscContext);
    g_free(jsonStr);
  }
}

WebKitUserScript* UserContentController::createWebKitUserScript(
    const std::shared_ptr<UserScript>& userScript) const {
  if (userScript == nullptr) {
    return nullptr;
  }

  WebKitUserScriptInjectionTime webkitTime =
      userScript->injectionTime == UserScriptInjectionTime::atDocumentStart
          ? WEBKIT_USER_SCRIPT_INJECT_AT_DOCUMENT_START
          : WEBKIT_USER_SCRIPT_INJECT_AT_DOCUMENT_END;

  WebKitUserContentInjectedFrames frames = userScript->forMainFrameOnly
                                               ? WEBKIT_USER_CONTENT_INJECT_TOP_FRAME
                                               : WEBKIT_USER_CONTENT_INJECT_ALL_FRAMES;

  return webkit_user_script_new(userScript->source.c_str(), frames, webkitTime,
                                nullptr,  // allow_list
                                nullptr   // block_list
  );
}

void UserContentController::rebuildScripts() {
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

    WebKitUserContentInjectedFrames frames = pluginScript->forMainFrameOnly
                                                 ? WEBKIT_USER_CONTENT_INJECT_TOP_FRAME
                                                 : WEBKIT_USER_CONTENT_INJECT_ALL_FRAMES;

    WebKitUserScript* wkScript =
        webkit_user_script_new(pluginScript->source.c_str(), frames, webkitTime,
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

gboolean UserContentController::onScriptMessageWithReplyReceived(
    WebKitUserContentManager* manager,
    JSCValue* value,
    WebKitScriptMessageReply* reply,
    gpointer user_data) {
  auto* self = static_cast<UserContentController*>(user_data);

  if (self == nullptr) {
    return FALSE;
  }

  if (value == nullptr || reply == nullptr) {
    return FALSE;
  }

  // Convert JSC value to JSON string
  gchar* jsonStr = nullptr;
  JSCContext* jscContext = jsc_value_get_context(value);

  if (jsc_value_is_object(value)) {
    if (jscContext != nullptr) {
      jsc_context_set_value(jscContext, "__inappwebview_temp_value", value);
      JSCValue* jsonResult =
          jsc_context_evaluate(jscContext, "JSON.stringify(__inappwebview_temp_value)", -1);
      if (jsonResult != nullptr && jsc_value_is_string(jsonResult)) {
        jsonStr = jsc_value_to_string(jsonResult);
      }
      if (jsonResult != nullptr) {
        g_object_unref(jsonResult);
      }
      JSCValue* deleteResult =
          jsc_context_evaluate(jscContext, "delete __inappwebview_temp_value", -1);
      if (deleteResult != nullptr) {
        g_object_unref(deleteResult);
      }
    }
  } else if (jsc_value_is_string(value)) {
    jsonStr = jsc_value_to_string(value);
  }

  if (jsonStr == nullptr) {
    return FALSE;
  }

  std::string jsonBody(jsonStr);
  g_free(jsonStr);

  // The signal detail contains the WebKit handler name (e.g., "callHandler")
  // We need to try all registered handlers since we can't easily extract the detail
  // The "callHandler" handler is the main one that handles all JavaScript bridge calls
  
  // First try to find the handler using the handlerName from the JSON body
  // This is for backwards compatibility with handlers that use different names
  try {
    json body = json::parse(jsonBody);
    if (body.contains("handlerName") && body["handlerName"].is_string()) {
      std::string handlerName = body["handlerName"].get<std::string>();
      
      auto it = self->script_message_with_reply_handlers_.find(handlerName);
      if (it != self->script_message_with_reply_handlers_.end()) {
        bool handled = it->second(jsonBody, reply);
        return handled ? TRUE : FALSE;
      }
    }
  } catch (const std::exception& e) {
    // Ignore parse errors, try fallback
  }
  
  // Fallback: If "callHandler" is registered, use it as the main handler
  // This is the primary path for the JavaScript bridge
  auto callHandlerIt = self->script_message_with_reply_handlers_.find("callHandler");
  if (callHandlerIt != self->script_message_with_reply_handlers_.end()) {
    bool handled = callHandlerIt->second(jsonBody, reply);
    return handled ? TRUE : FALSE;
  }

  errorLog("UserContentController: No handler found for with_reply message");
  return FALSE;
}

}  // namespace flutter_inappwebview_plugin
