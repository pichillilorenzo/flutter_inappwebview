#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_ENVIRONMENT_CREATION_PARAMS_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_ENVIRONMENT_CREATION_PARAMS_H_

#include <flutter/standard_method_codec.h>
#include <optional>
#include <string>

#include "../flutter_inappwebview_windows_plugin.h"
#include "../types/custom_scheme_registration.h"

namespace flutter_inappwebview_plugin
{
  class WebViewEnvironmentSettings
  {
  public:
    const std::optional<std::string> browserExecutableFolder;
    const std::optional<std::string> userDataFolder;
    const std::optional<std::string> additionalBrowserArguments;
    const std::optional<bool> allowSingleSignOnUsingOSPrimaryAccount;
    const std::optional<std::string> language;
    const std::optional<std::string> targetCompatibleBrowserVersion;
    const std::optional<std::vector<std::shared_ptr<CustomSchemeRegistration>>> customSchemeRegistrations;
    const std::optional<bool> exclusiveUserDataFolderAccess;
    const std::optional<bool> isCustomCrashReportingEnabled;
    const std::optional<bool> enableTrackingPrevention;
    const std::optional<bool> areBrowserExtensionsEnabled;
    const std::optional<int64_t> channelSearchKind;
    const std::optional<int64_t> releaseChannels;
    const std::optional<int64_t> scrollbarStyle;

    WebViewEnvironmentSettings() = default;
    WebViewEnvironmentSettings(const flutter::EncodableMap& map);
    ~WebViewEnvironmentSettings() = default;

    flutter::EncodableMap toEncodableMap() const;
  };
}
#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_ENVIRONMENT_CREATION_PARAMS_H_