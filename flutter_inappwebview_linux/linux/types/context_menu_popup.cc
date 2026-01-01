#include "context_menu_popup.h"

#include <algorithm>
#include <cmath>
#include <cstring>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

namespace flutter_inappwebview_plugin {

ContextMenuPopup::ContextMenuPopup(GtkWindow* parent_window) : parent_window_(parent_window) {
  // Create a popup window
  popup_window_ = gtk_window_new(GTK_WINDOW_POPUP);
  gtk_window_set_type_hint(GTK_WINDOW(popup_window_), GDK_WINDOW_TYPE_HINT_POPUP_MENU);
  gtk_window_set_skip_taskbar_hint(GTK_WINDOW(popup_window_), TRUE);
  gtk_window_set_skip_pager_hint(GTK_WINDOW(popup_window_), TRUE);
  gtk_window_set_decorated(GTK_WINDOW(popup_window_), FALSE);
  gtk_window_set_resizable(GTK_WINDOW(popup_window_), FALSE);

  if (parent_window_ != nullptr) {
    gtk_window_set_transient_for(GTK_WINDOW(popup_window_), parent_window_);
  }

  // Enable RGBA for transparency
  GdkScreen* screen = gtk_widget_get_screen(popup_window_);
  GdkVisual* visual = gdk_screen_get_rgba_visual(screen);
  if (visual != nullptr) {
    gtk_widget_set_visual(popup_window_, visual);
  }
  gtk_widget_set_app_paintable(popup_window_, TRUE);

  // Create drawing area
  drawing_area_ = gtk_drawing_area_new();
  gtk_container_add(GTK_CONTAINER(popup_window_), drawing_area_);

  // Enable events on drawing area
  gtk_widget_add_events(drawing_area_,
                        GDK_BUTTON_PRESS_MASK | GDK_BUTTON_RELEASE_MASK | GDK_POINTER_MOTION_MASK |
                            GDK_LEAVE_NOTIFY_MASK);

  // Connect signals for drawing area
  g_signal_connect(drawing_area_, "draw", G_CALLBACK(OnDraw), this);
  g_signal_connect(drawing_area_, "button-press-event", G_CALLBACK(OnButtonPress), this);
  g_signal_connect(drawing_area_, "button-release-event", G_CALLBACK(OnButtonRelease), this);
  g_signal_connect(drawing_area_, "motion-notify-event", G_CALLBACK(OnMotionNotify), this);
  g_signal_connect(drawing_area_, "leave-notify-event", G_CALLBACK(OnLeaveNotify), this);

  // Also connect button-press to popup window for when clicks land on window edge
  g_signal_connect(popup_window_, "button-press-event", G_CALLBACK(OnButtonPress), this);

  // Connect signals for popup window
  g_signal_connect(popup_window_, "focus-out-event", G_CALLBACK(OnFocusOut), this);
  g_signal_connect(popup_window_, "unrealize", G_CALLBACK(OnUnrealize), this);

  gtk_widget_show(drawing_area_);
}

ContextMenuPopup::~ContextMenuPopup() {
  Hide();  // Ensure cleanup
  if (popup_window_ != nullptr) {
    gtk_widget_destroy(popup_window_);
    popup_window_ = nullptr;
  }
}

void ContextMenuPopup::AddItem(const std::string& id, const std::string& title, bool enabled) {
  PopupMenuItem item;
  item.id = id;
  item.title = title;
  item.enabled = enabled;
  item.is_separator = false;
  items_.push_back(std::move(item));
}

void ContextMenuPopup::AddSeparator() {
  PopupMenuItem item;
  item.is_separator = true;
  items_.push_back(std::move(item));
}

void ContextMenuPopup::Clear() {
  items_.clear();
  hovered_index_ = -1;
  pressed_index_ = -1;
}

void ContextMenuPopup::UpdateSize() {
  if (items_.empty()) {
    width_ = MENU_MIN_WIDTH;
    height_ = MENU_VERTICAL_PADDING * 2;
    return;
  }

  // Calculate width based on text
  cairo_surface_t* surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 1, 1);
  cairo_t* cr = cairo_create(surface);

  cairo_select_font_face(cr, "Sans", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL);
  cairo_set_font_size(cr, MENU_ITEM_TEXT_SIZE);

  int max_text_width = 0;
  int non_separator_count = 0;
  for (const auto& item : items_) {
    if (!item.is_separator) {
      non_separator_count++;
      cairo_text_extents_t extents;
      cairo_text_extents(cr, item.title.c_str(), &extents);
      max_text_width = std::max(max_text_width, static_cast<int>(extents.width));
    }
  }

  cairo_destroy(cr);
  cairo_surface_destroy(surface);

  width_ = std::max(MENU_MIN_WIDTH, std::min(MENU_MAX_WIDTH, max_text_width + MENU_HORIZONTAL_PADDING * 4));

  // Calculate height with separator filtering logic
  height_ = MENU_VERTICAL_PADDING * 2;
  bool last_was_separator = true;  // Start true to skip leading separators
  
  for (size_t i = 0; i < items_.size(); ++i) {
    const auto& item = items_[i];
    
    if (item.is_separator) {
      // Skip separator if:
      // 1. Only 1 or fewer non-separator items
      // 2. Last item was a separator (consecutive)
      // 3. This is at the start
      // 4. This is at the end (all remaining items are separators)
      if (non_separator_count <= 1 || last_was_separator) {
        continue;
      }
      
      // Check if trailing separator
      bool is_trailing = true;
      for (size_t j = i + 1; j < items_.size(); ++j) {
        if (!items_[j].is_separator) {
          is_trailing = false;
          break;
        }
      }
      if (is_trailing) {
        continue;
      }
      
      height_ += MENU_SEPARATOR_HEIGHT;
      last_was_separator = true;
    } else {
      height_ += MENU_ITEM_HEIGHT;
      last_was_separator = false;
    }
  }
}

void ContextMenuPopup::Show(int x, int y) {
  if (items_.empty()) {
    return;
  }

  UpdateSize();

  // Get display for monitor geometry
  GdkDisplay* display = gdk_display_get_default();

  // Get screen/monitor geometry for boundary checks
  GdkMonitor* monitor = nullptr;
  int screen_x = 0, screen_y = 0;
  int screen_width = 1920, screen_height = 1080;

  if (display != nullptr) {
    monitor = gdk_display_get_monitor_at_point(display, x, y);
    if (monitor == nullptr) {
      monitor = gdk_display_get_primary_monitor(display);
    }
    if (monitor == nullptr) {
      monitor = gdk_display_get_monitor(display, 0);
    }
  }

  if (monitor != nullptr) {
    GdkRectangle geometry;
    gdk_monitor_get_geometry(monitor, &geometry);
    screen_x = geometry.x;
    screen_y = geometry.y;
    screen_width = geometry.x + geometry.width;
    screen_height = geometry.y + geometry.height;
  }

  // Position menu so its top-left corner is at (x, y), adjusted for screen bounds
  // If it would go off the right edge, flip to show on the left of cursor
  if (x + width_ > screen_width) {
    x = x - width_;
  }
  // If it would go off the bottom, flip to show above cursor
  if (y + height_ > screen_height) {
    y = y - height_;
  }
  // Ensure it stays within screen bounds
  if (x < screen_x) {
    x = screen_x;
  }
  if (y < screen_y) {
    y = screen_y;
  }

  // Store menu position for outside click detection
  menu_x_ = x;
  menu_y_ = y;

  gtk_widget_set_size_request(drawing_area_, width_, height_);
  gtk_window_resize(GTK_WINDOW(popup_window_), width_, height_);
  gtk_window_move(GTK_WINDOW(popup_window_), x, y);
  gtk_window_set_position(GTK_WINDOW(popup_window_), GTK_WIN_POS_NONE);
  gtk_widget_show(popup_window_);
  gtk_window_move(GTK_WINDOW(popup_window_), x, y);
  
  visible_ = true;

  // Connect to parent window as fallback for clicks outside Flutter area
  if (parent_window_ != nullptr && parent_button_handler_id_ == 0) {
    parent_button_handler_id_ = g_signal_connect(
        parent_window_, "button-press-event", G_CALLBACK(OnParentButtonPress), this);
  }
}

void ContextMenuPopup::Hide() {
  if (!visible_) {
    return;
  }

  visible_ = false;
  hovered_index_ = -1;
  pressed_index_ = -1;

  // Disconnect from parent window
  if (parent_window_ != nullptr && parent_button_handler_id_ != 0) {
    g_signal_handler_disconnect(parent_window_, parent_button_handler_id_);
    parent_button_handler_id_ = 0;
  }

  // Hide the popup
  gtk_widget_hide(popup_window_);

  if (dismissed_callback_) {
    dismissed_callback_();
  }
}

int ContextMenuPopup::GetItemAtPosition(int x, int y) const {
  if (x < 0 || x >= width_) {
    return -1;
  }

  int current_y = MENU_VERTICAL_PADDING;
  for (size_t i = 0; i < items_.size(); ++i) {
    int item_height = items_[i].is_separator ? MENU_SEPARATOR_HEIGHT : MENU_ITEM_HEIGHT;

    if (y >= current_y && y < current_y + item_height) {
      if (items_[i].is_separator || !items_[i].enabled) {
        return -1;  // Can't select separators or disabled items
      }
      return static_cast<int>(i);
    }

    current_y += item_height;
  }

  return -1;
}

void ContextMenuPopup::Paint() {
  gtk_widget_queue_draw(drawing_area_);
}

gboolean ContextMenuPopup::OnDraw(GtkWidget* widget, cairo_t* cr, gpointer user_data) {
  auto* self = static_cast<ContextMenuPopup*>(user_data);

  // Clear with transparency
  cairo_set_operator(cr, CAIRO_OPERATOR_SOURCE);

  // Draw background with rounded corners
  double radius = 6.0;
  double x = 0, y = 0;
  double w = self->width_, h = self->height_;

  cairo_new_path(cr);
  cairo_arc(cr, x + w - radius, y + radius, radius, -M_PI / 2, 0);
  cairo_arc(cr, x + w - radius, y + h - radius, radius, 0, M_PI / 2);
  cairo_arc(cr, x + radius, y + h - radius, radius, M_PI / 2, M_PI);
  cairo_arc(cr, x + radius, y + radius, radius, M_PI, 3 * M_PI / 2);
  cairo_close_path(cr);

  // Background
  cairo_set_source_rgba(cr, 0.98, 0.98, 0.98, 0.98);
  cairo_fill_preserve(cr);

  // Border
  cairo_set_source_rgba(cr, 0.7, 0.7, 0.7, 1.0);
  cairo_set_line_width(cr, 1.0);
  cairo_stroke(cr);

  // Draw items
  cairo_select_font_face(cr, "Sans", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL);
  cairo_set_font_size(cr, MENU_ITEM_TEXT_SIZE);

  // Count non-separator items
  int non_separator_count = 0;
  for (const auto& item : self->items_) {
    if (!item.is_separator) {
      non_separator_count++;
    }
  }

  int current_y = MENU_VERTICAL_PADDING;
  bool last_was_separator = true;  // Start true to skip leading separators
  
  for (size_t i = 0; i < self->items_.size(); ++i) {
    const auto& item = self->items_[i];

    if (item.is_separator) {
      // Skip separator if:
      // 1. Only 1 or fewer non-separator items
      // 2. Last drawn item was a separator (consecutive)
      // 3. This is at the start (last_was_separator is true initially)
      // 4. This is at the end (check if remaining items are all separators)
      if (non_separator_count <= 1 || last_was_separator) {
        continue;
      }
      
      // Check if this is a trailing separator (all remaining items are separators)
      bool is_trailing = true;
      for (size_t j = i + 1; j < self->items_.size(); ++j) {
        if (!self->items_[j].is_separator) {
          is_trailing = false;
          break;
        }
      }
      if (is_trailing) {
        continue;
      }

      // Draw separator line
      int sep_y = current_y + MENU_SEPARATOR_HEIGHT / 2;
      cairo_set_source_rgba(cr, 0.8, 0.8, 0.8, 1.0);
      cairo_set_line_width(cr, 1.0);
      cairo_move_to(cr, MENU_HORIZONTAL_PADDING, sep_y);
      cairo_line_to(cr, self->width_ - MENU_HORIZONTAL_PADDING, sep_y);
      cairo_stroke(cr);

      current_y += MENU_SEPARATOR_HEIGHT;
      last_was_separator = true;
    } else {
      // Draw item background if hovered
      if (static_cast<int>(i) == self->hovered_index_ && item.enabled) {
        cairo_set_source_rgba(cr, 0.2, 0.5, 0.9, 1.0);
        cairo_rectangle(cr, 4, current_y, self->width_ - 8, MENU_ITEM_HEIGHT);
        cairo_fill(cr);
      }

      // Draw text
      if (!item.enabled) {
        cairo_set_source_rgba(cr, 0.6, 0.6, 0.6, 1.0);
      } else if (static_cast<int>(i) == self->hovered_index_) {
        cairo_set_source_rgba(cr, 1.0, 1.0, 1.0, 1.0);
      } else {
        cairo_set_source_rgba(cr, 0.1, 0.1, 0.1, 1.0);
      }

      cairo_move_to(cr, MENU_HORIZONTAL_PADDING, current_y + MENU_ITEM_HEIGHT - 10);
      cairo_show_text(cr, item.title.c_str());

      current_y += MENU_ITEM_HEIGHT;
      last_was_separator = false;
    }
  }

  return TRUE;
}

gboolean ContextMenuPopup::OnButtonPress(GtkWidget* widget, GdkEventButton* event,
                                         gpointer user_data) {
  auto* self = static_cast<ContextMenuPopup*>(user_data);

  // Get screen coordinates of the click
  gint screen_x = static_cast<gint>(event->x_root);
  gint screen_y = static_cast<gint>(event->y_root);

  // Check if click is outside the menu bounds
  bool outside = (screen_x < self->menu_x_ || screen_x >= self->menu_x_ + self->width_ ||
                  screen_y < self->menu_y_ || screen_y >= self->menu_y_ + self->height_);

  if (outside) {
    // Click was outside the menu - dismiss it
    self->Hide();
    return FALSE;  // Let the event propagate
  }

  if (event->button == 1) {
    int index = self->GetItemAtPosition(static_cast<int>(event->x), static_cast<int>(event->y));
    self->pressed_index_ = index;
  } else if (event->button == 3) {
    // Right click outside menu item dismisses
    self->Hide();
    return TRUE;
  }

  return TRUE;
}

gboolean ContextMenuPopup::OnButtonRelease(GtkWidget* widget, GdkEventButton* event,
                                           gpointer user_data) {
  auto* self = static_cast<ContextMenuPopup*>(user_data);

  if (event->button == 1) {
    int index = self->GetItemAtPosition(static_cast<int>(event->x), static_cast<int>(event->y));

    if (index >= 0 && index == self->pressed_index_ && index < static_cast<int>(self->items_.size())) {
      const auto& item = self->items_[index];
      if (item.enabled && !item.is_separator) {
        std::string id = item.id;
        std::string title = item.title;

        self->Hide();

        if (self->item_callback_) {
          self->item_callback_(id, title);
        }
      }
    }
  } else if (event->button == 3) {
    // Right click dismisses menu
    self->Hide();
  }

  self->pressed_index_ = -1;
  return TRUE;
}

gboolean ContextMenuPopup::OnMotionNotify(GtkWidget* widget, GdkEventMotion* event,
                                          gpointer user_data) {
  auto* self = static_cast<ContextMenuPopup*>(user_data);

  int index = self->GetItemAtPosition(static_cast<int>(event->x), static_cast<int>(event->y));

  if (index != self->hovered_index_) {
    self->hovered_index_ = index;
    self->Paint();
  }

  return TRUE;
}

gboolean ContextMenuPopup::OnLeaveNotify(GtkWidget* widget, GdkEventCrossing* event,
                                         gpointer user_data) {
  auto* self = static_cast<ContextMenuPopup*>(user_data);

  if (self->hovered_index_ >= 0) {
    self->hovered_index_ = -1;
    self->Paint();
  }

  return TRUE;
}

gboolean ContextMenuPopup::OnParentButtonPress(GtkWidget* widget, GdkEventButton* event,
                                               gpointer user_data) {
  auto* self = static_cast<ContextMenuPopup*>(user_data);
  // Any click on parent window while popup is visible should hide the popup
  if (self->visible_) {
    self->Hide();
  }
  return FALSE;  // Let the event continue to Flutter
}

gboolean ContextMenuPopup::OnFocusOut(GtkWidget* widget, GdkEventFocus* event, gpointer user_data) {
  auto* self = static_cast<ContextMenuPopup*>(user_data);
  if (self->visible_) {
    self->Hide();
  }
  return FALSE;
}

void ContextMenuPopup::OnUnrealize(GtkWidget* widget, gpointer user_data) {
  auto* self = static_cast<ContextMenuPopup*>(user_data);
  self->visible_ = false;
}

}  // namespace flutter_inappwebview_plugin
