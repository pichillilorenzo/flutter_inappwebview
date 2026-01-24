#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_BROWSER_SETTINGS_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_BROWSER_SETTINGS_H_

#include <flutter_linux/flutter_linux.h>

#include <memory>
#include <optional>
#include <string>

namespace flutter_inappwebview_plugin {

class InAppBrowser;

/// Window type for InAppBrowser
enum class InAppBrowserWindowType {
  window,  // Top-level window
  child    // Child window (transient for parent)
};

/// Rect structure for window frame
struct InAppBrowserRect {
  double x = 0;
  double y = 0;
  double width = 0;
  double height = 0;

  InAppBrowserRect() = default;
  InAppBrowserRect(double x, double y, double width, double height)
      : x(x), y(y), width(width), height(height) {}
  explicit InAppBrowserRect(FlValue* map);

  FlValue* toFlValue() const;
};

/// Settings class for InAppBrowser
///
/// Stores configuration options for the browser window appearance and behavior.
class InAppBrowserSettings {
 public:
  /// Start with hidden window
  bool hidden = false;

  /// Hide the top toolbar
  bool hideToolbarTop = false;

  /// Toolbar background color (CSS color string, e.g., "#RRGGBB" or "#AARRGGBB")
  std::string toolbarTopBackgroundColor;

  /// Hide the URL bar in the toolbar
  bool hideUrlBar = false;

  /// Hide the progress bar
  bool hideProgressBar = false;

  /// Hide the default menu items (back, forward, reload)
  bool hideDefaultMenuItems = false;

  /// Fixed title for the window (instead of using page title)
  std::string toolbarTopFixedTitle;

  /// Window type (top-level or child)
  InAppBrowserWindowType windowType = InAppBrowserWindowType::window;

  /// Window opacity (0.0 to 1.0)
  double windowAlphaValue = 1.0;

  /// Window frame (position and size)
  std::shared_ptr<InAppBrowserRect> windowFrame;

  InAppBrowserSettings();
  explicit InAppBrowserSettings(FlValue* map);
  ~InAppBrowserSettings();

  /// Convert settings to FlValue map
  FlValue* toFlValue() const;

  /// Get actual settings from a live browser instance
  FlValue* getRealSettings(const InAppBrowser* browser) const;
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_BROWSER_SETTINGS_H_
