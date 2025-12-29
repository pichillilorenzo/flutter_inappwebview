// WPE WebKit-based InAppWebView implementation
//
// This file provides offscreen web rendering using WPE WebKit with the FDO backend.
// The FDO backend enables DMA-BUF export for efficient GPU texture sharing with Flutter.

#include "in_app_webview.h"


#include <algorithm>
#include <cstring>
#include <random>
#include <nlohmann/json.hpp>

// Use epoxy for OpenGL/EGL instead of direct headers to avoid conflicts
#include <epoxy/egl.h>
#include <epoxy/gl.h>
#include <wpe/fdo-egl.h>
#include <wpe/unstable/fdo-shm.h>
#include <wayland-server.h>

#include "../plugin_scripts_js/javascript_bridge_js.h"
#include "../plugin_scripts_js/console_log_js.h"
#include "../types/navigation_action.h"
#include "../types/web_resource_error.h"
#include "../types/web_resource_request.h"
#include "../utils/flutter.h"
#include "../utils/log.h"
#include "user_content_controller.h"
#include "webview_channel_delegate.h"
#include "../types/create_window_action.h"

using json = nlohmann::json;

// GDK for EGL display access
#include <gdk/gdk.h>
#ifdef GDK_WINDOWING_WAYLAND
#include <gdk/gdkwayland.h>
#endif
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif

// Forward declaration of the class in the namespace
namespace flutter_inappwebview_plugin {
class InAppWebView;
}

// C-style callback functions outside the namespace for C API compatibility
extern "C" {
static void wpe_export_fdo_egl_image_callback(
    void* data, 
    struct wpe_fdo_egl_exported_image* image);

static void wpe_export_shm_buffer_callback(
    void* data,
    struct wpe_fdo_shm_exported_buffer* buffer);
}

namespace flutter_inappwebview_plugin {

namespace {

// Simple modifier mask for WPE keyboard/pointer events.
// libwpe does not define symbolic constants, so we keep a local set.
constexpr uint32_t kModShift   = 1u << 0;
constexpr uint32_t kModControl = 1u << 1;
constexpr uint32_t kModAlt     = 1u << 2;
constexpr uint32_t kModMeta    = 1u << 3;

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

}  // namespace

bool InAppWebView::IsWpeWebKitAvailable() {
  // Check if WPE FDO is available
  static bool checked = false;
  static bool available = false;
  
  if (checked) {
    return available;
  }
  checked = true;
  
  // Try to initialize WPE FDO
  // Note: wpe_fdo_initialize_for_egl_display should be called with a valid EGL display
  // For now, we just check if the library is loaded
  available = wpe_loader_init("libWPEBackend-fdo-1.0.so.1") != 0;
  
  if (DebugLogEnabled()) {
    g_message("InAppWebView: WPE WebKit %s", 
              available ? "available" : "not available");
  }
  
  return available;
}

InAppWebView::InAppWebView(FlBinaryMessenger* messenger, int64_t id,
                                 const InAppWebViewCreationParams& params)
    : id_(id),
      settings_(params.initialSettings) {
  if (DebugLogEnabled()) {
    g_message("InAppWebView[%ld]: ctor", static_cast<long>(id_));
  }
  
  js_bridge_secret_ = GenerateRandomSecret();
  
  InitWpeBackend();
  InitWebView(params);
  RegisterEventHandlers();

  // Apply initial settings
  if (settings_) {
    settings_->applyToWebView(webview_);
  }

  // Load initial content
  if (params.initialUrlRequest.has_value()) {
    auto& urlRequest = params.initialUrlRequest.value();
    if (DebugLogEnabled()) {
      g_message("InAppWebView[%ld]: initialUrlRequest url=%s",
                static_cast<long>(id_),
                urlRequest->url.value_or("").c_str());
    }
    loadUrl(urlRequest);
  } else if (params.initialData.has_value()) {
    std::string mimeType = params.initialDataMimeType.value_or("text/html");
    std::string encoding = params.initialDataEncoding.value_or("UTF-8");
    std::string baseUrl = params.initialDataBaseUrl.value_or("about:blank");
    loadData(params.initialData.value(), mimeType, encoding, baseUrl);
  } else if (params.initialFile.has_value()) {
    loadFile(params.initialFile.value());
  }
}

void InAppWebView::AttachChannel(FlBinaryMessenger* messenger,
                                    int64_t channel_id) {
  channel_id_ = channel_id;
  if (messenger == nullptr) {
    g_warning("InAppWebView[%ld]: AttachChannel messenger is null", 
              static_cast<long>(id_));
    return;
  }
  
  std::string channelName = std::string(METHOD_CHANNEL_NAME_PREFIX) + 
                            std::to_string(channel_id_);
  channel_delegate_ = std::make_unique<WebViewChannelDelegate>(
      this, messenger, channelName);
  
  if (DebugLogEnabled()) {
    g_message("InAppWebView[%ld]: attached channel id=%ld", 
              static_cast<long>(id_), static_cast<long>(channel_id_));
  }
}

InAppWebView::~InAppWebView() {
  // Clean up pending policy decisions
  for (auto& pair : pending_policy_decisions_) {
    webkit_policy_decision_ignore(pair.second);
    g_object_unref(pair.second);
  }
  pending_policy_decisions_.clear();

  // Clean up exported image (use global namespace for C API)
  if (exported_image_ != nullptr && exportable_ != nullptr) {
    ::wpe_view_backend_exportable_fdo_egl_dispatch_release_exported_image(
        exportable_, exported_image_);
    exported_image_ = nullptr;
  }

  // Destroy the webview
  if (webview_ != nullptr) {
    g_object_unref(webview_);
    webview_ = nullptr;
  }
}

void InAppWebView::InitWpeBackend() {
  if (DebugLogEnabled()) {
    g_message("InAppWebView[%ld]: InitWpeBackend %dx%d (scale=%0.2f)",
              static_cast<long>(id_), width_, height_, scale_factor_);
  }

  // Get EGL display from GDK
  EGLDisplay egl_display = EGL_NO_DISPLAY;
  GdkDisplay* gdk_display = gdk_display_get_default();
  
  if (gdk_display != nullptr) {
#ifdef GDK_WINDOWING_WAYLAND
    if (GDK_IS_WAYLAND_DISPLAY(gdk_display)) {
      struct wl_display* wl_display = gdk_wayland_display_get_wl_display(gdk_display);
      if (wl_display != nullptr) {
        egl_display = eglGetDisplay((EGLNativeDisplayType)wl_display);
        if (DebugLogEnabled()) {
          g_message("InAppWebView[%ld]: Using Wayland EGL display", static_cast<long>(id_));
        }
      }
    }
#endif
#ifdef GDK_WINDOWING_X11
    if (egl_display == EGL_NO_DISPLAY && GDK_IS_X11_DISPLAY(gdk_display)) {
      Display* x11_display = gdk_x11_display_get_xdisplay(gdk_display);
      if (x11_display != nullptr) {
        egl_display = eglGetDisplay((EGLNativeDisplayType)x11_display);
        if (DebugLogEnabled()) {
          g_message("InAppWebView[%ld]: Using X11 EGL display", static_cast<long>(id_));
        }
      }
    }
#endif
  }

  // If we couldn't get an EGL display, try the default
  if (egl_display == EGL_NO_DISPLAY) {
    egl_display = eglGetDisplay(EGL_DEFAULT_DISPLAY);
    if (DebugLogEnabled()) {
      g_message("InAppWebView[%ld]: Using default EGL display", static_cast<long>(id_));
    }
  }

  // Initialize EGL if needed
  if (egl_display != EGL_NO_DISPLAY) {
    EGLint major, minor;
    if (!eglInitialize(egl_display, &major, &minor)) {
      g_warning("InAppWebView[%ld]: Failed to initialize EGL: 0x%x", 
                static_cast<long>(id_), eglGetError());
      egl_display = EGL_NO_DISPLAY;
    } else if (DebugLogEnabled()) {
      g_message("InAppWebView[%ld]: EGL initialized: %d.%d", 
                static_cast<long>(id_), major, minor);
    }
  }

  // Store the EGL display for later use
  egl_display_ = egl_display;

  // Initialize WPE FDO with the EGL display
  if (!wpe_fdo_initialize_for_egl_display(egl_display)) {
    g_warning("InAppWebView[%ld]: Failed to initialize WPE FDO (display=%p)", 
              static_cast<long>(id_), (void*)egl_display);
    // Try again with headless mode
    if (!wpe_fdo_initialize_for_egl_display(EGL_NO_DISPLAY)) {
      g_warning("InAppWebView[%ld]: Failed to initialize WPE FDO in headless mode", 
                static_cast<long>(id_));
      return;
    }
    if (DebugLogEnabled()) {
      g_message("InAppWebView[%ld]: Using WPE FDO in headless mode", static_cast<long>(id_));
    }
  }

  // Create the exportable backend for DMA-BUF export
  // Note: The callbacks use the void* data parameter to access 'this'
  static struct wpe_view_backend_exportable_fdo_egl_client exportable_client = {
    // export_egl_image callback (legacy)
    nullptr,
    // export_fdo_egl_image callback (C function outside namespace)
    wpe_export_fdo_egl_image_callback,
    // export_shm_buffer callback for software rendering fallback
    wpe_export_shm_buffer_callback,
    // reserved
    nullptr,
    nullptr
  };

  exportable_ = wpe_view_backend_exportable_fdo_egl_create(
      &exportable_client, this, width_, height_);
  
  if (exportable_ == nullptr) {
    g_warning("InAppWebView[%ld]: Failed to create WPE exportable backend",
              static_cast<long>(id_));
    return;
  }

  wpe_backend_ = wpe_view_backend_exportable_fdo_get_view_backend(exportable_);
  
  // Create WebKit backend wrapper
  backend_ = webkit_web_view_backend_new(
      wpe_backend_,
      [](gpointer data) {
        // Destroy callback for the exportable
        auto* exportable = static_cast<struct wpe_view_backend_exportable_fdo*>(data);
        wpe_view_backend_exportable_fdo_destroy(exportable);
      },
      exportable_);

  if (DebugLogEnabled()) {
    g_message("InAppWebView[%ld]: WPE backend created successfully",
              static_cast<long>(id_));
  }
}

void InAppWebView::InitWebView(const InAppWebViewCreationParams& params) {
  if (backend_ == nullptr) {
    g_warning("InAppWebView[%ld]: Cannot create webview without backend",
              static_cast<long>(id_));
    return;
  }

  // Create WebKit settings
  WebKitSettings* settings = webkit_settings_new();
  if (settings != nullptr) {
    webkit_settings_set_enable_javascript(settings, TRUE);
    webkit_settings_set_enable_developer_extras(settings, TRUE);
    // WPE always uses hardware acceleration
  }

  // Create the web view with the WPE backend
  // WPE 2.0 API: webkit_web_view_new takes the backend
  webview_ = webkit_web_view_new(backend_);
  
  if (webview_ == nullptr) {
    g_warning("InAppWebView[%ld]: Failed to create WebKitWebView",
              static_cast<long>(id_));
    return;
  }

  // Apply settings
  webkit_web_view_set_settings(webview_, settings);
  g_object_unref(settings);

  // Set background color
  WebKitColor bg = { 1.0, 1.0, 1.0, 1.0 };
  webkit_web_view_set_background_color(webview_, &bg);

  // Create user content controller
  user_content_controller_ = std::make_unique<UserContentController>(webview_);

  if (DebugLogEnabled()) {
    g_message("InAppWebView[%ld]: WebView created with WPE backend",
              static_cast<long>(id_));
  }
}

void InAppWebView::RegisterEventHandlers() {
  if (webview_ == nullptr) {
    return;
  }

  // Set up the script message handler callback
  if (user_content_controller_) {
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
    
    // Add the console log interception script
    auto consoleLogScript = ConsoleLogJS::CONSOLE_LOG_JS_PLUGIN_SCRIPT(std::nullopt);
    user_content_controller_->addPluginScript(std::move(consoleLogScript));
    
    if (DebugLogEnabled()) {
      g_message("InAppWebView[%ld]: JavaScript bridge and console log initialized",
                static_cast<long>(id_));
    }
  }

  // Connect to load-changed signal
  g_signal_connect(webview_, "load-changed",
                   G_CALLBACK(OnLoadChanged), this);

  // Connect to decide-policy signal
  g_signal_connect(webview_, "decide-policy",
                   G_CALLBACK(OnDecidePolicy), this);

  // Connect to notify::estimated-load-progress signal
  g_signal_connect(webview_, "notify::estimated-load-progress",
                   G_CALLBACK(OnNotifyEstimatedLoadProgress), this);

  // Connect to notify::title signal
  g_signal_connect(webview_, "notify::title",
                   G_CALLBACK(OnNotifyTitle), this);

  // Connect to load-failed signal
  g_signal_connect(webview_, "load-failed",
                   G_CALLBACK(OnLoadFailed), this);

  // Connect to load-failed-with-tls-errors signal
  g_signal_connect(webview_, "load-failed-with-tls-errors",
                   G_CALLBACK(OnLoadFailedWithTlsErrors), this);

  // Connect to close signal
  g_signal_connect(webview_, "close",
                   G_CALLBACK(OnCloseRequest), this);

  // Connect to script-dialog signal
  g_signal_connect(webview_, "script-dialog",
                   G_CALLBACK(OnScriptDialog), this);

  // Connect to permission-request signal
  g_signal_connect(webview_, "permission-request",
                   G_CALLBACK(OnPermissionRequest), this);

  // Connect to authenticate signal
  g_signal_connect(webview_, "authenticate",
                   G_CALLBACK(OnAuthenticate), this);

  // Connect to context-menu signal
  g_signal_connect(webview_, "context-menu",
                   G_CALLBACK(OnContextMenu), this);

  // Connect to enter-fullscreen signal
  g_signal_connect(webview_, "enter-fullscreen",
                   G_CALLBACK(OnEnterFullscreen), this);

  // Connect to leave-fullscreen signal
  g_signal_connect(webview_, "leave-fullscreen",
                   G_CALLBACK(OnLeaveFullscreen), this);

  // Connect to mouse-target-changed for cursor type detection
  g_signal_connect(webview_, "mouse-target-changed",
                   G_CALLBACK(OnMouseTargetChanged), this);

  // Connect to create signal for window.open() / target="_blank"
  g_signal_connect(webview_, "create",
                   G_CALLBACK(OnCreateWebView), this);

  // Add frame displayed callback (WPE-specific)
  webkit_web_view_add_frame_displayed_callback(
      webview_,
      [](WebKitWebView*, gpointer data) {
        auto* self = static_cast<InAppWebView*>(data);
        self->OnFrameDisplayed(data);
      },
      this,
      nullptr);

  if (DebugLogEnabled()) {
    g_message("InAppWebView[%ld]: Event handlers registered",
              static_cast<long>(id_));
  }
}

// === WPE Backend Callbacks ===

void InAppWebView::OnFrameDisplayed(void* data) {
  auto* self = static_cast<InAppWebView*>(data);
  
  if (self->on_frame_available_) {
    self->on_frame_available_();
  }
}

void InAppWebView::OnExportDmaBuf(::wpe_fdo_egl_exported_image* image) {
  if (image == nullptr) {
    if (DebugLogEnabled()) {
      g_message("InAppWebView[%ld]: OnExportDmaBuf called with null image",
                static_cast<long>(id_));
    }
    return;
  }

  // Get image dimensions
  uint32_t img_width = wpe_fdo_egl_exported_image_get_width(image);
  uint32_t img_height = wpe_fdo_egl_exported_image_get_height(image);
  
  static int frame_count = 0;
  frame_count++;
  if (DebugLogEnabled() && frame_count % 60 == 0) {
    g_message("InAppWebView[%ld]: OnExportDmaBuf frame %d (%ux%u)",
              static_cast<long>(id_), frame_count, img_width, img_height);
  }

  // Get the EGL image from the exported image
  EGLImageKHR egl_image = wpe_fdo_egl_exported_image_get_egl_image(image);
  
  if (egl_image != EGL_NO_IMAGE_KHR && egl_display_ != nullptr) {
    // Read pixels from the EGL image using OpenGL
    ReadPixelsFromEglImage(egl_image, img_width, img_height);
  }

  // Release previous exported image
  if (exported_image_ != nullptr && exportable_ != nullptr) {
    ::wpe_view_backend_exportable_fdo_egl_dispatch_release_exported_image(
        exportable_, exported_image_);
  }
  
  exported_image_ = image;
  
  // Dispatch frame complete to allow WebKit to render next frame
  if (exportable_ != nullptr) {
    wpe_view_backend_exportable_fdo_dispatch_frame_complete(exportable_);
  }
  
  if (on_frame_available_) {
    on_frame_available_();
  }
}

void InAppWebView::ReadPixelsFromEglImage(void* egl_image, 
                                              uint32_t width, uint32_t height) {
  EGLDisplay display = static_cast<EGLDisplay>(egl_display_);
  EGLImageKHR image = static_cast<EGLImageKHR>(egl_image);
  
  if (display == EGL_NO_DISPLAY || image == EGL_NO_IMAGE_KHR) {
    return;
  }

  // Create texture from EGL image if we haven't already
  if (readback_texture_ == 0) {
    glGenTextures(1, &readback_texture_);
  }
  
  // Create FBO if needed
  if (fbo_ == 0) {
    glGenFramebuffers(1, &fbo_);
  }

  // Bind the EGL image to our texture
  glBindTexture(GL_TEXTURE_2D, readback_texture_);
  
  // Use the OES_EGL_image extension to create texture from EGL image
  static PFNGLEGLIMAGETARGETTEXTURE2DOESPROC glEGLImageTargetTexture2DOES = nullptr;
  if (glEGLImageTargetTexture2DOES == nullptr) {
    glEGLImageTargetTexture2DOES = (PFNGLEGLIMAGETARGETTEXTURE2DOESPROC)
        eglGetProcAddress("glEGLImageTargetTexture2DOES");
  }
  
  if (glEGLImageTargetTexture2DOES != nullptr) {
    glEGLImageTargetTexture2DOES(GL_TEXTURE_2D, image);
  } else {
    glBindTexture(GL_TEXTURE_2D, 0);
    return;
  }

  // Set up FBO to read from texture
  glBindFramebuffer(GL_FRAMEBUFFER, fbo_);
  glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, 
                         GL_TEXTURE_2D, readback_texture_, 0);

  // Check FBO status
  GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
  if (status != GL_FRAMEBUFFER_COMPLETE) {
    if (DebugLogEnabled()) {
      g_warning("InAppWebView[%ld]: FBO incomplete: 0x%x", 
                static_cast<long>(id_), status);
    }
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glBindTexture(GL_TEXTURE_2D, 0);
    return;
  }

  // Read pixels
  size_t buffer_size = width * height * 4;  // RGBA
  
  // Use triple buffering
  size_t write_idx = write_buffer_index_.load(std::memory_order_relaxed);
  auto& buffer = pixel_buffers_[write_idx];
  
  if (buffer.data.size() != buffer_size) {
    buffer.data.resize(buffer_size);
  }
  
  buffer.width = width;
  buffer.height = height;
  
  glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, buffer.data.data());
  
  // Swap buffers
  {
    std::lock_guard<std::mutex> lock(buffer_swap_mutex_);
    read_buffer_index_.store(write_idx, std::memory_order_release);
    write_buffer_index_.store((write_idx + 1) % kNumBuffers, std::memory_order_relaxed);
  }

  // Unbind
  glBindFramebuffer(GL_FRAMEBUFFER, 0);
  glBindTexture(GL_TEXTURE_2D, 0);
}

// === Navigation Methods ===

void InAppWebView::loadUrl(const std::string& url) {
  if (webview_ == nullptr) return;
  webkit_web_view_load_uri(webview_, url.c_str());
}

void InAppWebView::loadUrl(const std::shared_ptr<URLRequest>& urlRequest) {
  if (webview_ == nullptr || !urlRequest) return;
  
  if (!urlRequest->url.has_value()) {
    return;
  }

  std::string method = urlRequest->method.value_or("GET");
  
  if (method == "GET" && !urlRequest->body.has_value() && 
      !urlRequest->headers.has_value()) {
    webkit_web_view_load_uri(webview_, urlRequest->url.value().c_str());
    return;
  }

  // Create a WebKitURIRequest for more complex requests
  WebKitURIRequest* request = webkit_uri_request_new(urlRequest->url.value().c_str());
  
  // Set headers
  if (urlRequest->headers.has_value()) {
    SoupMessageHeaders* headers = webkit_uri_request_get_http_headers(request);
    for (const auto& header : urlRequest->headers.value()) {
      soup_message_headers_append(headers, header.first.c_str(), 
                                  header.second.c_str());
    }
  }
  
  webkit_web_view_load_request(webview_, request);
  g_object_unref(request);
}

void InAppWebView::loadData(const std::string& data,
                               const std::string& mime_type,
                               const std::string& encoding,
                               const std::string& base_url) {
  if (webview_ == nullptr) return;
  
  GBytes* bytes = g_bytes_new(data.data(), data.size());
  webkit_web_view_load_bytes(webview_, bytes, mime_type.c_str(),
                              encoding.c_str(), base_url.c_str());
  g_bytes_unref(bytes);
}

void InAppWebView::loadFile(const std::string& asset_file_path) {
  if (webview_ == nullptr) return;
  
  std::string file_url = "file://" + asset_file_path;
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

// === Getters ===

std::optional<std::string> InAppWebView::getUrl() const {
  if (webview_ == nullptr) return std::nullopt;
  const gchar* uri = webkit_web_view_get_uri(webview_);
  if (uri == nullptr) return std::nullopt;
  return std::string(uri);
}

std::optional<std::string> InAppWebView::getTitle() const {
  if (webview_ == nullptr) return std::nullopt;
  const gchar* title = webkit_web_view_get_title(webview_);
  if (title == nullptr) return std::nullopt;
  return std::string(title);
}

int64_t InAppWebView::getProgress() const {
  if (webview_ == nullptr) return 0;
  return static_cast<int64_t>(
      webkit_web_view_get_estimated_load_progress(webview_) * 100);
}

// === JavaScript ===

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
  
  auto* cb_data = new CallbackData{std::move(callback)};
  
  webkit_web_view_evaluate_javascript(
      webview_,
      source.c_str(),
      source.length(),
      nullptr,  // world name
      nullptr,  // source URI
      nullptr,  // cancellable
      [](GObject* source, GAsyncResult* result, gpointer user_data) {
        auto* data = static_cast<CallbackData*>(user_data);
        GError* error = nullptr;
        JSCValue* js_result = webkit_web_view_evaluate_javascript_finish(
            WEBKIT_WEB_VIEW(source), result, &error);
        
        if (error != nullptr) {
          if (data->callback) data->callback(std::nullopt);
          g_error_free(error);
        } else if (js_result != nullptr) {
          gchar* str = jsc_value_to_string(js_result);
          if (data->callback) data->callback(std::string(str));
          g_free(str);
          g_object_unref(js_result);
        } else {
          if (data->callback) data->callback(std::nullopt);
        }
        
        delete data;
      },
      cb_data);
}

void InAppWebView::injectJavascriptFileFromUrl(const std::string& urlFile) {
  std::string script = 
      "(function() {"
      "  var script = document.createElement('script');"
      "  script.src = '" + urlFile + "';"
      "  document.head.appendChild(script);"
      "})();";
  evaluateJavascript(script, nullptr);
}

void InAppWebView::injectCSSCode(const std::string& source) {
  // Escape single quotes and newlines in CSS
  std::string escaped_source = source;
  size_t pos = 0;
  while ((pos = escaped_source.find("'", pos)) != std::string::npos) {
    escaped_source.replace(pos, 1, "\\'");
    pos += 2;
  }
  pos = 0;
  while ((pos = escaped_source.find("\n", pos)) != std::string::npos) {
    escaped_source.replace(pos, 1, "\\n");
    pos += 2;
  }

  std::string script =
      "(function() {"
      "  var style = document.createElement('style');"
      "  style.textContent = '" + escaped_source + "';"
      "  document.head.appendChild(style);"
      "})();";
  evaluateJavascript(script, nullptr);
}

void InAppWebView::injectCSSFileFromUrl(const std::string& urlFile) {
  std::string script =
      "(function() {"
      "  var link = document.createElement('link');"
      "  link.rel = 'stylesheet';"
      "  link.href = '" + urlFile + "';"
      "  document.head.appendChild(link);"
      "})();";
  evaluateJavascript(script, nullptr);
}

// === User Scripts ===

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

// === HTML Content ===

void InAppWebView::getHtml(
    std::function<void(const std::optional<std::string>&)> callback) {
  evaluateJavascript("document.documentElement.outerHTML", callback);
}

// === Zoom ===

double InAppWebView::getZoomScale() const {
  if (webview_ == nullptr) return 1.0;
  return webkit_web_view_get_zoom_level(webview_);
}

void InAppWebView::setZoomScale(double zoomScale) {
  if (webview_ == nullptr) return;
  webkit_web_view_set_zoom_level(webview_, zoomScale);
}

// === Scroll ===

void InAppWebView::scrollTo(int64_t x, int64_t y, bool animated) {
  std::string script = animated
      ? "window.scrollTo({top: " + std::to_string(y) + 
        ", left: " + std::to_string(x) + ", behavior: 'smooth'});"
      : "window.scrollTo(" + std::to_string(x) + ", " + std::to_string(y) + ");";
  evaluateJavascript(script, nullptr);
}

void InAppWebView::scrollBy(int64_t x, int64_t y, bool animated) {
  std::string script = animated
      ? "window.scrollBy({top: " + std::to_string(y) + 
        ", left: " + std::to_string(x) + ", behavior: 'smooth'});"
      : "window.scrollBy(" + std::to_string(x) + ", " + std::to_string(y) + ");";
  evaluateJavascript(script, nullptr);
}

int64_t InAppWebView::getScrollX() const {
  // This would need to be async in a real implementation
  return 0;
}

int64_t InAppWebView::getScrollY() const {
  // This would need to be async in a real implementation
  return 0;
}

// === Settings ===

FlValue* InAppWebView::getSettings() const {
  if (settings_) {
    return settings_->toFlValue();
  }
  return fl_value_new_null();
}

void InAppWebView::setSettings(
    const std::shared_ptr<InAppWebViewSettings> newSettings,
    FlValue* newSettingsMap) {
  if (newSettings && webview_) {
    settings_ = newSettings;
    settings_->applyToWebView(webview_);
  }
}

// === Size Management ===

void InAppWebView::setSize(int width, int height) {
  if (width == width_ && height == height_) return;
  
  width_ = width;
  height_ = height;

  // Resize the WPE backend
  if (wpe_backend_ != nullptr) {
    wpe_view_backend_dispatch_set_size(wpe_backend_, width_, height_);
  }

  if (DebugLogEnabled()) {
    g_message("InAppWebView[%ld]: setSize %dx%d",
              static_cast<long>(id_), width_, height_);
  }
}

void InAppWebView::setScaleFactor(double scale_factor) {
  if (scale_factor == scale_factor_) return;
  scale_factor_ = scale_factor;

  // WPE uses device scale factor
  if (wpe_backend_ != nullptr) {
    wpe_view_backend_dispatch_set_device_scale_factor(wpe_backend_, scale_factor_);
  }
}

// === Input Handling ===

void InAppWebView::SetCursorPos(double x, double y) {
  // Store logical coordinates
  cursor_x_ = x;
  cursor_y_ = y;
  
  // Send pointer motion event with scaled coordinates (logical -> physical)
  if (wpe_backend_ != nullptr) {
    struct wpe_input_pointer_event event = {};
    event.type = wpe_input_pointer_event_type_motion;
    event.time = g_get_monotonic_time() / 1000;  // Convert to milliseconds
    // Scale coordinates from logical to physical pixels
    event.x = static_cast<int>(x * scale_factor_);
    event.y = static_cast<int>(y * scale_factor_);
    event.state = button_state_;
    event.modifiers = current_modifiers_;
    wpe_view_backend_dispatch_pointer_event(wpe_backend_, &event);
  }
}

void InAppWebView::SetPointerButton(int kind, int button, int clickCount) {
  if (wpe_backend_ == nullptr) return;

  // Scale coordinates from logical to physical pixels
  int scaled_x = static_cast<int>(cursor_x_ * scale_factor_);
  int scaled_y = static_cast<int>(cursor_y_ * scale_factor_);

  // Map button: Flutter uses 0=none, 1=primary, 2=secondary, 3=tertiary
  // WPE uses Linux evdev button codes: 1=BTN_LEFT, 2=BTN_MIDDLE, 3=BTN_RIGHT
  uint32_t wpe_button;
  switch (button) {
    case 1: wpe_button = 1; break;  // Primary -> BTN_LEFT
    case 2: wpe_button = 3; break;  // Secondary -> BTN_RIGHT
    case 3: wpe_button = 2; break;  // Tertiary -> BTN_MIDDLE
    default: wpe_button = 1; break; // Default to primary
  }

  // First send a motion event to ensure WebKit has the correct cursor position
  // This is important because the button event needs to know where the click occurred
  {
    struct wpe_input_pointer_event motion_event = {};
    motion_event.type = wpe_input_pointer_event_type_motion;
    motion_event.time = g_get_monotonic_time() / 1000;
    motion_event.x = scaled_x;
    motion_event.y = scaled_y;
    motion_event.button = 0;
    motion_event.state = button_state_;
    motion_event.modifiers = current_modifiers_;
    wpe_view_backend_dispatch_pointer_event(wpe_backend_, &motion_event);
  }

  struct wpe_input_pointer_event event = {};
  event.time = g_get_monotonic_time() / 1000;
  event.x = scaled_x;
  event.y = scaled_y;
  event.button = wpe_button;
  event.modifiers = current_modifiers_;

  // Map event type based on kind
  switch (static_cast<WpePointerEventKind>(kind)) {
    case WpePointerEventKind::Down:
      event.type = wpe_input_pointer_event_type_button;
      button_state_ |= (1 << wpe_button);
      event.state = button_state_;  // Button mask
      if (DebugLogEnabled()) {
        g_message("InAppWebView[%ld]: button DOWN at (%d,%d) button=%d state=%d",
                  static_cast<long>(id_), scaled_x, scaled_y, wpe_button, event.state);
      }
      break;
    case WpePointerEventKind::Up:
      event.type = wpe_input_pointer_event_type_button;
      button_state_ &= ~(1 << wpe_button);
      event.state = button_state_;  // Button mask after release
      if (DebugLogEnabled()) {
        g_message("InAppWebView[%ld]: button UP at (%d,%d) button=%d state=%d",
                  static_cast<long>(id_), scaled_x, scaled_y, wpe_button, event.state);
      }
      break;
    default:
      // Ignore enter/leave/cancel etc for button events
      return;
  }

  wpe_view_backend_dispatch_pointer_event(wpe_backend_, &event);
}

void InAppWebView::SetScrollDelta(double dx, double dy) {
  if (wpe_backend_ == nullptr) return;

  // Scale coordinates from logical to physical pixels
  int scaled_x = static_cast<int>(cursor_x_ * scale_factor_);
  int scaled_y = static_cast<int>(cursor_y_ * scale_factor_);
  
  // Use the 2D axis event with smooth scrolling for proper pixel-based scrolling
  // The wpe_input_axis_2d_event provides x_axis and y_axis as doubles
  // With wpe_input_axis_event_type_motion_smooth | wpe_input_axis_event_type_mask_2d,
  // WebKit will use the raw pixel values for smooth scrolling
  
  struct wpe_input_axis_2d_event event = {};
  event.base.type = static_cast<wpe_input_axis_event_type>(
      wpe_input_axis_event_type_motion_smooth | wpe_input_axis_event_type_mask_2d);
  event.base.time = g_get_monotonic_time() / 1000;
  event.base.x = scaled_x;
  event.base.y = scaled_y;
  event.base.modifiers = current_modifiers_;
  
  // Flutter provides delta in logical pixels, scale to physical and apply sensitivity
  // The scale factor converts logical to physical pixels
  event.x_axis = dx * scale_factor_;
  event.y_axis = dy * scale_factor_;
  
  wpe_view_backend_dispatch_axis_event(wpe_backend_, &event.base);
}

void InAppWebView::SendKeyEvent(int type, int64_t keyCode, int scanCode, 
                                    int modifiers, const std::string& characters) {
  if (wpe_backend_ == nullptr) return;

  struct wpe_input_keyboard_event event = {};
  event.time = g_get_monotonic_time() / 1000;
  event.key_code = static_cast<uint32_t>(keyCode);
  event.hardware_key_code = static_cast<uint32_t>(scanCode);
  // type: 0=down, 1=up, 2=repeat
  event.pressed = (type == 0 || type == 2);

  // Map Flutter modifiers (Shift=1, Ctrl=2, Alt=4, Meta=8) to WPE mask
  current_modifiers_ = 0;
  if (modifiers & 1) current_modifiers_ |= kModShift;
  if (modifiers & 2) current_modifiers_ |= kModControl;
  if (modifiers & 4) current_modifiers_ |= kModAlt;
  if (modifiers & 8) current_modifiers_ |= kModMeta;
  event.modifiers = current_modifiers_;

  if (DebugLogEnabled()) {
    g_message("InAppWebView[%ld]: key %s keyCode=0x%x scanCode=%d mods=0x%x char='%s'",
              static_cast<long>(id_),
              event.pressed ? "DOWN" : "UP",
              event.key_code, event.hardware_key_code, event.modifiers,
              characters.c_str());
  }

  wpe_view_backend_dispatch_keyboard_event(wpe_backend_, &event);
}

// === Pixel Buffer Access ===

size_t InAppWebView::GetPixelBufferSize(uint32_t* out_width, 
                                            uint32_t* out_height) const {
  // With WPE + FDO, we typically use DMA-BUF export instead of CPU copy
  // This is a fallback for when DMA-BUF is not available
  std::lock_guard<std::mutex> lock(buffer_swap_mutex_);
  
  size_t read_idx = read_buffer_index_.load(std::memory_order_acquire);
  const auto& buffer = pixel_buffers_[read_idx];
  
  if (out_width) *out_width = static_cast<uint32_t>(buffer.width);
  if (out_height) *out_height = static_cast<uint32_t>(buffer.height);
  
  return buffer.data.size();
}

bool InAppWebView::CopyPixelBufferTo(uint8_t* dst, size_t dst_size,
                                         uint32_t* out_width,
                                         uint32_t* out_height) const {
  std::lock_guard<std::mutex> lock(buffer_swap_mutex_);
  
  size_t read_idx = read_buffer_index_.load(std::memory_order_acquire);
  const auto& buffer = pixel_buffers_[read_idx];
  
  if (buffer.data.empty() || dst_size < buffer.data.size()) {
    return false;
  }
  
  std::memcpy(dst, buffer.data.data(), buffer.data.size());
  
  if (out_width) *out_width = static_cast<uint32_t>(buffer.width);
  if (out_height) *out_height = static_cast<uint32_t>(buffer.height);
  
  return true;
}

bool InAppWebView::HasDmaBufExport() const {
  return exported_image_ != nullptr;
}

bool InAppWebView::GetDmaBufFd(int* fd, uint32_t* stride, 
                                   uint32_t* width, uint32_t* height) const {
  if (exported_image_ == nullptr) {
    return false;
  }
  
  // Get DMA-BUF file descriptor from the exported image
  // This allows zero-copy sharing with Flutter's texture system
  // Note: The actual API depends on the WPE version
  // This is a simplified version
  
  if (width) *width = static_cast<uint32_t>(width_);
  if (height) *height = static_cast<uint32_t>(height_);
  
  // In a real implementation, you'd get the DMA-BUF FD from the EGL image
  // For now, return false to indicate not implemented
  return false;
}

void InAppWebView::SetOnFrameAvailable(std::function<void()> callback) {
  on_frame_available_ = std::move(callback);
}

void InAppWebView::SetOnCursorChanged(
    std::function<void(const std::string&)> callback) {
  on_cursor_changed_ = std::move(callback);
}

void InAppWebView::OnShouldOverrideUrlLoadingDecision(int64_t decision_id, 
                                                          bool allow) {
  auto it = pending_policy_decisions_.find(decision_id);
  if (it == pending_policy_decisions_.end()) {
    return;
  }
  
  WebKitPolicyDecision* decision = it->second;
  if (allow) {
    webkit_policy_decision_use(decision);
  } else {
    webkit_policy_decision_ignore(decision);
  }
  
  g_object_unref(decision);
  pending_policy_decisions_.erase(it);
}

// === WebKit Signal Handlers ===

void InAppWebView::OnLoadChanged(WebKitWebView* web_view,
                                     WebKitLoadEvent load_event,
                                     gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);
  if (self->channel_delegate_ == nullptr) return;

  switch (load_event) {
    case WEBKIT_LOAD_STARTED:
      self->channel_delegate_->onLoadStart(
          self->getUrl().value_or(""));
      break;
    case WEBKIT_LOAD_COMMITTED:
      // Inject cursor detection script when page content starts loading
      self->injectCursorDetectionScript();
      break;
    case WEBKIT_LOAD_FINISHED:
      self->channel_delegate_->onLoadStop(
          self->getUrl().value_or(""));
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
  
  if (decision_type != WEBKIT_POLICY_DECISION_TYPE_NAVIGATION_ACTION) {
    if (DebugLogEnabled()) {
      g_message("InAppWebView[%ld]: OnDecidePolicy ignored type=%d",
                static_cast<long>(self->id_), static_cast<int>(decision_type));
    }
    return FALSE;  // Let WebKit handle other decision types
  }

  if (DebugLogEnabled()) {
    g_message("InAppWebView[%ld]: OnDecidePolicy invoked (navigation_action)", static_cast<long>(self->id_));
  }

  auto* nav_decision = WEBKIT_NAVIGATION_POLICY_DECISION(decision);
  auto* nav_action = webkit_navigation_policy_decision_get_navigation_action(
      nav_decision);
  auto* request = webkit_navigation_action_get_request(nav_action);
  const gchar* uri = webkit_uri_request_get_uri(request);

  if (self->settings_ && self->settings_->useShouldOverrideUrlLoading) {
    if (self->channel_delegate_) {
      int64_t decision_id = self->next_decision_id_++;
      g_object_ref(decision);
      self->pending_policy_decisions_[decision_id] = decision;

      // Best-effort main frame detection: frame name is usually null/empty for main frame.
      bool is_for_main_frame = true;
      const gchar* frame_name = webkit_navigation_action_get_frame_name(nav_action);
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
      WebKitNavigationType nav_type = webkit_navigation_action_get_navigation_type(nav_action);
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
        bool allow = result.has_value() && result.value() == NavigationActionPolicy::allow;
        self->OnShouldOverrideUrlLoadingDecision(decision_id, allow);
      };

      // Notify Dart side with callback
      self->channel_delegate_->shouldOverrideUrlLoading(navigationAction, std::move(callback));

      if (DebugLogEnabled()) {
        g_message("InAppWebView[%ld]: deferring policy decision id=%ld", 
                  static_cast<long>(self->id_), static_cast<long>(decision_id));
      }

      return TRUE;  // We're handling this asynchronously
    }
  }

  return FALSE;  // Let WebKit proceed with navigation
}

void InAppWebView::OnNotifyEstimatedLoadProgress(GObject* object,
                                                     GParamSpec* pspec,
                                                     gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);
  if (self->channel_delegate_ == nullptr) return;

  double progress = webkit_web_view_get_estimated_load_progress(
      WEBKIT_WEB_VIEW(object));
  int progress_percent = static_cast<int>(progress * 100);
  
  self->channel_delegate_->onProgressChanged(progress_percent);
}

void InAppWebView::OnNotifyTitle(GObject* object,
                                     GParamSpec* pspec,
                                     gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);
  if (self->channel_delegate_ == nullptr) return;

  const gchar* title = webkit_web_view_get_title(WEBKIT_WEB_VIEW(object));
  if (title != nullptr) {
    self->channel_delegate_->onTitleChanged(std::string(title));
  }
}

gboolean InAppWebView::OnLoadFailed(WebKitWebView* web_view,
                                        WebKitLoadEvent load_event,
                                        gchar* failing_uri,
                                        GError* error,
                                        gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);
  if (self->channel_delegate_ == nullptr) return FALSE;

  // Create WebResourceRequest for the failing URL
  auto request = std::make_shared<WebResourceRequest>(
      failing_uri ? std::optional<std::string>(failing_uri) : std::nullopt,
      std::optional<std::string>("GET"),  // Default method
      std::nullopt,  // headers
      std::optional<bool>(true)  // isForMainFrame - load failures are typically main frame
  );

  // Create WebResourceError from GError
  auto webError = std::make_shared<WebResourceError>(
      error ? std::string(error->message) : "Unknown error",
      error ? static_cast<int64_t>(error->code) : -1
  );

  self->channel_delegate_->onReceivedError(request, webError);

  return FALSE;
}

gboolean InAppWebView::OnLoadFailedWithTlsErrors(WebKitWebView* web_view,
                                                     gchar* failing_uri,
                                                     GTlsCertificate* certificate,
                                                     GTlsCertificateFlags errors,
                                                     gpointer user_data) {
  (void)web_view;
  (void)failing_uri;
  (void)certificate;
  (void)errors;
  (void)user_data;
  // Handle TLS errors
  return FALSE;
}

void InAppWebView::OnCloseRequest(WebKitWebView* web_view, gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);
  if (self->channel_delegate_) {
    self->channel_delegate_->onCloseWindow();
  }
}

// WPE WebKit create signal handler - returns WebKitWebView* (not GtkWidget*)
WebKitWebView* InAppWebView::OnCreateWebView(WebKitWebView* web_view,
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
      if (uri != nullptr && self->webview_ != nullptr) {
        webkit_web_view_load_uri(self->webview_, uri);
      }
    }
    return nullptr;
  }

  if (self->channel_delegate_) {
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

    std::string captured_url = url_to_load;
    auto* webview_ptr = self->webview_;
    callback->defaultBehaviour = [webview_ptr, captured_url](std::optional<bool>) {
      if (!captured_url.empty() && webview_ptr != nullptr) {
        webkit_web_view_load_uri(webview_ptr, captured_url.c_str());
      }
    };

    self->channel_delegate_->onCreateWindow(std::move(createWindowAction), std::move(callback));
  }

  // Return nullptr - we don't actually create a new WebView
  // The Dart side handles the window creation
  return nullptr;
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
                                         WebKitHitTestResult* hit_test_result,
                                         gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);
  
  // Disable context menu if setting is enabled
  if (self->settings_ && self->settings_->disableContextMenu) {
    return TRUE;  // Suppress context menu
  }
  
  return FALSE;
}

gboolean InAppWebView::OnEnterFullscreen(WebKitWebView* web_view, 
                                             gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);
  if (self->channel_delegate_) {
    self->channel_delegate_->onEnterFullscreen();
  }
  return FALSE;
}

gboolean InAppWebView::OnLeaveFullscreen(WebKitWebView* web_view, 
                                             gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);
  if (self->channel_delegate_) {
    self->channel_delegate_->onExitFullscreen();
  }
  return FALSE;
}

void InAppWebView::OnMouseTargetChanged(WebKitWebView* web_view,
                                            WebKitHitTestResult* hit_test_result,
                                            guint modifiers,
                                            gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);
  
  // Determine cursor based on hit test result
  std::string cursor_name = "basic";
  
  if (hit_test_result == nullptr) {
    // No hit test result, use default cursor
  } else if (webkit_hit_test_result_context_is_link(hit_test_result)) {
    cursor_name = "click";  // Hand cursor for links
  } else if (webkit_hit_test_result_context_is_editable(hit_test_result)) {
    cursor_name = "text";  // Text cursor for editable content
  } else if (webkit_hit_test_result_context_is_selection(hit_test_result)) {
    cursor_name = "text";  // Text cursor for selection
  } else if (webkit_hit_test_result_context_is_image(hit_test_result)) {
    // Check if image is also a link
    if (webkit_hit_test_result_context_is_link(hit_test_result)) {
      cursor_name = "click";
    }
  } else if (webkit_hit_test_result_context_is_media(hit_test_result)) {
    cursor_name = "basic";
  } else if (webkit_hit_test_result_context_is_scrollbar(hit_test_result)) {
    cursor_name = "basic";
  }
  
  // Only emit if cursor changed
  if (cursor_name != self->last_cursor_name_) {
    self->last_cursor_name_ = cursor_name;
    if (self->on_cursor_changed_) {
      self->on_cursor_changed_(cursor_name);
    }
    if (DebugLogEnabled()) {
      g_message("InAppWebView[%ld]: cursor changed to '%s'",
                static_cast<long>(self->id_), cursor_name.c_str());
    }
  }
}

// NOTE: OnMotionNotify and OnNotifyFavicon have been removed because:
// - motion-notify-event is a GTK widget signal (WPE WebView is NOT a GTK widget)
// - notify::favicon property does not exist in WPE WebKit (GTK-only)
// Cursor detection in WPE is handled via mouse-target-changed and JS injection.

// === Cursor Detection ===

void InAppWebView::injectCursorDetectionScript() {
  // Inject a script that monitors cursor style changes via mousemove
  // This captures CSS cursor properties that OnMouseTargetChanged doesn't detect
  const char* script = R"JS(
(function() {
  if (window._flutterCursorDetectorInstalled) return;
  window._flutterCursorDetectorInstalled = true;
  
  var lastCursor = '';
  document.addEventListener('mousemove', function(e) {
    var el = document.elementFromPoint(e.clientX, e.clientY);
    if (el) {
      var cursor = window.getComputedStyle(el).cursor;
      if (cursor !== lastCursor) {
        lastCursor = cursor;
        // Send to native via console (picked up by user script handler)
        if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
          window.flutter_inappwebview.callHandler('_cursorChanged', cursor);
        }
      }
    }
  }, { passive: true });
})();
)JS";
  evaluateJavascript(script, nullptr);
}

void InAppWebView::updateCursorFromCssStyle(const std::string& cursor_style) {
  // Map CSS cursor values to Flutter cursor names
  std::string cursor_name = "basic";
  
  if (cursor_style == "pointer" || cursor_style == "hand") {
    cursor_name = "click";
  } else if (cursor_style == "text" || cursor_style == "vertical-text") {
    cursor_name = "text";
  } else if (cursor_style == "wait") {
    cursor_name = "wait";
  } else if (cursor_style == "progress") {
    cursor_name = "progress";
  } else if (cursor_style == "help") {
    cursor_name = "help";
  } else if (cursor_style == "crosshair") {
    cursor_name = "precise";
  } else if (cursor_style == "move" || cursor_style == "all-scroll") {
    cursor_name = "move";
  } else if (cursor_style == "grab") {
    cursor_name = "grab";
  } else if (cursor_style == "grabbing") {
    cursor_name = "grabbing";
  } else if (cursor_style == "not-allowed" || cursor_style == "no-drop") {
    cursor_name = "forbidden";
  } else if (cursor_style == "context-menu") {
    cursor_name = "contextMenu";
  } else if (cursor_style == "cell") {
    cursor_name = "cell";
  } else if (cursor_style == "copy") {
    cursor_name = "copy";
  } else if (cursor_style == "alias") {
    cursor_name = "alias";
  } else if (cursor_style == "none") {
    cursor_name = "none";
  } else if (cursor_style == "col-resize") {
    cursor_name = "resizeColumn";
  } else if (cursor_style == "row-resize") {
    cursor_name = "resizeRow";
  } else if (cursor_style == "n-resize" || cursor_style == "ns-resize") {
    cursor_name = "resizeUpDown";
  } else if (cursor_style == "e-resize" || cursor_style == "ew-resize" || 
             cursor_style == "w-resize") {
    cursor_name = "resizeLeftRight";
  } else if (cursor_style == "ne-resize" || cursor_style == "sw-resize") {
    cursor_name = "resizeUpRightDownLeft";
  } else if (cursor_style == "nw-resize" || cursor_style == "se-resize" ||
             cursor_style == "nesw-resize" || cursor_style == "nwse-resize") {
    cursor_name = "resizeUpLeftDownRight";
  } else if (cursor_style == "zoom-in") {
    cursor_name = "zoomIn";
  } else if (cursor_style == "zoom-out") {
    cursor_name = "zoomOut";
  }
  // default, auto, inherit -> "basic"
  
  if (cursor_name != last_cursor_name_) {
    last_cursor_name_ = cursor_name;
    if (on_cursor_changed_) {
      on_cursor_changed_(cursor_name);
    }
  }
}

// === JavaScript Bridge ===

void InAppWebView::handleScriptMessage(const std::string& name, 
                                           const std::string& body) {
  // Handle internal cursor change messages (sent directly via messageHandlers)
  if (name == "_cursorChanged") {
    updateCursorFromCssStyle(body);
    return;
  }

  // === Security Check 1: javaScriptBridgeEnabled ===
  // Match iOS: guard javaScriptBridgeEnabled else { return }
  if (settings_ && !settings_->javaScriptBridgeEnabled) {
    if (DebugLogEnabled()) {
      g_message("InAppWebView[%ld]: JavaScript bridge is disabled",
                static_cast<long>(id_));
    }
    return;
  }

  // Parse the body as JSON using nlohmann/json
  json bodyJson;
  try {
    bodyJson = json::parse(body);
  } catch (const json::parse_error& e) {
    if (DebugLogEnabled()) {
      g_message("InAppWebView[%ld]: Failed to parse script message JSON: %s",
                static_cast<long>(id_), e.what());
    }
    return;
  }

  // === Security Check 2: Bridge Secret Validation ===
  // Match iOS: guard bridgeSecret == exceptedBridgeSecret
  std::string receivedSecret = "";
  if (bodyJson.contains("_bridgeSecret") && bodyJson["_bridgeSecret"].is_string()) {
    receivedSecret = bodyJson["_bridgeSecret"].get<std::string>();
  }
  
  if (receivedSecret != js_bridge_secret_) {
    // Get origin for logging
    std::string securityOrigin = "unknown";
    const gchar* uri = webkit_web_view_get_uri(webview_);
    if (uri != nullptr) {
      securityOrigin = std::string(uri);
    }
    g_warning("InAppWebView[%ld]: Bridge access attempt with wrong secret token, "
              "possibly from malicious code from origin %s",
              static_cast<long>(id_), securityOrigin.c_str());
    return;
  }

  // === Build Source Origin (matches iOS securityOrigin handling) ===
  std::string sourceOrigin = "";
  std::string requestUrl = "";
  bool isMainFrame = true;  // Main frame by default for WPE
  
  // Get current URL from webview - this is the "request URL"
  const gchar* uri = webkit_web_view_get_uri(webview_);
  if (uri != nullptr) {
    requestUrl = std::string(uri);
    // Extract origin from URL (scheme://host:port)
    // This matches iOS: URL(string: "\(scheme)://\(host)\(port != 0 ? ":" + String(port) : "")")
    try {
      size_t schemeEnd = requestUrl.find("://");
      if (schemeEnd != std::string::npos) {
        size_t hostStart = schemeEnd + 3;
        size_t hostEnd = requestUrl.find('/', hostStart);
        if (hostEnd == std::string::npos) {
          hostEnd = requestUrl.length();
        }
        sourceOrigin = requestUrl.substr(0, hostEnd);
      }
    } catch (...) {}
  }

  // === Security Check 3: Origin Allow List ===
  // Match iOS: javaScriptHandlersOriginAllowList check
  bool isOriginAllowed = true;
  if (settings_ && settings_->javaScriptHandlersOriginAllowList.has_value()) {
    const auto& allowList = settings_->javaScriptHandlersOriginAllowList.value();
    if (!allowList.empty()) {
      isOriginAllowed = false;
      for (const auto& allowedOrigin : allowList) {
        // Simple substring/regex-like matching (iOS uses regex)
        if (!sourceOrigin.empty() && sourceOrigin.find(allowedOrigin) != std::string::npos) {
          isOriginAllowed = true;
          break;
        }
      }
    }
    // If allowList is empty, origin is allowed by default
  }
  // If javaScriptHandlersOriginAllowList is nullopt, origin is allowed by default (matches iOS)
  
  if (!isOriginAllowed) {
    g_warning("InAppWebView[%ld]: Bridge access attempt from an origin not allowed: %s",
              static_cast<long>(id_), sourceOrigin.c_str());
    return;
  }

  // === Multi-Window Support: Extract _windowId ===
  // Match iOS: let _windowId = body["_windowId"] as? Int64
  // The _windowId allows routing callbacks to the correct webview in multi-window scenarios
  std::optional<int64_t> windowId;
  if (bodyJson.contains("_windowId") && bodyJson["_windowId"].is_number()) {
    windowId = bodyJson["_windowId"].get<int64_t>();
  }
  
  // Get the target webview for this message
  // Match iOS: if let wId = _windowId, let webViewTransport = plugin?.inAppWebViewManager?.windowWebViews[wId]
  // For now, we use 'this' webview. When window management is implemented,
  // this should look up the webview by windowId from a global registry.
  InAppWebView* targetWebView = this;
  // TODO: When multi-window is fully implemented:
  // if (windowId.has_value()) {
  //   auto* manager = InAppWebViewManager::getInstance();
  //   if (manager && manager->hasWindowWebView(windowId.value())) {
  //     targetWebView = manager->getWindowWebView(windowId.value());
  //   }
  // }

  // For callHandler messages, extract the actual handler name from body
  std::string handlerName = name;
  if (name == "callHandler") {
    if (bodyJson.contains("handlerName") && bodyJson["handlerName"].is_string()) {
      handlerName = bodyJson["handlerName"].get<std::string>();
    }
    
    if (DebugLogEnabled()) {
      g_message("InAppWebView[%ld]: handleScriptMessage handlerName='%s' windowId=%s",
                static_cast<long>(id_), handlerName.c_str(),
                windowId.has_value() ? std::to_string(windowId.value()).c_str() : "null");
    }
  }

  // Extract _callHandlerID for callback
  int64_t callHandlerId = 0;
  if (bodyJson.contains("_callHandlerID") && bodyJson["_callHandlerID"].is_number()) {
    callHandlerId = bodyJson["_callHandlerID"].get<int64_t>();
  }

  // Extract args - it's already a JSON string
  std::string argsJsonStr = "";
  if (bodyJson.contains("args") && bodyJson["args"].is_string()) {
    argsJsonStr = bodyJson["args"].get<std::string>();
  }

  // === Handle Internal Handlers ===
  // Match iOS: switch(handlerName) for internal handlers
  // Use targetWebView for multi-window support
  bool isInternalHandler = true;
  
  if (handlerName == "onConsoleMessage") {
    // Handle console message interception (from console_log_js.h script)
    std::string message = "";
    std::string level = "log";
    
    // The args field contains a JSON-encoded string: [{"level":"log","message":"..."}]
    if (!argsJsonStr.empty()) {
      try {
        json argsJson = json::parse(argsJsonStr);
        // args is an array with a single object
        if (argsJson.is_array() && !argsJson.empty()) {
          json firstArg = argsJson[0];
          if (firstArg.contains("level") && firstArg["level"].is_string()) {
            level = firstArg["level"].get<std::string>();
          }
          if (firstArg.contains("message") && firstArg["message"].is_string()) {
            message = firstArg["message"].get<std::string>();
          }
        }
      } catch (const json::parse_error& e) {
        if (DebugLogEnabled()) {
          g_message("InAppWebView[%ld]: Failed to parse console args JSON: %s",
                    static_cast<long>(targetWebView->id_), e.what());
        }
      }
    }
    
    // Map level string to numeric value
    // Match iOS: case "log" -> 1, "debug" -> 0 (TIP), "error" -> 3, "info" -> 1, "warn" -> 2
    int64_t messageLevel = 1;  // LOG
    if (level == "debug") {
      messageLevel = 0;  // TIP (on Android, console.debug is TIP)
    } else if (level == "info" || level == "log") {
      messageLevel = 1;  // LOG
    } else if (level == "warn") {
      messageLevel = 2;  // WARNING
    } else if (level == "error") {
      messageLevel = 3;  // ERROR
    }
    
    if (DebugLogEnabled()) {
      g_message("InAppWebView[%ld]: console.%s: %s",
                static_cast<long>(targetWebView->id_), level.c_str(), message.c_str());
    }
    
    // Use targetWebView's channel delegate (for multi-window support)
    if (targetWebView->channel_delegate_) {
      targetWebView->channel_delegate_->onConsoleMessage(message, messageLevel);
    }
    // Fall through to resolve the internal handler
    
  } else if (handlerName == "onPrintRequest") {
    // TODO: Implement print request handling (matches iOS)
    if (DebugLogEnabled()) {
      g_message("InAppWebView[%ld]: onPrintRequest (not yet implemented)",
                static_cast<long>(targetWebView->id_));
    }
    
  } else if (handlerName == "onFindResultReceived") {
    // TODO: Implement find result handling (matches iOS)
    if (DebugLogEnabled()) {
      g_message("InAppWebView[%ld]: onFindResultReceived (not yet implemented)",
                static_cast<long>(targetWebView->id_));
    }
    
  } else {
    // Not an internal handler - will be sent to Dart
    isInternalHandler = false;
  }

  // === Resolve Internal Handlers ===
  // Match iOS: if isInternalHandler { evaluateJavaScript to resolve }
  if (isInternalHandler) {
    if (callHandlerId > 0) {
      std::string script =
          "if(window." + JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() + 
          "[" + std::to_string(callHandlerId) + "] != null) {\n"
          "    window." + JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() + 
          "[" + std::to_string(callHandlerId) + "].resolve();\n"
          "    delete window." + JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() + 
          "[" + std::to_string(callHandlerId) + "];\n"
          "}";

      // Resolve on the target webview
      webkit_web_view_evaluate_javascript(
          targetWebView->webview_, script.c_str(), static_cast<gssize>(script.length()),
          nullptr, nullptr, nullptr, nullptr, nullptr);
    }
    return;
  }

  // === External Handler - Send to Dart ===
  // Use targetWebView for multi-window support (matches iOS webView variable)
  if (DebugLogEnabled()) {
    g_message("InAppWebView[%ld]: callHandler '%s' origin=%s mainFrame=%d windowId=%s args=%.50s...",
              static_cast<long>(targetWebView->id_), handlerName.c_str(), sourceOrigin.c_str(), 
              isMainFrame, 
              windowId.has_value() ? std::to_string(windowId.value()).c_str() : "null",
              argsJsonStr.c_str());
  }

  // Notify Dart side via channel delegate
  // Use targetWebView's channel delegate for multi-window support
  if (targetWebView->channel_delegate_) {
    // Match iOS: JavaScriptHandlerFunctionData(args:, isMainFrame:, origin:, requestUrl:)
    auto data = std::make_unique<JavaScriptHandlerFunctionData>(
        sourceOrigin,
        requestUrl,
        isMainFrame,
        argsJsonStr);
    
    // Create callback to send response back to JavaScript
    // Match iOS: CallJsHandlerCallback with defaultBehaviour and error
    auto callback = std::make_unique<WebViewChannelDelegate::CallJsHandlerCallback>();
    
    int64_t capturedCallHandlerId = callHandlerId;
    InAppWebView* capturedTargetWebView = targetWebView;
    
    // Match iOS: callback.defaultBehaviour = { (response: Any?) in ... }
    callback->defaultBehaviour = [capturedTargetWebView, capturedCallHandlerId](const std::optional<FlValue*>& response) {
      if (capturedTargetWebView->webview_ == nullptr) return;

      std::string jsonResult = "null";
      if (response.has_value() && response.value() != nullptr) {
        FlValue* val = response.value();
        if (fl_value_get_type(val) == FL_VALUE_TYPE_STRING) {
          jsonResult = fl_value_get_string(val);
        }
      }

      // Match iOS: window.flutter_inappwebview[_callHandlerID].resolve(json)
      std::string script =
          "if(window." + JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() + 
          "[" + std::to_string(capturedCallHandlerId) + "] != null) {\n"
          "    window." + JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() + 
          "[" + std::to_string(capturedCallHandlerId) + "].resolve(" + jsonResult + ");\n"
          "    delete window." + JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() + 
          "[" + std::to_string(capturedCallHandlerId) + "];\n"
          "}";

      webkit_web_view_evaluate_javascript(
          capturedTargetWebView->webview_, script.c_str(), static_cast<gssize>(script.length()),
          nullptr, nullptr, nullptr, nullptr, nullptr);
    };
    
    // Match iOS: callback.error = { (code: String, message: String?, details: Any?) in ... }
    callback->error = [capturedTargetWebView, capturedCallHandlerId](const std::string& code,
                                                     const std::string& message) {
      if (capturedTargetWebView->webview_ == nullptr) return;

      // Match iOS: let errorMessage = code + (message != nil ? ", " + (message ?? "") : "")
      std::string errorMessage = code;
      if (!message.empty()) {
        errorMessage += ", " + message;
      }
      
      // Escape single quotes (match iOS: replacingOccurrences(of: "\'", with: "\\'"))
      std::string escapedMessage;
      for (char c : errorMessage) {
        if (c == '\'') {
          escapedMessage += "\\'";
        } else {
          escapedMessage += c;
        }
      }

      // Match iOS: window.flutter_inappwebview[_callHandlerID].reject(new Error(...))
      std::string script =
          "if(window." + JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() + 
          "[" + std::to_string(capturedCallHandlerId) + "] != null) {\n"
          "    window." + JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() + 
          "[" + std::to_string(capturedCallHandlerId) + "].reject(new Error('" + escapedMessage + "'));\n"
          "    delete window." + JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() + 
          "[" + std::to_string(capturedCallHandlerId) + "];\n"
          "}";

      webkit_web_view_evaluate_javascript(
          capturedTargetWebView->webview_, script.c_str(), static_cast<gssize>(script.length()),
          nullptr, nullptr, nullptr, nullptr, nullptr);
    };
    
    // Match iOS: channelDelegate.onCallJsHandler(handlerName:, data:, callback:)
    targetWebView->channel_delegate_->onCallJsHandler(handlerName, std::move(data), std::move(callback));
  }
}

void InAppWebView::dispatchPlatformReady() {
  std::string script = "window.dispatchEvent(new Event('flutterInAppWebViewPlatformReady'));";
  evaluateJavascript(script, nullptr);
}

void InAppWebView::initializeWindowIdJS() {
  // Match iOS: initializeWindowIdJS()
  // Injects JavaScript to set the window ID variable for multi-window support
  if (!window_id_.has_value()) {
    return;
  }
  
  int64_t windowId = window_id_.value();
  
  // Build the JavaScript to initialize the window ID
  // Match iOS: WindowIdJS.WINDOW_ID_INITIALIZE_JS_SOURCE().replacingOccurrences(of: VAR_PLACEHOLDER_VALUE, with: String(windowId))
  std::string script = R"JS(
(function() {
    )JS" + JavaScriptBridgeJS::WINDOW_ID_VARIABLE_JS_SOURCE() + R"JS( = )JS" + std::to_string(windowId) + R"JS(;
    return )JS" + JavaScriptBridgeJS::WINDOW_ID_VARIABLE_JS_SOURCE() + R"JS(;
})()
)JS";
  
  if (DebugLogEnabled()) {
    g_message("InAppWebView[%ld]: initializeWindowIdJS windowId=%ld",
              static_cast<long>(id_), static_cast<long>(windowId));
  }
  
  evaluateJavascript(script, nullptr);
}

void InAppWebView::OnExportShmBuffer(struct wpe_fdo_shm_exported_buffer* buffer) {
  if (buffer == nullptr) {
    if (DebugLogEnabled()) {
      g_message("InAppWebView[%ld]: OnExportShmBuffer called with null buffer",
                static_cast<long>(id_));
    }
    return;
  }

  // Get the wl_shm_buffer from the exported buffer
  struct wl_shm_buffer* shm_buffer = wpe_fdo_shm_exported_buffer_get_shm_buffer(buffer);
  if (shm_buffer == nullptr) {
    if (DebugLogEnabled()) {
      g_warning("InAppWebView[%ld]: Failed to get wl_shm_buffer", static_cast<long>(id_));
    }
    // Release the buffer
    if (exportable_ != nullptr) {
      wpe_view_backend_exportable_fdo_dispatch_release_shm_exported_buffer(exportable_, buffer);
    }
    return;
  }

  // Get buffer dimensions and data
  int32_t width = wl_shm_buffer_get_width(shm_buffer);
  int32_t height = wl_shm_buffer_get_height(shm_buffer);
  int32_t stride = wl_shm_buffer_get_stride(shm_buffer);
  uint32_t format = wl_shm_buffer_get_format(shm_buffer);

  if (DebugLogEnabled()) {
    static int shm_frame_count = 0;
    shm_frame_count++;
    if (shm_frame_count <= 5 || shm_frame_count % 60 == 0) {
      g_message("InAppWebView[%ld]: OnExportShmBuffer frame %d (%dx%d stride=%d format=0x%x)",
                static_cast<long>(id_), shm_frame_count, width, height, stride, format);
    }
  }

  // Begin access to buffer data
  wl_shm_buffer_begin_access(shm_buffer);
  void* data = wl_shm_buffer_get_data(shm_buffer);

  if (data != nullptr && width > 0 && height > 0) {
    // Copy to our pixel buffer
    // Note: stride is the row pitch in bytes (may include padding)
    
    size_t write_idx = write_buffer_index_.load(std::memory_order_relaxed);
    auto& pixel_buffer = pixel_buffers_[write_idx];
    
    // Use width*4 for tightly packed RGBA output (no stride padding)
    size_t output_row_size = static_cast<size_t>(width) * 4;
    size_t output_size = static_cast<size_t>(height) * output_row_size;
    
    if (pixel_buffer.data.size() != output_size) {
      pixel_buffer.data.resize(output_size);
    }
    
    pixel_buffer.width = static_cast<size_t>(width);
    pixel_buffer.height = static_cast<size_t>(height);
    
    // Convert from BGRA (WL_SHM_FORMAT_ARGB8888 in memory) to RGBA
    // Also handle stride properly
    uint8_t* src = static_cast<uint8_t*>(data);
    uint8_t* dst = pixel_buffer.data.data();
    
    for (int32_t y = 0; y < height; ++y) {
      uint8_t* src_row = src + y * stride;
      uint8_t* dst_row = dst + y * output_row_size;
      
      for (int32_t x = 0; x < width; ++x) {
        // Source is BGRA (WL_SHM_FORMAT_ARGB8888 on little-endian)
        uint8_t b = src_row[x * 4 + 0];
        uint8_t g = src_row[x * 4 + 1];
        uint8_t r = src_row[x * 4 + 2];
        uint8_t a = src_row[x * 4 + 3];
        
        // Destination is RGBA for Flutter
        dst_row[x * 4 + 0] = r;
        dst_row[x * 4 + 1] = g;
        dst_row[x * 4 + 2] = b;
        dst_row[x * 4 + 3] = a;
      }
    }
    
    // Swap buffers
    {
      std::lock_guard<std::mutex> lock(buffer_swap_mutex_);
      read_buffer_index_.store(write_idx, std::memory_order_release);
      write_buffer_index_.store((write_idx + 1) % kNumBuffers, std::memory_order_relaxed);
    }
  }

  // End access
  wl_shm_buffer_end_access(shm_buffer);

  // Release the buffer back to WPE
  if (exportable_ != nullptr) {
    wpe_view_backend_exportable_fdo_dispatch_release_shm_exported_buffer(exportable_, buffer);
    wpe_view_backend_exportable_fdo_dispatch_frame_complete(exportable_);
  }

  // Notify that a new frame is available
  if (on_frame_available_) {
    on_frame_available_();
  }
}

}  // namespace flutter_inappwebview_plugin

// C-style callback implementation for WPE FDO EGL export
// Must be outside the namespace for C API compatibility
extern "C" {
static void wpe_export_fdo_egl_image_callback(
    void* data, 
    struct wpe_fdo_egl_exported_image* image) {
  auto* self = static_cast<flutter_inappwebview_plugin::InAppWebView*>(data);
  self->OnExportDmaBuf(image);
}

static void wpe_export_shm_buffer_callback(
    void* data,
    struct wpe_fdo_shm_exported_buffer* buffer) {
  auto* self = static_cast<flutter_inappwebview_plugin::InAppWebView*>(data);
  self->OnExportShmBuffer(buffer);
}
}

