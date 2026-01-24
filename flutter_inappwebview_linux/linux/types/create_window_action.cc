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
  return to_fl_map({
      {"menuBarVisible", make_fl_value(menuBarVisible)},
      {"statusBarVisible", make_fl_value(statusBarVisible)},
      {"toolbarsVisible", make_fl_value(toolbarsVisible)},
      {"scrollbarsVisible", make_fl_value(scrollbarsVisible)},
      {"locationbarVisible", make_fl_value(locationbarVisible)},
      {"fullscreen", make_fl_value(fullscreen)},
      {"resizable", make_fl_value(resizable)},
      {"x", make_fl_value(x)},
      {"y", make_fl_value(y)},
      {"width", make_fl_value(width)},
      {"height", make_fl_value(height)},
  });
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
  return to_fl_map({
      {"windowId", make_fl_value(windowId)},
      {"isDialog", make_fl_value(isDialog)},
      {"request", request ? request->toFlValue() : make_fl_value()},
      {"navigationType", make_fl_value(navigationType)},
      {"isForMainFrame", make_fl_value(isForMainFrame)},
      {"hasGesture", make_fl_value(isUserGesture)},
      {"targetFrame", make_fl_value(targetFrame)},
      {"sourceUrl", make_fl_value(sourceUrl)},
      {"windowFeatures", windowFeatures.has_value() ? windowFeatures->toFlValue() : make_fl_value()},
  });
}

}  // namespace flutter_inappwebview_plugin
