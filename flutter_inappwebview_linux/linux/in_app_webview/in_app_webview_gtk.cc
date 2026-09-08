// WebKitGTK (webkit2gtk-4.1) backend for InAppWebView.
//
// This file is only compiled when HAVE_WEBKITGTK is defined, i.e. when WPE
// WebKit is not available and CMake selected the WebKitGTK fallback.
//
// How it works
// ------------
// WebKitGTK's WebKitWebView is a GtkWidget and needs a widget hierarchy. Flutter
// on Linux has no platform views, so the widget is hosted in a
// GtkOffscreenWindow: a real, mapped GtkWindow that renders into an offscreen
// surface instead of the screen. WebKit therefore believes the view is visible
// and renders normally (including accelerated compositing in the web process).
//
// Rendering:  GtkOffscreenWindow emits "damage-event" whenever its contents
//             change. On each damage we draw the widget into a cairo image
//             surface (gtk_widget_draw), convert BGRA -> RGBA into the shared
//             triple-buffered pixel buffers and notify Flutter that a new frame
//             is available. A full 1280x720 capture costs about 2 ms.
//
// Input:      Flutter forwards pointer/keyboard/touch events over the method
//             channel. They are turned into synthetic GdkEvents targeted at the
//             widget's GdkWindow and dispatched with gtk_widget_event(), which
//             runs WebKitWebViewBase's regular event handlers.
//
// InAppBrowser: the widget can be detached from the offscreen host and packed
//             into the browser's real GtkWindow, where it renders and receives
//             input natively (see DetachWidgetForEmbedding()).

#include "in_app_webview.h"

#ifdef HAVE_WEBKITGTK

#include <gdk/gdk.h>
#include <gdk/gdkkeysyms.h>

#include <algorithm>
#include <cstring>

#include "../utils/log.h"
#include "simd_convert.h"

namespace flutter_inappwebview_plugin {

namespace {

// WebCore::Scrollbar::pixelsPerLineStep() - WebKit multiplies precise smooth
// scroll deltas by this value to get pixels.
constexpr double kWebKitPixelsPerLineStep = 40.0;

guint32 CurrentEventTime() {
  return static_cast<guint32>(g_get_monotonic_time() / 1000);
}

// Dart sends modifiers in WPE order: Control=1, Shift=2, Alt=4, Meta=8.
guint WpeModifiersToGdkState(int modifiers) {
  guint state = 0;
  if (modifiers & 1) state |= GDK_CONTROL_MASK;
  if (modifiers & 2) state |= GDK_SHIFT_MASK;
  if (modifiers & 4) state |= GDK_MOD1_MASK;
  if (modifiers & 8) state |= GDK_META_MASK;
  return state;
}

// Flutter: 1=primary, 2=secondary, 3=tertiary  ->  GDK: 1=left, 3=right, 2=middle
guint FlutterButtonToGdkButton(int button) {
  switch (button) {
    case 2:
      return GDK_BUTTON_SECONDARY;
    case 3:
      return GDK_BUTTON_MIDDLE;
    default:
      return GDK_BUTTON_PRIMARY;
  }
}

guint GdkButtonMask(guint gdk_button) {
  switch (gdk_button) {
    case GDK_BUTTON_PRIMARY:
      return GDK_BUTTON1_MASK;
    case GDK_BUTTON_MIDDLE:
      return GDK_BUTTON2_MASK;
    case GDK_BUTTON_SECONDARY:
      return GDK_BUTTON3_MASK;
    default:
      return 0;
  }
}

bool IsModifierKeyval(guint keyval) {
  switch (keyval) {
    case GDK_KEY_Shift_L:
    case GDK_KEY_Shift_R:
    case GDK_KEY_Control_L:
    case GDK_KEY_Control_R:
    case GDK_KEY_Alt_L:
    case GDK_KEY_Alt_R:
    case GDK_KEY_Meta_L:
    case GDK_KEY_Meta_R:
    case GDK_KEY_Super_L:
    case GDK_KEY_Super_R:
    case GDK_KEY_Caps_Lock:
      return true;
    default:
      return false;
  }
}

// Copies the properties WebViewEnvironment can configure from one context to
// another. Used when an incognito (ephemeral) context has to be created for a
// WebView that was also given a custom WebKitWebContext.
void CopyWebContextSettings(WebKitWebContext* from, WebKitWebContext* to) {
  if (from == nullptr || to == nullptr) return;
  webkit_web_context_set_cache_model(to, webkit_web_context_get_cache_model(from));
  webkit_web_context_set_spell_checking_enabled(to,
                                                webkit_web_context_get_spell_checking_enabled(from));
  const gchar* const* languages = webkit_web_context_get_spell_checking_languages(from);
  if (languages != nullptr) {
    webkit_web_context_set_spell_checking_languages(to, languages);
  }
  webkit_web_context_set_automation_allowed(to, webkit_web_context_is_automation_allowed(from));
  // Note: "time-zone-override" is construct-only and cannot be copied.
}

}  // namespace

// === Initialization ===

void InAppWebView::GtkInitBackend() {
  // GtkOffscreenWindow is a toplevel GtkWindow that renders to an offscreen
  // surface. It is "mapped" from GTK's point of view, so WebKit keeps the view
  // visible and rendering.
  gtk_offscreen_window_ = gtk_offscreen_window_new();
  if (gtk_offscreen_window_ == nullptr) {
    errorLog("InAppWebView: Failed to create GtkOffscreenWindow");
    return;
  }
  gtk_widget_set_size_request(gtk_offscreen_window_, width_, height_);
  gtk_damage_handler_id_ = g_signal_connect(gtk_offscreen_window_, "damage-event",
                                            G_CALLBACK(GtkOnDamageEvent), this);
}

void InAppWebView::GtkInitWebView(const InAppWebViewCreationParams& params) {
  if (gtk_offscreen_window_ == nullptr) {
    errorLog("InAppWebView: Cannot create webview without offscreen window");
    return;
  }

  bool useIncognito = params.initialSettings && params.initialSettings->incognito;

  if (params.relatedWebView != nullptr) {
    // Popup window (window.open): share web process, settings and user content
    // manager with the parent view. The context is inherited from the related view.
    webview_ = WEBKIT_WEB_VIEW(g_object_new(
        WEBKIT_TYPE_WEB_VIEW, "related-view", params.relatedWebView, "user-content-manager",
        webkit_web_view_get_user_content_manager(params.relatedWebView), "settings",
        webkit_web_view_get_settings(params.relatedWebView), nullptr));
  } else {
    WebKitSettings* settings = webkit_settings_new();

    // In the 4.1 API the WebKitWebContext owns the storage (there is no separate
    // WebKitNetworkSession), so incognito means an ephemeral context.
    WebKitWebContext* context = params.webContext;
    WebKitWebContext* owned_context = nullptr;
    if (useIncognito) {
      owned_context = webkit_web_context_new_ephemeral();
      if (context != nullptr) {
        debugLog("InAppWebView: incognito + custom WebKitWebContext requested; WebKitGTK cannot "
                 "combine them, using an ephemeral context with the environment's settings");
        CopyWebContextSettings(context, owned_context);
      }
      context = owned_context;
      debugLog("InAppWebView: Creating WebView with ephemeral (incognito) web context");
    } else if (context != nullptr) {
      debugLog("InAppWebView: Creating WebView with custom WebKitWebContext");
    }

    if (context != nullptr) {
      webview_ = WEBKIT_WEB_VIEW(g_object_new(WEBKIT_TYPE_WEB_VIEW, "web-context", context,
                                              "settings", settings, nullptr));
    } else {
      webview_ = WEBKIT_WEB_VIEW(g_object_new(WEBKIT_TYPE_WEB_VIEW, "settings", settings, nullptr));
    }
    g_object_unref(settings);
    if (owned_context != nullptr) {
      // The view holds its own reference to the context.
      g_object_unref(owned_context);
    }
  }

  if (webview_ == nullptr) {
    errorLog("InAppWebView: Failed to create WebKitWebView (WebKitGTK)");
    return;
  }

  // Keep our own reference so the widget outlives any container it is packed
  // into (offscreen host or an InAppBrowser window).
  g_object_ref_sink(webview_);

  GtkWidget* widget = GTK_WIDGET(webview_);
  gtk_widget_set_can_focus(widget, TRUE);
  gtk_widget_set_hexpand(widget, TRUE);
  gtk_widget_set_vexpand(widget, TRUE);
  gtk_widget_set_size_request(widget, width_, height_);
  gtk_container_add(GTK_CONTAINER(gtk_offscreen_window_), widget);

  // Show + realize so that WebKit maps the view and we can synthesize GDK
  // events with a valid GdkWindow.
  gtk_widget_show_all(gtk_offscreen_window_);
  gtk_widget_realize(gtk_offscreen_window_);
  gtk_widget_realize(widget);
  gtk_widget_grab_focus(widget);

  // Apply ITP setting if configured
  if (params.initialSettings != nullptr && params.initialSettings->itpEnabled) {
    WebKitNetworkSession* session = webkit_web_view_get_network_session(webview_);
    if (session != nullptr) {
      webkit_network_session_set_itp_enabled(session, TRUE);
    }
  }

  // Track the display scale of the Flutter window so that HiDPI changes trigger
  // a re-capture (the offscreen widget itself follows GDK_SCALE automatically).
  if (gtk_window_ != nullptr) {
    scale_factor_ = static_cast<double>(gtk_widget_get_scale_factor(GTK_WIDGET(gtk_window_)));
  }
}

void InAppWebView::GtkDestroy() {
  is_disposing_.store(true);

  if (gtk_pending_capture_idle_ != 0) {
    g_source_remove(gtk_pending_capture_idle_);
    gtk_pending_capture_idle_ = 0;
  }

  if (gtk_offscreen_window_ != nullptr && gtk_damage_handler_id_ != 0) {
    g_signal_handler_disconnect(gtk_offscreen_window_, gtk_damage_handler_id_);
    gtk_damage_handler_id_ = 0;
  }

  if (webview_ != nullptr) {
    GtkWidget* widget = GTK_WIDGET(webview_);
    g_signal_handlers_disconnect_by_data(webview_, this);
    // gtk_widget_destroy() also removes the widget from its parent (offscreen
    // host or browser window). Our own reference keeps the object valid until
    // the unref below.
    gtk_widget_destroy(widget);
    g_object_unref(webview_);
    webview_ = nullptr;
  }

  if (gtk_offscreen_window_ != nullptr) {
    gtk_widget_destroy(gtk_offscreen_window_);
    gtk_offscreen_window_ = nullptr;
  }

  if (gtk_capture_surface_ != nullptr) {
    cairo_surface_destroy(gtk_capture_surface_);
    gtk_capture_surface_ = nullptr;
  }
}

GtkWidget* InAppWebView::DetachWidgetForEmbedding() {
  if (webview_ == nullptr) {
    return nullptr;
  }
  GtkWidget* widget = GTK_WIDGET(webview_);
  GtkWidget* parent = gtk_widget_get_parent(widget);
  if (parent != nullptr) {
    gtk_container_remove(GTK_CONTAINER(parent), widget);
  }
  // The offscreen host forced a fixed size; let the new container decide.
  gtk_widget_set_size_request(widget, -1, -1);
  gtk_widget_embedded_ = true;

  if (gtk_offscreen_window_ != nullptr) {
    if (gtk_damage_handler_id_ != 0) {
      g_signal_handler_disconnect(gtk_offscreen_window_, gtk_damage_handler_id_);
      gtk_damage_handler_id_ = 0;
    }
    gtk_widget_destroy(gtk_offscreen_window_);
    gtk_offscreen_window_ = nullptr;
  }
  return widget;
}

// === Frame capture ===

gboolean InAppWebView::GtkOnDamageEvent(GtkWidget* widget, GdkEventExpose* event,
                                        gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);
  if (self != nullptr && !self->is_disposing_.load()) {
    self->GtkCaptureFrame();
  }
  return FALSE;
}

gboolean InAppWebView::GtkOnCaptureIdle(gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);
  self->gtk_pending_capture_idle_ = 0;
  if (!self->is_disposing_.load()) {
    self->GtkCaptureFrame();
  }
  return G_SOURCE_REMOVE;
}

void InAppWebView::GtkScheduleCapture() {
  if (gtk_pending_capture_idle_ != 0 || is_disposing_.load()) {
    return;
  }
  gtk_pending_capture_idle_ = g_idle_add(GtkOnCaptureIdle, this);
}

void InAppWebView::GtkCaptureFrame() {
  if (webview_ == nullptr || gtk_widget_embedded_ || is_disposing_.load()) {
    return;
  }
  GtkWidget* widget = GTK_WIDGET(webview_);
  if (!gtk_widget_get_realized(widget) || !gtk_widget_get_mapped(widget)) {
    return;
  }

  int width = gtk_widget_get_allocated_width(widget);
  int height = gtk_widget_get_allocated_height(widget);
  int scale = std::max(1, gtk_widget_get_scale_factor(widget));
  if (width <= 0 || height <= 0) {
    return;
  }
  int pixel_width = width * scale;
  int pixel_height = height * scale;

  // (Re)create the reusable capture surface when the size changes.
  if (gtk_capture_surface_ == nullptr ||
      cairo_image_surface_get_width(gtk_capture_surface_) != pixel_width ||
      cairo_image_surface_get_height(gtk_capture_surface_) != pixel_height) {
    if (gtk_capture_surface_ != nullptr) {
      cairo_surface_destroy(gtk_capture_surface_);
    }
    gtk_capture_surface_ =
        cairo_image_surface_create(CAIRO_FORMAT_ARGB32, pixel_width, pixel_height);
    if (cairo_surface_status(gtk_capture_surface_) != CAIRO_STATUS_SUCCESS) {
      cairo_surface_destroy(gtk_capture_surface_);
      gtk_capture_surface_ = nullptr;
      return;
    }
  }

  // Draw the widget (WebKit paints its current backing store) into the surface.
  cairo_t* cr = cairo_create(gtk_capture_surface_);
  cairo_set_operator(cr, CAIRO_OPERATOR_SOURCE);
  cairo_set_source_rgba(cr, 0, 0, 0, 0);
  cairo_paint(cr);
  cairo_set_operator(cr, CAIRO_OPERATOR_OVER);
  cairo_scale(cr, scale, scale);
  gtk_widget_draw(widget, cr);
  cairo_destroy(cr);
  cairo_surface_flush(gtk_capture_surface_);

  const uint8_t* src = cairo_image_surface_get_data(gtk_capture_surface_);
  int stride = cairo_image_surface_get_stride(gtk_capture_surface_);
  if (src == nullptr) {
    return;
  }

  // Convert cairo ARGB32 (BGRA in memory, premultiplied) to the RGBA buffer that
  // FlPixelBufferTexture expects, using the shared triple buffers.
  size_t write_idx = write_buffer_index_.load(std::memory_order_relaxed);
  auto& pixel_buffer = pixel_buffers_[write_idx];
  size_t output_size = static_cast<size_t>(pixel_width) * pixel_height * 4;
  if (pixel_buffer.data.size() != output_size) {
    pixel_buffer.data.resize(output_size);
  }
  ConvertARGB32ToRGBA(src, pixel_buffer.data.data(), pixel_width, pixel_height, stride);
  pixel_buffer.width = static_cast<size_t>(pixel_width);
  pixel_buffer.height = static_cast<size_t>(pixel_height);

  {
    std::lock_guard<std::mutex> lock(buffer_swap_mutex_);
    read_buffer_index_.store(write_idx, std::memory_order_release);
    write_buffer_index_.store((write_idx + 1) % kNumBuffers, std::memory_order_relaxed);
  }

  if (on_frame_available_) {
    on_frame_available_();
  }
}

// === Size / focus / visibility ===

void InAppWebView::GtkSetSize(int width, int height) {
  if (gtk_widget_embedded_) {
    // A native container controls the allocation.
    return;
  }
  if (gtk_offscreen_window_ != nullptr) {
    gtk_widget_set_size_request(gtk_offscreen_window_, width, height);
    gtk_window_resize(GTK_WINDOW(gtk_offscreen_window_), width, height);
  }
  if (webview_ != nullptr) {
    gtk_widget_set_size_request(GTK_WIDGET(webview_), width, height);
  }
  // WebKit repaints after the resize which triggers damage-event; schedule a
  // capture as well in case the content did not change.
  GtkScheduleCapture();
}

void InAppWebView::GtkEnsureFocused() {
  if (webview_ == nullptr) return;
  GtkWidget* widget = GTK_WIDGET(webview_);
  gtk_widget_grab_focus(widget);

  GdkWindow* window = GtkEventWindow();
  if (window == nullptr) return;

  // WebKitWebViewBase marks the view focused (and its window active) on
  // focus-in-event; the offscreen toplevel never receives real focus events.
  GdkEvent* event = gdk_event_new(GDK_FOCUS_CHANGE);
  event->any.window = GDK_WINDOW(g_object_ref(window));
  event->any.send_event = TRUE;
  event->focus_change.in = TRUE;
  GdkDevice* keyboard = GtkKeyboardDevice();
  if (keyboard != nullptr) {
    gdk_event_set_device(event, keyboard);
    gdk_event_set_source_device(event, keyboard);
  }
  gtk_widget_event(widget, event);
  gdk_event_free(event);
}

void InAppWebView::GtkSetFocused(bool focused) {
  if (webview_ == nullptr || gtk_widget_embedded_) return;
  if (focused) {
    GtkEnsureFocused();
    return;
  }
  GdkWindow* window = GtkEventWindow();
  if (window == nullptr) return;
  GdkEvent* event = gdk_event_new(GDK_FOCUS_CHANGE);
  event->any.window = GDK_WINDOW(g_object_ref(window));
  event->any.send_event = TRUE;
  event->focus_change.in = FALSE;
  GdkDevice* keyboard = GtkKeyboardDevice();
  if (keyboard != nullptr) {
    gdk_event_set_device(event, keyboard);
    gdk_event_set_source_device(event, keyboard);
  }
  gtk_widget_event(GTK_WIDGET(webview_), event);
  gdk_event_free(event);
}

void InAppWebView::GtkSetVisible(bool visible) {
  if (webview_ == nullptr || gtk_widget_embedded_) return;
  // Mapping/unmapping the widget toggles WebKit's IsVisible activity state,
  // which pauses rendering and timers while hidden.
  if (visible) {
    gtk_widget_show(GTK_WIDGET(webview_));
    GtkScheduleCapture();
  } else {
    gtk_widget_hide(GTK_WIDGET(webview_));
  }
}

// === Input synthesis ===

GdkWindow* InAppWebView::GtkEventWindow() {
  if (webview_ == nullptr) return nullptr;
  GtkWidget* widget = GTK_WIDGET(webview_);
  if (!gtk_widget_get_realized(widget)) {
    gtk_widget_realize(widget);
  }
  return gtk_widget_get_window(widget);
}

GdkDevice* InAppWebView::GtkPointerDevice() const {
  GdkDisplay* display = gdk_display_get_default();
  if (display == nullptr) return nullptr;
  GdkSeat* seat = gdk_display_get_default_seat(display);
  if (seat == nullptr) return nullptr;
  return gdk_seat_get_pointer(seat);
}

GdkDevice* InAppWebView::GtkKeyboardDevice() const {
  GdkDisplay* display = gdk_display_get_default();
  if (display == nullptr) return nullptr;
  GdkSeat* seat = gdk_display_get_default_seat(display);
  if (seat == nullptr) return nullptr;
  return gdk_seat_get_keyboard(seat);
}

// WebKitGTK treats smooth scroll deltas as precise pixel-based deltas only when
// the source device is not a mouse. Flutter already gives us pixel deltas, so
// prefer a touchpad slave device and otherwise fall back to the keyboard device
// (any non-mouse source works); the master pointer is the last resort.
GdkDevice* InAppWebView::GtkPreciseScrollDevice() const {
  GdkDisplay* display = gdk_display_get_default();
  if (display == nullptr) return nullptr;
  GdkSeat* seat = gdk_display_get_default_seat(display);
  if (seat == nullptr) return nullptr;

  GdkDevice* result = nullptr;
  GList* slaves = gdk_seat_get_slaves(seat, GDK_SEAT_CAPABILITY_ALL_POINTING);
  for (GList* l = slaves; l != nullptr; l = l->next) {
    auto* device = static_cast<GdkDevice*>(l->data);
    GdkInputSource source = gdk_device_get_source(device);
    if (source == GDK_SOURCE_TOUCHPAD || source == GDK_SOURCE_TRACKPOINT) {
      result = device;
      break;
    }
  }
  g_list_free(slaves);
  if (result != nullptr) return result;

  GdkDevice* keyboard = gdk_seat_get_keyboard(seat);
  if (keyboard != nullptr) return keyboard;
  return gdk_seat_get_pointer(seat);
}

void InAppWebView::GtkSendMotion(double x, double y) {
  if (webview_ == nullptr || gtk_widget_embedded_) return;
  GdkWindow* window = GtkEventWindow();
  if (window == nullptr) return;

  GdkEvent* event = gdk_event_new(GDK_MOTION_NOTIFY);
  event->any.window = GDK_WINDOW(g_object_ref(window));
  event->any.send_event = TRUE;
  event->motion.time = CurrentEventTime();
  event->motion.x = x;
  event->motion.y = y;
  event->motion.x_root = x + texture_offset_x_;
  event->motion.y_root = y + texture_offset_y_;
  event->motion.state = gtk_button_mask_ | gtk_modifier_state_;
  event->motion.is_hint = FALSE;
  GdkDevice* pointer = GtkPointerDevice();
  if (pointer != nullptr) {
    gdk_event_set_device(event, pointer);
    gdk_event_set_source_device(event, pointer);
  }
  gtk_widget_event(GTK_WIDGET(webview_), event);
  gdk_event_free(event);
}

void InAppWebView::GtkSendButton(int kind, int button, int clickCount) {
  if (webview_ == nullptr || gtk_widget_embedded_) return;

  auto pointer_kind = static_cast<WpePointerEventKind>(kind);
  GdkEventType event_type;
  switch (pointer_kind) {
    case WpePointerEventKind::Down:
      event_type = GDK_BUTTON_PRESS;
      break;
    case WpePointerEventKind::Up:
    case WpePointerEventKind::Cancel:
      event_type = GDK_BUTTON_RELEASE;
      break;
    case WpePointerEventKind::Enter:
      event_type = GDK_ENTER_NOTIFY;
      break;
    case WpePointerEventKind::Leave:
      event_type = GDK_LEAVE_NOTIFY;
      break;
    default:
      return;
  }

  GdkWindow* window = GtkEventWindow();
  if (window == nullptr) return;
  GdkDevice* pointer = GtkPointerDevice();
  guint32 time = CurrentEventTime();

  if (event_type == GDK_ENTER_NOTIFY || event_type == GDK_LEAVE_NOTIFY) {
    GdkEvent* event = gdk_event_new(event_type);
    event->any.window = GDK_WINDOW(g_object_ref(window));
    event->any.send_event = TRUE;
    event->crossing.time = time;
    event->crossing.x = cursor_x_;
    event->crossing.y = cursor_y_;
    event->crossing.x_root = cursor_x_ + texture_offset_x_;
    event->crossing.y_root = cursor_y_ + texture_offset_y_;
    event->crossing.mode = GDK_CROSSING_NORMAL;
    event->crossing.detail = GDK_NOTIFY_NONLINEAR;
    event->crossing.focus = FALSE;
    event->crossing.state = gtk_button_mask_ | gtk_modifier_state_;
    if (pointer != nullptr) {
      gdk_event_set_device(event, pointer);
      gdk_event_set_source_device(event, pointer);
    }
    gtk_widget_event(GTK_WIDGET(webview_), event);
    gdk_event_free(event);
    return;
  }

  guint gdk_button = FlutterButtonToGdkButton(button);
  guint mask = GdkButtonMask(gdk_button);

  if (event_type == GDK_BUTTON_PRESS) {
    GtkEnsureFocused();
    // Make sure WebKit knows where the pointer is before the press.
    GtkSendMotion(cursor_x_, cursor_y_);
  }

  // WebKit derives double/triple clicks from event timestamps and positions
  // (ClickCounter), so a plain button press per click with a real timestamp is
  // what it expects. clickCount from Dart is therefore not needed here.
  (void)clickCount;

  GdkEvent* event = gdk_event_new(event_type);
  event->any.window = GDK_WINDOW(g_object_ref(window));
  event->any.send_event = TRUE;
  event->button.time = time;
  event->button.x = cursor_x_;
  event->button.y = cursor_y_;
  event->button.x_root = cursor_x_ + texture_offset_x_;
  event->button.y_root = cursor_y_ + texture_offset_y_;
  event->button.button = gdk_button;
  // For a release GDK reports the state *before* the release (button still down).
  event->button.state = gtk_button_mask_ | gtk_modifier_state_ |
                        (event_type == GDK_BUTTON_PRESS ? 0 : mask);
  if (pointer != nullptr) {
    gdk_event_set_device(event, pointer);
    gdk_event_set_source_device(event, pointer);
  }

  if (event_type == GDK_BUTTON_PRESS) {
    gtk_button_mask_ |= mask;
  } else {
    gtk_button_mask_ &= ~mask;
  }

  gtk_widget_event(GTK_WIDGET(webview_), event);
  gdk_event_free(event);
}

void InAppWebView::GtkSendScroll(double dx, double dy) {
  if (webview_ == nullptr || gtk_widget_embedded_) return;
  GdkWindow* window = GtkEventWindow();
  if (window == nullptr) return;

  GdkEvent* event = gdk_event_new(GDK_SCROLL);
  event->any.window = GDK_WINDOW(g_object_ref(window));
  event->any.send_event = TRUE;
  event->scroll.time = CurrentEventTime();
  event->scroll.x = cursor_x_;
  event->scroll.y = cursor_y_;
  event->scroll.x_root = cursor_x_ + texture_offset_x_;
  event->scroll.y_root = cursor_y_ + texture_offset_y_;
  event->scroll.state = gtk_button_mask_ | gtk_modifier_state_;
  event->scroll.direction = GDK_SCROLL_SMOOTH;
  event->scroll.is_stop = FALSE;
  // Dart sends deltas with WPE semantics (positive = scroll up, in pixels).
  // GDK smooth deltas are the opposite sign and WebKit scales precise deltas by
  // pixelsPerLineStep, so pre-divide to end up with exact pixels.
  event->scroll.delta_x = -dx / kWebKitPixelsPerLineStep;
  event->scroll.delta_y = -dy / kWebKitPixelsPerLineStep;

  GdkDevice* device = GtkPreciseScrollDevice();
  if (device != nullptr) {
    gdk_event_set_device(event, device);
    gdk_event_set_source_device(event, device);
  }
  gtk_widget_event(GTK_WIDGET(webview_), event);
  gdk_event_free(event);
}

void InAppWebView::GtkSendKey(int type, int64_t keyCode, int scanCode, int modifiers,
                              const std::string& characters) {
  if (webview_ == nullptr || gtk_widget_embedded_) return;
  GdkWindow* window = GtkEventWindow();
  if (window == nullptr) return;

  // type: 0=press, 1=release, 2=repeat
  GdkEventType event_type = (type == 1) ? GDK_KEY_RELEASE : GDK_KEY_PRESS;
  guint keyval = static_cast<guint>(keyCode);  // Dart sends X11 keysyms
  gtk_modifier_state_ = WpeModifiersToGdkState(modifiers);

  GdkEvent* event = gdk_event_new(event_type);
  event->any.window = GDK_WINDOW(g_object_ref(window));
  event->any.send_event = TRUE;
  event->key.time = CurrentEventTime();
  event->key.state = gtk_modifier_state_ | gtk_button_mask_;
  event->key.keyval = keyval;
  event->key.hardware_keycode = static_cast<guint16>(scanCode);
  event->key.group = 0;
  event->key.is_modifier = IsModifierKeyval(keyval) ? 1 : 0;
  if (!characters.empty() && event_type == GDK_KEY_PRESS) {
    event->key.string = g_strdup(characters.c_str());
    event->key.length = static_cast<gint>(characters.size());
  } else {
    event->key.string = nullptr;
    event->key.length = 0;
  }

  if (event->key.hardware_keycode == 0 && keyval != GDK_KEY_VoidSymbol) {
    // Derive a hardware keycode from the keymap so key auto-repeat tracking and
    // key bindings in WebKit behave.
    GdkKeymap* keymap = gdk_keymap_get_for_display(gdk_window_get_display(window));
    GdkKeymapKey* keys = nullptr;
    gint n_keys = 0;
    if (keymap != nullptr && gdk_keymap_get_entries_for_keyval(keymap, keyval, &keys, &n_keys) &&
        n_keys > 0) {
      event->key.hardware_keycode = static_cast<guint16>(keys[0].keycode);
      event->key.group = static_cast<guint8>(keys[0].group);
    }
    g_free(keys);
  }

  GdkDevice* keyboard = GtkKeyboardDevice();
  if (keyboard != nullptr) {
    gdk_event_set_device(event, keyboard);
    gdk_event_set_source_device(event, keyboard);
  }

  gtk_widget_event(GTK_WIDGET(webview_), event);
  gdk_event_free(event);  // also frees key.string
}

void InAppWebView::GtkSendTouch(int type, int id, double x, double y,
                                const std::vector<std::tuple<int, double, double, int>>& touchPoints) {
  if (webview_ == nullptr || gtk_widget_embedded_) return;
  GdkWindow* window = GtkEventWindow();
  if (window == nullptr) return;

  // Dart: 0=down, 1=up, 2=move, 3=cancel
  GdkEventType event_type;
  switch (type) {
    case 0:
      event_type = GDK_TOUCH_BEGIN;
      break;
    case 1:
      event_type = GDK_TOUCH_END;
      break;
    case 2:
      event_type = GDK_TOUCH_UPDATE;
      break;
    case 3:
      event_type = GDK_TOUCH_CANCEL;
      break;
    default:
      return;
  }

  // WebKitWebViewBase keeps one GdkEvent per sequence, so only the point that
  // changed needs to be dispatched; other active points stay as last reported.
  (void)touchPoints;

  GdkEvent* event = gdk_event_new(event_type);
  event->any.window = GDK_WINDOW(g_object_ref(window));
  event->any.send_event = TRUE;
  event->touch.time = CurrentEventTime();
  event->touch.x = x;
  event->touch.y = y;
  event->touch.x_root = x + texture_offset_x_;
  event->touch.y_root = y + texture_offset_y_;
  event->touch.state = gtk_modifier_state_;
  // Sequences are opaque pointers; encode the Flutter pointer id (never 0).
  event->touch.sequence = reinterpret_cast<GdkEventSequence*>(static_cast<intptr_t>(id + 1));
  event->touch.emulating_pointer = FALSE;
  GdkDevice* pointer = GtkPointerDevice();
  if (pointer != nullptr) {
    gdk_event_set_device(event, pointer);
    gdk_event_set_source_device(event, pointer);
  }
  gtk_widget_event(GTK_WIDGET(webview_), event);
  gdk_event_free(event);
}

// === Signal adapters for the 4.1 API ===

gboolean InAppWebView::OnContextMenuGtk(WebKitWebView* web_view, WebKitContextMenu* context_menu,
                                        GdkEvent* event, WebKitHitTestResult* hit_test_result,
                                        gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);
  if (self->gtk_widget_embedded_ && (!self->settings_ || !self->settings_->disableContextMenu) &&
      !self->context_menu_config_) {
    // Native window: let WebKitGTK show its own GTK context menu.
    return FALSE;
  }
  return OnContextMenu(web_view, context_menu, hit_test_result, user_data);
}

gboolean InAppWebView::OnShowOptionMenuGtk(WebKitWebView* web_view, WebKitOptionMenu* menu,
                                           GdkEvent* event, GdkRectangle* rectangle,
                                           gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);
  if (self->gtk_widget_embedded_) {
    // Native window: WebKitGTK's own popup positions itself correctly.
    return FALSE;
  }
  return OnShowOptionMenu(web_view, menu, rectangle, user_data);
}

gboolean InAppWebView::OnRunColorChooserGtk(WebKitWebView* web_view,
                                            WebKitColorChooserRequest* request,
                                            gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);
  // <input type="color"> is normally intercepted by the ColorInputJS plugin
  // script. If WebKit still asks, show a GTK color chooser parented to the
  // Flutter window instead of the (invisible) offscreen toplevel.
  GtkWindow* parent = self->gtk_window_;
  if (self->gtk_widget_embedded_ && self->webview_ != nullptr) {
    GtkWidget* toplevel = gtk_widget_get_toplevel(GTK_WIDGET(self->webview_));
    if (GTK_IS_WINDOW(toplevel)) parent = GTK_WINDOW(toplevel);
  }
  GtkWidget* dialog = gtk_color_chooser_dialog_new("Select a color", parent);
  GdkRGBA rgba;
  webkit_color_chooser_request_get_rgba(request, &rgba);
  gtk_color_chooser_set_rgba(GTK_COLOR_CHOOSER(dialog), &rgba);
  gtk_color_chooser_set_use_alpha(GTK_COLOR_CHOOSER(dialog), FALSE);
  g_object_ref(request);
  g_signal_connect(dialog, "response",
                   G_CALLBACK(+[](GtkDialog* dlg, gint response_id, gpointer data) {
                     auto* req = static_cast<WebKitColorChooserRequest*>(data);
                     if (response_id == GTK_RESPONSE_OK) {
                       GdkRGBA chosen;
                       gtk_color_chooser_get_rgba(GTK_COLOR_CHOOSER(dlg), &chosen);
                       webkit_color_chooser_request_set_rgba(req, &chosen);
                       webkit_color_chooser_request_finish(req);
                     } else {
                       webkit_color_chooser_request_cancel(req);
                     }
                     g_object_unref(req);
                     gtk_widget_destroy(GTK_WIDGET(dlg));
                   }),
                   request);
  gtk_widget_show(dialog);
  return TRUE;
}

gboolean InAppWebView::OnPrintGtk(WebKitWebView* web_view, WebKitPrintOperation* print_operation,
                                  gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);
  // window.print() is normally intercepted by PrintInterceptionJS and reported
  // to Dart. If WebKit still emits "print", run the GTK print dialog parented to
  // a real window rather than the offscreen toplevel.
  GtkWindow* parent = self->gtk_window_;
  if (self->gtk_widget_embedded_ && self->webview_ != nullptr) {
    GtkWidget* toplevel = gtk_widget_get_toplevel(GTK_WIDGET(self->webview_));
    if (GTK_IS_WINDOW(toplevel)) parent = GTK_WINDOW(toplevel);
  }
  webkit_print_operation_run_dialog(print_operation, parent);
  return TRUE;
}

}  // namespace flutter_inappwebview_plugin

#endif  // HAVE_WEBKITGTK
