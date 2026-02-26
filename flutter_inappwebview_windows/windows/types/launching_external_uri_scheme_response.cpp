#include "launching_external_uri_scheme_response.h"

namespace flutter_inappwebview_plugin
{
  LaunchingExternalUriSchemeResponse::LaunchingExternalUriSchemeResponse(const bool& cancel)
    : cancel(cancel)
  {}

  LaunchingExternalUriSchemeResponse::LaunchingExternalUriSchemeResponse(const flutter::EncodableMap& map)
    : LaunchingExternalUriSchemeResponse(get_fl_map_value<bool>(map, "cancel", false))
  {}

  flutter::EncodableMap LaunchingExternalUriSchemeResponse::toEncodableMap() const
  {
    return flutter::EncodableMap{
      {"cancel", make_fl_value(cancel)}
    };
  }
}