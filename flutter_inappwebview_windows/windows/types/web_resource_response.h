#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_WEB_RESOURCE_RESPONSE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_WEB_RESOURCE_RESPONSE_H_

#include <flutter/standard_method_codec.h>

#include <optional>

namespace flutter_inappwebview_plugin
{
    class WebResourceResponse
    {
    public:
        const std::optional<int> statusCode;

        WebResourceResponse(const std::optional<int>& statusCode);
        WebResourceResponse(const flutter::EncodableMap& map);
        ~WebResourceResponse() = default;
        flutter::EncodableMap toEncodableMap();
    };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_WEB_RESOURCE_RESPONSE_H_