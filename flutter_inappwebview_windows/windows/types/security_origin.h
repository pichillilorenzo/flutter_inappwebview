#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_SECURITY_ORIGIN_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_SECURITY_ORIGIN_H_

#include <flutter/standard_method_codec.h>
#include <string>

namespace flutter_inappwebview_plugin
{

  class SecurityOrigin
  {
  public:
    const std::string host;
    const int64_t port;
    const std::string protocol;

    SecurityOrigin(const std::string& host, const int64_t& port, const std::string& protocol);
    ~SecurityOrigin() = default;

    flutter::EncodableMap toEncodableMap() const;
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_SECURITY_ORIGIN_H_