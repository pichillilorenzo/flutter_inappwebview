#include "../utils/flutter.h"
#include "webview_environment_settings.h"

namespace flutter_inappwebview_plugin
{
  WebViewEnvironmentSettings::WebViewEnvironmentSettings(const flutter::EncodableMap& map)
    : browserExecutableFolder(get_optional_fl_map_value<std::string>(map, "browserExecutableFolder")),
    userDataFolder(get_optional_fl_map_value<std::string>(map, "userDataFolder")),
    additionalBrowserArguments(get_optional_fl_map_value<std::string>(map, "additionalBrowserArguments")),
    allowSingleSignOnUsingOSPrimaryAccount(get_optional_fl_map_value<bool>(map, "allowSingleSignOnUsingOSPrimaryAccount")),
    language(get_optional_fl_map_value<std::string>(map, "language")),
    targetCompatibleBrowserVersion(get_optional_fl_map_value<std::string>(map, "targetCompatibleBrowserVersion"))
  {}

  flutter::EncodableMap WebViewEnvironmentSettings::toEncodableMap() const
  {
    return flutter::EncodableMap{
      {"browserExecutableFolder", make_fl_value(browserExecutableFolder)},
      {"userDataFolder", make_fl_value(userDataFolder)},
      {"additionalBrowserArguments", make_fl_value(additionalBrowserArguments)},
      {"allowSingleSignOnUsingOSPrimaryAccount", make_fl_value(allowSingleSignOnUsingOSPrimaryAccount)},
      {"language", make_fl_value(language)},
      {"targetCompatibleBrowserVersion", make_fl_value(targetCompatibleBrowserVersion)}
    };
  }

}