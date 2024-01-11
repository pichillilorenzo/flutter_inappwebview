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
      {"request", request->toEncodableMap()},
      {"isForMainFrame", make_fl_value(isForMainFrame)}
    };
  }
}