#ifndef DRAGO_INAPPWEBVIEW_PLUGIN_LAUNCHING_EXTERNAL_URI_SCHEME_RESPONSE_H_
#define DRAGO_INAPPWEBVIEW_PLUGIN_LAUNCHING_EXTERNAL_URI_SCHEME_RESPONSE_H_

#include <flutter/standard_method_codec.h>

#include "../utils/flutter.h"

namespace drago_inappwebview_plugin
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

#endif //DRAGO_INAPPWEBVIEW_PLUGIN_LAUNCHING_EXTERNAL_URI_SCHEME_RESPONSE_H_