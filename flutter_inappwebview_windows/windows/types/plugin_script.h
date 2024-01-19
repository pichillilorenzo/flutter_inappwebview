#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_PLUGIN_SCRIPT_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_PLUGIN_SCRIPT_H_

#include "user_script.h"

namespace flutter_inappwebview_plugin
{
  class PluginScript : public UserScript
  {
  public:

    PluginScript(
      const std::optional<std::string>& groupName,
      const std::string& source,
      const UserScriptInjectionTime& injectionTime,
      const std::set<std::string>& allowedOriginRules
    );
    ~PluginScript();
  };
}
#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_PLUGIN_SCRIPT_H_