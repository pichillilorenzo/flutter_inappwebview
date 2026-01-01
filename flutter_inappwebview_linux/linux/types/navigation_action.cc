#include "navigation_action.h"

#include "../utils/flutter.h"

namespace flutter_inappwebview_plugin {

NavigationAction::NavigationAction(std::shared_ptr<URLRequest> request, bool isForMainFrame,
                                   const std::optional<bool>& isRedirect,
                                   const std::optional<NavigationActionType>& navigationType)
    : request(std::move(request)),
      isForMainFrame(isForMainFrame),
      isRedirect(isRedirect),
      navigationType(navigationType) {}

FlValue* NavigationAction::toFlValue() const {
  return to_fl_map({
      {"request", request ? request->toFlValue() : make_fl_value()},
      {"isForMainFrame", make_fl_value(isForMainFrame)},
      {"isRedirect", make_fl_value(isRedirect)},
      {"navigationType", make_fl_value(NavigationActionTypeToInteger(navigationType))},
  });
}

}  // namespace flutter_inappwebview_plugin
