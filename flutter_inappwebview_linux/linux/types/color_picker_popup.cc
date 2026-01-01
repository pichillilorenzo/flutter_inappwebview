#include "color_picker_popup.h"

#include <algorithm>
#include <cmath>
#include <cstdio>
#include <cstring>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

namespace flutter_inappwebview_plugin {

// === ColorRGBA Implementation ===

std::string ColorRGBA::toHex() const {
  char hex[8];
  int ri = static_cast<int>(std::round(r * 255));
  int gi = static_cast<int>(std::round(g * 255));
  int bi = static_cast<int>(std::round(b * 255));
  ri = std::max(0, std::min(255, ri));
  gi = std::max(0, std::min(255, gi));
  bi = std::max(0, std::min(255, bi));
  snprintf(hex, sizeof(hex), "#%02X%02X%02X", ri, gi, bi);
  return std::string(hex);
}

std::string ColorRGBA::toHexWithAlpha() const {
  char hex[10];
  int ri = static_cast<int>(std::round(r * 255));
  int gi = static_cast<int>(std::round(g * 255));
  int bi = static_cast<int>(std::round(b * 255));
  int ai = static_cast<int>(std::round(a * 255));
  ri = std::max(0, std::min(255, ri));
  gi = std::max(0, std::min(255, gi));
  bi = std::max(0, std::min(255, bi));
  ai = std::max(0, std::min(255, ai));
  snprintf(hex, sizeof(hex), "#%02X%02X%02X%02X", ri, gi, bi, ai);
  return std::string(hex);
}

ColorRGBA ColorRGBA::fromHex(const std::string& hex) {
  ColorRGBA color;
  color.r = 0;
  color.g = 0;
  color.b = 0;
  color.a = 1.0;

  std::string h = hex;

  // Check for CSS color() function format: color(display-p3 R G B) or color(display-p3 R G B / A)
  if (h.find("color(") == 0) {
    double cr = 0, cg = 0, cb = 0, ca = 1.0;
    // Try with alpha: color(display-p3 R G B / A)
    if (sscanf(h.c_str(), "color(display-p3 %lf %lf %lf / %lf)", &cr, &cg, &cb, &ca) >= 3 ||
        sscanf(h.c_str(), "color(display-p3 %lf %lf %lf)", &cr, &cg, &cb) == 3) {
      // Values are in Display P3 space, convert to sRGB for internal use
      color.r = std::max(0.0, std::min(1.0, cr));
      color.g = std::max(0.0, std::min(1.0, cg));
      color.b = std::max(0.0, std::min(1.0, cb));
      color.a = std::max(0.0, std::min(1.0, ca));
      // Convert from P3 to sRGB
      color = color.displayP3ToSRGB();
      color.a = ca;  // Preserve alpha
    }
    return color;
  }

  // Strip leading #
  if (!h.empty() && h[0] == '#') {
    h = h.substr(1);
  }

  if (h.length() == 3) {
    // #RGB format
    int ri = 0, gi = 0, bi = 0;
    sscanf(h.c_str(), "%1x%1x%1x", &ri, &gi, &bi);
    color.r = (ri * 17) / 255.0;
    color.g = (gi * 17) / 255.0;
    color.b = (bi * 17) / 255.0;
  } else if (h.length() == 6) {
    // #RRGGBB format
    int ri = 0, gi = 0, bi = 0;
    sscanf(h.c_str(), "%2x%2x%2x", &ri, &gi, &bi);
    color.r = ri / 255.0;
    color.g = gi / 255.0;
    color.b = bi / 255.0;
  } else if (h.length() == 8) {
    // #RRGGBBAA format
    int ri = 0, gi = 0, bi = 0, ai = 0;
    sscanf(h.c_str(), "%2x%2x%2x%2x", &ri, &gi, &bi, &ai);
    color.r = ri / 255.0;
    color.g = gi / 255.0;
    color.b = bi / 255.0;
    color.a = ai / 255.0;
  }

  return color;
}

void ColorRGBA::toHSV(double& h, double& s, double& v) const {
  double max_c = std::max({r, g, b});
  double min_c = std::min({r, g, b});
  double delta = max_c - min_c;

  v = max_c;
  s = (max_c == 0) ? 0 : delta / max_c;

  if (delta == 0) {
    h = 0;
  } else if (max_c == r) {
    h = 60.0 * fmod((g - b) / delta, 6.0);
  } else if (max_c == g) {
    h = 60.0 * ((b - r) / delta + 2.0);
  } else {
    h = 60.0 * ((r - g) / delta + 4.0);
  }

  if (h < 0) h += 360.0;
}

ColorRGBA ColorRGBA::fromHSV(double h, double s, double v, double a) {
  ColorRGBA color;
  color.a = a;

  double c = v * s;
  double x = c * (1.0 - fabs(fmod(h / 60.0, 2.0) - 1.0));
  double m = v - c;

  double rp = 0, gp = 0, bp = 0;

  if (h >= 0 && h < 60) { rp = c; gp = x; bp = 0; }
  else if (h >= 60 && h < 120) { rp = x; gp = c; bp = 0; }
  else if (h >= 120 && h < 180) { rp = 0; gp = c; bp = x; }
  else if (h >= 180 && h < 240) { rp = 0; gp = x; bp = c; }
  else if (h >= 240 && h < 300) { rp = x; gp = 0; bp = c; }
  else { rp = c; gp = 0; bp = x; }

  color.r = rp + m;
  color.g = gp + m;
  color.b = bp + m;

  return color;
}

// Display P3 to sRGB conversion
// Uses the standard matrix transformation from Display P3 to linear sRGB,
// then applies sRGB gamma correction
ColorRGBA ColorRGBA::displayP3ToSRGB() const {
  // First, linearize from Display P3 gamma (same as sRGB gamma)
  auto linearize = [](double v) -> double {
    if (v <= 0.04045) return v / 12.92;
    return std::pow((v + 0.055) / 1.055, 2.4);
  };

  double lr = linearize(r);
  double lg = linearize(g);
  double lb = linearize(b);

  // Display P3 to linear sRGB matrix
  // Source: https://www.color.org/chardata/rgb/DisplayP3.xalter
  double sr = 1.2249401 * lr - 0.2249402 * lg + 0.0 * lb;
  double sg = -0.0420569 * lr + 1.0420571 * lg + 0.0 * lb;
  double sb = -0.0196376 * lr - 0.0786361 * lg + 1.0982735 * lb;

  // Apply sRGB gamma
  auto gammaEncode = [](double v) -> double {
    v = std::max(0.0, std::min(1.0, v));  // Clamp for out-of-gamut colors
    if (v <= 0.0031308) return v * 12.92;
    return 1.055 * std::pow(v, 1.0 / 2.4) - 0.055;
  };

  ColorRGBA result;
  result.r = gammaEncode(sr);
  result.g = gammaEncode(sg);
  result.b = gammaEncode(sb);
  result.a = a;
  return result;
}

// sRGB to Display P3 conversion
ColorRGBA ColorRGBA::sRGBToDisplayP3() const {
  // First, linearize from sRGB gamma
  auto linearize = [](double v) -> double {
    if (v <= 0.04045) return v / 12.92;
    return std::pow((v + 0.055) / 1.055, 2.4);
  };

  double lr = linearize(r);
  double lg = linearize(g);
  double lb = linearize(b);

  // Linear sRGB to Display P3 matrix (inverse of above)
  double pr = 0.8225 * lr + 0.1774 * lg + 0.0 * lb;
  double pg = 0.0332 * lr + 0.9669 * lg + 0.0 * lb;
  double pb = 0.0171 * lr + 0.0724 * lg + 0.9108 * lb;

  // Apply Display P3 gamma (same as sRGB)
  auto gammaEncode = [](double v) -> double {
    v = std::max(0.0, std::min(1.0, v));
    if (v <= 0.0031308) return v * 12.92;
    return 1.055 * std::pow(v, 1.0 / 2.4) - 0.055;
  };

  ColorRGBA result;
  result.r = gammaEncode(pr);
  result.g = gammaEncode(pg);
  result.b = gammaEncode(pb);
  result.a = a;
  return result;
}

// === ColorPickerPopup Implementation ===

ColorPickerPopup::ColorPickerPopup(GtkWindow* parent_window) : parent_window_(parent_window) {
  popup_window_ = gtk_window_new(GTK_WINDOW_POPUP);
  gtk_window_set_type_hint(GTK_WINDOW(popup_window_), GDK_WINDOW_TYPE_HINT_POPUP_MENU);
  gtk_window_set_skip_taskbar_hint(GTK_WINDOW(popup_window_), TRUE);
  gtk_window_set_skip_pager_hint(GTK_WINDOW(popup_window_), TRUE);
  gtk_window_set_decorated(GTK_WINDOW(popup_window_), FALSE);
  gtk_window_set_resizable(GTK_WINDOW(popup_window_), FALSE);

  if (parent_window_ != nullptr) {
    gtk_window_set_transient_for(GTK_WINDOW(popup_window_), parent_window_);
  }

  GdkScreen* screen = gtk_widget_get_screen(popup_window_);
  GdkVisual* visual = gdk_screen_get_rgba_visual(screen);
  if (visual != nullptr) {
    gtk_widget_set_visual(popup_window_, visual);
  }
  gtk_widget_set_app_paintable(popup_window_, TRUE);

  drawing_area_ = gtk_drawing_area_new();
  gtk_container_add(GTK_CONTAINER(popup_window_), drawing_area_);
  gtk_widget_set_can_focus(drawing_area_, TRUE);
  gtk_widget_add_events(drawing_area_, GDK_BUTTON_PRESS_MASK | GDK_BUTTON_RELEASE_MASK |
                                           GDK_POINTER_MOTION_MASK | GDK_KEY_PRESS_MASK);

  g_signal_connect(drawing_area_, "draw", G_CALLBACK(OnDraw), this);
  g_signal_connect(drawing_area_, "button-press-event", G_CALLBACK(OnButtonPress), this);
  g_signal_connect(drawing_area_, "button-release-event", G_CALLBACK(OnButtonRelease), this);
  g_signal_connect(drawing_area_, "motion-notify-event", G_CALLBACK(OnMotionNotify), this);
  g_signal_connect(drawing_area_, "key-press-event", G_CALLBACK(OnKeyPress), this);
  g_signal_connect(popup_window_, "button-press-event", G_CALLBACK(OnButtonPress), this);
  g_signal_connect(popup_window_, "focus-out-event", G_CALLBACK(OnFocusOut), this);
  g_signal_connect(popup_window_, "unrealize", G_CALLBACK(OnUnrealize), this);

  gtk_widget_show(drawing_area_);
  SetInitialColor("#FF0000");
}

ColorPickerPopup::~ColorPickerPopup() {
  Hide();
  if (popup_window_ != nullptr) {
    gtk_widget_destroy(popup_window_);
    popup_window_ = nullptr;
  }
}

int ColorPickerPopup::CalculateHeight() const {
  int base_height = COLOR_PICKER_PADDING +           // Top padding
                    COLOR_PICKER_GRADIENT_SIZE +     // Gradient square
                    COLOR_PICKER_SPACING +           // Space
                    COLOR_PICKER_HUE_BAR_HEIGHT +    // Hue bar
                    COLOR_PICKER_SPACING;            // Space

  // Add alpha bar height if alpha is enabled
  if (alpha_enabled_) {
    base_height += COLOR_PICKER_ALPHA_BAR_HEIGHT + COLOR_PICKER_SPACING;
  }

  base_height += COLOR_PICKER_PREVIEW_SIZE + 20 +    // Preview + hex text
                 COLOR_PICKER_SPACING +              // Space
                 COLOR_PICKER_BUTTON_HEIGHT +        // Buttons
                 COLOR_PICKER_PADDING;               // Bottom padding

  if (!predefined_colors_.empty()) {
    int swatches_per_row = (COLOR_PICKER_WIDTH - 2 * COLOR_PICKER_PADDING + COLOR_PICKER_SWATCH_SPACING) /
                           (COLOR_PICKER_SWATCH_SIZE + COLOR_PICKER_SWATCH_SPACING);
    int rows = (static_cast<int>(predefined_colors_.size()) + swatches_per_row - 1) / swatches_per_row;
    base_height += COLOR_PICKER_SPACING + 14 + // "Suggested" label
                   rows * (COLOR_PICKER_SWATCH_SIZE + COLOR_PICKER_SWATCH_SPACING);
  }

  return base_height;
}

void ColorPickerPopup::SetInitialColor(const std::string& hexColor) {
  initial_color_ = ColorRGBA::fromHex(hexColor);
  current_color_ = initial_color_;
  alpha_ = initial_color_.a;
  initial_color_.toHSV(hue_, saturation_, value_);
  gradient_x_ = static_cast<int>(saturation_ * (COLOR_PICKER_GRADIENT_SIZE - 1));
  gradient_y_ = static_cast<int>((1.0 - value_) * (COLOR_PICKER_GRADIENT_SIZE - 1));
  hue_x_ = static_cast<int>((hue_ / 360.0) * (COLOR_PICKER_GRADIENT_SIZE - 1));
  alpha_x_ = static_cast<int>(alpha_ * (COLOR_PICKER_GRADIENT_SIZE - 1));
}

void ColorPickerPopup::SetPredefinedColors(const std::vector<std::string>& colors) {
  predefined_colors_ = colors;
  height_ = CalculateHeight();
}

void ColorPickerPopup::SetAlphaEnabled(bool enabled) {
  alpha_enabled_ = enabled;
  height_ = CalculateHeight();
}

void ColorPickerPopup::SetColorSpace(const std::string& colorSpace) {
  color_space_ = colorSpace;
}

std::string ColorPickerPopup::GetCurrentColor() const {
  // For display-p3 colorspace, output CSS color() function format
  if (color_space_ == "display-p3") {
    // Convert from sRGB (picker) to Display P3
    ColorRGBA p3Color = current_color_.sRGBToDisplayP3();
    char buffer[100];
    if (alpha_enabled_) {
      snprintf(buffer, sizeof(buffer), "color(display-p3 %.4f %.4f %.4f / %.4f)",
               p3Color.r, p3Color.g, p3Color.b, alpha_);
    } else {
      snprintf(buffer, sizeof(buffer), "color(display-p3 %.4f %.4f %.4f)",
               p3Color.r, p3Color.g, p3Color.b);
    }
    return std::string(buffer);
  }

  // For sRGB, return hex format
  if (alpha_enabled_) {
    return current_color_.toHexWithAlpha();
  }
  return current_color_.toHex();
}

void ColorPickerPopup::Show(int x, int y) {
  height_ = CalculateHeight();

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

  // Position popup so its top-left corner is at (x, y), adjusted for screen bounds
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

  popup_x_ = x;
  popup_y_ = y;

  gtk_widget_set_size_request(drawing_area_, width_, height_);
  gtk_window_resize(GTK_WINDOW(popup_window_), width_, height_);
  gtk_window_move(GTK_WINDOW(popup_window_), x, y);
  gtk_window_set_position(GTK_WINDOW(popup_window_), GTK_WIN_POS_NONE);
  gtk_widget_show(popup_window_);
  gtk_window_move(GTK_WINDOW(popup_window_), x, y);
  
  gtk_widget_grab_focus(drawing_area_);
  visible_ = true;

  if (parent_window_ != nullptr && parent_button_handler_id_ == 0) {
    parent_button_handler_id_ = g_signal_connect(parent_window_, "button-press-event",
                                                 G_CALLBACK(OnParentButtonPress), this);
  }
}

void ColorPickerPopup::Hide() {
  if (!visible_) return;
  visible_ = false;
  dragging_gradient_ = false;
  dragging_hue_ = false;
  dragging_alpha_ = false;

  if (parent_window_ != nullptr && parent_button_handler_id_ != 0) {
    g_signal_handler_disconnect(parent_window_, parent_button_handler_id_);
    parent_button_handler_id_ = 0;
  }
  gtk_widget_hide(popup_window_);
}

void ColorPickerPopup::Paint() {
  gtk_widget_queue_draw(drawing_area_);
}

void ColorPickerPopup::DrawRoundedRect(cairo_t* cr, double x, double y, double w, double h, double r) {
  cairo_new_path(cr);
  cairo_arc(cr, x + w - r, y + r, r, -M_PI / 2, 0);
  cairo_arc(cr, x + w - r, y + h - r, r, 0, M_PI / 2);
  cairo_arc(cr, x + r, y + h - r, r, M_PI / 2, M_PI);
  cairo_arc(cr, x + r, y + r, r, M_PI, 3 * M_PI / 2);
  cairo_close_path(cr);
}

void ColorPickerPopup::DrawBackground(cairo_t* cr) {
  // Shadow (subtle drop shadow effect)
  for (int i = 3; i > 0; i--) {
    cairo_set_source_rgba(cr, 0, 0, 0, 0.03 * i);
    DrawRoundedRect(cr, i, i, width_ - 2, height_ - 2, COLOR_PICKER_CORNER_RADIUS);
    cairo_fill(cr);
  }

  // Main background - light gray like macOS
  DrawRoundedRect(cr, 0, 0, width_, height_, COLOR_PICKER_CORNER_RADIUS);
  cairo_set_source_rgba(cr, 0.98, 0.98, 0.98, 0.98);
  cairo_fill_preserve(cr);

  // Border
  cairo_set_source_rgba(cr, 0.8, 0.8, 0.8, 1.0);
  cairo_set_line_width(cr, 0.5);
  cairo_stroke(cr);
}

void ColorPickerPopup::DrawGradientSquare(cairo_t* cr, int x, int y, int size) {
  // Create clipping region with rounded corners
  DrawRoundedRect(cr, x, y, size, size, COLOR_PICKER_INNER_RADIUS);
  cairo_clip_preserve(cr);

  // Create gradient surface
  cairo_surface_t* surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, size, size);
  unsigned char* data = cairo_image_surface_get_data(surface);
  int stride = cairo_image_surface_get_stride(surface);

  for (int py = 0; py < size; py++) {
    for (int px = 0; px < size; px++) {
      double s = static_cast<double>(px) / (size - 1);
      double v = 1.0 - static_cast<double>(py) / (size - 1);
      ColorRGBA c = ColorRGBA::fromHSV(hue_, s, v);
      unsigned char* pixel = data + py * stride + px * 4;
      pixel[0] = static_cast<unsigned char>(c.b * 255);
      pixel[1] = static_cast<unsigned char>(c.g * 255);
      pixel[2] = static_cast<unsigned char>(c.r * 255);
      pixel[3] = 255;
    }
  }

  cairo_surface_mark_dirty(surface);
  cairo_set_source_surface(cr, surface, x, y);
  cairo_paint(cr);
  cairo_surface_destroy(surface);
  cairo_reset_clip(cr);

  // Border
  DrawRoundedRect(cr, x, y, size, size, COLOR_PICKER_INNER_RADIUS);
  cairo_set_source_rgba(cr, 0.7, 0.7, 0.7, 1.0);
  cairo_set_line_width(cr, 1.0);
  cairo_stroke(cr);

  // Selector circle with shadow
  int sel_x = x + gradient_x_;
  int sel_y = y + gradient_y_;

  // Shadow
  cairo_set_source_rgba(cr, 0, 0, 0, 0.3);
  cairo_arc(cr, sel_x + 1, sel_y + 1, 8, 0, 2 * M_PI);
  cairo_fill(cr);

  // White outer ring
  cairo_set_source_rgba(cr, 1.0, 1.0, 1.0, 1.0);
  cairo_arc(cr, sel_x, sel_y, 8, 0, 2 * M_PI);
  cairo_fill(cr);

  // Current color fill
  cairo_set_source_rgba(cr, current_color_.r, current_color_.g, current_color_.b, 1.0);
  cairo_arc(cr, sel_x, sel_y, 6, 0, 2 * M_PI);
  cairo_fill(cr);
}

void ColorPickerPopup::DrawHueBar(cairo_t* cr, int x, int y, int width, int height) {
  // Clip to rounded rect
  DrawRoundedRect(cr, x, y, width, height, height / 2.0);
  cairo_clip_preserve(cr);

  // Hue gradient
  cairo_pattern_t* gradient = cairo_pattern_create_linear(x, y, x + width, y);
  for (int i = 0; i <= 6; i++) {
    ColorRGBA c = ColorRGBA::fromHSV(i * 60.0, 1.0, 1.0);
    cairo_pattern_add_color_stop_rgb(gradient, i / 6.0, c.r, c.g, c.b);
  }
  cairo_set_source(cr, gradient);
  cairo_fill(cr);
  cairo_pattern_destroy(gradient);
  cairo_reset_clip(cr);

  // Border
  DrawRoundedRect(cr, x, y, width, height, height / 2.0);
  cairo_set_source_rgba(cr, 0.7, 0.7, 0.7, 1.0);
  cairo_set_line_width(cr, 1.0);
  cairo_stroke(cr);

  // Selector handle
  int sel_x = x + hue_x_;
  int sel_y = y + height / 2;

  // Shadow
  cairo_set_source_rgba(cr, 0, 0, 0, 0.3);
  cairo_arc(cr, sel_x + 1, sel_y + 1, height / 2 + 2, 0, 2 * M_PI);
  cairo_fill(cr);

  // White circle
  cairo_set_source_rgba(cr, 1.0, 1.0, 1.0, 1.0);
  cairo_arc(cr, sel_x, sel_y, height / 2 + 2, 0, 2 * M_PI);
  cairo_fill(cr);

  // Hue color fill
  ColorRGBA hue_color = ColorRGBA::fromHSV(hue_, 1.0, 1.0);
  cairo_set_source_rgba(cr, hue_color.r, hue_color.g, hue_color.b, 1.0);
  cairo_arc(cr, sel_x, sel_y, height / 2, 0, 2 * M_PI);
  cairo_fill(cr);
}

void ColorPickerPopup::DrawAlphaBar(cairo_t* cr, int x, int y, int width, int height) {
  // Draw checkerboard background for transparency visualization
  int check_size = 4;
  DrawRoundedRect(cr, x, y, width, height, height / 2.0);
  cairo_clip_preserve(cr);

  for (int py = 0; py < height; py += check_size) {
    for (int px = 0; px < width; px += check_size) {
      bool light = ((px / check_size) + (py / check_size)) % 2 == 0;
      cairo_set_source_rgba(cr, light ? 0.95 : 0.75, light ? 0.95 : 0.75, light ? 0.95 : 0.75, 1.0);
      cairo_rectangle(cr, x + px, y + py, check_size, check_size);
      cairo_fill(cr);
    }
  }

  // Alpha gradient (transparent to current color)
  cairo_pattern_t* gradient = cairo_pattern_create_linear(x, y, x + width, y);
  cairo_pattern_add_color_stop_rgba(gradient, 0.0, current_color_.r, current_color_.g, current_color_.b, 0.0);
  cairo_pattern_add_color_stop_rgba(gradient, 1.0, current_color_.r, current_color_.g, current_color_.b, 1.0);
  cairo_set_source(cr, gradient);
  DrawRoundedRect(cr, x, y, width, height, height / 2.0);
  cairo_fill(cr);
  cairo_pattern_destroy(gradient);
  cairo_reset_clip(cr);

  // Border
  DrawRoundedRect(cr, x, y, width, height, height / 2.0);
  cairo_set_source_rgba(cr, 0.7, 0.7, 0.7, 1.0);
  cairo_set_line_width(cr, 1.0);
  cairo_stroke(cr);

  // Selector handle
  int sel_x = x + alpha_x_;
  int sel_y = y + height / 2;

  // Shadow
  cairo_set_source_rgba(cr, 0, 0, 0, 0.3);
  cairo_arc(cr, sel_x + 1, sel_y + 1, height / 2 + 2, 0, 2 * M_PI);
  cairo_fill(cr);

  // White circle with border
  cairo_set_source_rgba(cr, 1.0, 1.0, 1.0, 1.0);
  cairo_arc(cr, sel_x, sel_y, height / 2 + 2, 0, 2 * M_PI);
  cairo_fill(cr);

  // Current alpha color fill
  cairo_set_source_rgba(cr, current_color_.r, current_color_.g, current_color_.b, alpha_);
  cairo_arc(cr, sel_x, sel_y, height / 2, 0, 2 * M_PI);
  cairo_fill(cr);
}

void ColorPickerPopup::DrawPreviewAndHex(cairo_t* cr, int x, int y) {
  int preview_size = COLOR_PICKER_PREVIEW_SIZE;

  // Original color (left)
  DrawRoundedRect(cr, x, y, preview_size, preview_size, COLOR_PICKER_INNER_RADIUS);
  cairo_set_source_rgba(cr, initial_color_.r, initial_color_.g, initial_color_.b, 1.0);
  cairo_fill_preserve(cr);
  cairo_set_source_rgba(cr, 0.7, 0.7, 0.7, 1.0);
  cairo_set_line_width(cr, 1.0);
  cairo_stroke(cr);

  // Current color (right) - show with alpha if enabled
  int current_x = x + COLOR_PICKER_GRADIENT_SIZE - preview_size;
  // Draw checkerboard for alpha visualization
  if (alpha_enabled_) {
    int check_size = 4;
    DrawRoundedRect(cr, current_x, y, preview_size, preview_size, COLOR_PICKER_INNER_RADIUS);
    cairo_clip_preserve(cr);
    for (int py = 0; py < preview_size; py += check_size) {
      for (int px = 0; px < preview_size; px += check_size) {
        bool light = ((px / check_size) + (py / check_size)) % 2 == 0;
        cairo_set_source_rgba(cr, light ? 0.95 : 0.75, light ? 0.95 : 0.75, light ? 0.95 : 0.75, 1.0);
        cairo_rectangle(cr, current_x + px, y + py, check_size, check_size);
        cairo_fill(cr);
      }
    }
    cairo_reset_clip(cr);
  }
  DrawRoundedRect(cr, current_x, y, preview_size, preview_size, COLOR_PICKER_INNER_RADIUS);
  cairo_set_source_rgba(cr, current_color_.r, current_color_.g, current_color_.b, alpha_);
  cairo_fill_preserve(cr);
  cairo_set_source_rgba(cr, 0.7, 0.7, 0.7, 1.0);
  cairo_stroke(cr);

  // Hex value in center (with alpha if enabled)
  cairo_select_font_face(cr, "Sans", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD);
  cairo_set_font_size(cr, alpha_enabled_ ? 11 : 13);
  cairo_set_source_rgba(cr, 0.2, 0.2, 0.2, 1.0);

  std::string hex = alpha_enabled_ ? current_color_.toHexWithAlpha() : current_color_.toHex();
  cairo_text_extents_t extents;
  cairo_text_extents(cr, hex.c_str(), &extents);
  int text_y = y + preview_size / 2 + extents.height / 2;
  
  // If display-p3, show colorspace indicator below hex
  if (color_space_ == "display-p3") {
    text_y -= 6;
  }
  
  cairo_move_to(cr, x + (COLOR_PICKER_GRADIENT_SIZE - extents.width) / 2, text_y);
  cairo_show_text(cr, hex.c_str());

  // Show colorspace indicator for display-p3
  if (color_space_ == "display-p3") {
    cairo_set_font_size(cr, 9);
    cairo_set_source_rgba(cr, 0.4, 0.6, 0.4, 1.0);  // Green-ish for P3
    const char* p3_label = "Display P3";
    cairo_text_extents(cr, p3_label, &extents);
    cairo_move_to(cr, x + (COLOR_PICKER_GRADIENT_SIZE - extents.width) / 2, text_y + 11);
    cairo_show_text(cr, p3_label);
  }
}

void ColorPickerPopup::DrawPredefinedColors(cairo_t* cr, int x, int y, int available_width) {
  if (predefined_colors_.empty()) return;

  // Label
  cairo_select_font_face(cr, "Sans", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL);
  cairo_set_font_size(cr, 11);
  cairo_set_source_rgba(cr, 0.5, 0.5, 0.5, 1.0);
  cairo_move_to(cr, x, y + 10);
  cairo_show_text(cr, "Suggested Colors");

  int swatch_y = y + 16;
  int swatches_per_row = (available_width + COLOR_PICKER_SWATCH_SPACING) /
                         (COLOR_PICKER_SWATCH_SIZE + COLOR_PICKER_SWATCH_SPACING);

  for (size_t i = 0; i < predefined_colors_.size(); i++) {
    int row = static_cast<int>(i) / swatches_per_row;
    int col = static_cast<int>(i) % swatches_per_row;
    int sx = x + col * (COLOR_PICKER_SWATCH_SIZE + COLOR_PICKER_SWATCH_SPACING);
    int sy = swatch_y + row * (COLOR_PICKER_SWATCH_SIZE + COLOR_PICKER_SWATCH_SPACING);

    ColorRGBA c = ColorRGBA::fromHex(predefined_colors_[i]);

    // Hover effect
    bool hovered = (hovered_area_ == HitArea::Swatch && hovered_swatch_index_ == static_cast<int>(i));
    double scale = hovered ? 1.1 : 1.0;
    int offset = hovered ? -1 : 0;

    // Shadow
    if (hovered) {
      cairo_set_source_rgba(cr, 0, 0, 0, 0.2);
      DrawRoundedRect(cr, sx + offset + 2, sy + offset + 2,
                     COLOR_PICKER_SWATCH_SIZE * scale, COLOR_PICKER_SWATCH_SIZE * scale, 6);
      cairo_fill(cr);
    }

    // Color swatch
    DrawRoundedRect(cr, sx + offset, sy + offset,
                   COLOR_PICKER_SWATCH_SIZE * scale, COLOR_PICKER_SWATCH_SIZE * scale, 6);
    cairo_set_source_rgba(cr, c.r, c.g, c.b, 1.0);
    cairo_fill_preserve(cr);

    // Border
    cairo_set_source_rgba(cr, 0.7, 0.7, 0.7, 1.0);
    cairo_set_line_width(cr, hovered ? 2.0 : 1.0);
    cairo_stroke(cr);
  }
}

void ColorPickerPopup::DrawButtons(cairo_t* cr) {
  int button_y = height_ - COLOR_PICKER_PADDING - COLOR_PICKER_BUTTON_HEIGHT;
  int total_width = 2 * COLOR_PICKER_BUTTON_WIDTH + COLOR_PICKER_SPACING;
  int start_x = (width_ - total_width) / 2;
  int cancel_x = start_x;
  int ok_x = start_x + COLOR_PICKER_BUTTON_WIDTH + COLOR_PICKER_SPACING;

  cairo_select_font_face(cr, "Sans", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL);
  cairo_set_font_size(cr, 13);

  // Cancel button - gray style
  bool cancel_hovered = (hovered_area_ == HitArea::CancelButton);
  DrawRoundedRect(cr, cancel_x, button_y, COLOR_PICKER_BUTTON_WIDTH, COLOR_PICKER_BUTTON_HEIGHT, 8);
  cairo_set_source_rgba(cr, cancel_hovered ? 0.88 : 0.92, cancel_hovered ? 0.88 : 0.92,
                        cancel_hovered ? 0.88 : 0.92, 1.0);
  cairo_fill_preserve(cr);
  cairo_set_source_rgba(cr, 0.75, 0.75, 0.75, 1.0);
  cairo_set_line_width(cr, 1.0);
  cairo_stroke(cr);

  cairo_set_source_rgba(cr, 0.3, 0.3, 0.3, 1.0);
  cairo_text_extents_t extents;
  cairo_text_extents(cr, "Cancel", &extents);
  cairo_move_to(cr, cancel_x + (COLOR_PICKER_BUTTON_WIDTH - extents.width) / 2,
                button_y + (COLOR_PICKER_BUTTON_HEIGHT + extents.height) / 2);
  cairo_show_text(cr, "Cancel");

  // OK button - blue accent like macOS
  bool ok_hovered = (hovered_area_ == HitArea::OkButton);
  DrawRoundedRect(cr, ok_x, button_y, COLOR_PICKER_BUTTON_WIDTH, COLOR_PICKER_BUTTON_HEIGHT, 8);
  cairo_set_source_rgba(cr, ok_hovered ? 0.0 : 0.0, ok_hovered ? 0.45 : 0.48,
                        ok_hovered ? 0.85 : 0.95, 1.0);
  cairo_fill(cr);

  cairo_set_source_rgba(cr, 1.0, 1.0, 1.0, 1.0);
  cairo_text_extents(cr, "Select", &extents);
  cairo_move_to(cr, ok_x + (COLOR_PICKER_BUTTON_WIDTH - extents.width) / 2,
                button_y + (COLOR_PICKER_BUTTON_HEIGHT + extents.height) / 2);
  cairo_show_text(cr, "Select");
}

void ColorPickerPopup::UpdateColorFromGradient(int x, int y) {
  gradient_x_ = std::max(0, std::min(COLOR_PICKER_GRADIENT_SIZE - 1, x));
  gradient_y_ = std::max(0, std::min(COLOR_PICKER_GRADIENT_SIZE - 1, y));
  saturation_ = static_cast<double>(gradient_x_) / (COLOR_PICKER_GRADIENT_SIZE - 1);
  value_ = 1.0 - static_cast<double>(gradient_y_) / (COLOR_PICKER_GRADIENT_SIZE - 1);
  current_color_ = ColorRGBA::fromHSV(hue_, saturation_, value_, alpha_);
}

void ColorPickerPopup::UpdateHueFromBar(int x) {
  hue_x_ = std::max(0, std::min(COLOR_PICKER_GRADIENT_SIZE - 1, x));
  hue_ = (static_cast<double>(hue_x_) / (COLOR_PICKER_GRADIENT_SIZE - 1)) * 360.0;
  current_color_ = ColorRGBA::fromHSV(hue_, saturation_, value_, alpha_);
}

void ColorPickerPopup::UpdateAlphaFromBar(int x) {
  alpha_x_ = std::max(0, std::min(COLOR_PICKER_GRADIENT_SIZE - 1, x));
  alpha_ = static_cast<double>(alpha_x_) / (COLOR_PICKER_GRADIENT_SIZE - 1);
  current_color_.a = alpha_;
}

void ColorPickerPopup::UpdateColorFromSwatch(int index) {
  if (index >= 0 && index < static_cast<int>(predefined_colors_.size())) {
    current_color_ = ColorRGBA::fromHex(predefined_colors_[index]);
    alpha_ = current_color_.a;
    current_color_.toHSV(hue_, saturation_, value_);
    gradient_x_ = static_cast<int>(saturation_ * (COLOR_PICKER_GRADIENT_SIZE - 1));
    gradient_y_ = static_cast<int>((1.0 - value_) * (COLOR_PICKER_GRADIENT_SIZE - 1));
    hue_x_ = static_cast<int>((hue_ / 360.0) * (COLOR_PICKER_GRADIENT_SIZE - 1));
    alpha_x_ = static_cast<int>(alpha_ * (COLOR_PICKER_GRADIENT_SIZE - 1));
  }
}

ColorRGBA ColorPickerPopup::GetColorAtGradientPosition(int x, int y) const {
  double s = static_cast<double>(x) / (COLOR_PICKER_GRADIENT_SIZE - 1);
  double v = 1.0 - static_cast<double>(y) / (COLOR_PICKER_GRADIENT_SIZE - 1);
  return ColorRGBA::fromHSV(hue_, s, v);
}

ColorPickerPopup::HitArea ColorPickerPopup::GetHitArea(int x, int y, int* swatch_index) const {
  int gradient_left = (width_ - COLOR_PICKER_GRADIENT_SIZE) / 2;
  int gradient_top = COLOR_PICKER_PADDING;
  int hue_top = gradient_top + COLOR_PICKER_GRADIENT_SIZE + COLOR_PICKER_SPACING;
  int alpha_top = hue_top + COLOR_PICKER_HUE_BAR_HEIGHT + COLOR_PICKER_SPACING;
  int preview_top = alpha_enabled_
                        ? alpha_top + COLOR_PICKER_ALPHA_BAR_HEIGHT + COLOR_PICKER_SPACING
                        : hue_top + COLOR_PICKER_HUE_BAR_HEIGHT + COLOR_PICKER_SPACING;

  // Gradient
  if (x >= gradient_left && x < gradient_left + COLOR_PICKER_GRADIENT_SIZE &&
      y >= gradient_top && y < gradient_top + COLOR_PICKER_GRADIENT_SIZE) {
    return HitArea::Gradient;
  }

  // Hue bar
  if (x >= gradient_left && x < gradient_left + COLOR_PICKER_GRADIENT_SIZE &&
      y >= hue_top && y < hue_top + COLOR_PICKER_HUE_BAR_HEIGHT) {
    return HitArea::HueBar;
  }

  // Alpha bar (only if enabled)
  if (alpha_enabled_ &&
      x >= gradient_left && x < gradient_left + COLOR_PICKER_GRADIENT_SIZE &&
      y >= alpha_top && y < alpha_top + COLOR_PICKER_ALPHA_BAR_HEIGHT) {
    return HitArea::AlphaBar;
  }

  // Predefined colors
  if (!predefined_colors_.empty()) {
    int swatch_area_top = preview_top + COLOR_PICKER_PREVIEW_SIZE + COLOR_PICKER_SPACING + 14;
    int available_width = COLOR_PICKER_GRADIENT_SIZE;
    int swatches_per_row = (available_width + COLOR_PICKER_SWATCH_SPACING) /
                           (COLOR_PICKER_SWATCH_SIZE + COLOR_PICKER_SWATCH_SPACING);

    for (size_t i = 0; i < predefined_colors_.size(); i++) {
      int row = static_cast<int>(i) / swatches_per_row;
      int col = static_cast<int>(i) % swatches_per_row;
      int sx = gradient_left + col * (COLOR_PICKER_SWATCH_SIZE + COLOR_PICKER_SWATCH_SPACING);
      int sy = swatch_area_top + row * (COLOR_PICKER_SWATCH_SIZE + COLOR_PICKER_SWATCH_SPACING);

      if (x >= sx && x < sx + COLOR_PICKER_SWATCH_SIZE &&
          y >= sy && y < sy + COLOR_PICKER_SWATCH_SIZE) {
        if (swatch_index) *swatch_index = static_cast<int>(i);
        return HitArea::Swatch;
      }
    }
  }

  // Buttons
  int button_y = height_ - COLOR_PICKER_PADDING - COLOR_PICKER_BUTTON_HEIGHT;
  int total_width = 2 * COLOR_PICKER_BUTTON_WIDTH + COLOR_PICKER_SPACING;
  int start_x = (width_ - total_width) / 2;

  if (y >= button_y && y < button_y + COLOR_PICKER_BUTTON_HEIGHT) {
    if (x >= start_x && x < start_x + COLOR_PICKER_BUTTON_WIDTH) {
      return HitArea::CancelButton;
    }
    if (x >= start_x + COLOR_PICKER_BUTTON_WIDTH + COLOR_PICKER_SPACING &&
        x < start_x + total_width) {
      return HitArea::OkButton;
    }
  }

  return HitArea::None;
}

gboolean ColorPickerPopup::OnDraw(GtkWidget* widget, cairo_t* cr, gpointer user_data) {
  auto* self = static_cast<ColorPickerPopup*>(user_data);

  cairo_set_operator(cr, CAIRO_OPERATOR_SOURCE);
  cairo_set_source_rgba(cr, 0, 0, 0, 0);
  cairo_paint(cr);
  cairo_set_operator(cr, CAIRO_OPERATOR_OVER);

  self->DrawBackground(cr);

  int gradient_left = (self->width_ - COLOR_PICKER_GRADIENT_SIZE) / 2;
  int gradient_top = COLOR_PICKER_PADDING;
  int hue_top = gradient_top + COLOR_PICKER_GRADIENT_SIZE + COLOR_PICKER_SPACING;
  int alpha_top = hue_top + COLOR_PICKER_HUE_BAR_HEIGHT + COLOR_PICKER_SPACING;
  int preview_top = self->alpha_enabled_
                        ? alpha_top + COLOR_PICKER_ALPHA_BAR_HEIGHT + COLOR_PICKER_SPACING
                        : hue_top + COLOR_PICKER_HUE_BAR_HEIGHT + COLOR_PICKER_SPACING;

  self->DrawGradientSquare(cr, gradient_left, gradient_top, COLOR_PICKER_GRADIENT_SIZE);
  self->DrawHueBar(cr, gradient_left, hue_top, COLOR_PICKER_GRADIENT_SIZE, COLOR_PICKER_HUE_BAR_HEIGHT);

  if (self->alpha_enabled_) {
    self->DrawAlphaBar(cr, gradient_left, alpha_top, COLOR_PICKER_GRADIENT_SIZE, COLOR_PICKER_ALPHA_BAR_HEIGHT);
  }

  self->DrawPreviewAndHex(cr, gradient_left, preview_top);

  if (!self->predefined_colors_.empty()) {
    int swatch_top = preview_top + COLOR_PICKER_PREVIEW_SIZE + COLOR_PICKER_SPACING;
    self->DrawPredefinedColors(cr, gradient_left, swatch_top, COLOR_PICKER_GRADIENT_SIZE);
  }

  self->DrawButtons(cr);

  return TRUE;
}

gboolean ColorPickerPopup::OnButtonPress(GtkWidget* widget, GdkEventButton* event, gpointer user_data) {
  auto* self = static_cast<ColorPickerPopup*>(user_data);

  gint screen_x = static_cast<gint>(event->x_root);
  gint screen_y = static_cast<gint>(event->y_root);

  bool outside = (screen_x < self->popup_x_ || screen_x >= self->popup_x_ + self->width_ ||
                  screen_y < self->popup_y_ || screen_y >= self->popup_y_ + self->height_);

  if (outside) {
    self->Hide();
    if (self->color_cancelled_callback_) self->color_cancelled_callback_();
    return FALSE;
  }

  if (event->button != 1) return TRUE;

  int local_x = static_cast<int>(event->x);
  int local_y = static_cast<int>(event->y);
  int gradient_left = (self->width_ - COLOR_PICKER_GRADIENT_SIZE) / 2;
  int gradient_top = COLOR_PICKER_PADDING;

  int swatch_index = -1;
  HitArea area = self->GetHitArea(local_x, local_y, &swatch_index);

  switch (area) {
    case HitArea::Gradient:
      self->dragging_gradient_ = true;
      self->UpdateColorFromGradient(local_x - gradient_left, local_y - gradient_top);
      self->Paint();
      break;
    case HitArea::HueBar:
      self->dragging_hue_ = true;
      self->UpdateHueFromBar(local_x - gradient_left);
      self->Paint();
      break;
    case HitArea::AlphaBar:
      self->dragging_alpha_ = true;
      self->UpdateAlphaFromBar(local_x - gradient_left);
      self->Paint();
      break;
    case HitArea::Swatch:
      self->UpdateColorFromSwatch(swatch_index);
      self->Paint();
      break;
    case HitArea::OkButton:
      self->Hide();
      if (self->color_selected_callback_) self->color_selected_callback_(self->GetCurrentColor());
      break;
    case HitArea::CancelButton:
      self->Hide();
      if (self->color_cancelled_callback_) self->color_cancelled_callback_();
      break;
    default:
      break;
  }

  return TRUE;
}

gboolean ColorPickerPopup::OnButtonRelease(GtkWidget* widget, GdkEventButton* event, gpointer user_data) {
  auto* self = static_cast<ColorPickerPopup*>(user_data);
  self->dragging_gradient_ = false;
  self->dragging_hue_ = false;
  self->dragging_alpha_ = false;
  return TRUE;
}

gboolean ColorPickerPopup::OnMotionNotify(GtkWidget* widget, GdkEventMotion* event, gpointer user_data) {
  auto* self = static_cast<ColorPickerPopup*>(user_data);

  int local_x = static_cast<int>(event->x);
  int local_y = static_cast<int>(event->y);
  int gradient_left = (self->width_ - COLOR_PICKER_GRADIENT_SIZE) / 2;
  int gradient_top = COLOR_PICKER_PADDING;

  if (self->dragging_gradient_) {
    self->UpdateColorFromGradient(local_x - gradient_left, local_y - gradient_top);
    self->Paint();
  } else if (self->dragging_hue_) {
    self->UpdateHueFromBar(local_x - gradient_left);
    self->Paint();
  } else if (self->dragging_alpha_) {
    self->UpdateAlphaFromBar(local_x - gradient_left);
    self->Paint();
  } else {
    int swatch_index = -1;
    HitArea new_area = self->GetHitArea(local_x, local_y, &swatch_index);
    if (new_area != self->hovered_area_ || swatch_index != self->hovered_swatch_index_) {
      self->hovered_area_ = new_area;
      self->hovered_swatch_index_ = swatch_index;
      self->Paint();
    }
  }

  return TRUE;
}

gboolean ColorPickerPopup::OnKeyPress(GtkWidget* widget, GdkEventKey* event, gpointer user_data) {
  auto* self = static_cast<ColorPickerPopup*>(user_data);

  switch (event->keyval) {
    case GDK_KEY_Escape:
      self->Hide();
      if (self->color_cancelled_callback_) self->color_cancelled_callback_();
      return TRUE;
    case GDK_KEY_Return:
    case GDK_KEY_KP_Enter:
      self->Hide();
      if (self->color_selected_callback_) self->color_selected_callback_(self->GetCurrentColor());
      return TRUE;
    default:
      break;
  }
  return FALSE;
}

gboolean ColorPickerPopup::OnParentButtonPress(GtkWidget* widget, GdkEventButton* event, gpointer user_data) {
  auto* self = static_cast<ColorPickerPopup*>(user_data);
  if (self->visible_) {
    self->Hide();
    if (self->color_cancelled_callback_) self->color_cancelled_callback_();
  }
  return FALSE;
}

gboolean ColorPickerPopup::OnFocusOut(GtkWidget* widget, GdkEventFocus* event, gpointer user_data) {
  auto* self = static_cast<ColorPickerPopup*>(user_data);
  if (self->visible_) {
    self->Hide();
    if (self->color_cancelled_callback_) self->color_cancelled_callback_();
  }
  return FALSE;
}

void ColorPickerPopup::OnUnrealize(GtkWidget* widget, gpointer user_data) {
  auto* self = static_cast<ColorPickerPopup*>(user_data);
  self->visible_ = false;
}

}  // namespace flutter_inappwebview_plugin
