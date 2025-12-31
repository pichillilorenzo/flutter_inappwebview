#include "create_window_action.h"

#include "../utils/flutter.h"

namespace flutter_inappwebview_plugin {

WindowFeatures::WindowFeatures(WebKitWindowProperties* properties) {
  if (properties == nullptr) {
    return;
  }

  // WPE WebKit doesn't have window geometry API - use defaults
  // WPE is headless so window properties aren't meaningful
  menuBarVisible = false;
  statusBarVisible = false;
  toolbarsVisible = false;
  scrollbarsVisible = true;
  locationbarVisible = false;
  fullscreen = false;
  resizable = true;
}

FlValue* WindowFeatures::toFlValue() const {
  FlValue* map = fl_value_new_map();

  if (menuBarVisible.has_value()) {
    fl_value_set_string_take(map, "menuBarVisible", fl_value_new_bool(menuBarVisible.value()));
  }
  if (statusBarVisible.has_value()) {
    fl_value_set_string_take(map, "statusBarVisible", fl_value_new_bool(statusBarVisible.value()));
  }
  if (toolbarsVisible.has_value()) {
    fl_value_set_string_take(map, "toolbarsVisible", fl_value_new_bool(toolbarsVisible.value()));
  }
  if (scrollbarsVisible.has_value()) {
    fl_value_set_string_take(map, "scrollbarsVisible",
                             fl_value_new_bool(scrollbarsVisible.value()));
  }
  if (locationbarVisible.has_value()) {
    fl_value_set_string_take(map, "locationbarVisible",
                             fl_value_new_bool(locationbarVisible.value()));
  }
  if (fullscreen.has_value()) {
    fl_value_set_string_take(map, "fullscreen", fl_value_new_bool(fullscreen.value()));
  }
  if (resizable.has_value()) {
    fl_value_set_string_take(map, "resizable", fl_value_new_bool(resizable.value()));
  }
  if (x.has_value()) {
    fl_value_set_string_take(map, "x", fl_value_new_float(x.value()));
  }
  if (y.has_value()) {
    fl_value_set_string_take(map, "y", fl_value_new_float(y.value()));
  }
  if (width.has_value()) {
    fl_value_set_string_take(map, "width", fl_value_new_float(width.value()));
  }
  if (height.has_value()) {
    fl_value_set_string_take(map, "height", fl_value_new_float(height.value()));
  }

  return map;
}

CreateWindowAction::CreateWindowAction(WebKitNavigationAction* navigationAction, int64_t windowId,
                                       WebKitWindowProperties* windowProperties)
    : windowId(windowId), isUserGesture(false), isForMainFrame(true) {
  if (navigationAction != nullptr) {
    WebKitURIRequest* uriRequest = webkit_navigation_action_get_request(navigationAction);
    if (uriRequest != nullptr) {
      const gchar* uri = webkit_uri_request_get_uri(uriRequest);
      const gchar* method = webkit_uri_request_get_http_method(uriRequest);

      request = std::make_shared<URLRequest>(
          uri != nullptr ? std::make_optional(std::string(uri)) : std::nullopt,
          method != nullptr ? std::make_optional(std::string(method))
                            : std::make_optional(std::string("GET")),
          std::nullopt,  // headers
          std::nullopt   // body
      );
    }

    navigationType =
        static_cast<int64_t>(webkit_navigation_action_get_navigation_type(navigationAction));
    isUserGesture = webkit_navigation_action_is_user_gesture(navigationAction);

    // Get target frame name
    const gchar* frameName = webkit_navigation_action_get_frame_name(navigationAction);
    if (frameName != nullptr) {
      targetFrame = std::string(frameName);
    }
  }

  if (windowProperties != nullptr) {
    windowFeatures = WindowFeatures(windowProperties);
  }
}

FlValue* CreateWindowAction::toFlValue() const {
  FlValue* map = fl_value_new_map();

  fl_value_set_string_take(map, "windowId", fl_value_new_int(windowId));

  if (isDialog.has_value()) {
    fl_value_set_string_take(map, "isDialog", fl_value_new_bool(isDialog.value()));
  }

  if (request != nullptr) {
    fl_value_set_string_take(map, "request", request->toFlValue());
  }

  fl_value_set_string_take(map, "navigationType", fl_value_new_int(navigationType));
  fl_value_set_string_take(map, "isForMainFrame", fl_value_new_bool(isForMainFrame));
  fl_value_set_string_take(map, "hasGesture", fl_value_new_bool(isUserGesture));

  if (targetFrame.has_value()) {
    fl_value_set_string_take(map, "targetFrame", fl_value_new_string(targetFrame.value().c_str()));
  }

  if (sourceUrl.has_value()) {
    fl_value_set_string_take(map, "sourceUrl", fl_value_new_string(sourceUrl.value().c_str()));
  }

  if (windowFeatures.has_value()) {
    fl_value_set_string_take(map, "windowFeatures", windowFeatures.value().toFlValue());
  }

  return map;
}

}  // namespace flutter_inappwebview_plugin
