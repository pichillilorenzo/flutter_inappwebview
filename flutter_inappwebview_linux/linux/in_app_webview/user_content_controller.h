#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_USER_CONTENT_CONTROLLER_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_USER_CONTENT_CONTROLLER_H_

// Use the appropriate WebKit header based on backend
#ifdef USE_WPE_WEBKIT
#include <wpe/webkit.h>
#else
#include <webkit2/webkit2.h>
#endif

#include <functional>
#include <map>
#include <memory>
#include <string>
#include <vector>

#include "../types/content_world.h"
#include "../types/plugin_script.h"
#include "../types/user_script.h"

namespace flutter_inappwebview_plugin {

class InAppWebView;

/**
 * Manages user scripts and plugin scripts for a WebKitWebView.
 * This is analogous to WKUserContentController in WKWebView.
 */
class UserContentController {
 public:
  using ScriptMessageHandler = std::function<void(const std::string& name,
                                                   const std::string& body)>;

  explicit UserContentController(InAppWebView* webView);
  ~UserContentController();

  /**
   * Initialize the user content controller.
   * Call this after the WebKitWebView is created.
   */
  void initialize();

  /**
   * Set the callback for script messages.
   */
  void setScriptMessageHandler(ScriptMessageHandler handler);

  /**
   * Add a user script.
   */
  void addUserScript(std::shared_ptr<UserScript> userScript);

  /**
   * Add multiple user scripts.
   */
  void addUserScripts(const std::vector<std::shared_ptr<UserScript>>& userScripts);

  /**
   * Add a plugin script.
   */
  void addPluginScript(std::shared_ptr<PluginScript> pluginScript);

  /**
   * Remove a user script by index and injection time.
   */
  void removeUserScriptAt(size_t index, UserScriptInjectionTime injectionTime);

  /**
   * Remove all user scripts with a specific group name.
   */
  void removeUserScriptsByGroupName(const std::string& groupName);

  /**
   * Remove all user scripts.
   */
  void removeAllUserScripts();

  /**
   * Get all user scripts at a specific injection time.
   */
  std::vector<std::shared_ptr<UserScript>> getUserScriptsAt(
      UserScriptInjectionTime injectionTime) const;

  /**
   * Inject all pending scripts into the web view.
   * Called internally when page loading starts.
   */
  void injectScriptsAtDocumentStart();

  /**
   * Inject end scripts.
   * Called internally when page loading finishes.
   */
  void injectScriptsAtDocumentEnd();

  /**
   * Register a script message handler with WebKit.
   */
  void registerScriptMessageHandler(const std::string& name);

  /**
   * Unregister a script message handler.
   */
  void unregisterScriptMessageHandler(const std::string& name);

  /**
   * Get the WebKit user content manager.
   */
  WebKitUserContentManager* getWebKitUserContentManager() const;

 private:
  InAppWebView* webView_;
  WebKitUserContentManager* userContentManager_ = nullptr;

  // User scripts (from Dart)
  std::vector<std::shared_ptr<UserScript>> userScriptsAtDocumentStart_;
  std::vector<std::shared_ptr<UserScript>> userScriptsAtDocumentEnd_;

  // Plugin scripts (internal)
  std::vector<std::shared_ptr<PluginScript>> pluginScriptsAtDocumentStart_;
  std::vector<std::shared_ptr<PluginScript>> pluginScriptsAtDocumentEnd_;

  // Registered message handler names
  std::vector<std::string> registeredMessageHandlers_;

  // Script message callback
  ScriptMessageHandler scriptMessageHandler_;

  // Signal handler ID for script-message-received
  gulong scriptMessageSignalId_ = 0;

  // WebKit callback for script messages
  static void onScriptMessageReceived(WebKitUserContentManager* manager,
                                       WebKitJavascriptResult* result,
                                       gpointer user_data);

  // Helper to inject a script
  void injectScript(const std::string& source, 
                    UserScriptInjectionTime injectionTime,
                    bool forMainFrameOnly);
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_USER_CONTENT_CONTROLLER_H_
