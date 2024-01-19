#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_USER_CONTENT_CONTROLLER_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_USER_CONTENT_CONTROLLER_H_

#include <map>
#include <vector>

#include "../plugin_scripts_js/javascript_bridge_js.h"
#include "../plugin_scripts_js/plugin_scripts_util.h"
#include "../types/plugin_script.h"
#include "../types/user_script.h"

namespace flutter_inappwebview_plugin
{
  class InAppWebView;

  const std::string USER_SCRIPTS_AT_DOCUMENT_END_WRAPPER_JS_SOURCE =
    "if (window." + JAVASCRIPT_BRIDGE_NAME + " != null && (window." + JAVASCRIPT_BRIDGE_NAME + "._userScriptsAtDocumentEndLoaded == null || !window." + JAVASCRIPT_BRIDGE_NAME + "._userScriptsAtDocumentEndLoaded)) { \
      window." + JAVASCRIPT_BRIDGE_NAME + "._userScriptsAtDocumentEndLoaded = true; \
      " + VAR_PLACEHOLDER_VALUE + " \
    }";

  class UserContentController
  {
  public:
    UserContentController(InAppWebView* webView);
    ~UserContentController();

    std::vector<std::shared_ptr<UserScript>> getUserOnlyScriptsAt(const UserScriptInjectionTime& injectionTime) const;
    void addUserOnlyScript(std::shared_ptr<UserScript> userScript);
    void addUserOnlyScripts(std::vector<std::shared_ptr<UserScript>> userScripts);
    void removeUserOnlyScript(std::shared_ptr<UserScript> userScript);
    void removeUserOnlyScriptAt(const int64_t& index, const UserScriptInjectionTime& injectionTime);
    void removeAllUserOnlyScripts();
    bool containsUserOnlyScript(std::shared_ptr<UserScript> userScript) const;
    bool containsUserOnlyScriptByGroupName(const std::string& groupName) const;
    void removeUserOnlyScriptsByGroupName(const std::string& groupName);
    std::vector<std::shared_ptr<PluginScript>> getPluginScriptsAt(const UserScriptInjectionTime& injectionTime) const;
    void addPluginScript(std::shared_ptr<PluginScript> pluginScript);
    void addPluginScripts(std::vector<std::shared_ptr<PluginScript>> pluginScripts);
    void removePluginScript(std::shared_ptr<PluginScript> pluginScript);
    void removeAllPluginScripts();
    bool containsPluginScript(std::shared_ptr<PluginScript> pluginScript) const;
    bool containsPluginScriptByGroupName(const std::string& groupName) const;
    void removePluginScriptsByGroupName(const std::string& groupName);
    std::string generatePluginScriptsCodeAt(const UserScriptInjectionTime& injectionTime) const;
    std::string generateUserOnlyScriptsCodeAt(const UserScriptInjectionTime& injectionTime) const;
    std::string generateWrappedCodeForDocumentEnd() const;
  private:
    InAppWebView* webView_;

    std::map<UserScriptInjectionTime, std::vector<std::shared_ptr<PluginScript>>> pluginScripts_ = {
      {UserScriptInjectionTime::atDocumentStart, {}},
      {UserScriptInjectionTime::atDocumentEnd, {}}
    };

    std::map<UserScriptInjectionTime, std::vector<std::shared_ptr<UserScript>>> userOnlyScripts_ = {
      {UserScriptInjectionTime::atDocumentStart, {}},
      {UserScriptInjectionTime::atDocumentEnd, {}}
    };
  };
}
#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_USER_CONTENT_CONTROLLER_H_