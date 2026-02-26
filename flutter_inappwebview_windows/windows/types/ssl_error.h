#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_SSL_ERROR_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_SSL_ERROR_H_

#include <flutter/standard_method_codec.h>
#include <optional>
#include <string>

#include "WebView2.h"

namespace flutter_inappwebview_plugin
{
  inline std::optional<std::string> COREWEBVIEW2_WEB_ERROR_STATUS_ToString(const COREWEBVIEW2_WEB_ERROR_STATUS& code)
  {
    switch (code) {
    case COREWEBVIEW2_WEB_ERROR_STATUS_CERTIFICATE_COMMON_NAME_IS_INCORRECT:
      return "Indicates that the SSL certificate common name does not match the web address.";
    case COREWEBVIEW2_WEB_ERROR_STATUS_CERTIFICATE_EXPIRED:
      return "Indicates that the SSL certificate has expired.";
    case COREWEBVIEW2_WEB_ERROR_STATUS_CLIENT_CERTIFICATE_CONTAINS_ERRORS:
      return "Indicates that the SSL client certificate contains errors.";
    case COREWEBVIEW2_WEB_ERROR_STATUS_CERTIFICATE_REVOKED:
      return "Indicates that the SSL certificate has been revoked.";
    case COREWEBVIEW2_WEB_ERROR_STATUS_CERTIFICATE_IS_INVALID:
      return "Indicates that the SSL certificate is not valid.";
    default:
      break;
    }
    return std::optional<std::string>{};
  }

  class SslError
  {
  public:
    const COREWEBVIEW2_WEB_ERROR_STATUS code;
    const std::optional<std::string> message;

    SslError(const COREWEBVIEW2_WEB_ERROR_STATUS& code, const std::optional<std::string>& message);
    ~SslError() = default;

    flutter::EncodableMap toEncodableMap() const;
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_SSL_ERROR_H_