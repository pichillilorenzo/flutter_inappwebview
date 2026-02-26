#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_CONTEXT_MENU_POPUP_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_CONTEXT_MENU_POPUP_H_

#include <cairo.h>
#include <gtk/gtk.h>

#include <functional>
#include <string>
#include <vector>

namespace flutter_inappwebview_plugin {

// Constants for menu rendering
constexpr int MENU_VERTICAL_PADDING = 8;
constexpr int MENU_HORIZONTAL_PADDING = 12;
constexpr int MENU_ITEM_HEIGHT = 32;
constexpr int MENU_ITEM_TEXT_SIZE = 14;
constexpr int MENU_SEPARATOR_HEIGHT = 9;
constexpr int MENU_MIN_WIDTH = 150;
constexpr int MENU_MAX_WIDTH = 400;

struct PopupMenuItem {
  std::string id;
  std::string title;
  bool enabled = true;
  bool is_separator = false;
};

// Callback when a menu item is clicked
using MenuItemCallback = std::function<void(const std::string& id, const std::string& title)>;
// Callback when the menu is dismissed
using MenuDismissedCallback = std::function<void()>;

class ContextMenuPopup {
 public:
  ContextMenuPopup(GtkWindow* parent_window);
  ~ContextMenuPopup();

  // Add a menu item
  void AddItem(const std::string& id, const std::string& title, bool enabled = true);

  // Add a separator
  void AddSeparator();

  // Clear all items
  void Clear();

  // Show the popup at the given screen coordinates
  void Show(int x, int y);

  // Hide the popup
  void Hide();

  // Check if the popup is visible
  bool IsVisible() const { return visible_; }

  // Set callbacks
  void SetItemCallback(MenuItemCallback callback) { item_callback_ = std::move(callback); }
  void SetDismissedCallback(MenuDismissedCallback callback) {
    dismissed_callback_ = std::move(callback);
  }

 private:
  // Cairo drawing
  void Paint();
  void UpdateSize();
  int GetItemAtPosition(int x, int y) const;

  // GTK signal handlers
  static gboolean OnDraw(GtkWidget* widget, cairo_t* cr, gpointer user_data);
  static gboolean OnButtonPress(GtkWidget* widget, GdkEventButton* event, gpointer user_data);
  static gboolean OnButtonRelease(GtkWidget* widget, GdkEventButton* event, gpointer user_data);
  static gboolean OnMotionNotify(GtkWidget* widget, GdkEventMotion* event, gpointer user_data);
  static gboolean OnLeaveNotify(GtkWidget* widget, GdkEventCrossing* event, gpointer user_data);
  static gboolean OnParentButtonPress(GtkWidget* widget, GdkEventButton* event, gpointer user_data);
  static gboolean OnFocusOut(GtkWidget* widget, GdkEventFocus* event, gpointer user_data);
  static void OnUnrealize(GtkWidget* widget, gpointer user_data);

  GtkWindow* parent_window_ = nullptr;
  GtkWidget* popup_window_ = nullptr;
  GtkWidget* drawing_area_ = nullptr;

  std::vector<PopupMenuItem> items_;
  int width_ = 0;
  int height_ = 0;
  int menu_x_ = 0;  // Screen X position of menu
  int menu_y_ = 0;  // Screen Y position of menu
  int hovered_index_ = -1;
  int pressed_index_ = -1;
  bool visible_ = false;
  gulong parent_button_handler_id_ = 0;

  MenuItemCallback item_callback_;
  MenuDismissedCallback dismissed_callback_;
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_CONTEXT_MENU_POPUP_H_
