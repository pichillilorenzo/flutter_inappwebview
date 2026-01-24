#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_USER_CONTENT_CONTROLLER_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_USER_CONTENT_CONTROLLER_H_

// WPE WebKit User Content Controller
//
// Manages user scripts and plugin scripts for a WebKitWebView.
// This is analogous to WKUserContentController in WKWebView.

#include <wpe/webkit.h>

#include <functional>
#include <map>
#include <memory>
#include <string>
#include <vector>

#include "../types/plugin_script.h"
#include "../types/user_script.h"

#include <jsc/jsc.h>

namespace flutter_inappwebview_plugin {

// Script message handler callback type
// Third parameter is the JSCContext* of the frame that sent the message (for iframe support)
using ScriptMessageHandler = std::function<void(const std::string&, const std::string&, JSCContext*)>;

// Script message handler with reply callback type
// Receives the message body (JSON string) and a WebKitScriptMessageReply* for async reply
// The reply object must be ref'd if the callback wants to respond asynchronously
// Returns true if the message was handled and reply is pending (async), false for sync handling
using ScriptMessageWithReplyHandler = std::function<bool(const std::string&, WebKitScriptMessageReply*)>;

class UserContentController {
 public:
  explicit UserContentController(WebKitWebView* webview);
  ~UserContentController();

  // User script management
  void addUserScript(std::shared_ptr<UserScript> userScript);
  void removeUserScriptAt(size_t index, UserScriptInjectionTime injectionTime);
  void removeUserScriptsByGroupName(const std::string& groupName);
  void removeAllUserScripts();

  // Plugin script management (for internal scripts like JS bridge)
  void addPluginScript(std::unique_ptr<PluginScript> pluginScript);

  // Script message handler (standard - no reply capability)
  void setScriptMessageHandler(ScriptMessageHandler handler);
  void registerScriptMessageHandler(const std::string& name);
  
  // Script message handler with reply (for async responses to JavaScript)
  // Used by color/date pickers to respond to the exact frame that sent the message
  void setScriptMessageWithReplyHandler(const std::string& name, ScriptMessageWithReplyHandler handler);
  void registerScriptMessageHandlerWithReply(const std::string& name);

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
  std::vector<std::string> registered_message_handlers_with_reply_;

  ScriptMessageHandler script_message_handler_;
  std::map<std::string, ScriptMessageWithReplyHandler> script_message_with_reply_handlers_;

  // Helper to convert UserScript to WebKitUserScript
  WebKitUserScript* createWebKitUserScript(const std::shared_ptr<UserScript>& userScript) const;

  // Rebuild all scripts (called after add/remove)
  void rebuildScripts();

  // Static callback for script message received signal
  static void onScriptMessageReceived(WebKitUserContentManager* manager, JSCValue* value,
                                      gpointer user_data);
  
  // Static callback for script message with reply received signal
  static gboolean onScriptMessageWithReplyReceived(WebKitUserContentManager* manager,
                                                   JSCValue* value,
                                                   WebKitScriptMessageReply* reply,
                                                   gpointer user_data);
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_USER_CONTENT_CONTROLLER_H_
