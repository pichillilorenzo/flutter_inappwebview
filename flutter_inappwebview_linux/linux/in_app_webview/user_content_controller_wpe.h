#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_USER_CONTENT_CONTROLLER_WPE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_USER_CONTENT_CONTROLLER_WPE_H_

// WPE WebKit User Content Controller
// 
// This is a placeholder for the WPE-specific user content controller.
// The WPE WebKit API for user content management is nearly identical to
// WebKitGTK, so this can largely share code with user_content_controller.h
//
// For now, we use the same implementation as WebKitGTK.

#ifdef USE_WPE_WEBKIT

#include <wpe/webkit.h>

#include <functional>
#include <memory>
#include <string>
#include <vector>

#include "../types/user_script.h"
#include "../types/plugin_script.h"

namespace flutter_inappwebview_plugin {

// Script message handler callback type
using ScriptMessageHandler = std::function<void(const std::string&, const std::string&)>;

class UserContentControllerWpe {
 public:
  explicit UserContentControllerWpe(WebKitWebView* webview);
  ~UserContentControllerWpe();

  // User script management
  void addUserScript(std::shared_ptr<UserScript> userScript);
  void removeUserScriptAt(size_t index, UserScriptInjectionTime injectionTime);
  void removeUserScriptsByGroupName(const std::string& groupName);
  void removeAllUserScripts();

  // Plugin script management (for internal scripts like JS bridge)
  void addPluginScript(std::unique_ptr<PluginScript> pluginScript);

  // Script message handler
  void setScriptMessageHandler(ScriptMessageHandler handler);
  void registerScriptMessageHandler(const std::string& name);

  // Get all user scripts
  const std::vector<std::shared_ptr<UserScript>>& getUserScripts(
      UserScriptInjectionTime injectionTime) const;

 private:
  WebKitWebView* webview_ = nullptr;
  WebKitUserContentManager* content_manager_ = nullptr;
  
  std::vector<std::shared_ptr<UserScript>> document_start_scripts_;
  std::vector<std::shared_ptr<UserScript>> document_end_scripts_;
  std::vector<std::unique_ptr<PluginScript>> plugin_scripts_;
  std::vector<std::string> registered_message_handlers_;
  
  ScriptMessageHandler script_message_handler_;

  // Helper to convert UserScript to WebKitUserScript
  WebKitUserScript* createWebKitUserScript(
      const std::shared_ptr<UserScript>& userScript) const;
  
  // Rebuild all scripts (called after add/remove)
  void rebuildScripts();

  // Static callback for script message received signal
  static void onScriptMessageReceived(WebKitUserContentManager* manager,
                                      JSCValue* value,
                                      gpointer user_data);
};

}  // namespace flutter_inappwebview_plugin

#endif  // USE_WPE_WEBKIT

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_USER_CONTENT_CONTROLLER_WPE_H_
