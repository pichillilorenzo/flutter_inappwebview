#ifndef DRAGO_INAPPWEBVIEW_PLUGIN_SSL_CERTIFICATE_H_
#define DRAGO_INAPPWEBVIEW_PLUGIN_SSL_CERTIFICATE_H_

#include <flutter/standard_method_codec.h>

namespace drago_inappwebview_plugin
{
  class SslCertificate
  {
  public:
    const std::string x509Certificate;

    SslCertificate(std::string x509Certificate);
    ~SslCertificate() = default;

    flutter::EncodableMap toEncodableMap() const;
  };
}

#endif //DRAGO_INAPPWEBVIEW_PLUGIN_SSL_CERTIFICATE_H_