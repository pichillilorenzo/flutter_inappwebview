#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_USER_SCRIPT_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_USER_SCRIPT_H_

#include <optional>
#include <set>
#include <string>

namespace flutter_inappwebview_plugin
{
  enum UserScriptInjectionTime {
    atDocumentStart,
    atDocumentEnd
  };

  class UserScript
  {
  public:
    std::wstring id;
    const std::optional<std::string> groupName;
    const std::string source;
    const UserScriptInjectionTime injectionTime;
    const std::set<std::string> allowedOriginRules;

    UserScript(
      const std::optional<std::string>& groupName,
      const std::string& source,
      const UserScriptInjectionTime& injectionTime,
      const std::set<std::string>& allowedOriginRules
    );
    ~UserScript();
  };
}
#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_USER_SCRIPT_H_