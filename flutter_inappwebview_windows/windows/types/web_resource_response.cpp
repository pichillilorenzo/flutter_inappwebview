#include "web_resource_response.h"

#include "../utils/flutter.h"

namespace flutter_inappwebview_plugin
{
    WebResourceResponse::WebResourceResponse(const std::optional<int>& statusCode) 
        : statusCode(statusCode)
    {

    }

    WebResourceResponse::WebResourceResponse(const flutter::EncodableMap& map) 
        : statusCode(get_optional_fl_map_value<int>(map, "statusCode"))
    {

    }

    flutter::EncodableMap WebResourceResponse::toEncodableMap()
    {
        return flutter::EncodableMap{
                {make_fl_value("statusCode"), make_fl_value(statusCode)}
        };
    }
}