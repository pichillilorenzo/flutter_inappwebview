// WPE WebKit User Content Controller implementation
// 
// The WPE WebKit API for user content management is identical to WebKitGTK,
// so this implementation follows the same patterns.

#include "user_content_controller_wpe.h"

#ifdef USE_WPE_WEBKIT

#include <algorithm>

#include "../utils/log.h"

namespace flutter_inappwebview_plugin {

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
  
  // Clear all scripts when destroyed
  if (content_manager_ != nullptr) {
    webkit_user_content_manager_remove_all_scripts(content_manager_);
  }
  
  document_start_scripts_.clear();
  document_end_scripts_.clear();
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
    webkit_user_content_manager_remove_all_scripts(content_manager_);
  }

  if (DebugLogEnabled()) {
    g_message("UserContentControllerWpe: removed all user scripts");
  }
}

const std::vector<std::shared_ptr<UserScript>>& 
UserContentControllerWpe::getUserScripts(UserScriptInjectionTime injectionTime) const {
  if (injectionTime == UserScriptInjectionTime::atDocumentStart) {
    return document_start_scripts_;
  }
  return document_end_scripts_;
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

  // Re-add all scripts
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
