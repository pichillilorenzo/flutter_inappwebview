#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_OPTION_MENU_POPUP_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_OPTION_MENU_POPUP_H_

#include <gtk/gtk.h>

#include <functional>
#include <string>
#include <vector>

// Forward declaration of WebKitOptionMenu to avoid including webkit headers
typedef struct _WebKitOptionMenu WebKitOptionMenu;

namespace flutter_inappwebview_plugin {

/// A custom popup for HTML <select> option menus using Cairo drawing.
/// This avoids focus issues with GtkMenu by using a GTK_WINDOW_POPUP
/// with custom rendering, similar to Cog browser's approach.
class OptionMenuPopup {
 public:
  explicit OptionMenuPopup(GtkWindow* parent_window);
  ~OptionMenuPopup();

  /// Set the WebKit option menu to display
  void SetOptionMenu(WebKitOptionMenu* menu);

  /// Show the popup at the specified position (screen coordinates)
  /// min_width is the minimum width based on the HTML element's width
  void Show(int x, int y, int min_width = 0);

  /// Hide the popup and clean up
  void Hide();

  /// Check if the popup is currently visible
  bool IsVisible() const { return visible_; }

  /// Set callback when an item is selected
  void SetItemSelectedCallback(std::function<void(int index)> callback) {
    item_selected_callback_ = std::move(callback);
  }

  /// Set callback when the menu is dismissed without selection
  void SetDismissedCallback(std::function<void()> callback) {
    dismissed_callback_ = std::move(callback);
  }

 private:
  struct MenuItem {
    std::string label;
    bool enabled = true;
    bool selected = false;
    bool is_group_label = false;
    bool is_group_child = false;
  };

  // Layout constants (matching Cog browser style)
  static constexpr int MENU_VERTICAL_PADDING = 8;
  static constexpr int MENU_HORIZONTAL_PADDING = 12;
  static constexpr int MENU_ITEM_HEIGHT = 32;
  static constexpr int MENU_GROUP_LABEL_HEIGHT = 28;
  static constexpr int MENU_ITEM_TEXT_SIZE = 14;
  static constexpr int MENU_MIN_WIDTH = 150;
  static constexpr int MENU_MAX_WIDTH = 400;
  static constexpr int MENU_MAX_VISIBLE_ITEMS = 10;

  void UpdateItems();
  void UpdateSize();
  void Paint();
  int GetItemAtPosition(int x, int y) const;
  void ScrollToItem(int index);

  // GTK signal handlers
  static gboolean OnDraw(GtkWidget* widget, cairo_t* cr, gpointer user_data);
  static gboolean OnButtonPress(GtkWidget* widget, GdkEventButton* event, gpointer user_data);
  static gboolean OnButtonRelease(GtkWidget* widget, GdkEventButton* event, gpointer user_data);
  static gboolean OnMotionNotify(GtkWidget* widget, GdkEventMotion* event, gpointer user_data);
  static gboolean OnLeaveNotify(GtkWidget* widget, GdkEventCrossing* event, gpointer user_data);
  static gboolean OnScroll(GtkWidget* widget, GdkEventScroll* event, gpointer user_data);
  static gboolean OnKeyPress(GtkWidget* widget, GdkEventKey* event, gpointer user_data);
  static gboolean OnFocusOut(GtkWidget* widget, GdkEventFocus* event, gpointer user_data);
  static gboolean OnParentButtonPress(GtkWidget* widget, GdkEventButton* event, gpointer user_data);
  static void OnUnrealize(GtkWidget* widget, gpointer user_data);

  GtkWindow* parent_window_ = nullptr;
  GtkWidget* popup_window_ = nullptr;
  GtkWidget* drawing_area_ = nullptr;

  WebKitOptionMenu* webkit_menu_ = nullptr;
  std::vector<MenuItem> items_;

  int width_ = 0;
  int height_ = 0;
  int content_height_ = 0;  // Total height of all items
  int scroll_offset_ = 0;   // Current scroll position
  int hovered_index_ = -1;
  int pressed_index_ = -1;
  int initially_selected_index_ = -1;

  int menu_x_ = 0;
  int menu_y_ = 0;

  bool visible_ = false;

  gulong parent_button_handler_id_ = 0;

  std::function<void(int index)> item_selected_callback_;
  std::function<void()> dismissed_callback_;
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_OPTION_MENU_POPUP_H_
