#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_CUSTOM_SCHEME_REGISTRATION_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_CUSTOM_SCHEME_REGISTRATION_H_

#include <flutter/standard_method_codec.h>
#include <optional>
#ifdef _MSC_VER
// The SDK's custom scheme template shadows its own `value` member. Keep the
// suppression inside the SDK header; project code still builds with /W4 /WX.
#pragma warning(push)
#pragma warning(disable: 4458)
#endif
#include <WebView2EnvironmentOptions.h>
#ifdef _MSC_VER
#pragma warning(pop)
#endif
#include <wrl.h>

namespace flutter_inappwebview_plugin
{
  class CustomSchemeRegistration
  {
  public:
    const std::string scheme;
    const std::optional<std::vector<std::string>> allowedOrigins;
    const std::optional<bool> treatAsSecure;
    const std::optional<bool> hasAuthorityComponent;

    CustomSchemeRegistration(const std::string& scheme, const std::optional<std::vector<std::string>>& allowedOrigins, const std::optional<bool>& treatAsSecure, const std::optional<bool>& hasAuthorityComponent);
    CustomSchemeRegistration(const flutter::EncodableMap& map);
    ~CustomSchemeRegistration() = default;

    flutter::EncodableMap toEncodableMap() const;
    Microsoft::WRL::ComPtr<CoreWebView2CustomSchemeRegistration> toWebView2CustomSchemeRegistration() const;
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_CUSTOM_SCHEME_REGISTRATION_H_
