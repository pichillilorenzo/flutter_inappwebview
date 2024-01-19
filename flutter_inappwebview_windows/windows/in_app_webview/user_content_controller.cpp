#include <wil/wrl.h>

#include "../utils/log.h"
#include "../utils/string.h"
#include "../utils/vector.h"
#include "in_app_webview.h"
#include "user_content_controller.h"

namespace flutter_inappwebview_plugin
{
  using namespace Microsoft::WRL;

  UserContentController::UserContentController(InAppWebView* webView)
    : webView_(webView)
  {}

  std::vector<std::shared_ptr<UserScript>> UserContentController::getUserOnlyScriptsAt(const UserScriptInjectionTime& injectionTime) const
  {
    return userOnlyScripts_.at(injectionTime);
  }

  void UserContentController::addUserOnlyScript(std::shared_ptr<UserScript> userScript)
  {
    if (!userScript) {
      return;
    }

    if (userScript->injectionTime == UserScriptInjectionTime::atDocumentStart && webView_) {
      failedLog(webView_->webView->AddScriptToExecuteOnDocumentCreated(ansi_to_wide(userScript->source).c_str(),
        Callback<ICoreWebView2AddScriptToExecuteOnDocumentCreatedCompletedHandler>(
          [userScript](HRESULT error, PCWSTR id) -> HRESULT
          {
            if (succeededOrLog(error)) {
              userScript->id = id;
            }
            return S_OK;
          }).Get()));
    }

    userOnlyScripts_.at(userScript->injectionTime).push_back(std::move(userScript));
  }

  void UserContentController::addUserOnlyScripts(std::vector<std::shared_ptr<UserScript>> userScripts)
  {
    for (auto& userScript : userScripts) {
      addUserOnlyScript(std::move(userScript));
    }
  }

  void UserContentController::removeUserOnlyScript(std::shared_ptr<UserScript> userScript)
  {
    if (!userScript) {
      return;
    }

    if (webView_) {
      failedLog(webView_->webView->RemoveScriptToExecuteOnDocumentCreated(userScript->id.c_str()));
    }

    vector_remove_erase(userOnlyScripts_.at(userScript->injectionTime), std::move(userScript));
  }

  void UserContentController::removeUserOnlyScriptAt(const int64_t& index, const UserScriptInjectionTime& injectionTime)
  {
    auto& vec = userOnlyScripts_.at(injectionTime);
    int64_t size = vec.size();
    if (index >= size) {
      return;
    }

    auto& userScript = vec.at(index);
    if (userScript) {
      if (webView_) {
        failedLog(webView_->webView->RemoveScriptToExecuteOnDocumentCreated(userScript->id.c_str()));
      }
      vec.erase(vec.begin() + index);
    }
  }

  void UserContentController::removeAllUserOnlyScripts()
  {
    auto& userScriptsAtStart = userOnlyScripts_.at(UserScriptInjectionTime::atDocumentStart);
    auto& userScriptsAtEnd = userOnlyScripts_.at(UserScriptInjectionTime::atDocumentEnd);

    if (webView_) {
      for (auto& userScript : userScriptsAtStart) {
        failedLog(webView_->webView->RemoveScriptToExecuteOnDocumentCreated(userScript->id.c_str()));
      }
      for (auto& userScript : userScriptsAtEnd) {
        failedLog(webView_->webView->RemoveScriptToExecuteOnDocumentCreated(userScript->id.c_str()));
      }
    }

    userScriptsAtStart.clear();
    userScriptsAtEnd.clear();
  }

  void UserContentController::removeUserOnlyScriptsByGroupName(const std::string& groupName)
  {
    std::vector<std::shared_ptr<UserScript>> userScriptsAtStart = userOnlyScripts_.at(UserScriptInjectionTime::atDocumentStart);
    std::vector<std::shared_ptr<UserScript>> userScriptsAtEnd = userOnlyScripts_.at(UserScriptInjectionTime::atDocumentEnd);

    for (auto& userScript : userScriptsAtStart) {
      if (string_equals(groupName, userScript->groupName)) {
        removeUserOnlyScript(userScript);
      }
    }

    for (auto& userScript : userScriptsAtEnd) {
      if (string_equals(groupName, userScript->groupName)) {
        removeUserOnlyScript(userScript);
      }
    }
  }

  std::vector<std::shared_ptr<PluginScript>> UserContentController::getPluginScriptsAt(const UserScriptInjectionTime& injectionTime) const
  {
    return pluginScripts_.at(injectionTime);
  }

  bool UserContentController::containsUserOnlyScript(std::shared_ptr<UserScript> userScript) const
  {
    if (!userScript) {
      return false;
    }

    return vector_contains(userOnlyScripts_.at(userScript->injectionTime), std::move(userScript));
  }

  bool UserContentController::containsUserOnlyScriptByGroupName(const std::string& groupName) const
  {
    return vector_contains_if(userOnlyScripts_.at(UserScriptInjectionTime::atDocumentStart), [groupName](const std::shared_ptr<UserScript> userScript) { return string_equals(groupName, userScript->groupName); }) ||
      vector_contains_if(userOnlyScripts_.at(UserScriptInjectionTime::atDocumentEnd), [groupName](const std::shared_ptr<UserScript> userScript) { return string_equals(groupName, userScript->groupName); });
  }

  void UserContentController::addPluginScript(std::shared_ptr<PluginScript> pluginScript)
  {
    if (!pluginScript) {
      return;
    }

    if (pluginScript->injectionTime == UserScriptInjectionTime::atDocumentStart && webView_) {
      failedLog(webView_->webView->AddScriptToExecuteOnDocumentCreated(ansi_to_wide(pluginScript->source).c_str(),
        Callback<ICoreWebView2AddScriptToExecuteOnDocumentCreatedCompletedHandler>(
          [pluginScript](HRESULT error, PCWSTR id) -> HRESULT
          {
            if (succeededOrLog(error)) {
              pluginScript->id = id;
            }
            return S_OK;
          }).Get()));
    }

    pluginScripts_.at(pluginScript->injectionTime).push_back(std::move(pluginScript));
  }

  void UserContentController::addPluginScripts(std::vector<std::shared_ptr<PluginScript>> pluginScripts)
  {
    for (auto& pluginScript : pluginScripts) {
      addPluginScript(std::move(pluginScript));
    }
  }

  void UserContentController::removePluginScript(std::shared_ptr<PluginScript> pluginScript)
  {
    if (!pluginScript) {
      return;
    }

    if (webView_) {
      failedLog(webView_->webView->RemoveScriptToExecuteOnDocumentCreated(pluginScript->id.c_str()));
    }

    vector_remove_erase(pluginScripts_.at(pluginScript->injectionTime), std::move(pluginScript));
  }

  void UserContentController::removeAllPluginScripts()
  {
    auto& pluginScriptsAtStart = pluginScripts_.at(UserScriptInjectionTime::atDocumentStart);
    auto& pluginScriptsAtEnd = pluginScripts_.at(UserScriptInjectionTime::atDocumentEnd);

    if (webView_) {
      for (auto& pluginScript : pluginScriptsAtStart) {
        failedLog(webView_->webView->RemoveScriptToExecuteOnDocumentCreated(pluginScript->id.c_str()));
      }
      for (auto& pluginScript : pluginScriptsAtEnd) {
        failedLog(webView_->webView->RemoveScriptToExecuteOnDocumentCreated(pluginScript->id.c_str()));
      }
    }

    pluginScriptsAtStart.clear();
    pluginScriptsAtEnd.clear();
  }

  bool UserContentController::containsPluginScript(std::shared_ptr<PluginScript> pluginScript) const
  {
    if (!pluginScript) {
      return false;
    }

    return vector_contains(pluginScripts_.at(pluginScript->injectionTime), std::move(pluginScript));
  }

  bool UserContentController::containsPluginScriptByGroupName(const std::string& groupName) const
  {
    return vector_contains_if(pluginScripts_.at(UserScriptInjectionTime::atDocumentStart), [groupName](const std::shared_ptr<PluginScript> pluginScript) { return string_equals(groupName, pluginScript->groupName); }) ||
      vector_contains_if(pluginScripts_.at(UserScriptInjectionTime::atDocumentEnd), [groupName](const std::shared_ptr<PluginScript> pluginScript) { return string_equals(groupName, pluginScript->groupName); });
  }

  void UserContentController::removePluginScriptsByGroupName(const std::string& groupName)
  {
    std::vector<std::shared_ptr<PluginScript>> pluginScriptsAtStart = pluginScripts_.at(UserScriptInjectionTime::atDocumentStart);
    std::vector<std::shared_ptr<PluginScript>> pluginScriptsAtEnd = pluginScripts_.at(UserScriptInjectionTime::atDocumentEnd);

    for (auto& pluginScript : pluginScriptsAtStart) {
      if (string_equals(groupName, pluginScript->groupName)) {
        removePluginScript(pluginScript);
      }
    }

    for (auto& pluginScript : pluginScriptsAtEnd) {
      if (string_equals(groupName, pluginScript->groupName)) {
        removePluginScript(pluginScript);
      }
    }
  }

  std::string UserContentController::generatePluginScriptsCodeAt(const UserScriptInjectionTime& injectionTime) const
  {
    std::string code;
    std::vector<std::shared_ptr<PluginScript>> pluginScripts = pluginScripts_.at(injectionTime);
    for (auto& pluginScript : pluginScripts) {
      code += ";" + pluginScript->source;
    }
    return code;
  }

  std::string UserContentController::generateUserOnlyScriptsCodeAt(const UserScriptInjectionTime& injectionTime) const
  {
    std::string code;
    std::vector<std::shared_ptr<UserScript>> userScripts = userOnlyScripts_.at(injectionTime);
    for (auto& userScript : userScripts) {
      code += ";" + userScript->source;
    }
    return code;
  }

  std::string UserContentController::generateWrappedCodeForDocumentEnd() const
  {
    std::string code = generatePluginScriptsCodeAt(UserScriptInjectionTime::atDocumentEnd);
    code += generateUserOnlyScriptsCodeAt(UserScriptInjectionTime::atDocumentEnd);
    return replace_all_copy(USER_SCRIPTS_AT_DOCUMENT_END_WRAPPER_JS_SOURCE, VAR_PLACEHOLDER_VALUE, code);
  }

  UserContentController::~UserContentController()
  {
    debugLog("dealloc UserContentController");
    removeAllUserOnlyScripts();
    removeAllPluginScripts();
    webView_ = nullptr;
  }
}
