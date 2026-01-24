#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_PLUGIN_SCRIPT_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_PLUGIN_SCRIPT_H_

#include <memory>
#include <string>
#include <vector>

#include "user_script.h"

namespace flutter_inappwebview_plugin {

/**
 * Represents an internal plugin script that is required for WebView functionality.
 * Plugin scripts extend user scripts with additional properties like:
 * - requiredInAllContentWorlds: whether the script needs to run in all content worlds
 * - messageHandlerNames: names of message handlers this script uses
 */
class PluginScript : public UserScript {
 public:
  bool requiredInAllContentWorlds;
  std::vector<std::string> messageHandlerNames;

  PluginScript(const std::string& groupName, const std::string& source,
               UserScriptInjectionTime injectionTime, bool forMainFrameOnly,
               const std::optional<std::vector<std::string>>& allowedOriginRules = std::nullopt,
               std::shared_ptr<ContentWorld> contentWorld = nullptr,
               bool requiredInAllContentWorlds = false,
               const std::vector<std::string>& messageHandlerNames = {});

  bool operator==(const PluginScript& other) const;
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_PLUGIN_SCRIPT_H_
