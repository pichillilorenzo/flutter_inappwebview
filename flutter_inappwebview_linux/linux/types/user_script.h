#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_USER_SCRIPT_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_USER_SCRIPT_H_

#include <flutter_linux/flutter_linux.h>

#include <memory>
#include <optional>
#include <string>
#include <vector>

#include "content_world.h"

namespace flutter_inappwebview_plugin {

enum class UserScriptInjectionTime {
  atDocumentStart = 0,
  atDocumentEnd = 1,
};

/**
 * Represents a user script to be injected into the web view.
 */
class UserScript {
 public:
  std::optional<std::string> groupName;
  std::string source;
  UserScriptInjectionTime injectionTime;
  bool forMainFrameOnly;
  std::optional<std::vector<std::string>> allowedOriginRules;
  std::shared_ptr<ContentWorld> contentWorld;

  UserScript(const std::optional<std::string>& groupName, const std::string& source,
             UserScriptInjectionTime injectionTime, bool forMainFrameOnly,
             const std::optional<std::vector<std::string>>& allowedOriginRules = std::nullopt,
             std::shared_ptr<ContentWorld> contentWorld = nullptr);

  UserScript(FlValue* map);

  FlValue* toFlValue() const;

  bool operator==(const UserScript& other) const;
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_USER_SCRIPT_H_
