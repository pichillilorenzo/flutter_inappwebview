#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_USER_CONTENT_CONTROLLER_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_USER_CONTENT_CONTROLLER_H_

#include <map>
#include <vector>

#include "../types/plugin_script.h"
#include "../types/user_script.h"

namespace flutter_inappwebview_plugin
{
  class InAppWebView;

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
    std::vector<std::shared_ptr<PluginScript>> getPluginScriptsAt(const UserScriptInjectionTime& injectionTime) const;
    void addPluginScript(std::shared_ptr<PluginScript> pluginScript);
    void addPluginScripts(std::vector<std::shared_ptr<PluginScript>> pluginScripts);
    void removePluginScript(std::shared_ptr<PluginScript> pluginScript);
    void removeAllPluginScripts();
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