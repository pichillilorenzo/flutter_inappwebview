#include "user_script.h"

namespace flutter_inappwebview_plugin
{
  UserScript::UserScript(
    const std::optional<std::string>& groupName,
    const std::string& source,
    const UserScriptInjectionTime& injectionTime,
    const std::set<std::string>& allowedOriginRules
  ) : groupName(groupName), source(source), injectionTime(injectionTime), allowedOriginRules(allowedOriginRules)
  {}

  UserScript::~UserScript()
  {}
}