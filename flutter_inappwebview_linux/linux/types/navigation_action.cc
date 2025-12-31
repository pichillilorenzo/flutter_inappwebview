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
  FlValue* map = fl_value_new_map();

  if (request) {
    fl_value_set_string_take(map, "request", request->toFlValue());
  } else {
    fl_value_set_string_take(map, "request", fl_value_new_null());
  }

  fl_value_set_string_take(map, "isForMainFrame", fl_value_new_bool(isForMainFrame));

  if (isRedirect.has_value()) {
    fl_value_set_string_take(map, "isRedirect", fl_value_new_bool(isRedirect.value()));
  } else {
    fl_value_set_string_take(map, "isRedirect", fl_value_new_null());
  }

  auto navTypeInt = NavigationActionTypeToInteger(navigationType);
  if (navTypeInt.has_value()) {
    fl_value_set_string_take(map, "navigationType", fl_value_new_int(navTypeInt.value()));
  } else {
    fl_value_set_string_take(map, "navigationType", fl_value_new_null());
  }

  return map;
}

}  // namespace flutter_inappwebview_plugin
