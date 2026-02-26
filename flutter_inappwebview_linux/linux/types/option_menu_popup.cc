#include "option_menu_popup.h"

#include <wpe/webkit.h>

#include <algorithm>
#include <cmath>
#include <cstring>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

namespace flutter_inappwebview_plugin {

OptionMenuPopup::OptionMenuPopup(GtkWindow* parent_window) : parent_window_(parent_window) {
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
  gtk_widget_set_can_focus(drawing_area_, TRUE);
  gtk_container_add(GTK_CONTAINER(popup_window_), drawing_area_);

  // Enable events on drawing area
  gtk_widget_add_events(drawing_area_,
                        GDK_BUTTON_PRESS_MASK | GDK_BUTTON_RELEASE_MASK | GDK_POINTER_MOTION_MASK |
                            GDK_LEAVE_NOTIFY_MASK | GDK_SCROLL_MASK | GDK_KEY_PRESS_MASK);

  // Connect signals for drawing area
  g_signal_connect(drawing_area_, "draw", G_CALLBACK(OnDraw), this);
  g_signal_connect(drawing_area_, "button-press-event", G_CALLBACK(OnButtonPress), this);
  g_signal_connect(drawing_area_, "button-release-event", G_CALLBACK(OnButtonRelease), this);
  g_signal_connect(drawing_area_, "motion-notify-event", G_CALLBACK(OnMotionNotify), this);
  g_signal_connect(drawing_area_, "leave-notify-event", G_CALLBACK(OnLeaveNotify), this);
  g_signal_connect(drawing_area_, "scroll-event", G_CALLBACK(OnScroll), this);
  g_signal_connect(drawing_area_, "key-press-event", G_CALLBACK(OnKeyPress), this);

  // Also connect button-press to popup window for when clicks land on window edge
  g_signal_connect(popup_window_, "button-press-event", G_CALLBACK(OnButtonPress), this);

  // Connect signals for popup window
  g_signal_connect(popup_window_, "focus-out-event", G_CALLBACK(OnFocusOut), this);
  g_signal_connect(popup_window_, "unrealize", G_CALLBACK(OnUnrealize), this);

  gtk_widget_show(drawing_area_);
}

OptionMenuPopup::~OptionMenuPopup() {
  Hide();  // Ensure cleanup
  if (popup_window_ != nullptr) {
    gtk_widget_destroy(popup_window_);
    popup_window_ = nullptr;
  }
}

void OptionMenuPopup::SetOptionMenu(WebKitOptionMenu* menu) {
  webkit_menu_ = menu;
  UpdateItems();
}

void OptionMenuPopup::UpdateItems() {
  items_.clear();
  initially_selected_index_ = -1;
  
  if (webkit_menu_ == nullptr) {
    return;
  }
  
  guint n_items = webkit_option_menu_get_n_items(webkit_menu_);
  
  for (guint i = 0; i < n_items; i++) {
    WebKitOptionMenuItem* item = webkit_option_menu_get_item(webkit_menu_, i);
    
    MenuItem menu_item;
    const gchar* label = webkit_option_menu_item_get_label(item);
    menu_item.label = label ? label : "";
    menu_item.enabled = webkit_option_menu_item_is_enabled(item);
    menu_item.selected = webkit_option_menu_item_is_selected(item);
    menu_item.is_group_label = webkit_option_menu_item_is_group_label(item);
    menu_item.is_group_child = webkit_option_menu_item_is_group_child(item);
    
    if (menu_item.selected && menu_item.enabled && !menu_item.is_group_label) {
      initially_selected_index_ = static_cast<int>(i);
    }
    
    items_.push_back(std::move(menu_item));
  }
}

void OptionMenuPopup::UpdateSize() {
  if (items_.empty()) {
    width_ = MENU_MIN_WIDTH;
    height_ = MENU_VERTICAL_PADDING * 2;
    content_height_ = 0;
    return;
  }

  // Calculate width based on text
  cairo_surface_t* surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 1, 1);
  cairo_t* cr = cairo_create(surface);

  cairo_select_font_face(cr, "Sans", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL);
  cairo_set_font_size(cr, MENU_ITEM_TEXT_SIZE);

  int max_text_width = 0;
  for (const auto& item : items_) {
    cairo_text_extents_t extents;
    cairo_text_extents(cr, item.label.c_str(), &extents);
    max_text_width = std::max(max_text_width, static_cast<int>(extents.width));
  }

  cairo_destroy(cr);
  cairo_surface_destroy(surface);

  // Add padding for margins
  width_ = std::max(MENU_MIN_WIDTH, std::min(MENU_MAX_WIDTH, 
                                              max_text_width + MENU_HORIZONTAL_PADDING * 4));

  // Calculate content height
  content_height_ = 0;
  for (const auto& item : items_) {
    if (item.is_group_label) {
      content_height_ += MENU_GROUP_LABEL_HEIGHT;
    } else {
      content_height_ += MENU_ITEM_HEIGHT;
    }
  }

  // Limit visible height
  int max_visible_height = MENU_MAX_VISIBLE_ITEMS * MENU_ITEM_HEIGHT + MENU_VERTICAL_PADDING * 2;
  height_ = std::min(content_height_ + MENU_VERTICAL_PADDING * 2, max_visible_height);
}

void OptionMenuPopup::Show(int x, int y, int min_width) {
  if (items_.empty()) {
    return;
  }

  UpdateSize();
  
  // Use the HTML <select> element's width if provided (ensures menu matches element width)
  if (min_width > 0) {
    width_ = min_width;
  }

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

  // Position menu so it doesn't go off screen
  if (x + width_ > screen_width) {
    x = screen_width - width_;
  }
  if (y + height_ > screen_height) {
    y = y - height_;
  }
  if (x < screen_x) {
    x = screen_x;
  }
  if (y < screen_y) {
    y = screen_y;
  }

  // Store menu position for outside click detection
  menu_x_ = x;
  menu_y_ = y;

  // Reset scroll and selection state
  scroll_offset_ = 0;
  hovered_index_ = -1;
  pressed_index_ = -1;

  gtk_widget_set_size_request(drawing_area_, width_, height_);
  gtk_window_resize(GTK_WINDOW(popup_window_), width_, height_);
  gtk_window_move(GTK_WINDOW(popup_window_), x, y);
  gtk_window_set_position(GTK_WINDOW(popup_window_), GTK_WIN_POS_NONE);
  gtk_widget_show(popup_window_);
  gtk_window_move(GTK_WINDOW(popup_window_), x, y);
  
  // Grab keyboard focus
  gtk_widget_grab_focus(drawing_area_);
  
  visible_ = true;

  // Scroll to initially selected item
  if (initially_selected_index_ >= 0) {
    ScrollToItem(initially_selected_index_);
  }

  // Connect to parent window as fallback for clicks outside Flutter area
  if (parent_window_ != nullptr && parent_button_handler_id_ == 0) {
    parent_button_handler_id_ = g_signal_connect(
        parent_window_, "button-press-event", G_CALLBACK(OnParentButtonPress), this);
  }
}

void OptionMenuPopup::Hide() {
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

void OptionMenuPopup::ScrollToItem(int index) {
  if (index < 0 || index >= static_cast<int>(items_.size())) {
    return;
  }
  
  // Calculate y position of item
  int item_y = 0;
  for (int i = 0; i < index; i++) {
    if (items_[i].is_group_label) {
      item_y += MENU_GROUP_LABEL_HEIGHT;
    } else {
      item_y += MENU_ITEM_HEIGHT;
    }
  }
  
  int visible_height = height_ - MENU_VERTICAL_PADDING * 2;
  
  // If item is above visible area, scroll up
  if (item_y < scroll_offset_) {
    scroll_offset_ = item_y;
  }
  // If item is below visible area, scroll down
  else if (item_y + MENU_ITEM_HEIGHT > scroll_offset_ + visible_height) {
    scroll_offset_ = item_y + MENU_ITEM_HEIGHT - visible_height;
  }
  
  // Clamp scroll
  scroll_offset_ = std::max(0, std::min(scroll_offset_, 
                                         content_height_ - visible_height));
}

int OptionMenuPopup::GetItemAtPosition(int x, int y) const {
  if (x < 0 || x >= width_) {
    return -1;
  }

  int adjusted_y = y - MENU_VERTICAL_PADDING + scroll_offset_;
  int current_y = 0;
  
  for (size_t i = 0; i < items_.size(); ++i) {
    int item_height = items_[i].is_group_label ? MENU_GROUP_LABEL_HEIGHT : MENU_ITEM_HEIGHT;

    if (adjusted_y >= current_y && adjusted_y < current_y + item_height) {
      // Can't select group labels or disabled items
      if (items_[i].is_group_label || !items_[i].enabled) {
        return -1;
      }
      return static_cast<int>(i);
    }

    current_y += item_height;
  }

  return -1;
}

void OptionMenuPopup::Paint() {
  gtk_widget_queue_draw(drawing_area_);
}

gboolean OptionMenuPopup::OnDraw(GtkWidget* widget, cairo_t* cr, gpointer user_data) {
  auto* self = static_cast<OptionMenuPopup*>(user_data);

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

  // Set up clipping for content area
  cairo_save(cr);
  cairo_rectangle(cr, 0, MENU_VERTICAL_PADDING, 
                  self->width_, self->height_ - MENU_VERTICAL_PADDING * 2);
  cairo_clip(cr);

  // Draw items
  cairo_select_font_face(cr, "Sans", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL);
  cairo_set_font_size(cr, MENU_ITEM_TEXT_SIZE);

  int current_y = MENU_VERTICAL_PADDING - self->scroll_offset_;
  
  for (size_t i = 0; i < self->items_.size(); ++i) {
    const auto& item = self->items_[i];
    int item_height = item.is_group_label ? MENU_GROUP_LABEL_HEIGHT : MENU_ITEM_HEIGHT;

    // Skip if not visible
    if (current_y + item_height < 0) {
      current_y += item_height;
      continue;
    }
    if (current_y > self->height_) {
      break;
    }

    if (item.is_group_label) {
      // Draw group label (bold, no selection)
      cairo_set_source_rgba(cr, 0.4, 0.4, 0.4, 1.0);
      
      cairo_select_font_face(cr, "Sans", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD);
      cairo_move_to(cr, MENU_HORIZONTAL_PADDING, current_y + item_height - 8);
      cairo_show_text(cr, item.label.c_str());
      cairo_select_font_face(cr, "Sans", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL);
    } else {
      // Draw item background if hovered or selected
      if (static_cast<int>(i) == self->hovered_index_ && item.enabled) {
        cairo_set_source_rgba(cr, 0.2, 0.5, 0.9, 1.0);
        cairo_rectangle(cr, 4, current_y, self->width_ - 8, item_height);
        cairo_fill(cr);
      } else if (item.selected) {
        cairo_set_source_rgba(cr, 0.85, 0.9, 1.0, 1.0);
        cairo_rectangle(cr, 4, current_y, self->width_ - 8, item_height);
        cairo_fill(cr);
      }

      // Calculate text position with group child indent
      int text_x = MENU_HORIZONTAL_PADDING;
      if (item.is_group_child) {
        text_x += 16;
      }

      // Draw text
      if (!item.enabled) {
        cairo_set_source_rgba(cr, 0.6, 0.6, 0.6, 1.0);
      } else if (static_cast<int>(i) == self->hovered_index_) {
        cairo_set_source_rgba(cr, 1.0, 1.0, 1.0, 1.0);
      } else {
        cairo_set_source_rgba(cr, 0.1, 0.1, 0.1, 1.0);
      }

      cairo_move_to(cr, text_x, current_y + item_height / 2 + 5);
      cairo_show_text(cr, item.label.c_str());
    }

    current_y += item_height;
  }

  cairo_restore(cr);

  // Draw scroll indicators if needed
  int visible_height = self->height_ - MENU_VERTICAL_PADDING * 2;
  if (self->content_height_ > visible_height) {
    // Top scroll indicator
    if (self->scroll_offset_ > 0) {
      cairo_set_source_rgba(cr, 0.5, 0.5, 0.5, 0.8);
      cairo_move_to(cr, self->width_ / 2, 6);
      cairo_line_to(cr, self->width_ / 2 - 6, 12);
      cairo_line_to(cr, self->width_ / 2 + 6, 12);
      cairo_close_path(cr);
      cairo_fill(cr);
    }
    
    // Bottom scroll indicator
    if (self->scroll_offset_ < self->content_height_ - visible_height) {
      cairo_set_source_rgba(cr, 0.5, 0.5, 0.5, 0.8);
      cairo_move_to(cr, self->width_ / 2, self->height_ - 6);
      cairo_line_to(cr, self->width_ / 2 - 6, self->height_ - 12);
      cairo_line_to(cr, self->width_ / 2 + 6, self->height_ - 12);
      cairo_close_path(cr);
      cairo_fill(cr);
    }
  }

  return TRUE;
}

gboolean OptionMenuPopup::OnButtonPress(GtkWidget* widget, GdkEventButton* event,
                                         gpointer user_data) {
  auto* self = static_cast<OptionMenuPopup*>(user_data);

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
    // Right click dismisses
    self->Hide();
    return TRUE;
  }

  return TRUE;
}

gboolean OptionMenuPopup::OnButtonRelease(GtkWidget* widget, GdkEventButton* event,
                                           gpointer user_data) {
  auto* self = static_cast<OptionMenuPopup*>(user_data);

  if (event->button == 1) {
    int index = self->GetItemAtPosition(static_cast<int>(event->x), static_cast<int>(event->y));

    if (index >= 0 && index == self->pressed_index_ && index < static_cast<int>(self->items_.size())) {
      const auto& item = self->items_[index];
      if (item.enabled && !item.is_group_label) {
        int selected_index = index;
        
        // Clear dismissed callback since we're selecting an item
        auto item_callback = self->item_selected_callback_;
        self->dismissed_callback_ = nullptr;
        
        self->Hide();

        if (item_callback) {
          item_callback(selected_index);
        }
        
        return TRUE;
      }
    }
  }

  self->pressed_index_ = -1;
  return TRUE;
}

gboolean OptionMenuPopup::OnMotionNotify(GtkWidget* widget, GdkEventMotion* event,
                                          gpointer user_data) {
  auto* self = static_cast<OptionMenuPopup*>(user_data);

  int index = self->GetItemAtPosition(static_cast<int>(event->x), static_cast<int>(event->y));

  if (index != self->hovered_index_) {
    self->hovered_index_ = index;
    self->Paint();
  }

  return TRUE;
}

gboolean OptionMenuPopup::OnLeaveNotify(GtkWidget* widget, GdkEventCrossing* event,
                                         gpointer user_data) {
  auto* self = static_cast<OptionMenuPopup*>(user_data);

  if (self->hovered_index_ >= 0) {
    self->hovered_index_ = -1;
    self->Paint();
  }

  return TRUE;
}

gboolean OptionMenuPopup::OnScroll(GtkWidget* widget, GdkEventScroll* event,
                                    gpointer user_data) {
  auto* self = static_cast<OptionMenuPopup*>(user_data);
  
  int visible_height = self->height_ - MENU_VERTICAL_PADDING * 2;
  int max_scroll = std::max(0, self->content_height_ - visible_height);
  
  int scroll_step = MENU_ITEM_HEIGHT;
  
  switch (event->direction) {
    case GDK_SCROLL_UP:
      self->scroll_offset_ = std::max(0, self->scroll_offset_ - scroll_step);
      self->Paint();
      break;
    case GDK_SCROLL_DOWN:
      self->scroll_offset_ = std::min(max_scroll, self->scroll_offset_ + scroll_step);
      self->Paint();
      break;
    case GDK_SCROLL_SMOOTH:
      self->scroll_offset_ -= static_cast<int>(event->delta_y * scroll_step);
      self->scroll_offset_ = std::max(0, std::min(max_scroll, self->scroll_offset_));
      self->Paint();
      break;
    default:
      break;
  }
  
  // Update hovered item after scroll
  gint x, y;
  GdkWindow* window = gtk_widget_get_window(widget);
  GdkDevice* device = gdk_seat_get_pointer(gdk_display_get_default_seat(gdk_display_get_default()));
  if (window != nullptr && device != nullptr) {
    gdk_window_get_device_position(window, device, &x, &y, nullptr);
    int index = self->GetItemAtPosition(x, y);
    if (index != self->hovered_index_) {
      self->hovered_index_ = index;
      self->Paint();
    }
  }
  
  return TRUE;
}

gboolean OptionMenuPopup::OnKeyPress(GtkWidget* widget, GdkEventKey* event,
                                      gpointer user_data) {
  auto* self = static_cast<OptionMenuPopup*>(user_data);
  
  switch (event->keyval) {
    case GDK_KEY_Escape:
      self->Hide();
      return TRUE;
      
    case GDK_KEY_Return:
    case GDK_KEY_KP_Enter:
      if (self->hovered_index_ >= 0 && self->hovered_index_ < static_cast<int>(self->items_.size())) {
        const auto& item = self->items_[self->hovered_index_];
        if (item.enabled && !item.is_group_label) {
          int selected_index = self->hovered_index_;
          
          auto item_callback = self->item_selected_callback_;
          self->dismissed_callback_ = nullptr;
          
          self->Hide();
          
          if (item_callback) {
            item_callback(selected_index);
          }
          return TRUE;
        }
      }
      break;
      
    case GDK_KEY_Up:
    case GDK_KEY_KP_Up: {
      // Find previous selectable item
      int new_index = self->hovered_index_ >= 0 ? self->hovered_index_ - 1 : 
                      static_cast<int>(self->items_.size()) - 1;
      while (new_index >= 0) {
        if (self->items_[new_index].enabled && !self->items_[new_index].is_group_label) {
          self->hovered_index_ = new_index;
          self->ScrollToItem(new_index);
          self->Paint();
          break;
        }
        new_index--;
      }
      return TRUE;
    }
      
    case GDK_KEY_Down:
    case GDK_KEY_KP_Down: {
      // Find next selectable item
      int new_index = self->hovered_index_ >= 0 ? self->hovered_index_ + 1 : 0;
      while (new_index < static_cast<int>(self->items_.size())) {
        if (self->items_[new_index].enabled && !self->items_[new_index].is_group_label) {
          self->hovered_index_ = new_index;
          self->ScrollToItem(new_index);
          self->Paint();
          break;
        }
        new_index++;
      }
      return TRUE;
    }
      
    default:
      break;
  }
  
  return FALSE;
}

gboolean OptionMenuPopup::OnParentButtonPress(GtkWidget* widget, GdkEventButton* event,
                                               gpointer user_data) {
  auto* self = static_cast<OptionMenuPopup*>(user_data);
  // Any click on parent window while popup is visible should hide the popup
  if (self->visible_) {
    self->Hide();
  }
  return FALSE;  // Let the event continue to Flutter
}

gboolean OptionMenuPopup::OnFocusOut(GtkWidget* widget, GdkEventFocus* event, gpointer user_data) {
  auto* self = static_cast<OptionMenuPopup*>(user_data);
  if (self->visible_) {
    self->Hide();
  }
  return FALSE;
}

void OptionMenuPopup::OnUnrealize(GtkWidget* widget, gpointer user_data) {
  auto* self = static_cast<OptionMenuPopup*>(user_data);
  self->visible_ = false;
}

}  // namespace flutter_inappwebview_plugin
