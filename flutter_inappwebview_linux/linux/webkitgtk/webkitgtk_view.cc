#include "webkitgtk_view.h"

#include <algorithm>
#include <cstring>
#include <sstream>

// ============================================================
// GObject pixel-buffer texture type for WebKitGTKView
// ============================================================
struct _WebKitGTKPixelTexture {
  FlPixelBufferTexture parent_instance;
};
typedef struct _WebKitGTKPixelTexture WebKitGTKPixelTexture;
typedef struct {
  FlPixelBufferTextureClass parent_class;
} WebKitGTKPixelTextureClass;

G_DEFINE_TYPE(WebKitGTKPixelTexture, webkit_gtk_pixel_texture, fl_pixel_buffer_texture_get_type())

static gboolean webkit_gtk_pixel_texture_copy_pixels(FlPixelBufferTexture* texture,
                                                     const uint8_t** buffer, uint32_t* width,
                                                     uint32_t* height, GError** /*error*/) {
  auto* view = static_cast<flutter_inappwebview_webkit::WebKitGTKView*>(
      g_object_get_data(G_OBJECT(texture), "view"));
  if (!view) {
    *buffer = nullptr;
    *width = 1;
    *height = 1;
    return TRUE;
  }
  return view->PopulatePixelBuffer(buffer, width, height);
}

static void webkit_gtk_pixel_texture_class_init(WebKitGTKPixelTextureClass* klass) {
  FL_PIXEL_BUFFER_TEXTURE_CLASS(klass)->copy_pixels = webkit_gtk_pixel_texture_copy_pixels;
}

static void webkit_gtk_pixel_texture_init(WebKitGTKPixelTexture* /*self*/) {}

namespace flutter_inappwebview_webkit {

// ============================================================
// Constructor / Destructor
// ============================================================

WebKitGTKView::WebKitGTKView(int64_t id, FlBinaryMessenger* messenger,
                             FlTextureRegistrar* texture_registrar, GtkWindow* gtk_window)
    : id_(id),
      messenger_(messenger),
      texture_registrar_(texture_registrar),
      gtk_window_(gtk_window) {
  // --- Create UserContentManager (for JS bridge) ---
  content_manager_ = webkit_user_content_manager_new();

  // Register message handler "flutter_inappwebview" for JS bridge
  webkit_user_content_manager_register_script_message_handler(content_manager_, kJsBridgeName);
  g_signal_connect(content_manager_, "script-message-received::flutter_inappwebview",
                   G_CALLBACK(OnScriptMessageReceived), this);

  // --- Create WebKitWebView ---
  webkit_view_ = WEBKIT_WEB_VIEW(webkit_web_view_new_with_user_content_manager(content_manager_));
  g_object_ref(webkit_view_);

  // Connect signals
  g_signal_connect(webkit_view_, "load-changed", G_CALLBACK(OnLoadChanged), this);
  g_signal_connect(webkit_view_, "load-failed", G_CALLBACK(OnLoadFailed), this);
  g_signal_connect(webkit_view_, "notify::estimated-load-progress", G_CALLBACK(OnEstimatedProgress),
                   this);

  // --- Create Offscreen window ---
  offscreen_window_ = gtk_offscreen_window_new();
  gtk_widget_set_size_request(offscreen_window_, static_cast<int>(width_),
                              static_cast<int>(height_));
  gtk_container_add(GTK_CONTAINER(offscreen_window_), GTK_WIDGET(webkit_view_));
  gtk_widget_show_all(offscreen_window_);

  // Connect damage event for render updates
  g_signal_connect(offscreen_window_, "damage-event", G_CALLBACK(OnDamageEvent), this);

  // Start periodic 30fps refresh timer (33ms)
  damage_timer_id_ = g_timeout_add(33, OnTimerTick, this);

  // --- Register Flutter pixel-buffer texture ---
  // Uses the WebKitGTKPixelTexture GObject subtype defined above.
  WebKitGTKPixelTexture* tex_obj = static_cast<WebKitGTKPixelTexture*>(
      g_object_new(webkit_gtk_pixel_texture_get_type(), nullptr));
  // Store back-pointer so copy_pixels can reach us
  g_object_set_data(G_OBJECT(tex_obj), "view", this);
  texture_ = FL_TEXTURE(tex_obj);

  fl_texture_registrar_register_texture(texture_registrar_, texture_);
  texture_id_ = reinterpret_cast<int64_t>(texture_);

  // --- Method channels ---
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();

  // WebView controller channel: com.pichillilorenzo/flutter_inappwebview_$id
  {
    std::string ch_name = "com.pichillilorenzo/flutter_inappwebview_" + std::to_string(id_);
    webview_channel_ = fl_method_channel_new(messenger_, ch_name.c_str(), FL_METHOD_CODEC(codec));
    fl_method_channel_set_method_call_handler(webview_channel_, HandleWebviewMethodCall, this,
                                              nullptr);
  }

  // Platform view method channel: com.pichillilorenzo/custom_platform_view_$textureId
  {
    std::string ch_name = "com.pichillilorenzo/custom_platform_view_" + std::to_string(texture_id_);
    platform_view_channel_ =
        fl_method_channel_new(messenger_, ch_name.c_str(), FL_METHOD_CODEC(codec));
    fl_method_channel_set_method_call_handler(platform_view_channel_, HandlePlatformViewMethodCall,
                                              this, nullptr);
  }

  // Event channel: com.pichillilorenzo/custom_platform_view_${textureId}_events
  {
    std::string ch_name =
        "com.pichillilorenzo/custom_platform_view_" + std::to_string(texture_id_) + "_events";
    event_channel_ = fl_event_channel_new(messenger_, ch_name.c_str(), FL_METHOD_CODEC(codec));
    fl_event_channel_set_stream_handlers(event_channel_, OnEventListen, OnEventCancel, this,
                                         nullptr);
  }

  // Inject the flutter_inappwebview JS bridge
  InjectBridgeScript();
}

WebKitGTKView::~WebKitGTKView() {
  if (damage_timer_id_ != 0) {
    g_source_remove(damage_timer_id_);
    damage_timer_id_ = 0;
  }

  if (texture_ != nullptr) {
    fl_texture_registrar_unregister_texture(texture_registrar_, texture_);
    g_object_unref(texture_);
    texture_ = nullptr;
  }

  if (webview_channel_ != nullptr) {
    fl_method_channel_set_method_call_handler(webview_channel_, nullptr, nullptr, nullptr);
    g_object_unref(webview_channel_);
    webview_channel_ = nullptr;
  }

  if (platform_view_channel_ != nullptr) {
    fl_method_channel_set_method_call_handler(platform_view_channel_, nullptr, nullptr, nullptr);
    g_object_unref(platform_view_channel_);
    platform_view_channel_ = nullptr;
  }

  if (event_channel_ != nullptr) {
    fl_event_channel_set_stream_handlers(event_channel_, nullptr, nullptr, nullptr, nullptr);
    g_object_unref(event_channel_);
    event_channel_ = nullptr;
  }

  if (webkit_view_ != nullptr) {
    webkit_web_view_stop_loading(webkit_view_);
    g_object_unref(webkit_view_);
    webkit_view_ = nullptr;
  }

  if (offscreen_window_ != nullptr) {
    gtk_widget_destroy(offscreen_window_);
    offscreen_window_ = nullptr;
  }

  if (content_manager_ != nullptr) {
    g_object_unref(content_manager_);
    content_manager_ = nullptr;
  }
}

// ============================================================
// Platform View Methods (called from Dart CustomPlatformView)
// ============================================================

void WebKitGTKView::SetSize(double width, double height, double scale_factor) {
  width_ = width > 0 ? width : 1;
  height_ = height > 0 ? height : 1;
  scale_factor_ = scale_factor > 0 ? scale_factor : 1.0;

  int w = static_cast<int>(width_ * scale_factor_);
  int h = static_cast<int>(height_ * scale_factor_);

  if (offscreen_window_) {
    gtk_widget_set_size_request(offscreen_window_, w, h);
    gtk_window_resize(GTK_WINDOW(offscreen_window_), w, h);
  }

  if (webkit_view_) {
    gtk_widget_set_size_request(GTK_WIDGET(webkit_view_), w, h);
  }
}

void WebKitGTKView::SetOffset(double /*dx*/, double /*dy*/) {
  // We don't manage window position for offscreen; Flutter positions the texture
}

void WebKitGTKView::SetCursorPos(double dx, double dy) {
  cursor_x_ = dx;
  cursor_y_ = dy;

  GdkWindow* gdk_win = GetGdkWindow();
  if (!gdk_win)
    return;

  // Synthesize GDK motion event so WebKit receives hover
  GdkEvent* event = gdk_event_new(GDK_MOTION_NOTIFY);
  GdkEventMotion& m = event->motion;
  m.window = gdk_win;
  g_object_ref(m.window);
  m.x = dx * scale_factor_;
  m.y = dy * scale_factor_;
  m.x_root = m.x;
  m.y_root = m.y;
  m.state = 0;
  m.time = GDK_CURRENT_TIME;
  m.is_hint = FALSE;
  m.axes = nullptr;
  m.device = gdk_seat_get_pointer(gdk_display_get_default_seat(gdk_display_get_default()));

  gtk_widget_event(GTK_WIDGET(webkit_view_), event);
  gdk_event_free(event);
}

void WebKitGTKView::SetPointerButton(int kind, int button, int click_count) {
  // kind: 2=down, 4=up  (InAppWebViewPointerEventKind enum)
  bool is_press = (kind == 1 /*down*/ || kind == 0 /*activate*/);
  // Map button: 0=none, 1=primary, 2=secondary, 3=tertiary
  guint gdk_button = 1;
  if (button == 2)
    gdk_button = 3;
  else if (button == 3)
    gdk_button = 2;

  GdkWindow* gdk_win = GetGdkWindow();
  if (!gdk_win)
    return;

  GdkEventType etype = is_press ? GDK_BUTTON_PRESS : GDK_BUTTON_RELEASE;
  GdkEvent* event = gdk_event_new(etype);
  GdkEventButton& b = event->button;
  b.window = gdk_win;
  g_object_ref(b.window);
  b.x = cursor_x_ * scale_factor_;
  b.y = cursor_y_ * scale_factor_;
  b.x_root = b.x;
  b.y_root = b.y;
  b.button = gdk_button;
  b.state = 0;
  b.time = GDK_CURRENT_TIME;
  b.axes = nullptr;
  b.device = gdk_seat_get_pointer(gdk_display_get_default_seat(gdk_display_get_default()));

  gtk_widget_event(GTK_WIDGET(webkit_view_), event);
  gdk_event_free(event);
}

void WebKitGTKView::SetScrollDelta(double dx, double dy) {
  GdkWindow* gdk_win = GetGdkWindow();
  if (!gdk_win)
    return;

  GdkEvent* event = gdk_event_new(GDK_SCROLL);
  GdkEventScroll& s = event->scroll;
  s.window = gdk_win;
  g_object_ref(s.window);
  s.x = cursor_x_ * scale_factor_;
  s.y = cursor_y_ * scale_factor_;
  s.x_root = s.x;
  s.y_root = s.y;
  s.direction = GDK_SCROLL_SMOOTH;
  s.delta_x = dx;
  s.delta_y = dy;
  s.state = 0;
  s.time = GDK_CURRENT_TIME;
  s.device = gdk_seat_get_pointer(gdk_display_get_default_seat(gdk_display_get_default()));

  gtk_widget_event(GTK_WIDGET(webkit_view_), event);
  gdk_event_free(event);
}

void WebKitGTKView::SendKeyEvent(int type, int key_code, int /*scan_code*/, int modifiers,
                                 const char* characters) {
  GdkWindow* gdk_win = GetGdkWindow();
  if (!gdk_win)
    return;

  GdkEventType etype = (type == 0) ? GDK_KEY_PRESS : GDK_KEY_RELEASE;
  GdkEvent* event = gdk_event_new(etype);
  GdkEventKey& k = event->key;
  k.window = gdk_win;
  g_object_ref(k.window);
  k.keyval = static_cast<guint>(key_code);
  k.state = static_cast<GdkModifierType>(modifiers);
  k.time = GDK_CURRENT_TIME;
  k.hardware_keycode = 0;
  k.group = 0;
  k.is_modifier = FALSE;
  k.length = 0;
  k.string = nullptr;

  if (characters && strlen(characters) > 0) {
    k.length = static_cast<gint>(strlen(characters));
    k.string = g_strdup(characters);
  }

  // GdkEventKey does not have a device field – key events are dispatched
  // without a device reference in GTK3.
  gtk_widget_event(GTK_WIDGET(webkit_view_), event);

  if (k.string)
    g_free(k.string);
  gdk_event_free(event);
}

// ============================================================
// WebView Operations (called from controller channel)
// ============================================================

void WebKitGTKView::LoadUrl(const std::string& url) {
  if (webkit_view_) {
    webkit_web_view_load_uri(webkit_view_, url.c_str());
  }
}

void WebKitGTKView::LoadData(const std::string& data, const std::string& mime_type,
                             const std::string& base_url) {
  if (webkit_view_) {
    const char* mt = mime_type.empty() ? "text/html" : mime_type.c_str();
    const char* bu = base_url.empty() ? "about:blank" : base_url.c_str();
    webkit_web_view_load_bytes(webkit_view_, g_bytes_new(data.c_str(), data.size()), mt, "UTF-8",
                               bu);
  }
}

void WebKitGTKView::EvaluateJavascript(const std::string& js, FlMethodCall* method_call) {
  if (!webkit_view_) {
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  // Wrap in a promise-compatible way
  std::string wrapped = "(function(){ return (" + js + "); })();";

  auto* pending = new PendingEval{method_call};
  webkit_web_view_evaluate_javascript(webkit_view_, wrapped.c_str(), -1, nullptr, nullptr, nullptr,
                                      OnJavascriptFinished, pending);
}

std::string WebKitGTKView::GetUrl() {
  if (!webkit_view_)
    return "";
  const char* uri = webkit_web_view_get_uri(webkit_view_);
  return uri ? uri : "";
}

std::string WebKitGTKView::GetTitle() {
  if (!webkit_view_)
    return "";
  const char* title = webkit_web_view_get_title(webkit_view_);
  return title ? title : "";
}

void WebKitGTKView::Reload() {
  if (webkit_view_)
    webkit_web_view_reload(webkit_view_);
}

void WebKitGTKView::StopLoading() {
  if (webkit_view_)
    webkit_web_view_stop_loading(webkit_view_);
}

bool WebKitGTKView::CanGoBack() {
  if (!webkit_view_)
    return false;
  return webkit_web_view_can_go_back(webkit_view_);
}

bool WebKitGTKView::CanGoForward() {
  if (!webkit_view_)
    return false;
  return webkit_web_view_can_go_forward(webkit_view_);
}

void WebKitGTKView::GoBack() {
  if (webkit_view_)
    webkit_web_view_go_back(webkit_view_);
}

void WebKitGTKView::GoForward() {
  if (webkit_view_)
    webkit_web_view_go_forward(webkit_view_);
}

void WebKitGTKView::AddUserScript(const std::string& source, bool at_document_start) {
  if (!webkit_view_)
    return;
  WebKitUserContentInjectedFrames frames = WEBKIT_USER_CONTENT_INJECT_ALL_FRAMES;
  WebKitUserScriptInjectionTime time = at_document_start
                                           ? WEBKIT_USER_SCRIPT_INJECT_AT_DOCUMENT_START
                                           : WEBKIT_USER_SCRIPT_INJECT_AT_DOCUMENT_END;
  WebKitUserScript* script = webkit_user_script_new(source.c_str(), frames, time, nullptr, nullptr);
  webkit_user_content_manager_add_script(content_manager_, script);
  webkit_user_script_unref(script);
}

void WebKitGTKView::RemoveAllUserScripts() {
  if (content_manager_) {
    webkit_user_content_manager_remove_all_scripts(content_manager_);
    // Re-inject our bridge after clearing
    InjectBridgeScript();
  }
}

void WebKitGTKView::AddJavaScriptHandler(const std::string& handler_name) {
  // We handle all messages through the unified bridge script message handler.
  // Just track the name so we can forward it from native bridge callback.
  js_handlers_.push_back(handler_name);
}

void WebKitGTKView::RemoveJavaScriptHandler(const std::string& handler_name) {
  js_handlers_.erase(std::remove(js_handlers_.begin(), js_handlers_.end(), handler_name),
                     js_handlers_.end());  // std::remove from <algorithm>
}

void WebKitGTKView::InjectBridgeScript() {
  // Inject the flutter_inappwebview JS bridge that provides
  // window.flutter_inappwebview.callHandler(name, ...args) → Promise
  // Uses WebKit's script message handler "flutter_inappwebview" as the transport.
  static const char* kBridgeScript = R"JS(
window.flutter_inappwebview = window.flutter_inappwebview || {};
window.flutter_inappwebview._callbackMap = {};
window.flutter_inappwebview._callCount = 0;
window.flutter_inappwebview.callHandler = function(handlerName) {
  var args = Array.prototype.slice.call(arguments, 1);
  var callId = ++window.flutter_inappwebview._callCount;
  return new Promise(function(resolve, reject) {
    window.flutter_inappwebview._callbackMap[callId] = { resolve: resolve, reject: reject };
    window.webkit.messageHandlers.flutter_inappwebview.postMessage(
      JSON.stringify({ handlerName: handlerName, args: args, callId: callId })
    );
  });
};
window.flutter_inappwebview._resolveCallback = function(callId, result) {
  var cb = window.flutter_inappwebview._callbackMap[callId];
  if (cb) { cb.resolve(result); delete window.flutter_inappwebview._callbackMap[callId]; }
};
window.flutter_inappwebview._rejectCallback = function(callId, error) {
  var cb = window.flutter_inappwebview._callbackMap[callId];
  if (cb) { cb.reject(error); delete window.flutter_inappwebview._callbackMap[callId]; }
};
)JS";

  WebKitUserScript* script =
      webkit_user_script_new(kBridgeScript, WEBKIT_USER_CONTENT_INJECT_ALL_FRAMES,
                             WEBKIT_USER_SCRIPT_INJECT_AT_DOCUMENT_START, nullptr, nullptr);
  webkit_user_content_manager_add_script(content_manager_, script);
  webkit_user_script_unref(script);
}

// ============================================================
// Pixel Buffer (Texture rendering)
// ============================================================

void WebKitGTKView::UpdatePixelBuffer() {
  if (!offscreen_window_)
    return;

  // Force GTK to process pending draw events
  gtk_widget_queue_draw(offscreen_window_);

  // Get the offscreen surface
  cairo_surface_t* src_surface =
      gtk_offscreen_window_get_surface(GTK_OFFSCREEN_WINDOW(offscreen_window_));
  if (!src_surface)
    return;

  // Get dimensions
  int w = cairo_image_surface_get_width(src_surface);
  int h = cairo_image_surface_get_height(src_surface);
  if (w <= 0 || h <= 0)
    return;

  // Convert to image surface if not already (needed to access pixel data)
  cairo_surface_t* img_surface = nullptr;
  bool owns_img = false;

  if (cairo_surface_get_type(src_surface) == CAIRO_SURFACE_TYPE_IMAGE) {
    img_surface = src_surface;
  } else {
    img_surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, w, h);
    cairo_t* cr = cairo_create(img_surface);
    cairo_set_source_surface(cr, src_surface, 0, 0);
    cairo_paint(cr);
    cairo_destroy(cr);
    owns_img = true;
  }

  cairo_surface_flush(img_surface);
  unsigned char* src_data = cairo_image_surface_get_data(img_surface);
  int stride = cairo_image_surface_get_stride(img_surface);

  if (!src_data) {
    if (owns_img)
      cairo_surface_destroy(img_surface);
    return;
  }

  // Convert Cairo ARGB32 (premultiplied, BGRA byte order on little-endian)
  // → Flutter RGBA (non-premultiplied, RGBA byte order)
  size_t needed = static_cast<size_t>(w) * static_cast<size_t>(h) * 4;

  {
    std::lock_guard<std::mutex> lock(pixel_mutex_);
    if (pixel_buffer_.size() < needed)
      pixel_buffer_.resize(needed);
    pixel_width_ = static_cast<uint32_t>(w);
    pixel_height_ = static_cast<uint32_t>(h);

    uint8_t* dst = pixel_buffer_.data();
    for (int row = 0; row < h; ++row) {
      const uint8_t* src_row = src_data + row * stride;
      for (int col = 0; col < w; ++col) {
        // Cairo ARGB32 little-endian: byte[0]=B, byte[1]=G, byte[2]=R, byte[3]=A
        uint8_t b = src_row[col * 4 + 0];
        uint8_t g = src_row[col * 4 + 1];
        uint8_t r = src_row[col * 4 + 2];
        uint8_t a = src_row[col * 4 + 3];
        // Un-premultiply
        if (a > 0 && a < 255) {
          r = static_cast<uint8_t>((static_cast<int>(r) * 255) / a);
          g = static_cast<uint8_t>((static_cast<int>(g) * 255) / a);
          b = static_cast<uint8_t>((static_cast<int>(b) * 255) / a);
        }
        dst[0] = r;
        dst[1] = g;
        dst[2] = b;
        dst[3] = a;
        dst += 4;
      }
    }
  }

  if (owns_img)
    cairo_surface_destroy(img_surface);

  MarkFrameAvailable();
}

void WebKitGTKView::MarkFrameAvailable() {
  if (texture_ && texture_registrar_) {
    fl_texture_registrar_mark_texture_frame_available(texture_registrar_, texture_);
  }
}

gboolean WebKitGTKView::PopulatePixelBuffer(const uint8_t** out_buffer, uint32_t* out_width,
                                            uint32_t* out_height) {
  std::lock_guard<std::mutex> lock(pixel_mutex_);
  if (pixel_buffer_.empty() || pixel_width_ == 0 || pixel_height_ == 0) {
    static const uint8_t kBlack[4] = {0, 0, 0, 255};
    *out_buffer = kBlack;
    *out_width = 1;
    *out_height = 1;
    return TRUE;
  }
  *out_buffer = pixel_buffer_.data();
  *out_width = pixel_width_;
  *out_height = pixel_height_;
  return TRUE;
}

// ============================================================
// Static signal handlers
// ============================================================

// static
void WebKitGTKView::OnLoadChanged(WebKitWebView* /*view*/, WebKitLoadEvent event,
                                  gpointer user_data) {
  auto* self = static_cast<WebKitGTKView*>(user_data);
  switch (event) {
    case WEBKIT_LOAD_STARTED: {
      const char* url = webkit_web_view_get_uri(self->webkit_view_);
      g_autoptr(FlValue) args = fl_value_new_map();
      fl_value_set_string_take(args, "url", fl_value_new_string(url ? url : ""));
      self->SendEventToDart("onPageStarted", args);
      break;
    }
    case WEBKIT_LOAD_FINISHED: {
      const char* url = webkit_web_view_get_uri(self->webkit_view_);
      g_autoptr(FlValue) args = fl_value_new_map();
      fl_value_set_string_take(args, "url", fl_value_new_string(url ? url : ""));
      self->SendEventToDart("onPageFinished", args);
      self->UpdatePixelBuffer();
      break;
    }
    default:
      break;
  }
}

// static
void WebKitGTKView::OnLoadFailed(WebKitWebView* /*view*/, WebKitLoadEvent /*event*/,
                                 const gchar* failing_uri, GError* error, gpointer user_data) {
  auto* self = static_cast<WebKitGTKView*>(user_data);
  g_autoptr(FlValue) args = fl_value_new_map();
  fl_value_set_string_take(args, "url", fl_value_new_string(failing_uri ? failing_uri : ""));
  fl_value_set_string_take(args, "description",
                           fl_value_new_string(error ? error->message : "Unknown error"));
  fl_value_set_string_take(args, "errorCode", fl_value_new_int(error ? error->code : -1));
  self->SendEventToDart("onReceivedError", args);
}

// static
void WebKitGTKView::OnEstimatedProgress(GObject* object, GParamSpec* /*pspec*/,
                                        gpointer user_data) {
  auto* self = static_cast<WebKitGTKView*>(user_data);
  double progress = webkit_web_view_get_estimated_load_progress(self->webkit_view_);
  int progress_int = static_cast<int>(progress * 100);
  g_autoptr(FlValue) args = fl_value_new_map();
  fl_value_set_string_take(args, "progress", fl_value_new_int(progress_int));
  self->SendEventToDart("onProgressChanged", args);
}

// static
void WebKitGTKView::OnScriptMessageReceived(WebKitUserContentManager* /*manager*/,
                                            WebKitJavascriptResult* result, gpointer user_data) {
  auto* self = static_cast<WebKitGTKView*>(user_data);
  if (!result)
    return;

  JSCValue* value = webkit_javascript_result_get_js_value(result);
  if (!value)
    return;

  // The message is a JSON string from our bridge
  char* json_str = nullptr;
  if (jsc_value_is_string(value)) {
    json_str = jsc_value_to_string(value);
  }

  if (!json_str)
    return;

  // Parse: { handlerName: string, args: array, callId: number }
  // Send to Dart as onCallJsHandler
  g_autoptr(FlValue) args = fl_value_new_map();
  fl_value_set_string_take(args, "handlerName", fl_value_new_string("_bridgeMessage"));
  fl_value_set_string_take(args, "args", fl_value_new_string(json_str));
  g_free(json_str);

  // Invoke on webview channel
  if (self->webview_channel_) {
    fl_method_channel_invoke_method(self->webview_channel_, "onCallJsHandler", args, nullptr,
                                    nullptr, nullptr);
  }
}

// static
void WebKitGTKView::OnJavascriptFinished(GObject* source_object, GAsyncResult* res,
                                         gpointer user_data) {
  auto* pending = static_cast<PendingEval*>(user_data);
  auto* webview = WEBKIT_WEB_VIEW(source_object);

  GError* error = nullptr;
  JSCValue* value = webkit_web_view_evaluate_javascript_finish(webview, res, &error);

  if (error) {
    fl_method_call_respond_error(pending->method_call, "evaluateJavascript", error->message,
                                 nullptr, nullptr);
    g_error_free(error);
    delete pending;
    return;
  }

  std::string result_str;
  if (value) {
    char* str = jsc_value_to_json(value, 0);
    if (str) {
      result_str = str;
      g_free(str);
    }
    g_object_unref(value);
  }

  g_autoptr(FlValue) fl_result = fl_value_new_string(result_str.c_str());
  fl_method_call_respond_success(pending->method_call, fl_result, nullptr);
  delete pending;
}

// static
gboolean WebKitGTKView::OnDamageEvent(GtkWidget* widget, GdkEventExpose* /*event*/,
                                      gpointer user_data) {
  auto* self = static_cast<WebKitGTKView*>(user_data);
  self->UpdatePixelBuffer();
  return FALSE;
}

// static
gboolean WebKitGTKView::OnTimerTick(gpointer user_data) {
  auto* self = static_cast<WebKitGTKView*>(user_data);
  if (!self->webkit_view_)
    return G_SOURCE_REMOVE;
  self->UpdatePixelBuffer();
  return G_SOURCE_CONTINUE;
}

// static
FlMethodErrorResponse* WebKitGTKView::OnEventListen(FlEventChannel* /*channel*/, FlValue* /*args*/,
                                                    gpointer user_data) {
  auto* self = static_cast<WebKitGTKView*>(user_data);
  self->event_listening_ = true;
  return nullptr;
}

// static
FlMethodErrorResponse* WebKitGTKView::OnEventCancel(FlEventChannel* /*channel*/, FlValue* /*args*/,
                                                    gpointer user_data) {
  auto* self = static_cast<WebKitGTKView*>(user_data);
  self->event_listening_ = false;
  return nullptr;
}

// ============================================================
// Method Channel Handlers
// ============================================================

// static
void WebKitGTKView::HandleWebviewMethodCall(FlMethodChannel* /*channel*/, FlMethodCall* method_call,
                                            gpointer user_data) {
  auto* self = static_cast<WebKitGTKView*>(user_data);
  self->HandleWebviewMethodCallImpl(method_call);
}

// static
void WebKitGTKView::HandlePlatformViewMethodCall(FlMethodChannel* /*channel*/,
                                                 FlMethodCall* method_call, gpointer user_data) {
  auto* self = static_cast<WebKitGTKView*>(user_data);
  self->HandlePlatformViewMethodCallImpl(method_call);
}

void WebKitGTKView::HandleWebviewMethodCallImpl(FlMethodCall* method_call) {
  const char* method = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);

  if (strcmp(method, "loadUrl") == 0) {
    // args: { "url": string, "headers": map? }
    const char* url = nullptr;
    if (fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
      FlValue* url_val = fl_value_lookup_string(args, "url");
      if (url_val && fl_value_get_type(url_val) == FL_VALUE_TYPE_STRING)
        url = fl_value_get_string(url_val);
    } else if (fl_value_get_type(args) == FL_VALUE_TYPE_STRING) {
      url = fl_value_get_string(args);
    }
    if (url)
      LoadUrl(url);
    fl_method_call_respond_success(method_call, nullptr, nullptr);

  } else if (strcmp(method, "loadData") == 0) {
    const char* data = nullptr;
    const char* mime_type = "text/html";
    const char* base_url = "about:blank";
    if (fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
      FlValue* v;
      v = fl_value_lookup_string(args, "data");
      if (v && fl_value_get_type(v) == FL_VALUE_TYPE_STRING)
        data = fl_value_get_string(v);
      v = fl_value_lookup_string(args, "mimeType");
      if (v && fl_value_get_type(v) == FL_VALUE_TYPE_STRING)
        mime_type = fl_value_get_string(v);
      v = fl_value_lookup_string(args, "baseUrl");
      if (v && fl_value_get_type(v) == FL_VALUE_TYPE_STRING)
        base_url = fl_value_get_string(v);
    }
    if (data)
      LoadData(data, mime_type ? mime_type : "text/html", base_url ? base_url : "about:blank");
    fl_method_call_respond_success(method_call, nullptr, nullptr);

  } else if (strcmp(method, "evaluateJavascript") == 0) {
    const char* js = nullptr;
    if (fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
      FlValue* v = fl_value_lookup_string(args, "source");
      if (v && fl_value_get_type(v) == FL_VALUE_TYPE_STRING)
        js = fl_value_get_string(v);
    } else if (fl_value_get_type(args) == FL_VALUE_TYPE_STRING) {
      js = fl_value_get_string(args);
    }
    if (js) {
      EvaluateJavascript(js, method_call);
    } else {
      fl_method_call_respond_success(method_call, nullptr, nullptr);
    }
    return;  // async response

  } else if (strcmp(method, "getUrl") == 0) {
    std::string url = GetUrl();
    g_autoptr(FlValue) result = fl_value_new_string(url.c_str());
    fl_method_call_respond_success(method_call, result, nullptr);

  } else if (strcmp(method, "getTitle") == 0) {
    std::string title = GetTitle();
    g_autoptr(FlValue) result = fl_value_new_string(title.c_str());
    fl_method_call_respond_success(method_call, result, nullptr);

  } else if (strcmp(method, "reload") == 0) {
    Reload();
    fl_method_call_respond_success(method_call, nullptr, nullptr);

  } else if (strcmp(method, "stopLoading") == 0) {
    StopLoading();
    fl_method_call_respond_success(method_call, nullptr, nullptr);

  } else if (strcmp(method, "canGoBack") == 0) {
    g_autoptr(FlValue) result = fl_value_new_bool(CanGoBack());
    fl_method_call_respond_success(method_call, result, nullptr);

  } else if (strcmp(method, "canGoForward") == 0) {
    g_autoptr(FlValue) result = fl_value_new_bool(CanGoForward());
    fl_method_call_respond_success(method_call, result, nullptr);

  } else if (strcmp(method, "goBack") == 0) {
    GoBack();
    fl_method_call_respond_success(method_call, nullptr, nullptr);

  } else if (strcmp(method, "goForward") == 0) {
    GoForward();
    fl_method_call_respond_success(method_call, nullptr, nullptr);

  } else if (strcmp(method, "addUserScript") == 0) {
    const char* source = nullptr;
    bool at_start = true;
    if (fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
      FlValue* v = fl_value_lookup_string(args, "source");
      if (v && fl_value_get_type(v) == FL_VALUE_TYPE_STRING)
        source = fl_value_get_string(v);
      FlValue* it = fl_value_lookup_string(args, "injectionTime");
      if (it && fl_value_get_type(it) == FL_VALUE_TYPE_INT)
        at_start = (fl_value_get_int(it) == 0);
    }
    if (source)
      AddUserScript(source, at_start);
    fl_method_call_respond_success(method_call, nullptr, nullptr);

  } else if (strcmp(method, "removeAllUserScripts") == 0) {
    RemoveAllUserScripts();
    fl_method_call_respond_success(method_call, nullptr, nullptr);

  } else if (strcmp(method, "addJavaScriptHandler") == 0) {
    const char* name = nullptr;
    if (fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
      FlValue* v = fl_value_lookup_string(args, "handlerName");
      if (v && fl_value_get_type(v) == FL_VALUE_TYPE_STRING)
        name = fl_value_get_string(v);
    }
    if (name)
      AddJavaScriptHandler(name);
    fl_method_call_respond_success(method_call, nullptr, nullptr);

  } else if (strcmp(method, "removeJavaScriptHandler") == 0) {
    const char* name = nullptr;
    if (fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
      FlValue* v = fl_value_lookup_string(args, "handlerName");
      if (v && fl_value_get_type(v) == FL_VALUE_TYPE_STRING)
        name = fl_value_get_string(v);
    }
    if (name)
      RemoveJavaScriptHandler(name);
    fl_method_call_respond_success(method_call, nullptr, nullptr);

  } else if (strcmp(method, "getProgress") == 0) {
    if (!webkit_view_) {
      fl_method_call_respond_success(method_call, fl_value_new_int(0), nullptr);
      return;
    }
    int progress =
        static_cast<int>(webkit_web_view_get_estimated_load_progress(webkit_view_) * 100);
    g_autoptr(FlValue) result = fl_value_new_int(progress);
    fl_method_call_respond_success(method_call, result, nullptr);

  } else if (strcmp(method, "setSettings") == 0) {
    // Apply basic settings from the args map
    if (webkit_view_ && fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
      WebKitSettings* settings = webkit_web_view_get_settings(webkit_view_);
      FlValue* v;
      v = fl_value_lookup_string(args, "javaScriptEnabled");
      if (v && fl_value_get_type(v) == FL_VALUE_TYPE_BOOL)
        webkit_settings_set_enable_javascript(settings, fl_value_get_bool(v));
      v = fl_value_lookup_string(args, "userAgent");
      if (v && fl_value_get_type(v) == FL_VALUE_TYPE_STRING)
        webkit_settings_set_user_agent(settings, fl_value_get_string(v));
    }
    fl_method_call_respond_success(method_call, nullptr, nullptr);

  } else if (strcmp(method, "getSettings") == 0) {
    // Return basic settings
    g_autoptr(FlValue) result = fl_value_new_map();
    if (webkit_view_) {
      WebKitSettings* settings = webkit_web_view_get_settings(webkit_view_);
      fl_value_set_string_take(result, "javaScriptEnabled",
                               fl_value_new_bool(webkit_settings_get_enable_javascript(settings)));
    }
    fl_method_call_respond_success(method_call, result, nullptr);

  } else {
    // Unknown method – respond with not implemented (non-fatal on Linux)
    fl_method_call_respond_not_implemented(method_call, nullptr);
  }
}

void WebKitGTKView::HandlePlatformViewMethodCallImpl(FlMethodCall* method_call) {
  const char* method = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);

  if (strcmp(method, "setSize") == 0 && fl_value_get_type(args) == FL_VALUE_TYPE_LIST &&
      fl_value_get_length(args) >= 3) {
    double w = fl_value_get_float(fl_value_get_list_value(args, 0));
    double h = fl_value_get_float(fl_value_get_list_value(args, 1));
    double sf = fl_value_get_float(fl_value_get_list_value(args, 2));
    SetSize(w, h, sf);
    fl_method_call_respond_success(method_call, nullptr, nullptr);

  } else if (strcmp(method, "setTextureOffset") == 0 &&
             fl_value_get_type(args) == FL_VALUE_TYPE_LIST && fl_value_get_length(args) >= 2) {
    double dx = fl_value_get_float(fl_value_get_list_value(args, 0));
    double dy = fl_value_get_float(fl_value_get_list_value(args, 1));
    SetOffset(dx, dy);
    fl_method_call_respond_success(method_call, nullptr, nullptr);

  } else if (strcmp(method, "setCursorPos") == 0 && fl_value_get_type(args) == FL_VALUE_TYPE_LIST &&
             fl_value_get_length(args) >= 2) {
    double dx = fl_value_get_float(fl_value_get_list_value(args, 0));
    double dy = fl_value_get_float(fl_value_get_list_value(args, 1));
    SetCursorPos(dx, dy);
    fl_method_call_respond_success(method_call, nullptr, nullptr);

  } else if (strcmp(method, "setPointerButton") == 0 &&
             fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
    FlValue* kind_v = fl_value_lookup_string(args, "kind");
    FlValue* btn_v = fl_value_lookup_string(args, "button");
    FlValue* cc_v = fl_value_lookup_string(args, "clickCount");
    int kind = kind_v ? static_cast<int>(fl_value_get_int(kind_v)) : 0;
    int btn = btn_v ? static_cast<int>(fl_value_get_int(btn_v)) : 1;
    int cc = cc_v ? static_cast<int>(fl_value_get_int(cc_v)) : 1;
    SetPointerButton(kind, btn, cc);
    fl_method_call_respond_success(method_call, nullptr, nullptr);

  } else if (strcmp(method, "setScrollDelta") == 0 &&
             fl_value_get_type(args) == FL_VALUE_TYPE_LIST && fl_value_get_length(args) >= 2) {
    double dx = fl_value_get_float(fl_value_get_list_value(args, 0));
    double dy = fl_value_get_float(fl_value_get_list_value(args, 1));
    SetScrollDelta(dx, dy);
    fl_method_call_respond_success(method_call, nullptr, nullptr);

  } else if (strcmp(method, "sendKeyEvent") == 0 && fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
    FlValue* type_v = fl_value_lookup_string(args, "type");
    FlValue* kc_v = fl_value_lookup_string(args, "keyCode");
    FlValue* sc_v = fl_value_lookup_string(args, "scanCode");
    FlValue* mod_v = fl_value_lookup_string(args, "modifiers");
    FlValue* ch_v = fl_value_lookup_string(args, "characters");
    int type = type_v ? static_cast<int>(fl_value_get_int(type_v)) : 0;
    int kc = kc_v ? static_cast<int>(fl_value_get_int(kc_v)) : 0;
    int sc = sc_v ? static_cast<int>(fl_value_get_int(sc_v)) : 0;
    int mod = mod_v ? static_cast<int>(fl_value_get_int(mod_v)) : 0;
    const char* ch = ch_v && fl_value_get_type(ch_v) == FL_VALUE_TYPE_STRING
                         ? fl_value_get_string(ch_v)
                         : nullptr;
    SendKeyEvent(type, kc, sc, mod, ch);
    fl_method_call_respond_success(method_call, nullptr, nullptr);

  } else {
    fl_method_call_respond_not_implemented(method_call, nullptr);
  }
}

// ============================================================
// Helpers
// ============================================================

GdkWindow* WebKitGTKView::GetGdkWindow() const {
  if (!webkit_view_)
    return nullptr;
  GtkWidget* widget = GTK_WIDGET(webkit_view_);
  if (!gtk_widget_get_realized(widget))
    return nullptr;
  return gtk_widget_get_window(widget);
}

void WebKitGTKView::SendEventToDart(const char* event_name, FlValue* args) {
  if (!webview_channel_)
    return;
  // Wrap as a map with "type" key for event channel, or invoke directly
  fl_method_channel_invoke_method(webview_channel_, event_name, args, nullptr, nullptr, nullptr);
}

}  // namespace flutter_inappwebview_webkit
