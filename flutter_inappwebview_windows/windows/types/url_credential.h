#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_URL_CREDENTIAL_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_URL_CREDENTIAL_H_

#include <flutter/standard_method_codec.h>
#include <optional>
#include <string>

namespace flutter_inappwebview_plugin
{
  class URLCredential
  {
  public:
    const std::optional<std::string> username;
    const std::optional<std::string> password;

    URLCredential(const std::optional<std::string>& username,
      const std::optional<std::string>& password);
    ~URLCredential() = default;

    flutter::EncodableMap toEncodableMap() const;
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_URL_CREDENTIAL_H_