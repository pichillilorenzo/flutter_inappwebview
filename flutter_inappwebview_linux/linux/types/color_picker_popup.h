#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_COLOR_PICKER_POPUP_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_COLOR_PICKER_POPUP_H_

#include <cairo.h>
#include <gtk/gtk.h>

#include <functional>
#include <string>
#include <vector>

namespace flutter_inappwebview_plugin {

// Constants for modern iOS/macOS-style color picker rendering
constexpr int COLOR_PICKER_WIDTH = 280;
constexpr int COLOR_PICKER_MIN_HEIGHT = 340;
constexpr int COLOR_PICKER_PADDING = 12;
constexpr int COLOR_PICKER_GRADIENT_SIZE = 200;
constexpr int COLOR_PICKER_HUE_BAR_HEIGHT = 14;
constexpr int COLOR_PICKER_ALPHA_BAR_HEIGHT = 14;
constexpr int COLOR_PICKER_PREVIEW_SIZE = 40;
constexpr int COLOR_PICKER_BUTTON_HEIGHT = 32;
constexpr int COLOR_PICKER_BUTTON_WIDTH = 80;
constexpr int COLOR_PICKER_SPACING = 10;
constexpr int COLOR_PICKER_SWATCH_SIZE = 26;
constexpr int COLOR_PICKER_SWATCH_SPACING = 5;
constexpr int COLOR_PICKER_CORNER_RADIUS = 10;
constexpr int COLOR_PICKER_INNER_RADIUS = 6;

struct ColorRGBA {
  double r = 0.0;  // 0-1
  double g = 0.0;  // 0-1
  double b = 0.0;  // 0-1
  double a = 1.0;  // 0-1

  // Convert to hex string (#RRGGBB format)
  std::string toHex() const;

  // Convert to hex string with alpha (#RRGGBBAA format)
  std::string toHexWithAlpha() const;

  // Parse from hex string (#RRGGBB, #RRGGBBAA, or #RGB format)
  static ColorRGBA fromHex(const std::string& hex);

  // Convert to/from HSV
  void toHSV(double& h, double& s, double& v) const;
  static ColorRGBA fromHSV(double h, double s, double v, double a = 1.0);

  // Display P3 color space conversions
  // Convert from Display P3 to sRGB (for display on standard monitors)
  ColorRGBA displayP3ToSRGB() const;
  // Convert from sRGB to Display P3 (for output)
  ColorRGBA sRGBToDisplayP3() const;
};

// Callback when a color is selected
using ColorSelectedCallback = std::function<void(const std::string& hexColor)>;
// Callback when the picker is cancelled
using ColorCancelledCallback = std::function<void()>;

class ColorPickerPopup {
 public:
  explicit ColorPickerPopup(GtkWindow* parent_window);
  ~ColorPickerPopup();

  // Set the initial color (hex format: #RRGGBB or #RRGGBBAA)
  void SetInitialColor(const std::string& hexColor);

  // Set predefined colors (from HTML datalist/list attribute)
  void SetPredefinedColors(const std::vector<std::string>& colors);

  // Set whether alpha channel is enabled (from HTML alpha attribute)
  void SetAlphaEnabled(bool enabled);

  // Set the color space (from HTML colorspace attribute: "limited-srgb" or "display-p3")
  void SetColorSpace(const std::string& colorSpace);

  // Get current selected color (returns #RRGGBBAA if alpha enabled, #RRGGBB otherwise)
  std::string GetCurrentColor() const;

  // Show the popup at the given screen coordinates
  void Show(int x, int y);

  // Hide the popup
  void Hide();

  // Check if the popup is visible
  bool IsVisible() const { return visible_; }

  // Set callbacks
  void SetColorSelectedCallback(ColorSelectedCallback callback) {
    color_selected_callback_ = std::move(callback);
  }
  void SetColorCancelledCallback(ColorCancelledCallback callback) {
    color_cancelled_callback_ = std::move(callback);
  }

 private:
  // Calculate dynamic height based on predefined colors
  int CalculateHeight() const;

  // Cairo drawing - modern iOS/macOS style
  void Paint();
  void DrawBackground(cairo_t* cr);
  void DrawGradientSquare(cairo_t* cr, int x, int y, int size);
  void DrawHueBar(cairo_t* cr, int x, int y, int width, int height);
  void DrawAlphaBar(cairo_t* cr, int x, int y, int width, int height);
  void DrawPreviewAndHex(cairo_t* cr, int x, int y);
  void DrawPredefinedColors(cairo_t* cr, int x, int y, int available_width);
  void DrawButtons(cairo_t* cr);
  void DrawRoundedRect(cairo_t* cr, double x, double y, double w, double h, double r);

  // Color calculations
  void UpdateColorFromGradient(int x, int y);
  void UpdateHueFromBar(int x);
  void UpdateAlphaFromBar(int x);
  void UpdateColorFromSwatch(int index);
  ColorRGBA GetColorAtGradientPosition(int x, int y) const;

  // Hit testing
  enum class HitArea {
    None,
    Gradient,
    HueBar,
    AlphaBar,
    OkButton,
    CancelButton,
    Swatch
  };
  HitArea GetHitArea(int x, int y, int* swatch_index = nullptr) const;

  // GTK signal handlers
  static gboolean OnDraw(GtkWidget* widget, cairo_t* cr, gpointer user_data);
  static gboolean OnButtonPress(GtkWidget* widget, GdkEventButton* event, gpointer user_data);
  static gboolean OnButtonRelease(GtkWidget* widget, GdkEventButton* event, gpointer user_data);
  static gboolean OnMotionNotify(GtkWidget* widget, GdkEventMotion* event, gpointer user_data);
  static gboolean OnKeyPress(GtkWidget* widget, GdkEventKey* event, gpointer user_data);
  static gboolean OnParentButtonPress(GtkWidget* widget, GdkEventButton* event, gpointer user_data);
  static gboolean OnFocusOut(GtkWidget* widget, GdkEventFocus* event, gpointer user_data);
  static void OnUnrealize(GtkWidget* widget, gpointer user_data);

  GtkWindow* parent_window_ = nullptr;
  GtkWidget* popup_window_ = nullptr;
  GtkWidget* drawing_area_ = nullptr;

  // Color state
  double hue_ = 0.0;         // 0-360
  double saturation_ = 1.0;  // 0-1
  double value_ = 1.0;       // 0-1
  double alpha_ = 1.0;       // 0-1 (only used when alpha_enabled_)
  ColorRGBA initial_color_;
  ColorRGBA current_color_;

  // Alpha and colorspace support (from HTML attributes)
  bool alpha_enabled_ = false;  // From HTML "alpha" attribute
  std::string color_space_ = "limited-srgb";  // From HTML "colorspace" attribute

  // Predefined colors from HTML datalist
  std::vector<std::string> predefined_colors_;

  // Gradient position (for the selector indicator)
  int gradient_x_ = 0;
  int gradient_y_ = 0;
  int hue_x_ = 0;
  int alpha_x_ = 0;  // Position on alpha bar (0 = transparent, max = opaque)

  // UI state
  int width_ = COLOR_PICKER_WIDTH;
  int height_ = COLOR_PICKER_MIN_HEIGHT;
  int popup_x_ = 0;
  int popup_y_ = 0;
  bool visible_ = false;
  bool dragging_gradient_ = false;
  bool dragging_hue_ = false;
  bool dragging_alpha_ = false;
  HitArea hovered_area_ = HitArea::None;
  int hovered_swatch_index_ = -1;
  gulong parent_button_handler_id_ = 0;

  ColorSelectedCallback color_selected_callback_;
  ColorCancelledCallback color_cancelled_callback_;
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_COLOR_PICKER_POPUP_H_
