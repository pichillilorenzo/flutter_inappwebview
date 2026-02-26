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
    targetCompatibleBrowserVersion(get_optional_fl_map_value<std::string>(map, "targetCompatibleBrowserVersion")),
    customSchemeRegistrations(functional_map(get_optional_fl_map_value<flutter::EncodableList>(map, "customSchemeRegistrations"), [](const flutter::EncodableValue& m) { return std::make_shared<CustomSchemeRegistration>(std::get<flutter::EncodableMap>(m)); })),
    exclusiveUserDataFolderAccess(get_optional_fl_map_value<bool>(map, "exclusiveUserDataFolderAccess")),
    isCustomCrashReportingEnabled(get_optional_fl_map_value<bool>(map, "isCustomCrashReportingEnabled")),
    enableTrackingPrevention(get_optional_fl_map_value<bool>(map, "enableTrackingPrevention")),
    areBrowserExtensionsEnabled(get_optional_fl_map_value<bool>(map, "areBrowserExtensionsEnabled")),
    channelSearchKind(get_optional_fl_map_value<int64_t>(map, "channelSearchKind")),
    releaseChannels(get_optional_fl_map_value<int64_t>(map, "releaseChannels")),
    scrollbarStyle(get_optional_fl_map_value<int64_t>(map, "scrollbarStyle"))
  {}

  flutter::EncodableMap WebViewEnvironmentSettings::toEncodableMap() const
  {
    return flutter::EncodableMap{
      {"browserExecutableFolder", make_fl_value(browserExecutableFolder)},
      {"userDataFolder", make_fl_value(userDataFolder)},
      {"additionalBrowserArguments", make_fl_value(additionalBrowserArguments)},
      {"allowSingleSignOnUsingOSPrimaryAccount", make_fl_value(allowSingleSignOnUsingOSPrimaryAccount)},
      {"language", make_fl_value(language)},
      {"targetCompatibleBrowserVersion", make_fl_value(targetCompatibleBrowserVersion)},
      {"customSchemeRegistrations", make_fl_value(functional_map(customSchemeRegistrations, [](const std::shared_ptr<CustomSchemeRegistration>& item) { return item->toEncodableMap(); }))},
      {"exclusiveUserDataFolderAccess", make_fl_value(exclusiveUserDataFolderAccess)},
      {"isCustomCrashReportingEnabled", make_fl_value(isCustomCrashReportingEnabled)},
      {"enableTrackingPrevention", make_fl_value(enableTrackingPrevention)},
      {"areBrowserExtensionsEnabled", make_fl_value(areBrowserExtensionsEnabled)},
      {"channelSearchKind", make_fl_value(channelSearchKind)},
      {"releaseChannels", make_fl_value(releaseChannels)},
      {"scrollbarStyle", make_fl_value(scrollbarStyle)}
    };
  }

}