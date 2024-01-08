#include "../utils/flutter.h"
#include "navigation_action.h"

namespace flutter_inappwebview_plugin
{
  NavigationAction::NavigationAction(std::shared_ptr<URLRequest> request, const bool& isForMainFrame)
    : request(std::move(request)), isForMainFrame(isForMainFrame)
  {}

  flutter::EncodableMap NavigationAction::toEncodableMap() const
  {
    return flutter::EncodableMap{
      {make_fl_value("request"), request->toEncodableMap()},
      {make_fl_value("isForMainFrame"), make_fl_value(isForMainFrame)}
    };
  }
}