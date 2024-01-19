#include <wil/wrl.h>

#include "../utils/log.h"
#include "../utils/strconv.h"
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

    vector_remove_erase_el(userOnlyScripts_.at(userScript->injectionTime), std::move(userScript));
  }

  void UserContentController::removeUserOnlyScriptAt(const int64_t& index, const UserScriptInjectionTime& injectionTime)
  {
    auto& vec = userOnlyScripts_.at(injectionTime);
    int64_t size = vec.size();
    if (index >= size) {
      return;
    }

    vec.erase(vec.begin() + index);
  }

  void UserContentController::removeAllUserOnlyScripts()
  {
    userOnlyScripts_.at(UserScriptInjectionTime::atDocumentStart).clear();
    userOnlyScripts_.at(UserScriptInjectionTime::atDocumentEnd).clear();
  }

  std::vector<std::shared_ptr<PluginScript>> UserContentController::getPluginScriptsAt(const UserScriptInjectionTime& injectionTime) const
  {
    return pluginScripts_.at(injectionTime);
  }

  void UserContentController::addPluginScript(std::shared_ptr<PluginScript> pluginScript)
  {
    if (!pluginScript || !webView_) {
      return;
    }

    if (pluginScript->injectionTime == UserScriptInjectionTime::atDocumentStart) {
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
    if (!pluginScript || !webView_) {
      return;
    }

    failedLog(webView_->webView->RemoveScriptToExecuteOnDocumentCreated(pluginScript->id.c_str()));

    vector_remove_erase_el(pluginScripts_.at(pluginScript->injectionTime), std::move(pluginScript));
  }

  void UserContentController::removeAllPluginScripts()
  {
    pluginScripts_.at(UserScriptInjectionTime::atDocumentStart).clear();
    pluginScripts_.at(UserScriptInjectionTime::atDocumentEnd).clear();
  }

  UserContentController::~UserContentController()
  {
    debugLog("dealloc UserContentController");
    removeAllUserOnlyScripts();
    removeAllPluginScripts();
    webView_ = nullptr;
  }
}
