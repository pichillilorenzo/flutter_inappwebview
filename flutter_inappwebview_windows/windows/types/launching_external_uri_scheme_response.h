#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_LAUNCHING_EXTERNAL_URI_SCHEME_RESPONSE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_LAUNCHING_EXTERNAL_URI_SCHEME_RESPONSE_H_

#include <flutter/standard_method_codec.h>

#include "../utils/flutter.h"

namespace flutter_inappwebview_plugin
{
  class LaunchingExternalUriSchemeResponse
  {
  public:
    const bool cancel;

    LaunchingExternalUriSchemeResponse(const bool& cancel);
    LaunchingExternalUriSchemeResponse(const flutter::EncodableMap& map);
    ~LaunchingExternalUriSchemeResponse() = default;

    flutter::EncodableMap toEncodableMap() const;
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_LAUNCHING_EXTERNAL_URI_SCHEME_RESPONSE_H_