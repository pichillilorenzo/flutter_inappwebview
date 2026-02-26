#include "launching_external_uri_scheme_request.h"

namespace flutter_inappwebview_plugin
{
  LaunchingExternalUriSchemeRequest::LaunchingExternalUriSchemeRequest(const std::string& uri, const std::optional<std::string>& initiatingOrigin,
    const std::optional<bool>& isUserInitiated)
    : uri(uri), initiatingOrigin(initiatingOrigin), isUserInitiated(isUserInitiated)
  {}

  flutter::EncodableMap LaunchingExternalUriSchemeRequest::toEncodableMap() const
  {
    return flutter::EncodableMap{
      {"uri", make_fl_value(uri)},
      {"initiatingOrigin", make_fl_value(initiatingOrigin)},
      {"isUserInitiated", make_fl_value(isUserInitiated)}
    };
  }
}