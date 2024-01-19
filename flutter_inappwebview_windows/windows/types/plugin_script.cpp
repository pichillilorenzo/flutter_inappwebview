#include "plugin_script.h"

namespace flutter_inappwebview_plugin
{
  PluginScript::PluginScript(
    const std::optional<std::string>& groupName,
    const std::string& source,
    const UserScriptInjectionTime& injectionTime,
    const std::set<std::string>& allowedOriginRules
  ) : UserScript(groupName, source, injectionTime, allowedOriginRules)
  {}

  PluginScript::~PluginScript() {}
}