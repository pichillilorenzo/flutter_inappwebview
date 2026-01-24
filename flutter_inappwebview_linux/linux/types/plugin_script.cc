#include "plugin_script.h"

namespace flutter_inappwebview_plugin {

PluginScript::PluginScript(const std::string& groupName, const std::string& source,
                           UserScriptInjectionTime injectionTime, bool forMainFrameOnly,
                           const std::optional<std::vector<std::string>>& allowedOriginRules,
                           std::shared_ptr<ContentWorld> contentWorld,
                           bool requiredInAllContentWorlds,
                           const std::vector<std::string>& messageHandlerNames)
    : UserScript(groupName, source, injectionTime, forMainFrameOnly, allowedOriginRules,
                 contentWorld),
      requiredInAllContentWorlds(requiredInAllContentWorlds),
      messageHandlerNames(messageHandlerNames) {}

bool PluginScript::operator==(const PluginScript& other) const {
  return UserScript::operator==(other) &&
         requiredInAllContentWorlds == other.requiredInAllContentWorlds &&
         messageHandlerNames == other.messageHandlerNames;
}

}  // namespace flutter_inappwebview_plugin
