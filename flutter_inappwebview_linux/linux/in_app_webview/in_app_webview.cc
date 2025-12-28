#include "in_app_webview.h"

#include <algorithm>
#include <cstring>
#include <random>
#include <gdk/gdk.h>
#include <libsoup/soup.h>

#include <cairo.h>

#include "simd_convert.h"
#include "../plugin_scripts_js/javascript_bridge_js.h"
#include "../types/create_window_action.h"
#include "../types/http_auth_types.h"
#include "../types/javascript_handler_function_data.h"
#include "../types/js_dialog_types.h"
#include "../types/navigation_action.h"
#include "../types/permission_types.h"
#include "../types/web_resource_error.h"
#include "../types/web_resource_request.h"
#include "../utils/flutter.h"
#include "../utils/log.h"
#include "user_content_controller.h"
#include "webview_channel_delegate.h"

namespace flutter_inappwebview_plugin {

// Static member initialization
GdkBackendType InAppWebView::cached_backend_type_ = GdkBackendType::Unknown;
bool InAppWebView::backend_type_detected_ = false;

namespace {

// Generate a random hex string for the JS bridge secret
std::string GenerateRandomSecret(size_t length = 32) {
  static const char* hex_chars = "0123456789abcdef";
  std::random_device rd;
  std::mt19937 gen(rd());
  std::uniform_int_distribution<> dis(0, 15);
  
  std::string result;
  result.reserve(length);
  for (size_t i = 0; i < length; ++i) {
    result += hex_chars[dis(gen)];
  }
  return result;
}

bool DebugLogEnabled() {
  static bool enabled = g_getenv("FLUTTER_INAPPWEBVIEW_LINUX_DEBUG") != nullptr;
  return enabled;
}

bool DisableShouldOverrideNative() {
  static bool disabled =
      g_getenv("FLUTTER_INAPPWEBVIEW_LINUX_DISABLE_SHOULD_OVERRIDE") != nullptr;
  return disabled;
}

// Check if OpenGL is available for WebKit hardware acceleration
bool IsWebKitGLAvailable() {
  static bool checked = false;
  static bool available = false;
  
  if (checked) {
    return available;
  }
  checked = true;
  
  // Check environment override first
  if (g_getenv("FLUTTER_INAPPWEBVIEW_LINUX_FORCE_WEBKIT_HW_ACCEL") != nullptr) {
    available = true;
    return true;
  }
  if (g_getenv("FLUTTER_INAPPWEBVIEW_LINUX_DISABLE_WEBKIT_HW_ACCEL") != nullptr) {
    available = false;
    return false;
  }
  
  // Try to detect if OpenGL is supported by the display
  GdkDisplay* display = gdk_display_get_default();
  if (display == nullptr) {
    return false;
  }
  
  // Create a temporary offscreen window to test GL capability
  GtkWidget* test_window = gtk_offscreen_window_new();
  if (test_window == nullptr) {
    return false;
  }
  
  gtk_widget_set_size_request(test_window, 1, 1);
  gtk_widget_realize(test_window);
  
  GdkWindow* gdk_window = gtk_widget_get_window(test_window);
  if (gdk_window != nullptr) {
    GError* error = nullptr;
    GdkGLContext* gl_context = gdk_window_create_gl_context(gdk_window, &error);
    
    if (gl_context != nullptr) {
      available = true;
      g_object_unref(gl_context);
      if (DebugLogEnabled()) {
        g_message("InAppWebView: OpenGL is available for WebKit HW acceleration");
      }
    } else {
      if (DebugLogEnabled()) {
        g_message("InAppWebView: OpenGL not available for WebKit: %s",
                  error ? error->message : "unknown error");
      }
      if (error) {
        g_error_free(error);
      }
    }
  }
  
  gtk_widget_destroy(test_window);
  
  return available;
}

// Check if WebKit hardware acceleration should be enabled
// Auto-detects if GL is available, enabled by default when supported.
// Set FLUTTER_INAPPWEBVIEW_LINUX_FORCE_WEBKIT_HW_ACCEL=1 to force enable.
// Set FLUTTER_INAPPWEBVIEW_LINUX_DISABLE_WEBKIT_HW_ACCEL=1 to force disable.
bool UseWebKitHardwareAcceleration() {
  return IsWebKitGLAvailable();
}
}  // namespace

void InAppWebView::DetectBackendType() {
  if (backend_type_detected_) {
    return;
  }
  
  backend_type_detected_ = true;
  cached_backend_type_ = GdkBackendType::Unknown;
  
  // Try environment variables first
  const char* session_type = g_getenv("XDG_SESSION_TYPE");
  const char* wayland_display = g_getenv("WAYLAND_DISPLAY");
  const char* display = g_getenv("DISPLAY");
  const char* gdk_backend = g_getenv("GDK_BACKEND");
  
  if (DebugLogEnabled()) {
    g_message("InAppWebView: DetectBackendType - XDG_SESSION_TYPE=%s, WAYLAND_DISPLAY=%s, DISPLAY=%s, GDK_BACKEND=%s",
              session_type ? session_type : "<null>",
              wayland_display ? wayland_display : "<null>",
              display ? display : "<null>",
              gdk_backend ? gdk_backend : "<null>");
  }
  
  // Check GDK display name if available
  GdkDisplay* gdk_display = gdk_display_get_default();
  if (gdk_display != nullptr) {
    const gchar* display_name = gdk_display_get_name(gdk_display);
    if (display_name != nullptr) {
      if (DebugLogEnabled()) {
        g_message("InAppWebView: GDK display name: %s", display_name);
      }
      
      // Parse display name to detect backend
      if (g_str_has_prefix(display_name, "wayland") ||
          g_str_has_prefix(display_name, "Wayland")) {
        cached_backend_type_ = GdkBackendType::Wayland;
      } else if (g_str_has_prefix(display_name, ":") ||
                 g_str_has_prefix(display_name, "x11")) {
        cached_backend_type_ = GdkBackendType::X11;
      } else if (g_str_has_prefix(display_name, "broadway")) {
        cached_backend_type_ = GdkBackendType::Broadway;
      }
    }
  }
  
  // Fallback to environment variable detection
  if (cached_backend_type_ == GdkBackendType::Unknown) {
    if (gdk_backend != nullptr) {
      if (g_strcmp0(gdk_backend, "wayland") == 0) {
        cached_backend_type_ = GdkBackendType::Wayland;
      } else if (g_strcmp0(gdk_backend, "x11") == 0) {
        cached_backend_type_ = GdkBackendType::X11;
      }
    } else if (session_type != nullptr) {
      if (g_strcmp0(session_type, "wayland") == 0) {
        cached_backend_type_ = GdkBackendType::Wayland;
      } else if (g_strcmp0(session_type, "x11") == 0) {
        cached_backend_type_ = GdkBackendType::X11;
      }
    } else if (wayland_display != nullptr) {
      cached_backend_type_ = GdkBackendType::Wayland;
    } else if (display != nullptr) {
      cached_backend_type_ = GdkBackendType::X11;
    }
  }
  
  if (DebugLogEnabled()) {
    const char* backend_name = "Unknown";
    switch (cached_backend_type_) {
      case GdkBackendType::X11: backend_name = "X11"; break;
      case GdkBackendType::Wayland: backend_name = "Wayland"; break;
      case GdkBackendType::Broadway: backend_name = "Broadway"; break;
      default: break;
    }
    g_message("InAppWebView: Detected backend: %s", backend_name);
  }
}

GdkBackendType InAppWebView::GetBackendType() {
  DetectBackendType();
  return cached_backend_type_;
}

bool InAppWebView::SupportsCursorWarp() {
  // Cursor warping is typically only supported on X11
  return GetBackendType() == GdkBackendType::X11;
}

InAppWebView::InAppWebView(FlBinaryMessenger* messenger, int64_t id,
                           const InAppWebViewCreationParams& params)
    : id_(id),
      settings_(params.initialSettings) {
  if (DebugLogEnabled()) {
    bool useShouldOverride = settings_ ? settings_->useShouldOverrideUrlLoading : false;
    g_message("InAppWebView[%ld]: ctor (useShouldOverrideUrlLoading=%s)",
              static_cast<long>(id_),
              useShouldOverride ? "true" : "false");
  }
  InitWebView(params);
  RegisterEventHandlers();

  // Channel delegate is attached later, once the texture id is known.
  // See CustomPlatformView -> AttachChannel.

  // Apply initial settings
  if (settings_) {
    settings_->applyToWebView(webview_);
  }

  // Load initial content
  if (params.initialUrlRequest.has_value()) {
    auto& urlRequest = params.initialUrlRequest.value();
    if (DebugLogEnabled()) {
      g_message("InAppWebView[%ld]: initialUrlRequest url=%s method=%s",
                static_cast<long>(id_),
                urlRequest->url.value_or("").c_str(),
                urlRequest->method.value_or("GET").c_str());
    }
    loadUrl(urlRequest);
  } else if (params.initialData.has_value()) {
    if (DebugLogEnabled()) {
      g_message("InAppWebView[%ld]: initialData (len=%zu)",
                static_cast<long>(id_), params.initialData->size());
    }
    std::string mimeType = params.initialDataMimeType.value_or("text/html");
    std::string encoding = params.initialDataEncoding.value_or("UTF-8");
    std::string baseUrl = params.initialDataBaseUrl.value_or("about:blank");
    loadData(params.initialData.value(), mimeType, encoding, baseUrl);
  } else if (params.initialFile.has_value()) {
    if (DebugLogEnabled()) {
      g_message("InAppWebView[%ld]: initialFile=%s", static_cast<long>(id_),
                params.initialFile.value().c_str());
    }
    loadFile(params.initialFile.value());
  } else {
    if (DebugLogEnabled()) {
      g_message("InAppWebView[%ld]: no initial content provided", static_cast<long>(id_));
    }
  }

  // Start snapshot timer after a short delay to allow webview to initialize
  StartSnapshotTimer();
}

void InAppWebView::AttachChannel(FlBinaryMessenger* messenger,
                                int64_t channel_id) {
  channel_id_ = channel_id;
  if (messenger == nullptr) {
    g_warning("InAppWebView[%ld]: AttachChannel messenger is null", static_cast<long>(id_));
    return;
  }
  // Create channel with explicit name using channel_id
  std::string channelName = std::string(METHOD_CHANNEL_NAME_PREFIX) + std::to_string(channel_id_);
  channel_delegate_ = std::make_unique<WebViewChannelDelegate>(this, messenger, channelName);
  if (DebugLogEnabled()) {
    g_message("InAppWebView[%ld]: attached channel id=%ld", static_cast<long>(id_),
              static_cast<long>(channel_id_));
  }
}

InAppWebView::~InAppWebView() {
  if (snapshot_timer_id_ != 0) {
    g_source_remove(snapshot_timer_id_);
    snapshot_timer_id_ = 0;
  }

  // Clean up pending policy decisions
  for (auto& pair : pending_policy_decisions_) {
    webkit_policy_decision_ignore(pair.second);
    g_object_unref(pair.second);
  }
  pending_policy_decisions_.clear();

  if (container_window_ != nullptr) {
    gtk_widget_destroy(container_window_);
    container_window_ = nullptr;
    webview_ = nullptr;
  }
}

void InAppWebView::InitWebView(const InAppWebViewCreationParams& params) {
  // Detect backend type for logging and feature adaptation
  DetectBackendType();
  
  // IMPORTANT: We do NOT call gtk_init() here - Flutter's Linux runner
  // already initializes GTK. Calling it again can cause backend conflicts.
  
  // IMPORTANT: We do NOT set GDK_BACKEND environment variable - this should
  // be determined by the system/user, not forced by the plugin.
  
  // Use GtkOffscreenWindow - this is the proper GTK widget for offscreen
  // rendering. It doesn't create a visible window and is designed for
  // capturing widget content to a surface.
  container_window_ = gtk_offscreen_window_new();
  if (container_window_ == nullptr) {
    g_warning("InAppWebView: Failed to create offscreen window");
    return;
  }
  
  gtk_widget_set_size_request(container_window_, width_, height_);

  if (DebugLogEnabled()) {
    g_message("InAppWebView[%ld]: InitWebView offscreen window %dx%d (scale=%0.2f)",
              static_cast<long>(id_), width_, height_, scale_factor_);
  }

  // Create WebKit settings
  WebKitSettings* settings = webkit_settings_new();
  if (settings != nullptr) {
    webkit_settings_set_enable_javascript(settings, TRUE);
    webkit_settings_set_enable_developer_extras(settings, TRUE);
    
    // Hardware acceleration policy:
    // - By default, keep HW accel OFF to avoid GL context conflicts with Flutter.
    // - We use FlTextureGL for efficient GPU texture sharing with Flutter, but
    //   WebKit still renders via CPU snapshot which we upload to GPU.
    // - Set FLUTTER_INAPPWEBVIEW_LINUX_WEBKIT_HW_ACCEL=1 to enable WebKit HW accel.
    if (UseWebKitHardwareAcceleration()) {
      webkit_settings_set_hardware_acceleration_policy(settings, 
          WEBKIT_HARDWARE_ACCELERATION_POLICY_ALWAYS);
      if (DebugLogEnabled()) {
        g_message("InAppWebView[%ld]: WebKit hardware acceleration ENABLED",
                  static_cast<long>(id_));
      }
    } else {
      webkit_settings_set_hardware_acceleration_policy(settings, 
          WEBKIT_HARDWARE_ACCELERATION_POLICY_NEVER);
      if (DebugLogEnabled()) {
        g_message("InAppWebView[%ld]: WebKit hardware acceleration DISABLED (using CPU snapshot)",
                  static_cast<long>(id_));
      }
    }
  }

  webview_ = WEBKIT_WEB_VIEW(
      webkit_web_view_new_with_settings(settings));
  
  if (webview_ == nullptr) {
    g_warning("InAppWebView: Failed to create WebKitWebView");
    if (settings != nullptr) {
      g_object_unref(settings);
    }
    gtk_widget_destroy(container_window_);
    container_window_ = nullptr;
    return;
  }

  gtk_container_add(GTK_CONTAINER(container_window_), GTK_WIDGET(webview_));
  gtk_widget_set_size_request(GTK_WIDGET(webview_), width_, height_);

  // Set a non-transparent background so snapshots aren't blank
  GdkRGBA bg;
  bg.red = 1.0;
  bg.green = 1.0;
  bg.blue = 1.0;
  bg.alpha = 1.0;
  webkit_web_view_set_background_color(webview_, &bg);

  // Show all widgets - GtkOffscreenWindow doesn't create a visible window,
  // it just enables the widget tree for rendering
  gtk_widget_show_all(container_window_);

  // Force realization so we can synthesize GDK events with a valid
  // GdkWindow/GdkDevice
  gtk_widget_realize(container_window_);
  gtk_widget_realize(GTK_WIDGET(webview_));

  if (DebugLogEnabled()) {
    g_message("InAppWebView[%ld]: webview created (GL texture rendering enabled)", 
              static_cast<long>(id_));
  }

  if (settings != nullptr) {
    g_object_unref(settings);
  }
}

void InAppWebView::StartSnapshotTimer() {
  // Start snapshot timer for continuous rendering
  if (webview_ == nullptr) {
    return;
  }
  snapshot_timer_id_ = g_timeout_add(1000 / fps_limit_, SnapshotTick, this);
}

void InAppWebView::RegisterEventHandlers() {
  if (webview_ == nullptr) return;
  
  // Initialize UserContentController and JavaScript bridge
  js_bridge_secret_ = GenerateRandomSecret();
  user_content_controller_ = std::make_unique<UserContentController>(this);
  user_content_controller_->initialize();
  
  // Set up the script message handler callback
  user_content_controller_->setScriptMessageHandler(
      [this](const std::string& name, const std::string& body) {
        handleScriptMessage(name, body);
      });
  
  // Add the JavaScript bridge plugin script
  auto jsBridgeScript = JavaScriptBridgeJS::JAVASCRIPT_BRIDGE_JS_PLUGIN_SCRIPT(
      js_bridge_secret_,
      std::nullopt,  // allowedOriginRules - allow all
      false          // forMainFrameOnly - inject in all frames
  );
  user_content_controller_->addPluginScript(std::move(jsBridgeScript));
  
  if (DebugLogEnabled()) {
    g_message("InAppWebView[%ld]: JavaScript bridge initialized", static_cast<long>(id_));
  }
  
  g_signal_connect(webview_, "load-changed", G_CALLBACK(OnLoadChanged), this);
  g_signal_connect(webview_, "decide-policy", G_CALLBACK(OnDecidePolicy), this);
  g_signal_connect(webview_, "load-failed", G_CALLBACK(OnLoadFailed), this);
  g_signal_connect(webview_, "load-failed-with-tls-errors",
                   G_CALLBACK(OnLoadFailedWithTlsErrors), this);
  g_signal_connect(webview_, "close", G_CALLBACK(OnCloseRequest), this);
  
  // Property change notifications
  g_signal_connect(webview_, "notify::estimated-load-progress",
                   G_CALLBACK(OnNotifyEstimatedLoadProgress), this);
  g_signal_connect(webview_, "notify::title",
                   G_CALLBACK(OnNotifyTitle), this);
  
  // Connect to motion-notify-event to detect cursor changes
  // WebKit changes the cursor based on what element is under the mouse
  gtk_widget_add_events(GTK_WIDGET(webview_), GDK_POINTER_MOTION_MASK);
  g_signal_connect(webview_, "motion-notify-event", G_CALLBACK(OnMotionNotify), this);
  
  // Connect to mouse-target-changed for more reliable cursor detection
  // This signal is emitted when the mouse moves over different elements
  g_signal_connect(webview_, "mouse-target-changed", G_CALLBACK(OnMouseTargetChanged), this);

  // Connect to create signal for window.open() / target="_blank"
  g_signal_connect(webview_, "create", G_CALLBACK(OnCreateWebView), this);
  
  // Connect to script-dialog for JavaScript alert/confirm/prompt
  g_signal_connect(webview_, "script-dialog", G_CALLBACK(OnScriptDialog), this);
  
  // Connect to permission-request for camera/microphone/geolocation
  g_signal_connect(webview_, "permission-request", G_CALLBACK(OnPermissionRequest), this);
  
  // Connect to authenticate for HTTP auth
  g_signal_connect(webview_, "authenticate", G_CALLBACK(OnAuthenticate), this);
  
  // Connect to context-menu for right-click menu handling
  g_signal_connect(webview_, "context-menu", G_CALLBACK(OnContextMenu), this);
  
  // Connect to fullscreen events
  g_signal_connect(webview_, "enter-fullscreen", G_CALLBACK(OnEnterFullscreen), this);
  g_signal_connect(webview_, "leave-fullscreen", G_CALLBACK(OnLeaveFullscreen), this);
  
  // Connect to favicon changes
  g_signal_connect(webview_, "notify::favicon", G_CALLBACK(OnNotifyFavicon), this);

  if (DebugLogEnabled()) {
    g_message("InAppWebView[%ld]: connected WebKit signals", static_cast<long>(id_));
  }
}

void InAppWebView::loadUrl(const std::string& url) {
  if (webview_ == nullptr) return;
  if (DebugLogEnabled()) {
    g_message("InAppWebView[%ld]: LoadUrl %s", static_cast<long>(id_), url.c_str());
  }
  webkit_web_view_load_uri(webview_, url.c_str());
}

void InAppWebView::loadUrl(const std::shared_ptr<URLRequest>& urlRequest) {
  if (webview_ == nullptr || !urlRequest) return;

  if (!urlRequest->url.has_value() || urlRequest->url->empty()) {
    if (DebugLogEnabled()) {
      g_message("InAppWebView[%ld]: LoadUrlRequest - no URL provided", static_cast<long>(id_));
    }
    return;
  }

  const std::string& url = urlRequest->url.value();
  const std::string method = urlRequest->method.value_or("GET");

  if (DebugLogEnabled()) {
    g_message("InAppWebView[%ld]: LoadUrlRequest url=%s method=%s",
              static_cast<long>(id_), url.c_str(), method.c_str());
  }

  // For simple GET requests without custom headers, use the simple load
  if (method == "GET" && !urlRequest->headers.has_value() && !urlRequest->body.has_value()) {
    webkit_web_view_load_uri(webview_, url.c_str());
    return;
  }

  // For requests with custom method, headers, or body, use WebKitURIRequest
  WebKitURIRequest* request = webkit_uri_request_new(url.c_str());
  if (request == nullptr) {
    g_warning("InAppWebView[%ld]: Failed to create WebKitURIRequest for %s",
              static_cast<long>(id_), url.c_str());
    return;
  }

  // Set HTTP method if not GET
  if (method != "GET") {
    // WebKitURIRequest doesn't directly support setting the method for load_request,
    // but we can use a message to modify the request. For POST, we need to use
    // webkit_web_view_load_request with body.
    // Note: WebKitGTK's simple API doesn't fully support custom methods for navigation.
    // For now, we'll log a warning for non-GET methods.
    if (DebugLogEnabled()) {
      g_message("InAppWebView[%ld]: Note - WebKitGTK load_request may not fully support method=%s",
                static_cast<long>(id_), method.c_str());
    }
  }

  // Set headers if provided
  if (urlRequest->headers.has_value()) {
    SoupMessageHeaders* headers = webkit_uri_request_get_http_headers(request);
    if (headers != nullptr) {
      for (const auto& [key, value] : urlRequest->headers.value()) {
        soup_message_headers_append(headers, key.c_str(), value.c_str());
        if (DebugLogEnabled()) {
          g_message("InAppWebView[%ld]: LoadUrlRequest header: %s=%s",
                    static_cast<long>(id_), key.c_str(), value.c_str());
        }
      }
    }
  }

  // Load the request
  webkit_web_view_load_request(webview_, request);
  g_object_unref(request);
}

void InAppWebView::loadData(const std::string& data,
                            const std::string& mime_type,
                            const std::string& encoding,
                            const std::string& base_url) {
  if (webview_ == nullptr) return;
  if (DebugLogEnabled()) {
    g_message(
        "InAppWebView[%ld]: LoadData mime=%s encoding=%s base=%s (len=%zu)",
        static_cast<long>(id_), mime_type.c_str(), encoding.c_str(),
        base_url.c_str(), data.size());
  }
  webkit_web_view_load_html(webview_, data.c_str(), base_url.c_str());
}

void InAppWebView::loadFile(const std::string& asset_file_path) {
  if (webview_ == nullptr) return;
  // Construct file:// URL from asset path
  std::string file_url = "file://" + asset_file_path;
  if (DebugLogEnabled()) {
    g_message("InAppWebView[%ld]: LoadFile %s", static_cast<long>(id_), file_url.c_str());
  }
  webkit_web_view_load_uri(webview_, file_url.c_str());
}

void InAppWebView::reload() {
  if (webview_ == nullptr) return;
  webkit_web_view_reload(webview_);
}

void InAppWebView::goBack() {
  if (webview_ == nullptr) return;
  webkit_web_view_go_back(webview_);
}

void InAppWebView::goForward() {
  if (webview_ == nullptr) return;
  webkit_web_view_go_forward(webview_);
}

bool InAppWebView::canGoBack() const {
  if (webview_ == nullptr) return false;
  return webkit_web_view_can_go_back(webview_);
}

bool InAppWebView::canGoForward() const {
  if (webview_ == nullptr) return false;
  return webkit_web_view_can_go_forward(webview_);
}

void InAppWebView::stopLoading() {
  if (webview_ == nullptr) return;
  webkit_web_view_stop_loading(webview_);
}

bool InAppWebView::isLoading() const {
  if (webview_ == nullptr) return false;
  return webkit_web_view_is_loading(webview_);
}

std::optional<std::string> InAppWebView::getUrl() const {
  if (webview_ == nullptr) return std::nullopt;
  const gchar* uri = webkit_web_view_get_uri(webview_);
  if (uri != nullptr) {
    return std::string(uri);
  }
  return std::nullopt;
}

std::optional<std::string> InAppWebView::getTitle() const {
  if (webview_ == nullptr) return std::nullopt;
  const gchar* title = webkit_web_view_get_title(webview_);
  if (title != nullptr) {
    return std::string(title);
  }
  return std::nullopt;
}

int64_t InAppWebView::getProgress() const {
  if (webview_ == nullptr) return 0;
  double progress = webkit_web_view_get_estimated_load_progress(webview_);
  return static_cast<int64_t>(progress * 100);
}

void InAppWebView::evaluateJavascript(
    const std::string& source,
    std::function<void(const std::optional<std::string>&)> callback) {
  if (webview_ == nullptr) {
    if (callback) callback(std::nullopt);
    return;
  }

  struct CallbackData {
    std::function<void(const std::optional<std::string>&)> callback;
  };
  auto* data = new CallbackData{std::move(callback)};

  webkit_web_view_evaluate_javascript(
      webview_, source.c_str(), static_cast<gssize>(source.length()),
      nullptr,  // world name (null = default)
      nullptr,  // source URI
      nullptr,  // cancellable
      [](GObject* source, GAsyncResult* result, gpointer user_data) {
        auto* data = static_cast<CallbackData*>(user_data);
        WebKitWebView* webview = WEBKIT_WEB_VIEW(source);

        g_autoptr(GError) error = nullptr;
        JSCValue* jsResult = webkit_web_view_evaluate_javascript_finish(
            webview, result, &error);

        if (error != nullptr) {
          if (data->callback) data->callback(std::nullopt);
        } else if (jsResult != nullptr) {
          gchar* str = jsc_value_to_json(jsResult, 0);
          if (str != nullptr) {
            std::string resultStr(str);
            g_free(str);
            if (data->callback) data->callback(resultStr);
          } else {
            if (data->callback) data->callback(std::nullopt);
          }
          g_object_unref(jsResult);
        } else {
          if (data->callback) data->callback(std::nullopt);
        }
        delete data;
      },
      data);
}

void InAppWebView::injectJavascriptFileFromUrl(const std::string& urlFile) {
  if (webview_ == nullptr) return;

  std::string script =
      "var script = document.createElement('script');"
      "script.type = 'text/javascript';"
      "script.src = '" + urlFile + "';"
      "document.head.appendChild(script);";

  webkit_web_view_evaluate_javascript(
      webview_, script.c_str(), static_cast<gssize>(script.length()),
      nullptr, nullptr, nullptr, nullptr, nullptr);
}

void InAppWebView::injectCSSCode(const std::string& source) {
  if (webview_ == nullptr) return;

  // Escape quotes and newlines in CSS
  std::string escapedSource;
  for (char c : source) {
    if (c == '\'') escapedSource += "\\'";
    else if (c == '\n') escapedSource += "\\n";
    else if (c == '\r') escapedSource += "\\r";
    else escapedSource += c;
  }

  std::string script =
      "var style = document.createElement('style');"
      "style.type = 'text/css';"
      "style.appendChild(document.createTextNode('" + escapedSource + "'));"
      "document.head.appendChild(style);";

  webkit_web_view_evaluate_javascript(
      webview_, script.c_str(), static_cast<gssize>(script.length()),
      nullptr, nullptr, nullptr, nullptr, nullptr);
}

void InAppWebView::injectCSSFileFromUrl(const std::string& urlFile) {
  if (webview_ == nullptr) return;

  std::string script =
      "var link = document.createElement('link');"
      "link.rel = 'stylesheet';"
      "link.type = 'text/css';"
      "link.href = '" + urlFile + "';"
      "document.head.appendChild(link);";

  webkit_web_view_evaluate_javascript(
      webview_, script.c_str(), static_cast<gssize>(script.length()),
      nullptr, nullptr, nullptr, nullptr, nullptr);
}

void InAppWebView::getHtml(
    std::function<void(const std::optional<std::string>&)> callback) {
  if (webview_ == nullptr) {
    if (callback) callback(std::nullopt);
    return;
  }

  const std::string source = "document.documentElement.outerHTML;";

  struct CallbackData {
    std::function<void(const std::optional<std::string>&)> callback;
  };
  auto* data = new CallbackData{std::move(callback)};

  webkit_web_view_evaluate_javascript(
      webview_, source.c_str(), static_cast<gssize>(source.length()),
      nullptr, nullptr, nullptr,
      [](GObject* source, GAsyncResult* result, gpointer user_data) {
        auto* data = static_cast<CallbackData*>(user_data);
        WebKitWebView* webview = WEBKIT_WEB_VIEW(source);

        g_autoptr(GError) error = nullptr;
        JSCValue* jsResult = webkit_web_view_evaluate_javascript_finish(
            webview, result, &error);

        if (error != nullptr || jsResult == nullptr) {
          if (data->callback) data->callback(std::nullopt);
        } else {
          gchar* str = jsc_value_to_string(jsResult);
          if (str != nullptr) {
            std::string resultStr(str);
            g_free(str);
            if (data->callback) data->callback(resultStr);
          } else {
            if (data->callback) data->callback(std::nullopt);
          }
          g_object_unref(jsResult);
        }
        delete data;
      },
      data);
}

double InAppWebView::getZoomScale() const {
  if (webview_ == nullptr) return 1.0;
  return webkit_web_view_get_zoom_level(webview_);
}

void InAppWebView::setZoomScale(double zoomScale) {
  if (webview_ == nullptr) return;
  webkit_web_view_set_zoom_level(webview_, zoomScale);
}

void InAppWebView::scrollTo(int64_t x, int64_t y, bool animated) {
  if (webview_ == nullptr) return;

  // WebKit doesn't have direct scroll API, so use JavaScript
  std::string script;
  if (animated) {
    script = "window.scrollTo({left: " + std::to_string(x) +
             ", top: " + std::to_string(y) + ", behavior: 'smooth'});";
  } else {
    script = "window.scrollTo(" + std::to_string(x) + ", " +
             std::to_string(y) + ");";
  }

  webkit_web_view_evaluate_javascript(
      webview_, script.c_str(), static_cast<gssize>(script.length()),
      nullptr, nullptr, nullptr, nullptr, nullptr);
}

void InAppWebView::scrollBy(int64_t x, int64_t y, bool animated) {
  if (webview_ == nullptr) return;

  std::string script;
  if (animated) {
    script = "window.scrollBy({left: " + std::to_string(x) +
             ", top: " + std::to_string(y) + ", behavior: 'smooth'});";
  } else {
    script = "window.scrollBy(" + std::to_string(x) + ", " +
             std::to_string(y) + ");";
  }

  webkit_web_view_evaluate_javascript(
      webview_, script.c_str(), static_cast<gssize>(script.length()),
      nullptr, nullptr, nullptr, nullptr, nullptr);
}

int64_t InAppWebView::getScrollX() const {
  // WebKit doesn't have synchronous scroll position API
  // This would need to be async via JavaScript
  return 0;
}

int64_t InAppWebView::getScrollY() const {
  // WebKit doesn't have synchronous scroll position API
  // This would need to be async via JavaScript
  return 0;
}

size_t InAppWebView::GetPixelBufferSize(uint32_t* out_width,
                                        uint32_t* out_height) const {
  std::lock_guard<std::mutex> lock(pixel_buffer_mutex_);
  if (rgba_.empty() || pixel_buffer_width_ == 0 || pixel_buffer_height_ == 0) {
    if (out_width) *out_width = 0;
    if (out_height) *out_height = 0;
    return 0;
  }
  if (out_width) *out_width = static_cast<uint32_t>(pixel_buffer_width_);
  if (out_height) *out_height = static_cast<uint32_t>(pixel_buffer_height_);
  return rgba_.size();
}

bool InAppWebView::CopyPixelBufferTo(uint8_t* dst, size_t dst_size,
                                    uint32_t* out_width,
                                    uint32_t* out_height) const {
  if (dst == nullptr) {
    return false;
  }
  std::lock_guard<std::mutex> lock(pixel_buffer_mutex_);
  if (rgba_.empty() || pixel_buffer_width_ == 0 || pixel_buffer_height_ == 0) {
    return false;
  }
  if (dst_size < rgba_.size()) {
    return false;
  }
  std::memcpy(dst, rgba_.data(), rgba_.size());
  if (out_width) *out_width = static_cast<uint32_t>(pixel_buffer_width_);
  if (out_height) *out_height = static_cast<uint32_t>(pixel_buffer_height_);
  return true;
}

void InAppWebView::SetOnFrameAvailable(std::function<void()> callback) {
  on_frame_available_ = std::move(callback);
}

void InAppWebView::SetOnCursorChanged(std::function<void(const std::string&)> callback) {
  on_cursor_changed_ = std::move(callback);
}

void InAppWebView::setScaleFactor(double scale_factor) {
  if (scale_factor > 0.0) {
    scale_factor_ = scale_factor;
  }
}

void InAppWebView::SetCursorPos(double x, double y) {
  // Coordinates from Flutter are in logical pixels (same as widget size).
  // GTK widgets are sized in logical pixels, so pass coordinates directly.
  // Do NOT multiply by scale_factor - that would send coordinates outside
  // the widget bounds when the snapshot is captured at HiDPI resolution.
  cursor_x_ = x;
  cursor_y_ = y;
  SendMouseEvent(GDK_MOTION_NOTIFY, cursor_x_, cursor_y_, 0, button_state_);
}

void InAppWebView::SetPointerButton(int kind, int button, int clickCount) {
  // kind: 1=down, 4=up (from PointerEventKind enum)
  // button: 1=primary, 2=secondary, 3=tertiary
  // clickCount: 1=single, 2=double, 3=triple
  
  guint gdk_button = 1;  // Default to left button
  if (button == 2) gdk_button = 3;  // Right button
  if (button == 3) gdk_button = 2;  // Middle button
  
  if (kind == static_cast<int>(PointerEventKind::Enter)) {
    EnsureFocused();
    SendMouseEvent(GDK_ENTER_NOTIFY, cursor_x_, cursor_y_, 0, button_state_);
    return;
  }
  if (kind == static_cast<int>(PointerEventKind::Leave)) {
    SendMouseEvent(GDK_LEAVE_NOTIFY, cursor_x_, cursor_y_, 0, button_state_);
    return;
  }

  if (kind == static_cast<int>(PointerEventKind::Down)) {
    EnsureFocused();

    // Update state to include button before sending press so drag selection gets a state with button down.
    button_state_ |= (1 << (gdk_button - 1));

    // Send appropriate click event based on click count
    GdkEventType event_type;
    switch (clickCount) {
      case 2:
        event_type = GDK_2BUTTON_PRESS;
        break;
      case 3:
        event_type = GDK_3BUTTON_PRESS;
        break;
      default:
        event_type = GDK_BUTTON_PRESS;
        break;
    }
    SendMouseEvent(event_type, cursor_x_, cursor_y_, gdk_button, button_state_);
  } else if (kind == static_cast<int>(PointerEventKind::Up) ||
             kind == static_cast<int>(PointerEventKind::Cancel)) {
    // Send release with current state (button still marked down)
    SendMouseEvent(GDK_BUTTON_RELEASE, cursor_x_, cursor_y_, gdk_button,
                   button_state_);
    // Clear state after release
    button_state_ &= ~(1 << (gdk_button - 1));
  }
}

void InAppWebView::SetScrollDelta(double dx, double dy) {
  // Flutter sends scroll delta in logical pixels (typically ~120 per notch).
  // WebKit scroll events use smaller values. Reduce by a factor to match.
  // Default scroll_multiplier_ is 1.0 but we divide by 10 to get reasonable scroll.
  constexpr double kScrollDivisor = 10.0;
  SendScrollEvent(cursor_x_, cursor_y_, 
                  dx * scroll_multiplier_ / kScrollDivisor, 
                  dy * scroll_multiplier_ / kScrollDivisor);
}

void InAppWebView::SendKeyEvent(int type, int64_t keyCode, int scanCode, 
                                 int modifiers, const std::string& characters) {
  if (webview_ == nullptr) return;

  GtkWidget* widget = GTK_WIDGET(webview_);
  if (!gtk_widget_get_realized(widget)) {
    gtk_widget_realize(widget);
  }
  GdkWindow* window = gtk_widget_get_window(widget);
  if (window == nullptr) return;

  // type: 0=press, 1=release, 2=repeat
  GdkEventType event_type = (type == 1) ? GDK_KEY_RELEASE : GDK_KEY_PRESS;

  // Determine if this is a special key that should ignore 'characters'
  // and should NOT skip release events.
  bool is_special_key = false;
  guint keyval = GDK_KEY_VoidSymbol;
  const int64_t k = keyCode;

  // Common control keys (use exact logical key ids)
  if (k == 0x100000008) { keyval = GDK_KEY_BackSpace; is_special_key = true; }
  else if (k == 0x10000007f) { keyval = GDK_KEY_Delete; is_special_key = true; }
  else if (k == 0x100000009) { keyval = GDK_KEY_Tab; is_special_key = true; }
  else if (k == 0x10000000d) { keyval = GDK_KEY_Return; is_special_key = true; }
  else if (k == 0x10000001b) { keyval = GDK_KEY_Escape; is_special_key = true; }
  
  // Arrow keys
  else if (k == 0x100000302) { keyval = GDK_KEY_Left; is_special_key = true; }
  else if (k == 0x100000301) { keyval = GDK_KEY_Down; is_special_key = true; }
  else if (k == 0x100000303) { keyval = GDK_KEY_Right; is_special_key = true; }
  else if (k == 0x100000304) { keyval = GDK_KEY_Up; is_special_key = true; }

  // Navigation keys
  else if (k == 0x100000305) { keyval = GDK_KEY_End; is_special_key = true; }
  else if (k == 0x100000306) { keyval = GDK_KEY_Home; is_special_key = true; }
  else if (k == 0x100000307) { keyval = GDK_KEY_Page_Up; is_special_key = true; }
  else if (k == 0x100000308) { keyval = GDK_KEY_Page_Down; is_special_key = true; }
  else if (k == 0x100000309) { keyval = GDK_KEY_Insert; is_special_key = true; }

  // Modifiers
  else if (k == 0x100000102 || k == 0x100000103) { keyval = GDK_KEY_Shift_L; is_special_key = true; }
  else if (k == 0x100000104 || k == 0x100000105) { keyval = GDK_KEY_Control_L; is_special_key = true; }
  else if (k == 0x100000106 || k == 0x100000107) { keyval = GDK_KEY_Alt_L; is_special_key = true; }
  else if (k == 0x100000108 || k == 0x100000109) { keyval = GDK_KEY_Meta_L; is_special_key = true; }

  // For printable character input (NOT special keys), only handle key press.
  if (type == 1 && !characters.empty() && !is_special_key) {
    return;
  }

  GdkEvent* event = gdk_event_new(event_type);
  if (event == nullptr) return;
  
  event->any.window = GDK_WINDOW(g_object_ref(window));
  event->any.send_event = TRUE;

  // Set modifier state
  GdkModifierType state = static_cast<GdkModifierType>(0);
  if (modifiers & 1) state = static_cast<GdkModifierType>(state | GDK_SHIFT_MASK);
  if (modifiers & 2) state = static_cast<GdkModifierType>(state | GDK_CONTROL_MASK);
  if (modifiers & 4) state = static_cast<GdkModifierType>(state | GDK_MOD1_MASK);  // Alt
  if (modifiers & 8) state = static_cast<GdkModifierType>(state | GDK_META_MASK);

  guint16 hw_keycode = 0;
  
  // If not special, try mapping from characters or fallback
  if (keyval == GDK_KEY_VoidSymbol) {
    if (!characters.empty()) {
      gunichar uc = g_utf8_get_char(characters.c_str());
      keyval = gdk_unicode_to_keyval(uc);
    } else {
       // Fallback for ASCII shortcuts without characters
       uint32_t keyLow = static_cast<uint32_t>(k & 0xFFFFFFFF);
       if (keyLow >= 0x20 && keyLow <= 0x7E) {
         keyval = gdk_unicode_to_keyval(keyLow);
       }
    }
  }
  
  // Try to get hardware keycode from keyval using keymap
  GdkKeymap* keymap = gdk_keymap_get_for_display(gdk_display_get_default());
  if (keymap != nullptr && keyval != GDK_KEY_VoidSymbol) {
    GdkKeymapKey* keys = nullptr;
    gint n_keys = 0;
    if (gdk_keymap_get_entries_for_keyval(keymap, keyval, &keys, &n_keys)) {
      if (n_keys > 0) {
        hw_keycode = static_cast<guint16>(keys[0].keycode);
      }
      g_free(keys);
    }
  }

  // Set up the key event
  event->key.keyval = keyval;
  event->key.hardware_keycode = hw_keycode;
  event->key.time = GDK_CURRENT_TIME;
  event->key.state = state;
  event->key.length = 0;
  event->key.string = nullptr;
  
  // Only set string if NOT special key
  if (!characters.empty() && type == 0 && !is_special_key) {
    event->key.length = static_cast<gint>(characters.length());
    event->key.string = g_strdup(characters.c_str());
  }
  
  // Set key group
  event->key.group = 0;
  event->key.is_modifier = (keyval == GDK_KEY_Shift_L || keyval == GDK_KEY_Shift_R ||
                            keyval == GDK_KEY_Control_L || keyval == GDK_KEY_Control_R ||
                            keyval == GDK_KEY_Alt_L || keyval == GDK_KEY_Alt_R ||
                            keyval == GDK_KEY_Meta_L || keyval == GDK_KEY_Meta_R) ? 1 : 0;

  // Set device
  GdkDevice* keyboard = GetKeyboardDevice();
  if (keyboard != nullptr) {
    gdk_event_set_device(event, keyboard);
    gdk_event_set_source_device(event, keyboard);
  }

  // Ensure the widget has focus before sending key event
  EnsureFocused();

  if (DebugLogEnabled()) {
    g_message("InAppWebView: SendKeyEvent type=%d keyval=%u hwcode=%u state=%u chars='%s' special=%d",
              type, keyval, hw_keycode, state, characters.c_str(), is_special_key);
  }

  // Send the event
  gtk_widget_event(widget, event);
  
  if (event->key.string != nullptr) {
    g_free(event->key.string);
    event->key.string = nullptr;
  }
  gdk_event_free(event);
}

void InAppWebView::SendMouseEvent(GdkEventType type, double x, double y,
                                  guint button, guint state) {
  if (webview_ == nullptr) return;

  GtkWidget* widget = GTK_WIDGET(webview_);
  if (!gtk_widget_get_realized(widget)) {
    gtk_widget_realize(widget);
  }
  GdkWindow* window = gtk_widget_get_window(widget);
  if (window == nullptr) return;

  GdkEvent* event = gdk_event_new(type);
  if (event == nullptr) return;

  // Attach window + device to prevent GdkDevice assertions.
  event->any.window = GDK_WINDOW(g_object_ref(window));
  event->any.send_event = TRUE;

  GdkDevice* pointer = GetPointerDevice();
  if (pointer != nullptr) {
    gdk_event_set_device(event, pointer);
    gdk_event_set_source_device(event, pointer);
  }

  switch (type) {
    case GDK_MOTION_NOTIFY:
      event->motion.x = x;
      event->motion.y = y;
      event->motion.x_root = x;
      event->motion.y_root = y;
      event->motion.state = state;
      event->motion.time = GDK_CURRENT_TIME;
      break;
    case GDK_BUTTON_PRESS:
    case GDK_2BUTTON_PRESS:
    case GDK_3BUTTON_PRESS:
    case GDK_BUTTON_RELEASE:
      event->button.x = x;
      event->button.y = y;
      event->button.x_root = x;
      event->button.y_root = y;
      event->button.button = button;
      event->button.state = state;
      event->button.time = GDK_CURRENT_TIME;
      break;
    case GDK_ENTER_NOTIFY:
    case GDK_LEAVE_NOTIFY:
      event->crossing.x = x;
      event->crossing.y = y;
      event->crossing.x_root = x;
      event->crossing.y_root = y;
      event->crossing.state = state;
      event->crossing.time = GDK_CURRENT_TIME;
      event->crossing.mode = GDK_CROSSING_NORMAL;
      event->crossing.detail = GDK_NOTIFY_NONLINEAR;
      break;
    default:
      break;
  }

  gtk_widget_event(widget, event);
  gdk_event_free(event);
}

void InAppWebView::SendScrollEvent(double x, double y, double dx, double dy) {
  if (webview_ == nullptr) return;

  GtkWidget* widget = GTK_WIDGET(webview_);
  if (!gtk_widget_get_realized(widget)) {
    gtk_widget_realize(widget);
  }
  GdkWindow* window = gtk_widget_get_window(widget);
  if (window == nullptr) return;

  GdkEvent* event = gdk_event_new(GDK_SCROLL);
  if (event == nullptr) return;
  event->any.window = GDK_WINDOW(g_object_ref(window));
  event->any.send_event = TRUE;

  GdkDevice* pointer = GetPointerDevice();
  if (pointer != nullptr) {
    gdk_event_set_device(event, pointer);
    gdk_event_set_source_device(event, pointer);
  }

  event->scroll.x = x;
  event->scroll.y = y;
  event->scroll.x_root = x;
  event->scroll.y_root = y;
  event->scroll.delta_x = dx;
  event->scroll.delta_y = dy;
  event->scroll.direction = GDK_SCROLL_SMOOTH;
  event->scroll.state = button_state_;
  event->scroll.time = GDK_CURRENT_TIME;

  gtk_widget_event(widget, event);
  gdk_event_free(event);
}

FlValue* InAppWebView::getSettings() const {
  if (!settings_) {
    return fl_value_new_null();
  }
  return settings_->getRealSettings(this);
}

void InAppWebView::setSettings(
    const std::shared_ptr<InAppWebViewSettings> newSettings,
    FlValue* /*newSettingsMap*/) {
  if (newSettings == nullptr) return;
  settings_ = newSettings;
  if (webview_ != nullptr) {
    settings_->applyToWebView(webview_);
  }
}

void InAppWebView::setSettingsFromMap(
    const std::map<std::string, FlValue*>& settingsMap) {
  // Create a FlValue map from the std::map
  FlValue* map = fl_value_new_map();
  for (const auto& pair : settingsMap) {
    if (pair.second != nullptr) {
      fl_value_set_string(map, pair.first.c_str(), pair.second);
    }
  }

  // Parse settings and apply
  auto newSettings = std::make_shared<InAppWebViewSettings>(map);
  setSettings(newSettings, map);

  g_object_unref(map);
}

void InAppWebView::setSize(int width, int height) {
  if (width > 0 && height > 0) {
    width_ = width;
    height_ = height;
    if (container_window_ != nullptr) {
      gtk_widget_set_size_request(container_window_, width_, height_);
    }
    if (webview_ != nullptr) {
      gtk_widget_set_size_request(GTK_WIDGET(webview_), width_, height_);
    }
  }
}

gboolean InAppWebView::SnapshotTick(gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);
  self->RequestSnapshot();
  return G_SOURCE_CONTINUE;
}

void InAppWebView::RequestSnapshot() {
  // Use atomic compare-exchange to prevent concurrent snapshot requests
  bool expected = false;
  if (!frame_pending_.compare_exchange_strong(expected, true)) {
    return;  // A snapshot is already in progress
  }
  
  if (webview_ == nullptr) {
    frame_pending_.store(false);
    return;
  }

  // Note: RequestSnapshot logging disabled for clarity - enable with FLUTTER_INAPPWEBVIEW_LINUX_DEBUG_SNAPSHOT
  if (g_getenv("FLUTTER_INAPPWEBVIEW_LINUX_DEBUG_SNAPSHOT") != nullptr) {
    const gchar* uri = webkit_web_view_get_uri(webview_);
    g_message("InAppWebView[%ld]: RequestSnapshot (uri=%s)", 
              static_cast<long>(id_),
              uri != nullptr ? uri : "<null>");
  }

  // Take a snapshot of the current visible region of the webview
  // This API is backend-agnostic and works on both Wayland and X11
  webkit_web_view_get_snapshot(
      webview_,
      WEBKIT_SNAPSHOT_REGION_VISIBLE,
      WEBKIT_SNAPSHOT_OPTIONS_INCLUDE_SELECTION_HIGHLIGHTING,
      nullptr,
      [](GObject* source, GAsyncResult* res, gpointer user_data) {
        auto* self = static_cast<InAppWebView*>(user_data);
        self->frame_pending_.store(false);

        GError* error = nullptr;
        cairo_surface_t* surface = webkit_web_view_get_snapshot_finish(
            WEBKIT_WEB_VIEW(source), res, &error);
        if (!surface) {
          if (error) {
            if (DebugLogEnabled()) {
              g_message("InAppWebView[%ld]: snapshot error: %s", 
                        static_cast<long>(self->id_), error->message);
            }
            g_error_free(error);
          } else if (DebugLogEnabled()) {
            g_message("InAppWebView[%ld]: snapshot_finish returned null surface", 
                      static_cast<long>(self->id_));
          }
          return;
        }

        cairo_surface_flush(surface);

        // WebKit may return non-image surfaces. Convert to an image surface
        // to reliably access pixel data.
        cairo_surface_t* image_surface = surface;
        bool destroy_image_surface = false;
        int w = 0;
        int h = 0;

        if (cairo_surface_get_type(surface) == CAIRO_SURFACE_TYPE_IMAGE) {
          w = cairo_image_surface_get_width(surface);
          h = cairo_image_surface_get_height(surface);
        } else {
          w = self->width_;
          h = self->height_;
          image_surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, w, h);
          destroy_image_surface = true;
          cairo_t* cr = cairo_create(image_surface);

          // Fill with opaque white background to avoid fully-transparent frames.
          cairo_set_source_rgba(cr, 1.0, 1.0, 1.0, 1.0);
          cairo_paint(cr);

          cairo_set_source_surface(cr, surface, 0, 0);
          cairo_paint(cr);
          cairo_destroy(cr);
          cairo_surface_flush(image_surface);
        }

        int stride = cairo_image_surface_get_stride(image_surface);
        unsigned char* data = cairo_image_surface_get_data(image_surface);

        if (w <= 0 || h <= 0 || data == nullptr) {
          if (DebugLogEnabled()) {
            g_message("InAppWebView[%ld]: snapshot invalid (w=%d h=%d data=%p)",
                      static_cast<long>(self->id_), w, h, data);
          }
          if (destroy_image_surface) {
            cairo_surface_destroy(image_surface);
          }
          cairo_surface_destroy(surface);
          return;
        }

        // Prepare output buffer
        std::vector<uint8_t> rgba;
        rgba.resize(static_cast<size_t>(w) * static_cast<size_t>(h) * 4);

        // Cairo image surface is ARGB32 premultiplied (native-endian).
        // Flutter PixelBuffer expects RGBA8888. Convert using SIMD-optimized function:
        ConvertARGB32ToRGBA(data, rgba.data(), w, h, stride);

        {
          std::lock_guard<std::mutex> lock(self->pixel_buffer_mutex_);
          self->rgba_.swap(rgba);
          self->pixel_buffer_width_ = static_cast<size_t>(w);
          self->pixel_buffer_height_ = static_cast<size_t>(h);
        }

        if (g_getenv("FLUTTER_INAPPWEBVIEW_LINUX_DEBUG_TEXTURE") != nullptr) {
          static uint32_t snapshot_counter = 0;
          snapshot_counter++;
          if ((snapshot_counter % 60) == 0) {  // ~1/sec at 60fps
            // Cheap checksum over the first few KB to avoid heavy logging.
            uint32_t checksum = 0;
            const size_t n = std::min<size_t>(4096, self->rgba_.size());
            for (size_t i = 0; i < n; i++) {
              checksum = (checksum * 33u) ^ self->rgba_[i];
            }
            // Log first few pixels to diagnose if we're getting actual content
            // or a solid color
            if (self->rgba_.size() >= 16) {
              g_message("InAppWebView[%ld]: snapshot %dx%d checksum=%u "
                        "first_pixels: r=%u g=%u b=%u a=%u | r=%u g=%u b=%u a=%u",
                        static_cast<long>(self->id_), w, h, checksum,
                        self->rgba_[0], self->rgba_[1], self->rgba_[2], self->rgba_[3],
                        self->rgba_[4], self->rgba_[5], self->rgba_[6], self->rgba_[7]);
            }
          }
        }

        static bool did_log_first_frame = false;
        if (!did_log_first_frame && g_getenv("FLUTTER_INAPPWEBVIEW_LINUX_DEBUG_TEXTURE") != nullptr) {
          did_log_first_frame = true;
          g_message("InAppWebView[%ld]: first snapshot %dx%d", static_cast<long>(self->id_), w, h);
        }

        if (destroy_image_surface) {
          cairo_surface_destroy(image_surface);
        }
        cairo_surface_destroy(surface);

        // Notify that a new frame is available
        if (self->on_frame_available_) {
          self->on_frame_available_();
        }
      },
      this);
}

GdkDevice* InAppWebView::GetPointerDevice() const {
  if (webview_ == nullptr) return nullptr;
  GtkWidget* widget = GTK_WIDGET(webview_);
  GdkWindow* window = gtk_widget_get_window(widget);
  if (window == nullptr) return nullptr;
  GdkDisplay* display = gdk_window_get_display(window);
  if (display == nullptr) return nullptr;
  GdkSeat* seat = gdk_display_get_default_seat(display);
  if (seat == nullptr) return nullptr;
  return gdk_seat_get_pointer(seat);
}

GdkDevice* InAppWebView::GetKeyboardDevice() const {
  if (webview_ == nullptr) return nullptr;
  GtkWidget* widget = GTK_WIDGET(webview_);
  GdkWindow* window = gtk_widget_get_window(widget);
  if (window == nullptr) return nullptr;
  GdkDisplay* display = gdk_window_get_display(window);
  if (display == nullptr) return nullptr;
  GdkSeat* seat = gdk_display_get_default_seat(display);
  if (seat == nullptr) return nullptr;
  return gdk_seat_get_keyboard(seat);
}

void InAppWebView::EnsureFocused() {
  if (webview_ == nullptr) return;
  GtkWidget* widget = GTK_WIDGET(webview_);
  gtk_widget_set_can_focus(widget, TRUE);
  gtk_widget_grab_focus(widget);
  
  // Force the widget to be in focused state to ensure selection highlighting is rendered
  GtkStateFlags flags = gtk_widget_get_state_flags(widget);
  if (!(flags & GTK_STATE_FLAG_FOCUSED)) {
    gtk_widget_set_state_flags(widget, GTK_STATE_FLAG_FOCUSED, FALSE);
  }

  // Also synthesize a focus-in event to match typical GTK focus behavior.
  if (!gtk_widget_get_realized(widget)) {
    gtk_widget_realize(widget);
  }
  GdkWindow* window = gtk_widget_get_window(widget);
  if (window == nullptr) return;

  GdkEvent* focus_event = gdk_event_new(GDK_FOCUS_CHANGE);
  if (focus_event == nullptr) return;
  focus_event->any.window = GDK_WINDOW(g_object_ref(window));
  focus_event->focus_change.in = TRUE;

  GdkDevice* keyboard = GetKeyboardDevice();
  if (keyboard != nullptr) {
    gdk_event_set_device(focus_event, keyboard);
    gdk_event_set_source_device(focus_event, keyboard);
  }

  gtk_widget_event(widget, focus_event);
  gdk_event_free(focus_event);
}

void InAppWebView::OnLoadChanged(WebKitWebView* web_view,
                                 WebKitLoadEvent load_event,
                                 gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);
  const gchar* uri = webkit_web_view_get_uri(web_view);
  std::optional<std::string> url =
      uri != nullptr ? std::make_optional(std::string(uri)) : std::nullopt;

  if (DebugLogEnabled()) {
    const char* ev = "UNKNOWN";
    switch (load_event) {
      case WEBKIT_LOAD_STARTED:
        ev = "STARTED";
        break;
      case WEBKIT_LOAD_REDIRECTED:
        ev = "REDIRECTED";
        break;
      case WEBKIT_LOAD_COMMITTED:
        ev = "COMMITTED";
        break;
      case WEBKIT_LOAD_FINISHED:
        ev = "FINISHED";
        break;
      default:
        break;
    }
    g_message("InAppWebView[%ld]: load-changed %s (uri=%s)",
              static_cast<long>(self->id_), ev, uri != nullptr ? uri : "<null>");
  }

  switch (load_event) {
    case WEBKIT_LOAD_STARTED:
      if (self->channel_delegate_) {
        self->channel_delegate_->onLoadStart(url);
      }
      break;
    case WEBKIT_LOAD_COMMITTED:
      break;
    case WEBKIT_LOAD_FINISHED:
      if (self->channel_delegate_) {
        self->channel_delegate_->onLoadStop(url);
      }
      // Dispatch platform ready event after page load finishes
      self->dispatchPlatformReady();
      break;
    default:
      break;
  }
}

gboolean InAppWebView::OnDecidePolicy(WebKitWebView* web_view,
                                      WebKitPolicyDecision* decision,
                                      WebKitPolicyDecisionType decision_type,
                                      gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);

  if (DebugLogEnabled()) {
    g_message("InAppWebView[%ld]: decide-policy type=%d", static_cast<long>(self->id_),
              static_cast<int>(decision_type));
  }

  if (decision_type == WEBKIT_POLICY_DECISION_TYPE_NAVIGATION_ACTION) {
    auto* nav_decision = WEBKIT_NAVIGATION_POLICY_DECISION(decision);
    WebKitNavigationAction* action =
        webkit_navigation_policy_decision_get_navigation_action(nav_decision);
    WebKitURIRequest* request = webkit_navigation_action_get_request(action);
    const gchar* uri = webkit_uri_request_get_uri(request);

    if (DebugLogEnabled()) {
      g_message("InAppWebView[%ld]: navigation request uri=%s", static_cast<long>(self->id_),
                uri != nullptr ? uri : "<null>");
    }

    bool useShouldOverride = self->settings_ && self->settings_->useShouldOverrideUrlLoading;
    if (!DisableShouldOverrideNative() && useShouldOverride &&
      self->channel_delegate_) {
      // Store the decision for async response
      g_object_ref(decision);
      int64_t decision_id = self->next_decision_id_++;
      self->pending_policy_decisions_[decision_id] = decision;

      // Get navigation type
      WebKitNavigationType nav_type =
          webkit_navigation_action_get_navigation_type(action);
      // Best-effort main frame detection: frame name is usually null/empty for main frame.
      bool is_for_main_frame = true;
      const gchar* frame_name = webkit_navigation_action_get_frame_name(action);
      if (frame_name != nullptr && frame_name[0] != '\0') {
        is_for_main_frame = false;
      }

      // Create URLRequest
      auto urlRequest = std::make_shared<URLRequest>(
          uri != nullptr ? std::optional<std::string>(uri) : std::nullopt,
          std::optional<std::string>("GET"),
          std::nullopt,  // headers
          std::nullopt   // body
      );

      // Map WebKit navigation type to our enum
      std::optional<NavigationActionType> navActionType;
      switch (nav_type) {
        case WEBKIT_NAVIGATION_TYPE_LINK_CLICKED:
          navActionType = NavigationActionType::linkActivated;
          break;
        case WEBKIT_NAVIGATION_TYPE_BACK_FORWARD:
          navActionType = NavigationActionType::backForward;
          break;
        case WEBKIT_NAVIGATION_TYPE_RELOAD:
          navActionType = NavigationActionType::reload;
          break;
        default:
          navActionType = NavigationActionType::other;
          break;
      }

      // Create NavigationAction
      auto navigationAction = std::make_shared<NavigationAction>(
          urlRequest,
          is_for_main_frame,
          std::nullopt,  // isRedirect - not easily available in WebKit
          navActionType
      );

      // Create callback to handle the response
      auto callback = std::make_unique<WebViewChannelDelegate::ShouldOverrideUrlLoadingCallback>();
      callback->defaultBehaviour = [self, decision_id](const std::optional<NavigationActionPolicy> result) {
        // If no result or cancel, ignore the navigation
        bool allow = result.has_value() && result.value() == NavigationActionPolicy::allow;
        self->OnShouldOverrideUrlLoadingDecision(decision_id, allow);
      };

      // Notify Dart side with callback
      self->channel_delegate_->shouldOverrideUrlLoading(
          navigationAction, std::move(callback));

      if (DebugLogEnabled()) {
        g_message("InAppWebView[%ld]: deferring policy decision id=%ld", 
                  static_cast<long>(self->id_), static_cast<long>(decision_id));
      }

      // Return TRUE to indicate we'll handle the decision asynchronously
      return TRUE;
    }

    if (DisableShouldOverrideNative() && DebugLogEnabled()) {
      g_message("InAppWebView[%ld]: shouldOverrideUrlLoading disabled natively; allowing navigation", 
                static_cast<long>(self->id_));
    }

    // Default: allow navigation
    webkit_policy_decision_use(decision);
    return TRUE;
  }

  return FALSE;
}

void InAppWebView::OnShouldOverrideUrlLoadingDecision(int64_t decision_id,
                                                      bool allow) {
  if (DebugLogEnabled()) {
    g_message("InAppWebView[%ld]: shouldOverride decision id=%ld allow=%s", 
              static_cast<long>(id_), static_cast<long>(decision_id),
              allow ? "true" : "false");
  }
  auto it = pending_policy_decisions_.find(decision_id);
  if (it != pending_policy_decisions_.end()) {
    WebKitPolicyDecision* decision = it->second;
    if (allow) {
      webkit_policy_decision_use(decision);
    } else {
      webkit_policy_decision_ignore(decision);
    }
    g_object_unref(decision);
    pending_policy_decisions_.erase(it);
  }
}

// Helper to map GDK cursor type to Flutter cursor name
static std::string GetCursorNameFromGdkCursor(GdkCursor* cursor) {
  if (cursor == nullptr) {
    return "basic";
  }
  
  GdkCursorType cursor_type = gdk_cursor_get_cursor_type(cursor);
  
  switch (cursor_type) {
    case GDK_ARROW:
    case GDK_LEFT_PTR:
      return "basic";
    case GDK_HAND1:
    case GDK_HAND2:
      return "click";
    case GDK_XTERM:
      return "text";
    case GDK_WATCH:
      return "wait";
    case GDK_QUESTION_ARROW:
      return "help";
    case GDK_CROSSHAIR:
    case GDK_CROSS:
      return "precise";
    case GDK_FLEUR:
      return "move";
    case GDK_SB_H_DOUBLE_ARROW:
    case GDK_LEFT_SIDE:
    case GDK_RIGHT_SIDE:
      return "resizeLeftRight";
    case GDK_SB_V_DOUBLE_ARROW:
    case GDK_TOP_SIDE:
    case GDK_BOTTOM_SIDE:
      return "resizeUpDown";
    case GDK_TOP_LEFT_CORNER:
    case GDK_BOTTOM_RIGHT_CORNER:
      return "resizeUpLeftDownRight";
    case GDK_TOP_RIGHT_CORNER:
    case GDK_BOTTOM_LEFT_CORNER:
      return "resizeUpRightDownLeft";
    case GDK_X_CURSOR:
    case GDK_PIRATE:
      return "forbidden";
    case GDK_PLUS:
      return "cell";
    case GDK_SIZING:
      return "allScroll";
    case GDK_SB_UP_ARROW:
      return "resizeUp";
    case GDK_SB_DOWN_ARROW:
      return "resizeDown";
    case GDK_SB_LEFT_ARROW:
      return "resizeLeft";
    case GDK_SB_RIGHT_ARROW:
      return "resizeRight";
    default:
      return "basic";
  }
}

gboolean InAppWebView::OnMotionNotify(GtkWidget* widget, GdkEventMotion* event,
                                      gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);
  
  // Check current cursor on the window
  GdkWindow* window = gtk_widget_get_window(widget);
  if (window == nullptr) {
    return FALSE;
  }
  
  GdkCursor* cursor = gdk_window_get_cursor(window);
  std::string cursor_name = GetCursorNameFromGdkCursor(cursor);
  
  // Only emit if cursor changed
  if (cursor_name != self->last_cursor_name_) {
    self->last_cursor_name_ = cursor_name;
    if (self->on_cursor_changed_) {
      self->on_cursor_changed_(cursor_name);
    }
  }
  
  return FALSE;  // Don't block the event
}

void InAppWebView::OnMouseTargetChanged(WebKitWebView* web_view,
                                         WebKitHitTestResult* hit_test_result,
                                         guint modifiers,
                                         gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);
  
  // Determine cursor based on hit test result
  std::string cursor_name = "basic";
  
  if (webkit_hit_test_result_context_is_link(hit_test_result)) {
    cursor_name = "click";  // Hand cursor for links
  } else if (webkit_hit_test_result_context_is_editable(hit_test_result)) {
    cursor_name = "text";  // Text cursor for editable content
  } else if (webkit_hit_test_result_context_is_image(hit_test_result)) {
    // Check if image is also a link
    if (webkit_hit_test_result_context_is_link(hit_test_result)) {
      cursor_name = "click";
    }
  } else if (webkit_hit_test_result_context_is_media(hit_test_result)) {
    cursor_name = "basic";
  } else if (webkit_hit_test_result_context_is_selection(hit_test_result)) {
    cursor_name = "text";
  } else if (webkit_hit_test_result_context_is_scrollbar(hit_test_result)) {
    cursor_name = "basic";
  }
  
  // Only emit if cursor changed
  if (cursor_name != self->last_cursor_name_) {
    self->last_cursor_name_ = cursor_name;
    if (self->on_cursor_changed_) {
      self->on_cursor_changed_(cursor_name);
    }
  }
}

void InAppWebView::OnNotifyEstimatedLoadProgress(GObject* object,
                                                  GParamSpec* pspec,
                                                  gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);
  WebKitWebView* web_view = WEBKIT_WEB_VIEW(object);

  double progress = webkit_web_view_get_estimated_load_progress(web_view);
  int64_t progressInt = static_cast<int64_t>(progress * 100);

  // Only emit if progress changed significantly
  if (progressInt != static_cast<int64_t>(self->last_progress_ * 100)) {
    self->last_progress_ = progress;
    if (self->channel_delegate_) {
      self->channel_delegate_->onProgressChanged(progressInt);
    }
  }
}

void InAppWebView::OnNotifyTitle(GObject* object,
                                  GParamSpec* pspec,
                                  gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);
  WebKitWebView* web_view = WEBKIT_WEB_VIEW(object);

  const gchar* title = webkit_web_view_get_title(web_view);
  std::optional<std::string> titleOpt =
      title != nullptr ? std::make_optional(std::string(title)) : std::nullopt;

  if (self->channel_delegate_) {
    self->channel_delegate_->onTitleChanged(titleOpt);
  }
}

gboolean InAppWebView::OnLoadFailed(WebKitWebView* web_view,
                                    WebKitLoadEvent load_event,
                                    gchar* failing_uri,
                                    GError* error,
                                    gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);

  if (DebugLogEnabled()) {
    g_message("InAppWebView[%ld]: load-failed uri=%s error=%s",
              static_cast<long>(self->id_),
              failing_uri != nullptr ? failing_uri : "<null>",
              error != nullptr ? error->message : "<null>");
  }

  if (self->channel_delegate_) {
    auto request = std::make_shared<WebResourceRequest>(
        failing_uri != nullptr ? std::optional<std::string>(failing_uri) : std::nullopt,
        std::optional<std::string>("GET"),
        std::nullopt,  // headers
        std::optional<bool>(true)  // isForMainFrame
    );

    std::string description = error != nullptr && error->message != nullptr
                                  ? std::string(error->message)
                                  : "Unknown error";
    int64_t errorCode = error != nullptr ? error->code : -1;

    auto resourceError =
        std::make_shared<WebResourceError>(description, errorCode);

    self->channel_delegate_->onReceivedError(request, resourceError);
  }

  return FALSE;  // Don't stop error handling
}

gboolean InAppWebView::OnLoadFailedWithTlsErrors(WebKitWebView* web_view,
                                                  gchar* failing_uri,
                                                  GTlsCertificate* certificate,
                                                  GTlsCertificateFlags errors,
                                                  gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);

  if (DebugLogEnabled()) {
    g_message("InAppWebView[%ld]: load-failed-with-tls-errors uri=%s",
              static_cast<long>(self->id_),
              failing_uri != nullptr ? failing_uri : "<null>");
  }

  if (self->channel_delegate_) {
    auto request = std::make_shared<WebResourceRequest>(
        failing_uri != nullptr ? std::optional<std::string>(failing_uri) : std::nullopt,
        std::optional<std::string>("GET"),
        std::nullopt,
        std::optional<bool>(true));

    std::string description = "SSL/TLS certificate error";
    auto resourceError =
        std::make_shared<WebResourceError>(description, static_cast<int64_t>(errors));

    self->channel_delegate_->onReceivedError(request, resourceError);
  }

  return FALSE;
}

void InAppWebView::OnCloseRequest(WebKitWebView* web_view, gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);

  if (DebugLogEnabled()) {
    g_message("InAppWebView[%ld]: close requested", static_cast<long>(self->id_));
  }

  if (self->channel_delegate_) {
    self->channel_delegate_->onCloseWindow();
  }
}

void InAppWebView::handleScriptMessage(const std::string& name,
                                        const std::string& body) {
  if (DebugLogEnabled()) {
    g_message("InAppWebView[%ld]: handleScriptMessage name=%s body=%.100s...",
              static_cast<long>(id_), name.c_str(), body.c_str());
  }

  // Parse the JSON body
  // Expected format from JavaScript bridge:
  // {
  //   "handlerName": "myHandler",
  //   "_callHandlerID": 123,
  //   "_bridgeSecret": "...",
  //   "origin": "https://...",
  //   "requestUrl": "https://...",
  //   "isMainFrame": true,
  //   "args": "[\"arg1\", \"arg2\"]"
  // }

  // Simple JSON parsing - extract the handler name and validate secret
  // In a production implementation, you'd use a proper JSON parser

  // Find handlerName
  size_t handlerNamePos = body.find("\"handlerName\"");
  if (handlerNamePos == std::string::npos) {
    g_warning("InAppWebView[%ld]: handleScriptMessage - missing handlerName",
              static_cast<long>(id_));
    return;
  }

  // Find the value
  size_t colonPos = body.find(':', handlerNamePos);
  size_t quoteStart = body.find('"', colonPos);
  size_t quoteEnd = body.find('"', quoteStart + 1);
  if (quoteStart == std::string::npos || quoteEnd == std::string::npos) {
    return;
  }
  std::string handlerName = body.substr(quoteStart + 1, quoteEnd - quoteStart - 1);

  // Find and validate bridge secret
  size_t secretPos = body.find("\"_bridgeSecret\"");
  if (secretPos != std::string::npos) {
    size_t secretColonPos = body.find(':', secretPos);
    size_t secretQuoteStart = body.find('"', secretColonPos);
    size_t secretQuoteEnd = body.find('"', secretQuoteStart + 1);
    if (secretQuoteStart != std::string::npos && secretQuoteEnd != std::string::npos) {
      std::string receivedSecret = body.substr(secretQuoteStart + 1,
                                                secretQuoteEnd - secretQuoteStart - 1);
      if (receivedSecret != js_bridge_secret_) {
        g_warning("InAppWebView[%ld]: handleScriptMessage - invalid bridge secret",
                  static_cast<long>(id_));
        return;
      }
    }
  }

  // Find _callHandlerID
  int64_t callHandlerId = 0;
  size_t idPos = body.find("\"_callHandlerID\"");
  if (idPos != std::string::npos) {
    size_t idColonPos = body.find(':', idPos);
    size_t numStart = idColonPos + 1;
    while (numStart < body.size() && (body[numStart] == ' ' || body[numStart] == '\t')) {
      numStart++;
    }
    size_t numEnd = numStart;
    while (numEnd < body.size() && body[numEnd] >= '0' && body[numEnd] <= '9') {
      numEnd++;
    }
    if (numEnd > numStart) {
      callHandlerId = std::stoll(body.substr(numStart, numEnd - numStart));
    }
  }

  // Find args
  std::string args = "[]";
  size_t argsPos = body.find("\"args\"");
  if (argsPos != std::string::npos) {
    size_t argsColonPos = body.find(':', argsPos);
    size_t argsQuoteStart = body.find('"', argsColonPos);
    size_t argsQuoteEnd = argsQuoteStart + 1;
    // Handle escaped JSON string
    while (argsQuoteEnd < body.size()) {
      if (body[argsQuoteEnd] == '"' && body[argsQuoteEnd - 1] != '\\') {
        break;
      }
      argsQuoteEnd++;
    }
    if (argsQuoteStart != std::string::npos && argsQuoteEnd < body.size()) {
      args = body.substr(argsQuoteStart + 1, argsQuoteEnd - argsQuoteStart - 1);
      // Unescape the string
      std::string unescaped;
      for (size_t i = 0; i < args.size(); i++) {
        if (args[i] == '\\' && i + 1 < args.size()) {
          if (args[i + 1] == '"') {
            unescaped += '"';
            i++;
            continue;
          } else if (args[i + 1] == '\\') {
            unescaped += '\\';
            i++;
            continue;
          } else if (args[i + 1] == 'n') {
            unescaped += '\n';
            i++;
            continue;
          }
        }
        unescaped += args[i];
      }
      args = unescaped;
    }
  }

  // Find origin
  std::string origin;
  size_t originPos = body.find("\"origin\"");
  if (originPos != std::string::npos) {
    size_t originColonPos = body.find(':', originPos);
    size_t originQuoteStart = body.find('"', originColonPos);
    size_t originQuoteEnd = body.find('"', originQuoteStart + 1);
    if (originQuoteStart != std::string::npos && originQuoteEnd != std::string::npos) {
      origin = body.substr(originQuoteStart + 1, originQuoteEnd - originQuoteStart - 1);
    }
  }

  // Find requestUrl
  std::string requestUrl;
  size_t requestUrlPos = body.find("\"requestUrl\"");
  if (requestUrlPos != std::string::npos) {
    size_t requestUrlColonPos = body.find(':', requestUrlPos);
    size_t requestUrlQuoteStart = body.find('"', requestUrlColonPos);
    size_t requestUrlQuoteEnd = body.find('"', requestUrlQuoteStart + 1);
    if (requestUrlQuoteStart != std::string::npos && requestUrlQuoteEnd != std::string::npos) {
      requestUrl = body.substr(requestUrlQuoteStart + 1, requestUrlQuoteEnd - requestUrlQuoteStart - 1);
    }
  }

  // Find isMainFrame
  bool isMainFrame = true;
  size_t isMainFramePos = body.find("\"isMainFrame\"");
  if (isMainFramePos != std::string::npos) {
    size_t isMainFrameColonPos = body.find(':', isMainFramePos);
    std::string afterColon = body.substr(isMainFrameColonPos + 1, 10);
    isMainFrame = afterColon.find("true") != std::string::npos;
  }

  if (DebugLogEnabled()) {
    g_message("InAppWebView[%ld]: JS handler '%s' callId=%ld origin=%s isMainFrame=%d",
              static_cast<long>(id_), handlerName.c_str(),
              static_cast<long>(callHandlerId), origin.c_str(), isMainFrame);
  }

  // Create the handler data and call the channel delegate
  if (channel_delegate_) {
    auto data = std::make_unique<JavaScriptHandlerFunctionData>(
        origin,
        requestUrl,
        isMainFrame,
        args);

    // Create callback to send response back to JavaScript
    auto callback =
        std::make_unique<WebViewChannelDelegate::CallJsHandlerCallback>();
    
    int64_t capturedCallHandlerId = callHandlerId;
    InAppWebView* self = this;
    
    callback->defaultBehaviour = [self, capturedCallHandlerId](
                                     const std::optional<FlValue*>& response) {
      if (self->webview_ == nullptr) return;

      std::string json = "null";
      if (response.has_value() && response.value() != nullptr) {
        // Convert FlValue to JSON string
        FlValue* val = response.value();
        if (fl_value_get_type(val) == FL_VALUE_TYPE_STRING) {
          json = fl_value_get_string(val);
        } else {
          // For non-string values, try to convert to string representation
          json = "null";
        }
      }

      // Send response back to JavaScript
      std::string script =
          "if(window." + JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() +
          "[" + std::to_string(capturedCallHandlerId) + "] != null) {"
          "  window." + JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() +
          "[" + std::to_string(capturedCallHandlerId) + "].resolve(" + json + ");"
          "  delete window." + JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() +
          "[" + std::to_string(capturedCallHandlerId) + "];"
          "}";

      webkit_web_view_evaluate_javascript(
          self->webview_, script.c_str(), static_cast<gssize>(script.length()),
          nullptr, nullptr, nullptr, nullptr, nullptr);
    };

    callback->error = [self, capturedCallHandlerId](const std::string& code,
                                                     const std::string& message) {
      if (self->webview_ == nullptr) return;

      std::string errorMessage = code + ": " + message;
      // Escape single quotes
      for (size_t pos = 0; (pos = errorMessage.find('\'', pos)) != std::string::npos; pos += 2) {
        errorMessage.replace(pos, 1, "\\'");
      }

      std::string script =
          "if(window." + JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() +
          "[" + std::to_string(capturedCallHandlerId) + "] != null) {"
          "  window." + JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() +
          "[" + std::to_string(capturedCallHandlerId) + "].reject(new Error('" + errorMessage + "'));"
          "  delete window." + JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() +
          "[" + std::to_string(capturedCallHandlerId) + "];"
          "}";

      webkit_web_view_evaluate_javascript(
          self->webview_, script.c_str(), static_cast<gssize>(script.length()),
          nullptr, nullptr, nullptr, nullptr, nullptr);
    };

    channel_delegate_->onCallJsHandler(handlerName, std::move(data), std::move(callback));
  }
}

void InAppWebView::dispatchPlatformReady() {
  if (webview_ == nullptr) return;

  std::string script = JavaScriptBridgeJS::PLATFORM_READY_JS_SOURCE();
  webkit_web_view_evaluate_javascript(
      webview_, script.c_str(), static_cast<gssize>(script.length()),
      nullptr, nullptr, nullptr, nullptr, nullptr);

  if (DebugLogEnabled()) {
    g_message("InAppWebView[%ld]: dispatched flutterInAppWebViewPlatformReady",
              static_cast<long>(id_));
  }
}

GtkWidget* InAppWebView::OnCreateWebView(WebKitWebView* web_view,
                                         WebKitNavigationAction* navigation_action,
                                         gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);
  
  if (DebugLogEnabled()) {
    g_message("InAppWebView[%ld]: create (new window requested)", static_cast<long>(self->id_));
  }
  
  // Check if JavaScript can open windows automatically
  if (!self->settings_ || !self->settings_->javaScriptCanOpenWindowsAutomatically) {
    // Default to allowing navigation in current window
    WebKitURIRequest* request = webkit_navigation_action_get_request(navigation_action);
    if (request != nullptr) {
      const gchar* uri = webkit_uri_request_get_uri(request);
      if (uri != nullptr) {
        webkit_web_view_load_uri(self->webview_, uri);
      }
    }
    return nullptr;
  }
  
  if (self->channel_delegate_) {
    // Generate a window ID
    static int64_t window_autoincrement_id = 0;
    int64_t windowId = ++window_autoincrement_id;
    
    auto createWindowAction = std::make_unique<CreateWindowAction>(
        navigation_action, windowId, nullptr);
    
    auto callback = std::make_unique<WebViewChannelDelegate::CreateWindowCallback>();
    
    // Capture necessary data for callback
    WebKitURIRequest* request = webkit_navigation_action_get_request(navigation_action);
    std::string url_to_load;
    if (request != nullptr) {
      const gchar* uri = webkit_uri_request_get_uri(request);
      if (uri != nullptr) {
        url_to_load = std::string(uri);
      }
    }
    
    callback->nonNullSuccess = [](bool handledByClient) {
      return !handledByClient;
    };
    
    // Store captured url for default behavior
    std::string captured_url = url_to_load;
    auto* webview_ptr = self->webview_;
    callback->defaultBehaviour = [webview_ptr, captured_url](std::optional<bool>) {
      // Load URL in current window if not handled
      if (!captured_url.empty() && webview_ptr != nullptr) {
        webkit_web_view_load_uri(webview_ptr, captured_url.c_str());
      }
    };
    
    self->channel_delegate_->onCreateWindow(std::move(createWindowAction),
                                            std::move(callback));
  }
  
  // Return nullptr - we don't actually create a new WebView
  // The Dart side handles the window creation
  return nullptr;
}

void InAppWebView::OnReadyToShow(WebKitWebView* web_view, gpointer user_data) {
  // This is called when a new window created by OnCreateWebView is ready
  // Currently not used since we don't create actual child WebViews
  if (DebugLogEnabled()) {
    g_message("InAppWebView: ready-to-show");
  }
}

gboolean InAppWebView::OnScriptDialog(WebKitWebView* web_view,
                                       WebKitScriptDialog* dialog,
                                       gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);
  
  WebKitScriptDialogType dialogType = webkit_script_dialog_get_dialog_type(dialog);
  const gchar* message = webkit_script_dialog_get_message(dialog);
  
  if (DebugLogEnabled()) {
    g_message("InAppWebView[%ld]: script-dialog type=%d message=%.50s...",
              static_cast<long>(self->id_), dialogType, message ? message : "null");
  }
  
  if (!self->channel_delegate_) {
    return FALSE;  // Use default WebKit dialog handling
  }
  
  std::optional<std::string> url;
  const gchar* uri = webkit_web_view_get_uri(web_view);
  if (uri != nullptr) {
    url = std::string(uri);
  }
  
  std::string messageStr = message ? std::string(message) : "";
  
  // Keep a reference to the dialog for async handling
  webkit_script_dialog_ref(dialog);
  int64_t dialogId = self->next_dialog_id_++;
  self->pending_script_dialogs_[dialogId] = dialog;
  
  switch (dialogType) {
    case WEBKIT_SCRIPT_DIALOG_ALERT: {
      auto request = std::make_unique<JsAlertRequest>(url, messageStr, true);
      auto callback = std::make_unique<WebViewChannelDelegate::JsAlertCallback>();
      
      auto* pendingDialogs = &self->pending_script_dialogs_;
      int64_t capturedId = dialogId;
      
      callback->nonNullSuccess = [](JsAlertResponse response) {
        return !response.handledByClient;
      };
      
      callback->defaultBehaviour = [pendingDialogs, capturedId](std::optional<JsAlertResponse>) {
        auto it = pendingDialogs->find(capturedId);
        if (it != pendingDialogs->end()) {
          webkit_script_dialog_close(it->second);
          webkit_script_dialog_unref(it->second);
          pendingDialogs->erase(it);
        }
      };
      
      self->channel_delegate_->onJsAlert(std::move(request), std::move(callback));
      break;
    }
    
    case WEBKIT_SCRIPT_DIALOG_CONFIRM: {
      auto request = std::make_unique<JsConfirmRequest>(url, messageStr, true);
      auto callback = std::make_unique<WebViewChannelDelegate::JsConfirmCallback>();
      
      auto* pendingDialogs = &self->pending_script_dialogs_;
      int64_t capturedId = dialogId;
      
      callback->nonNullSuccess = [pendingDialogs, capturedId](JsConfirmResponse response) {
        auto it = pendingDialogs->find(capturedId);
        if (it != pendingDialogs->end()) {
          webkit_script_dialog_confirm_set_confirmed(
              it->second, response.action == JsConfirmResponseAction::CONFIRM);
          webkit_script_dialog_close(it->second);
          webkit_script_dialog_unref(it->second);
          pendingDialogs->erase(it);
        }
        return false;
      };
      
      callback->defaultBehaviour = [pendingDialogs, capturedId](std::optional<JsConfirmResponse>) {
        auto it = pendingDialogs->find(capturedId);
        if (it != pendingDialogs->end()) {
          webkit_script_dialog_confirm_set_confirmed(it->second, FALSE);
          webkit_script_dialog_close(it->second);
          webkit_script_dialog_unref(it->second);
          pendingDialogs->erase(it);
        }
      };
      
      self->channel_delegate_->onJsConfirm(std::move(request), std::move(callback));
      break;
    }
    
    case WEBKIT_SCRIPT_DIALOG_PROMPT: {
      const gchar* defaultValue = webkit_script_dialog_prompt_get_default_text(dialog);
      std::optional<std::string> defaultValueStr;
      if (defaultValue != nullptr) {
        defaultValueStr = std::string(defaultValue);
      }
      
      auto request = std::make_unique<JsPromptRequest>(url, messageStr, defaultValueStr, true);
      auto callback = std::make_unique<WebViewChannelDelegate::JsPromptCallback>();
      
      auto* pendingDialogs = &self->pending_script_dialogs_;
      int64_t capturedId = dialogId;
      
      callback->nonNullSuccess = [pendingDialogs, capturedId](JsPromptResponse response) {
        auto it = pendingDialogs->find(capturedId);
        if (it != pendingDialogs->end()) {
          if (response.action == JsPromptResponseAction::CONFIRM && response.value.has_value()) {
            webkit_script_dialog_prompt_set_text(it->second, response.value.value().c_str());
          }
          webkit_script_dialog_close(it->second);
          webkit_script_dialog_unref(it->second);
          pendingDialogs->erase(it);
        }
        return false;
      };
      
      callback->defaultBehaviour = [pendingDialogs, capturedId](std::optional<JsPromptResponse>) {
        auto it = pendingDialogs->find(capturedId);
        if (it != pendingDialogs->end()) {
          webkit_script_dialog_close(it->second);
          webkit_script_dialog_unref(it->second);
          pendingDialogs->erase(it);
        }
      };
      
      self->channel_delegate_->onJsPrompt(std::move(request), std::move(callback));
      break;
    }
    
    case WEBKIT_SCRIPT_DIALOG_BEFORE_UNLOAD_CONFIRM: {
      auto callback = std::make_unique<WebViewChannelDelegate::JsBeforeUnloadCallback>();
      
      auto* pendingDialogs = &self->pending_script_dialogs_;
      int64_t capturedId = dialogId;
      
      callback->nonNullSuccess = [pendingDialogs, capturedId](JsBeforeUnloadResponse response) {
        auto it = pendingDialogs->find(capturedId);
        if (it != pendingDialogs->end()) {
          webkit_script_dialog_confirm_set_confirmed(it->second, response.shouldAllowNavigation);
          webkit_script_dialog_close(it->second);
          webkit_script_dialog_unref(it->second);
          pendingDialogs->erase(it);
        }
        return false;
      };
      
      callback->defaultBehaviour = [pendingDialogs, capturedId](std::optional<JsBeforeUnloadResponse>) {
        auto it = pendingDialogs->find(capturedId);
        if (it != pendingDialogs->end()) {
          webkit_script_dialog_confirm_set_confirmed(it->second, TRUE);
          webkit_script_dialog_close(it->second);
          webkit_script_dialog_unref(it->second);
          pendingDialogs->erase(it);
        }
      };
      
      self->channel_delegate_->onJsBeforeUnload(url, messageStr.empty() ? std::nullopt : std::make_optional(messageStr),
                                                 std::move(callback));
      break;
    }
    
    default:
      // Unknown dialog type, let WebKit handle it
      webkit_script_dialog_unref(dialog);
      self->pending_script_dialogs_.erase(dialogId);
      return FALSE;
  }
  
  return TRUE;  // We're handling the dialog
}

gboolean InAppWebView::OnPermissionRequest(WebKitWebView* web_view,
                                            WebKitPermissionRequest* request,
                                            gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);
  
  if (DebugLogEnabled()) {
    g_message("InAppWebView[%ld]: permission-request", static_cast<long>(self->id_));
  }
  
  if (!self->channel_delegate_) {
    webkit_permission_request_deny(request);
    return TRUE;
  }
  
  auto resourceTypes = PermissionRequest::getResourceTypes(request);
  if (resourceTypes.empty()) {
    webkit_permission_request_deny(request);
    return TRUE;
  }
  
  std::optional<std::string> origin;
  const gchar* uri = webkit_web_view_get_uri(web_view);
  if (uri != nullptr) {
    origin = std::string(uri);
  }
  
  auto permRequest = std::make_unique<PermissionRequest>(origin, resourceTypes);
  
  // Keep reference to the WebKit request
  g_object_ref(request);
  int64_t requestId = self->next_permission_id_++;
  self->pending_permission_requests_[requestId] = request;
  
  auto callback = std::make_unique<WebViewChannelDelegate::PermissionRequestCallback>();
  
  auto* pendingRequests = &self->pending_permission_requests_;
  int64_t capturedId = requestId;
  
  callback->nonNullSuccess = [pendingRequests, capturedId](PermissionResponse response) {
    auto it = pendingRequests->find(capturedId);
    if (it != pendingRequests->end()) {
      if (response.action == PermissionResponseAction::GRANT) {
        webkit_permission_request_allow(it->second);
      } else {
        webkit_permission_request_deny(it->second);
      }
      g_object_unref(it->second);
      pendingRequests->erase(it);
    }
    return false;
  };
  
  callback->defaultBehaviour = [pendingRequests, capturedId](std::optional<PermissionResponse>) {
    auto it = pendingRequests->find(capturedId);
    if (it != pendingRequests->end()) {
      webkit_permission_request_deny(it->second);
      g_object_unref(it->second);
      pendingRequests->erase(it);
    }
  };
  
  self->channel_delegate_->onPermissionRequest(std::move(permRequest), std::move(callback));
  
  return TRUE;  // We're handling the request
}

gboolean InAppWebView::OnAuthenticate(WebKitWebView* web_view,
                                       WebKitAuthenticationRequest* request,
                                       gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);
  
  if (DebugLogEnabled()) {
    g_message("InAppWebView[%ld]: authenticate", static_cast<long>(self->id_));
  }
  
  if (!self->channel_delegate_) {
    webkit_authentication_request_cancel(request);
    return TRUE;
  }
  
  const gchar* host = webkit_authentication_request_get_host(request);
  guint port = webkit_authentication_request_get_port(request);
  const gchar* realm = webkit_authentication_request_get_realm(request);
  WebKitAuthenticationScheme scheme = webkit_authentication_request_get_scheme(request);
  gboolean isProxy = webkit_authentication_request_is_for_proxy(request);
  gboolean isRetry = webkit_authentication_request_is_retry(request);
  
  URLProtectionSpace protectionSpace(
      host ? std::string(host) : "",
      static_cast<int64_t>(port),
      std::nullopt,  // protocol not directly available
      realm ? std::make_optional(std::string(realm)) : std::nullopt,
      URLProtectionSpace::fromWebKitScheme(scheme),
      isProxy);
  
  auto challenge = std::make_unique<HttpAuthenticationChallenge>(protectionSpace, isRetry);
  
  // Keep reference to the request
  g_object_ref(request);
  int64_t requestId = self->next_auth_id_++;
  self->pending_auth_requests_[requestId] = request;
  
  auto callback = std::make_unique<WebViewChannelDelegate::HttpAuthRequestCallback>();
  
  auto* pendingRequests = &self->pending_auth_requests_;
  int64_t capturedId = requestId;
  
  callback->nonNullSuccess = [pendingRequests, capturedId](HttpAuthResponse response) {
    auto it = pendingRequests->find(capturedId);
    if (it != pendingRequests->end()) {
      if (response.action == HttpAuthResponseAction::PROCEED &&
          response.username.has_value() && response.password.has_value()) {
        WebKitCredential* credential = webkit_credential_new(
            response.username.value().c_str(),
            response.password.value().c_str(),
            response.permanentPersistence
                ? WEBKIT_CREDENTIAL_PERSISTENCE_PERMANENT
                : WEBKIT_CREDENTIAL_PERSISTENCE_FOR_SESSION);
        webkit_authentication_request_authenticate(it->second, credential);
        webkit_credential_free(credential);
      } else {
        webkit_authentication_request_cancel(it->second);
      }
      g_object_unref(it->second);
      pendingRequests->erase(it);
    }
    return false;
  };
  
  callback->defaultBehaviour = [pendingRequests, capturedId](std::optional<HttpAuthResponse>) {
    auto it = pendingRequests->find(capturedId);
    if (it != pendingRequests->end()) {
      webkit_authentication_request_cancel(it->second);
      g_object_unref(it->second);
      pendingRequests->erase(it);
    }
  };
  
  self->channel_delegate_->onReceivedHttpAuthRequest(std::move(challenge), std::move(callback));
  
  return TRUE;  // We're handling the request
}

gboolean InAppWebView::OnContextMenu(WebKitWebView* web_view,
                                      WebKitContextMenu* context_menu,
                                      GdkEvent* event,
                                      WebKitHitTestResult* hit_test_result,
                                      gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);
  
  if (DebugLogEnabled()) {
    g_message("InAppWebView[%ld]: context-menu", static_cast<long>(self->id_));
  }
  
  // If context menu is disabled, suppress it
  if (self->settings_ && self->settings_->disableContextMenu) {
    return TRUE;  // Suppress the menu
  }
  
  // Allow the default context menu
  return FALSE;
}

gboolean InAppWebView::OnEnterFullscreen(WebKitWebView* web_view, gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);
  
  if (DebugLogEnabled()) {
    g_message("InAppWebView[%ld]: enter-fullscreen", static_cast<long>(self->id_));
  }
  
  if (self->channel_delegate_) {
    self->channel_delegate_->onEnterFullscreen();
  }
  
  return FALSE;  // Let WebKit handle fullscreen
}

gboolean InAppWebView::OnLeaveFullscreen(WebKitWebView* web_view, gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);
  
  if (DebugLogEnabled()) {
    g_message("InAppWebView[%ld]: leave-fullscreen", static_cast<long>(self->id_));
  }
  
  if (self->channel_delegate_) {
    self->channel_delegate_->onExitFullscreen();
  }
  
  return FALSE;  // Let WebKit handle fullscreen
}

void InAppWebView::OnNotifyFavicon(GObject* object, GParamSpec* pspec, gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);
  WebKitWebView* web_view = WEBKIT_WEB_VIEW(object);
  
  if (DebugLogEnabled()) {
    g_message("InAppWebView[%ld]: notify::favicon", static_cast<long>(self->id_));
  }
  
  // Get the favicon URI from the favicon database
  if (self->channel_delegate_) {
    const gchar* uri = webkit_web_view_get_uri(web_view);
    // Note: Getting actual favicon URL requires using WebKitFaviconDatabase
    // For now, we just notify that the favicon changed with the page URL
    self->channel_delegate_->onFaviconChanged(
        uri ? std::make_optional(std::string(uri)) : std::nullopt);
  }
}

void InAppWebView::addUserScript(std::shared_ptr<UserScript> userScript) {
  if (user_content_controller_) {
    user_content_controller_->addUserScript(userScript);
  }
}

void InAppWebView::removeUserScriptAt(size_t index,
                                       UserScriptInjectionTime injectionTime) {
  if (user_content_controller_) {
    user_content_controller_->removeUserScriptAt(index, injectionTime);
  }
}

void InAppWebView::removeUserScriptsByGroupName(const std::string& groupName) {
  if (user_content_controller_) {
    user_content_controller_->removeUserScriptsByGroupName(groupName);
  }
}

void InAppWebView::removeAllUserScripts() {
  if (user_content_controller_) {
    user_content_controller_->removeAllUserScripts();
  }
}

}  // namespace flutter_inappwebview_plugin
