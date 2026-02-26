#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_CREATE_WINDOW_ACTION_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_CREATE_WINDOW_ACTION_H_

#include <flutter_linux/flutter_linux.h>
#include <wpe/webkit.h>

#include <cstdint>
#include <memory>
#include <optional>
#include <string>

#include "url_request.h"

namespace flutter_inappwebview_plugin {

/**
 * Represents window features from WebKitWindowProperties.
 */
class WindowFeatures {
 public:
  std::optional<bool> menuBarVisible;
  std::optional<bool> statusBarVisible;
  std::optional<bool> toolbarsVisible;
  std::optional<bool> scrollbarsVisible;
  std::optional<bool> locationbarVisible;
  std::optional<bool> fullscreen;
  std::optional<bool> resizable;
  std::optional<double> x;
  std::optional<double> y;
  std::optional<double> width;
  std::optional<double> height;

  WindowFeatures() = default;
  WindowFeatures(WebKitWindowProperties* properties);
  ~WindowFeatures() = default;

  FlValue* toFlValue() const;
};

/**
 * Represents an action to create a new window (e.g., from window.open() or target="_blank").
 */
class CreateWindowAction {
 public:
  // The window id assigned to the new window
  int64_t windowId;

  // Whether this is a dialog window
  std::optional<bool> isDialog;

  // The navigation action that triggered this
  std::shared_ptr<URLRequest> request;

  // Navigation type (same as NavigationAction)
  int64_t navigationType;

  // Whether the navigation was triggered by a user gesture
  bool isUserGesture;

  // Whether it's for the main frame
  bool isForMainFrame;

  // Target frame name (e.g., "_blank")
  std::optional<std::string> targetFrame;

  // Source URL (the URL of the page that initiated the request)
  std::optional<std::string> sourceUrl;

  // Window features
  std::optional<WindowFeatures> windowFeatures;

  CreateWindowAction(WebKitNavigationAction* navigationAction, int64_t windowId,
                     WebKitWindowProperties* windowProperties = nullptr);
  ~CreateWindowAction() = default;

  FlValue* toFlValue() const;
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_CREATE_WINDOW_ACTION_H_
