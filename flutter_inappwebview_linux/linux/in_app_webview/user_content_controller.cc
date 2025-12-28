#include "user_content_controller.h"

#include <jsc/jsc.h>

#include "../plugin_scripts_js/javascript_bridge_js.h"
#include "../utils/log.h"
#include "in_app_webview.h"

namespace flutter_inappwebview_plugin {

namespace {
bool DebugLogEnabled() {
  static bool enabled = g_getenv("FLUTTER_INAPPWEBVIEW_LINUX_DEBUG") != nullptr;
  return enabled;
}
}  // namespace

UserContentController::UserContentController(InAppWebView* webView)
    : webView_(webView) {}

UserContentController::~UserContentController() {
  // Disconnect signal handlers
  if (userContentManager_ != nullptr && scriptMessageSignalId_ != 0) {
    g_signal_handler_disconnect(userContentManager_, scriptMessageSignalId_);
    scriptMessageSignalId_ = 0;
  }
  
  // Unregister all message handlers
  for (const auto& name : registeredMessageHandlers_) {
    if (userContentManager_ != nullptr) {
      webkit_user_content_manager_unregister_script_message_handler(
          userContentManager_, name.c_str());
    }
  }
  registeredMessageHandlers_.clear();
}

void UserContentController::initialize() {
  if (webView_ == nullptr || webView_->webview() == nullptr) {
    return;
  }

  userContentManager_ = webkit_web_view_get_user_content_manager(webView_->webview());
  if (userContentManager_ == nullptr) {
    g_warning("UserContentController: Failed to get user content manager");
    return;
  }

  if (DebugLogEnabled()) {
    g_message("UserContentController: initialized");
  }
}

void UserContentController::setScriptMessageHandler(ScriptMessageHandler handler) {
  scriptMessageHandler_ = handler;
}

void UserContentController::registerScriptMessageHandler(const std::string& name) {
  if (userContentManager_ == nullptr) {
    return;
  }

  // Check if already registered
  for (const auto& existing : registeredMessageHandlers_) {
    if (existing == name) {
      return;
    }
  }

  // Build the signal name: "script-message-received::<name>"
  std::string signalName = "script-message-received::" + name;

  // Connect the signal
  gulong signalId = g_signal_connect(
      userContentManager_,
      signalName.c_str(),
      G_CALLBACK(onScriptMessageReceived),
      this);

  if (signalId == 0) {
    g_warning("UserContentController: Failed to connect signal for %s", name.c_str());
    return;
  }

  // Register the handler with WebKit
  gboolean success = webkit_user_content_manager_register_script_message_handler(
      userContentManager_, name.c_str());

  if (!success) {
    g_warning("UserContentController: Failed to register message handler %s", name.c_str());
    g_signal_handler_disconnect(userContentManager_, signalId);
    return;
  }

  registeredMessageHandlers_.push_back(name);

  if (DebugLogEnabled()) {
    g_message("UserContentController: registered message handler '%s'", name.c_str());
  }
}

void UserContentController::unregisterScriptMessageHandler(const std::string& name) {
  if (userContentManager_ == nullptr) {
    return;
  }

  auto it = std::find(registeredMessageHandlers_.begin(),
                      registeredMessageHandlers_.end(), name);
  if (it != registeredMessageHandlers_.end()) {
    webkit_user_content_manager_unregister_script_message_handler(
        userContentManager_, name.c_str());
    registeredMessageHandlers_.erase(it);
  }
}

void UserContentController::onScriptMessageReceived(
    WebKitUserContentManager* manager,
    WebKitJavascriptResult* result,
    gpointer user_data) {
  auto* self = static_cast<UserContentController*>(user_data);
  if (self == nullptr || self->scriptMessageHandler_ == nullptr) {
    return;
  }

  JSCValue* jsValue = webkit_javascript_result_get_js_value(result);
  if (jsValue == nullptr) {
    return;
  }

  // Convert JSC value to string (JSON)
  gchar* jsonStr = nullptr;
  if (jsc_value_is_object(jsValue)) {
    JSCContext* context = jsc_value_get_context(jsValue);
    JSCValue* jsonStringify = jsc_context_evaluate(context, "JSON.stringify", -1);
    JSCValue* jsonResult = jsc_value_function_call(jsonStringify, G_TYPE_POINTER, jsValue, G_TYPE_NONE);
    if (jsc_value_is_string(jsonResult)) {
      jsonStr = jsc_value_to_string(jsonResult);
    }
    g_object_unref(jsonResult);
    g_object_unref(jsonStringify);
  } else if (jsc_value_is_string(jsValue)) {
    jsonStr = jsc_value_to_string(jsValue);
  }

  if (jsonStr != nullptr) {
    // The handler name is extracted from the signal name by WebKit,
    // but for our purposes we need to get it from the message body
    self->scriptMessageHandler_("callHandler", std::string(jsonStr));
    g_free(jsonStr);
  }
}

void UserContentController::addUserScript(std::shared_ptr<UserScript> userScript) {
  if (userScript == nullptr) {
    return;
  }

  if (userScript->injectionTime == UserScriptInjectionTime::atDocumentStart) {
    userScriptsAtDocumentStart_.push_back(userScript);
  } else {
    userScriptsAtDocumentEnd_.push_back(userScript);
  }

  // Also add to WebKit immediately if we have a content manager
  if (userContentManager_ != nullptr) {
    WebKitUserScriptInjectionTime webkitTime =
        userScript->injectionTime == UserScriptInjectionTime::atDocumentStart
            ? WEBKIT_USER_SCRIPT_INJECT_AT_DOCUMENT_START
            : WEBKIT_USER_SCRIPT_INJECT_AT_DOCUMENT_END;

    WebKitUserScript* wkScript = webkit_user_script_new(
        userScript->source.c_str(),
        userScript->forMainFrameOnly ? WEBKIT_USER_CONTENT_INJECT_TOP_FRAME
                                     : WEBKIT_USER_CONTENT_INJECT_ALL_FRAMES,
        webkitTime,
        nullptr,  // allow_list
        nullptr   // block_list
    );

    webkit_user_content_manager_add_script(userContentManager_, wkScript);
    webkit_user_script_unref(wkScript);
  }
}

void UserContentController::addUserScripts(
    const std::vector<std::shared_ptr<UserScript>>& userScripts) {
  for (const auto& script : userScripts) {
    addUserScript(script);
  }
}

void UserContentController::addPluginScript(std::shared_ptr<PluginScript> pluginScript) {
  if (pluginScript == nullptr) {
    return;
  }

  if (pluginScript->injectionTime == UserScriptInjectionTime::atDocumentStart) {
    pluginScriptsAtDocumentStart_.push_back(pluginScript);
  } else {
    pluginScriptsAtDocumentEnd_.push_back(pluginScript);
  }

  // Register message handlers
  for (const auto& handlerName : pluginScript->messageHandlerNames) {
    registerScriptMessageHandler(handlerName);
  }

  // Add to WebKit
  if (userContentManager_ != nullptr) {
    WebKitUserScriptInjectionTime webkitTime =
        pluginScript->injectionTime == UserScriptInjectionTime::atDocumentStart
            ? WEBKIT_USER_SCRIPT_INJECT_AT_DOCUMENT_START
            : WEBKIT_USER_SCRIPT_INJECT_AT_DOCUMENT_END;

    WebKitUserScript* wkScript = webkit_user_script_new(
        pluginScript->source.c_str(),
        pluginScript->forMainFrameOnly ? WEBKIT_USER_CONTENT_INJECT_TOP_FRAME
                                       : WEBKIT_USER_CONTENT_INJECT_ALL_FRAMES,
        webkitTime,
        nullptr,
        nullptr);

    webkit_user_content_manager_add_script(userContentManager_, wkScript);
    webkit_user_script_unref(wkScript);
  }
}

void UserContentController::removeUserScriptAt(size_t index,
                                                UserScriptInjectionTime injectionTime) {
  auto& scripts = injectionTime == UserScriptInjectionTime::atDocumentStart
                      ? userScriptsAtDocumentStart_
                      : userScriptsAtDocumentEnd_;

  if (index < scripts.size()) {
    scripts.erase(scripts.begin() + index);
    // Note: WebKitUserContentManager doesn't support removing individual scripts,
    // so we would need to remove all and re-add them
  }
}

void UserContentController::removeUserScriptsByGroupName(const std::string& groupName) {
  auto removeFromVector = [&groupName](std::vector<std::shared_ptr<UserScript>>& scripts) {
    scripts.erase(
        std::remove_if(scripts.begin(), scripts.end(),
                       [&groupName](const std::shared_ptr<UserScript>& script) {
                         return script->groupName.has_value() &&
                                script->groupName.value() == groupName;
                       }),
        scripts.end());
  };

  removeFromVector(userScriptsAtDocumentStart_);
  removeFromVector(userScriptsAtDocumentEnd_);
}

void UserContentController::removeAllUserScripts() {
  userScriptsAtDocumentStart_.clear();
  userScriptsAtDocumentEnd_.clear();

  // Remove all scripts from WebKit (this also removes plugin scripts)
  if (userContentManager_ != nullptr) {
    webkit_user_content_manager_remove_all_scripts(userContentManager_);
    // Re-add plugin scripts
    for (const auto& script : pluginScriptsAtDocumentStart_) {
      WebKitUserScript* wkScript = webkit_user_script_new(
          script->source.c_str(),
          script->forMainFrameOnly ? WEBKIT_USER_CONTENT_INJECT_TOP_FRAME
                                   : WEBKIT_USER_CONTENT_INJECT_ALL_FRAMES,
          WEBKIT_USER_SCRIPT_INJECT_AT_DOCUMENT_START,
          nullptr, nullptr);
      webkit_user_content_manager_add_script(userContentManager_, wkScript);
      webkit_user_script_unref(wkScript);
    }
    for (const auto& script : pluginScriptsAtDocumentEnd_) {
      WebKitUserScript* wkScript = webkit_user_script_new(
          script->source.c_str(),
          script->forMainFrameOnly ? WEBKIT_USER_CONTENT_INJECT_TOP_FRAME
                                   : WEBKIT_USER_CONTENT_INJECT_ALL_FRAMES,
          WEBKIT_USER_SCRIPT_INJECT_AT_DOCUMENT_END,
          nullptr, nullptr);
      webkit_user_content_manager_add_script(userContentManager_, wkScript);
      webkit_user_script_unref(wkScript);
    }
  }
}

std::vector<std::shared_ptr<UserScript>> UserContentController::getUserScriptsAt(
    UserScriptInjectionTime injectionTime) const {
  if (injectionTime == UserScriptInjectionTime::atDocumentStart) {
    return userScriptsAtDocumentStart_;
  }
  return userScriptsAtDocumentEnd_;
}

void UserContentController::injectScriptsAtDocumentStart() {
  // Scripts are already added to WebKit via addUserScript/addPluginScript
  // This method is kept for API compatibility and could be used for
  // dynamic script injection if needed
}

void UserContentController::injectScriptsAtDocumentEnd() {
  // Scripts are already added to WebKit
}

void UserContentController::injectScript(const std::string& source,
                                          UserScriptInjectionTime injectionTime,
                                          bool forMainFrameOnly) {
  if (webView_ == nullptr || webView_->webview() == nullptr) {
    return;
  }

  // For immediate injection, use evaluateJavaScript
  webView_->evaluateJavascript(source, nullptr);
}

WebKitUserContentManager* UserContentController::getWebKitUserContentManager() const {
  return userContentManager_;
}

}  // namespace flutter_inappwebview_plugin
