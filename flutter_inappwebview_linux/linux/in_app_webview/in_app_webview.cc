// WPE WebKit-based InAppWebView implementation
//
// This file provides offscreen web rendering using WPE WebKit.
// Supports two backend APIs:
// - WPEPlatform (HAVE_WPE_PLATFORM): New modern API for WPE WebKit 2.40+
// - WPEBackend-FDO (HAVE_WPE_BACKEND_LEGACY): Legacy API for older systems

#include "in_app_webview.h"

#include <dlfcn.h>
#include <linux/limits.h>
#include <unistd.h>

#include <algorithm>
#include <cmath>
#include <cstring>
#include <filesystem>
#include <limits>
#include <nlohmann/json.hpp>
#include <random>
#include <set>
#include <unordered_set>

// Use epoxy for OpenGL/EGL instead of direct headers to avoid conflicts
#include <epoxy/egl.h>
#include <epoxy/gl.h>

// WPEPlatform API (new modern API)
#ifdef HAVE_WPE_PLATFORM
#include <wpe/wpe-platform.h>
#include <wpe/headless/wpe-headless.h>
#include <wpe/WPEBufferSHM.h>  // For SHM software rendering fallback
#endif

// WPEBackend-FDO API (legacy)
#ifdef HAVE_WPE_BACKEND_LEGACY
#include <wayland-server.h>
#include <wpe/fdo-egl.h>
#include <wpe/unstable/fdo-shm.h>
#endif

// Cairo for PNG encoding (used by takeScreenshot)
#include <cairo.h>

#include "../plugin_scripts_js/color_input_js.h"
#include "../plugin_scripts_js/console_log_js.h"
#include "../plugin_scripts_js/cursor_detection_js.h"
#include "../plugin_scripts_js/date_input_js.h"
#include "../plugin_scripts_js/intercept_ajax_request_js.h"
#include "../plugin_scripts_js/intercept_fetch_request_js.h"
#include "../plugin_scripts_js/javascript_bridge_js.h"
#include "../plugin_scripts_js/on_load_resource_js.h"
#include "../plugin_scripts_js/print_interception_js.h"
#include "../plugin_scripts_js/web_message_channel_js.h"
#include "../plugin_scripts_js/web_message_listener_js.h"
#include "../types/client_cert_challenge.h"
#include "../types/client_cert_response.h"
#include "../types/create_window_action.h"
#include "../types/custom_scheme_response.h"
#include "../types/hit_test_result.h"
#include "../types/navigation_action.h"
#include "../types/server_trust_challenge.h"
#include "../types/web_resource_error.h"
#include "../types/web_resource_request.h"
#include "../types/web_view_transport.h"
#include "../credential_database.h"
#include "../flutter_inappwebview_linux_plugin_private.h"
#include "../plugin_instance.h"
#include "../utils/flutter.h"
#include "../utils/gl_context.h"
#include "../utils/log.h"
#include "../utils/uri.h"
#include "in_app_webview_manager.h"
#include "simd_convert.h"
#include "user_content_controller.h"
#include "webview_channel_delegate.h"
#include "../types/find_session.h"
#include "../web_message/web_message_channel.h"
#include "../web_message/web_message_listener.h"

using json = nlohmann::json;

// Forward declaration of InAppWebView for FileChooserContext
namespace flutter_inappwebview_plugin {
class InAppWebView;
}

// Context data for non-blocking file chooser dialog
// Defined early because HideFileChooser() needs access to members
struct FileChooserContext {
  WebKitFileChooserRequest* request;
  bool selectMultiple;
  flutter_inappwebview_plugin::InAppWebView* webview;  // Pointer to webview for tracking active dialog
  gulong response_handler_id;  // Signal handler ID for cleanup
  
  FileChooserContext(WebKitFileChooserRequest* req, bool multi, 
                     flutter_inappwebview_plugin::InAppWebView* wv)
      : request(req), selectMultiple(multi), webview(wv), response_handler_id(0) {
    g_object_ref(request);
  }
  
  ~FileChooserContext() {
    g_object_unref(request);
  }
};

// GDK for EGL display access
#include <gdk/gdk.h>
#ifdef GDK_WINDOWING_WAYLAND
#include <gdk/gdkwayland.h>
#endif
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif

// C-style callback functions outside the namespace for C API compatibility
#ifdef HAVE_WPE_BACKEND_LEGACY
extern "C" {
static void wpe_export_fdo_egl_image_callback(void* data, struct wpe_fdo_egl_exported_image* image);

static void wpe_export_shm_buffer_callback(void* data, struct wpe_fdo_shm_exported_buffer* buffer);
}
#endif

namespace flutter_inappwebview_plugin {

namespace {

// WPE modifier mask - matches wpe_input_modifier enum from wpe/input.h
// Control = bit 0 (1), Shift = bit 1 (2), Alt = bit 2 (4), Meta = bit 3 (8)
// These are not used directly in C++ code - modifiers come from Dart already in WPE format

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

}  // namespace

#ifdef HAVE_WPE_BACKEND_LEGACY
// Get the directory where the executable is located (only needed for legacy backend)
static std::string GetExecutableDir() {
  char path[PATH_MAX];
  ssize_t len = readlink("/proc/self/exe", path, sizeof(path) - 1);
  if (len != -1) {
    path[len] = '\0';
    std::string exe_path(path);
    size_t last_slash = exe_path.rfind('/');
    if (last_slash != std::string::npos) {
      return exe_path.substr(0, last_slash);
    }
  }
  return "";
}
#endif

bool InAppWebView::IsWpeWebKitAvailable() {
  static bool checked = false;
  static bool available = false;

  if (checked) {
    return available;
  }
  checked = true;

#ifdef HAVE_WPE_PLATFORM
  // WPEPlatform API: No loader initialization needed
  // The platform is initialized when we create a WPEDisplay
  debugLog("InAppWebView: Using WPEPlatform API (modern)");
  available = true;
#elif defined(HAVE_WPE_BACKEND_LEGACY)
  // Legacy WPEBackend-FDO: Need to initialize the loader
  // Try to load the WPE backend library
  // First, try to load from the bundled lib/ directory using the full path.
  std::string exe_dir = GetExecutableDir();
  if (!exe_dir.empty()) {
    std::string bundled_lib_path = exe_dir + "/lib/libWPEBackend-fdo-1.0.so.1";
    std::string bundled_lib_dir = exe_dir + "/lib";

    // Check if the bundled library exists
    if (access(bundled_lib_path.c_str(), F_OK) == 0) {
      // Set environment variables for the WPE WebProcess child process.
      setenv("WPE_BACKEND_LIBRARY", bundled_lib_path.c_str(), 0);

      // Also prepend the lib directory to LD_LIBRARY_PATH
      const char* current_ld_path = getenv("LD_LIBRARY_PATH");
      std::string new_ld_path = bundled_lib_dir;
      if (current_ld_path != nullptr && strlen(current_ld_path) > 0) {
        new_ld_path += ":";
        new_ld_path += current_ld_path;
      }
      setenv("LD_LIBRARY_PATH", new_ld_path.c_str(), 1);

      available = wpe_loader_init(bundled_lib_path.c_str()) != 0;
    }
  }

  // Fall back to system library if bundled version not found or failed to load
  if (!available) {
    available = wpe_loader_init("libWPEBackend-fdo-1.0.so.1") != 0;
  }
  
  if (available) {
    debugLog("InAppWebView: Using WPEBackend-FDO API (legacy)");
  }
#else
  #error "Neither HAVE_WPE_PLATFORM nor HAVE_WPE_BACKEND_LEGACY is defined"
#endif

  return available;
}

#ifdef HAVE_WPE_PLATFORM
// Check if DMA-BUF rendering should be used (called at WebView initialization)
// Returns true if DMA-BUF rendering is expected to work
// Note: The actual environment detection and LIBGL_ALWAYS_SOFTWARE setting
// is now done at plugin registration time via utils/software_rendering.h
bool InAppWebView::PreflightDmaBufSupport() {
  const char* sw_env = getenv("LIBGL_ALWAYS_SOFTWARE");
  if (sw_env && (strcmp(sw_env, "1") == 0 || strcasecmp(sw_env, "true") == 0)) {
    return false;  // Software rendering mode
  }
  return true;  // Hardware rendering mode
}
#endif

InAppWebView::InAppWebView(FlPluginRegistrar* registrar, FlBinaryMessenger* messenger, int64_t id,
                           const InAppWebViewCreationParams& params)
    : plugin_(params.plugin), registrar_(registrar), messenger_(messenger), gtk_window_(params.gtkWindow), fl_view_(params.flView), manager_(params.manager), id_(id), settings_(params.initialSettings),
      initial_user_scripts_(params.initialUserScripts) {
  js_bridge_secret_ = GenerateRandomSecret();
  
  if (params.windowId.has_value()) {
    window_id_ = params.windowId.value();
  }

  if (params.contextMenu.has_value()) {
    context_menu_config_ = params.contextMenu.value();
  }

  InitWpeBackend();
  InitWebView(params);
  RegisterEventHandlers();

  // Set up monitor change handlers and initial refresh rate (like Cog browser does)
  // This helps WPE synchronize frame production with the display
  SetupMonitorChangeHandlers();
  UpdateMonitorRefreshRate();

  if (settings_) {
    settings_->applyToWebView(webview_);
#ifdef HAVE_WPE_PLATFORM
    if (wpe_display_ != nullptr) {
      settings_->applyWpePlatformSettings(wpe_display_);
    }
#endif
  }

  RegisterCustomSchemes();

  // Apply content blockers if specified, then load initial content
  // Content blockers must be compiled asynchronously
  if (settings_ && settings_->contentBlockers != nullptr && content_blocker_handler_) {
    // Store initial load params for callback
    auto initialUrlRequest = params.initialUrlRequest;
    auto initialData = params.initialData;
    auto initialDataMimeType = params.initialDataMimeType;
    auto initialDataEncoding = params.initialDataEncoding;
    auto initialDataBaseUrl = params.initialDataBaseUrl;
    auto initialFile = params.initialFile;

    content_blocker_handler_->setContentBlockers(
        settings_->contentBlockers,
        [this, initialUrlRequest, initialData, initialDataMimeType, initialDataEncoding,
         initialDataBaseUrl, initialFile](bool success) {
          if (!success) {
            debugLog("InAppWebView: Content blockers failed to apply, loading content anyway");
          }

          // Now load initial content
          if (initialUrlRequest.has_value()) {
            loadUrl(initialUrlRequest.value());
          } else if (initialData.has_value()) {
            std::string mimeType = initialDataMimeType.value_or("text/html");
            std::string encoding = initialDataEncoding.value_or("UTF-8");
            std::string baseUrl = initialDataBaseUrl.value_or("about:blank");
            loadData(initialData.value(), mimeType, encoding, baseUrl);
          } else if (initialFile.has_value()) {
            loadFile(initialFile.value());
          }
        });
  } else {
    // No content blockers - load initial content immediately
    if (params.initialUrlRequest.has_value()) {
      auto& urlRequest = params.initialUrlRequest.value();
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
}

void InAppWebView::AttachChannel(FlBinaryMessenger* messenger, int64_t channel_id) {
  channel_id_ = channel_id;
  if (messenger == nullptr) {
    errorLog("InAppWebView: AttachChannel messenger is null");
    return;
  }

  std::string channelName = std::string(METHOD_CHANNEL_NAME_PREFIX) + std::to_string(channel_id_);
  channel_delegate_ = std::make_unique<WebViewChannelDelegate>(this, messenger, channelName);

  if (findInteractionController_) {
    findInteractionController_->attachChannel(messenger, std::to_string(channel_id_));
  }
}

void InAppWebView::AttachChannel(FlBinaryMessenger* messenger, const std::string& channel_id, const bool is_full_channel_name) {
  string_channel_id_ = channel_id;
  if (messenger == nullptr) {
    errorLog("InAppWebView: AttachChannel messenger is null");
    return;
  }

  // Determine the channel name:
  // - If is_full_channel_name (InAppBrowser case), use it directly
  // - If channel_id is just an ID (HeadlessInAppWebView case), prepend the prefix
  std::string channelName;
  if (is_full_channel_name) {
    // Already has the prefix (InAppBrowser passes full channel name)
    channelName = channel_id;
  } else {
    // Just an ID, prepend the prefix (HeadlessInAppWebView case)
    channelName = std::string(METHOD_CHANNEL_NAME_PREFIX) + channel_id;
  }
  channel_delegate_ = std::make_unique<WebViewChannelDelegate>(this, messenger, channelName);

  if (findInteractionController_) {
    findInteractionController_->attachChannel(messenger, channel_id);
  }
}

InAppWebView::~InAppWebView() {
  debugLog("dealloc InAppWebView");

  CleanupMonitorChangeHandlers();

  context_menu_popup_.reset();

  if (findInteractionController_) {
    findInteractionController_->dispose();
    findInteractionController_.reset();
  }

  if (pending_context_menu_ != nullptr) {
    g_object_unref(pending_context_menu_);
    pending_context_menu_ = nullptr;
  }
  if (pending_hit_test_result_ != nullptr) {
    g_object_unref(pending_hit_test_result_);
    pending_hit_test_result_ = nullptr;
  }

  if (last_hit_test_result_ != nullptr) {
    g_object_unref(last_hit_test_result_);
    last_hit_test_result_ = nullptr;
  }

  // Disconnect download-started signal from NetworkSession before destroying webview
  if (webview_ != nullptr && download_started_handler_id_ != 0) {
    WebKitNetworkSession* network_session = webkit_web_view_get_network_session(webview_);
    if (network_session != nullptr) {
      g_signal_handler_disconnect(network_session, download_started_handler_id_);
    }
    download_started_handler_id_ = 0;
  }

  for (auto& pair : web_message_channels_) {
    if (pair.second) {
      pair.second->dispose();
    }
  }
  web_message_channels_.clear();

  for (auto& pair : web_message_listeners_) {
    if (pair.second) {
      pair.second->dispose();
    }
  }
  web_message_listeners_.clear();

  // IMPORTANT: Clean up user content controller FIRST while webview is still valid
  // The UserContentController destructor needs access to WebKit's user content manager
  // which becomes invalid after we unref the webview
  user_content_controller_.reset();

  // IMPORTANT: Clean up content blocker handler BEFORE the webview is destroyed
  // The ContentBlockerHandler destructor calls removeAllFilters which needs a valid content manager
  content_blocker_handler_.reset();

  for (auto& pair : pending_policy_decisions_) {
    webkit_policy_decision_ignore(pair.second);
    g_object_unref(pair.second);
  }
  pending_policy_decisions_.clear();

#ifdef HAVE_WPE_PLATFORM
  // === WPEPlatform proper shutdown sequence ===
  // Mark as disposing to prevent buffer callbacks from processing
  is_disposing_.store(true);
  
  // 1. First disconnect signals to stop receiving callbacks
  if (wpe_view_ != nullptr && buffer_rendered_handler_ != 0) {
    g_signal_handler_disconnect(wpe_view_, buffer_rendered_handler_);
    buffer_rendered_handler_ = 0;
  }
  // Note: scale_changed_handler_ is connected to gtk_window_, not wpe_view_
  if (gtk_window_ != nullptr && scale_changed_handler_ != 0) {
    g_signal_handler_disconnect(gtk_window_, scale_changed_handler_);
    scale_changed_handler_ = 0;
  }
  
  if (wpe_view_ != nullptr) {
    wpe_view_focus_out(wpe_view_);
  }
  
  if (wpe_view_ != nullptr) {
    wpe_view_unmap(wpe_view_);
  }
  
  // 4. Release any pending buffer back to WPE and clean up EGL image
  {
    std::lock_guard<std::mutex> lock(wpe_buffer_mutex_);
    
    // Clean up EGL image first (while display is still valid)
    if (current_egl_image_ != nullptr && egl_display_ != nullptr) {
      static PFNEGLDESTROYIMAGEKHRPROC eglDestroyImageKHR = nullptr;
      if (eglDestroyImageKHR == nullptr) {
        eglDestroyImageKHR = (PFNEGLDESTROYIMAGEKHRPROC)eglGetProcAddress("eglDestroyImageKHR");
      }
      if (eglDestroyImageKHR != nullptr) {
        eglDestroyImageKHR(static_cast<EGLDisplay>(egl_display_), 
                           static_cast<EGLImageKHR>(current_egl_image_));
      }
      current_egl_image_ = nullptr;
    }
    
    // Release pending buffer back to WPE
    if (current_buffer_ != nullptr && wpe_view_ != nullptr) {
      wpe_view_buffer_released(wpe_view_, current_buffer_);
    }
    current_buffer_ = nullptr;
    current_buffer_width_ = 0;
    current_buffer_height_ = 0;
  }
  
  if (wpe_view_ != nullptr) {
    wpe_view_closed(wpe_view_);
  }
  
  wpe_view_ = nullptr;
  wpe_toplevel_ = nullptr;
  
  if (webview_ != nullptr) {
    g_object_unref(webview_);
    webview_ = nullptr;
  }
  
  if (wpe_display_ != nullptr) {
    g_object_unref(wpe_display_);
    wpe_display_ = nullptr;
  }
  
  egl_display_ = nullptr;
#elif defined(HAVE_WPE_BACKEND_LEGACY)
  {
    std::lock_guard<std::mutex> lock(exported_image_mutex_);
    if (exported_image_ != nullptr && exportable_ != nullptr) {
      ::wpe_view_backend_exportable_fdo_egl_dispatch_release_exported_image(exportable_,
                                                                            exported_image_);
      exported_image_ = nullptr;
    }
  }

  if (webview_ != nullptr) {
    g_object_unref(webview_);
    webview_ = nullptr;
  }
#endif
}

void InAppWebView::InitWpeBackend() {
  if (!IsWpeWebKitAvailable()) {
    errorLog("InAppWebView: WPE WebKit not available");
    return;
  }

#ifdef HAVE_WPE_PLATFORM
  // === WPEPlatform API (Modern) ===
  
  // NOTE: The DMA-BUF preflight check and LIBGL_ALWAYS_SOFTWARE setup
  // is now done at plugin registration time via RunEarlyPreflightCheck().
  // This ensures the environment is set BEFORE any WPEDisplay is created.
  
  // Create a headless display for offscreen rendering
  GError* error = nullptr;
  
  wpe_display_ = wpe_display_headless_new();
  if (wpe_display_ == nullptr) {
    errorLog("InAppWebView: Failed to create WPEDisplayHeadless");
    return;
  }
  
  // Connect the display
  if (!wpe_display_connect(wpe_display_, &error)) {
    errorLog("InAppWebView: Failed to connect WPEDisplay: " + 
             std::string(error ? error->message : "unknown"));
    g_clear_error(&error);
    g_clear_object(&wpe_display_);
    return;
  }
  
  // Get EGL display from WPEDisplay for texture operations
  egl_display_ = wpe_display_get_egl_display(wpe_display_, &error);
  if (egl_display_ == nullptr) {
    // Software rendering mode - no EGL display available
    g_clear_error(&error);
  }
  
  // Note: The WebView will be created in InitWebView() using the "display" property
  // WPEView and WPEToplevel are obtained from the WebView after creation
  
#elif defined(HAVE_WPE_BACKEND_LEGACY)
  // === WPEBackend-FDO API (Legacy) ===
  
  // Get EGL display from GDK
  EGLDisplay egl_display = EGL_NO_DISPLAY;
  GdkDisplay* gdk_display = gdk_display_get_default();

  if (gdk_display != nullptr) {
#ifdef GDK_WINDOWING_WAYLAND
    if (GDK_IS_WAYLAND_DISPLAY(gdk_display)) {
      struct wl_display* wl_display = gdk_wayland_display_get_wl_display(gdk_display);
      if (wl_display != nullptr) {
        egl_display = eglGetDisplay((EGLNativeDisplayType)wl_display);
      }
    }
#endif
#ifdef GDK_WINDOWING_X11
    if (egl_display == EGL_NO_DISPLAY && GDK_IS_X11_DISPLAY(gdk_display)) {
      Display* x11_display = gdk_x11_display_get_xdisplay(gdk_display);
      if (x11_display != nullptr) {
        egl_display = eglGetDisplay((EGLNativeDisplayType)x11_display);
      }
    }
#endif
  }

  // If we couldn't get an EGL display, try the default
  if (egl_display == EGL_NO_DISPLAY) {
    egl_display = eglGetDisplay(EGL_DEFAULT_DISPLAY);
  }

  // Initialize EGL if needed
  if (egl_display != EGL_NO_DISPLAY) {
    EGLint major, minor;
    if (!eglInitialize(egl_display, &major, &minor)) {
      errorLog("InAppWebView: Failed to initialize EGL");
      egl_display = EGL_NO_DISPLAY;
    }
  }

  egl_display_ = egl_display;

  // Initialize WPE FDO with the EGL display
  if (!wpe_fdo_initialize_for_egl_display(egl_display)) {
    errorLog("InAppWebView: Failed to initialize WPE FDO");
    // Try again with headless mode
    if (!wpe_fdo_initialize_for_egl_display(EGL_NO_DISPLAY)) {
      errorLog("InAppWebView: Failed to initialize WPE FDO in headless mode");
    }
  }

  // Create the exportable backend for DMA-BUF export
  static struct wpe_view_backend_exportable_fdo_egl_client exportable_client = {
      nullptr,  // export_egl_image callback (legacy)
      wpe_export_fdo_egl_image_callback,  // export_fdo_egl_image callback
      wpe_export_shm_buffer_callback,     // export_shm_buffer callback
      nullptr, nullptr  // reserved
  };

  exportable_ =
      wpe_view_backend_exportable_fdo_egl_create(&exportable_client, this, width_, height_);

  if (exportable_ == nullptr) {
    errorLog("InAppWebView: Failed to create WPE exportable backend");
    return;
  }

  wpe_backend_ = wpe_view_backend_exportable_fdo_get_view_backend(exportable_);

  // Create WebKit backend wrapper
  backend_ = webkit_web_view_backend_new(
      wpe_backend_,
      [](gpointer data) {
        auto* exportable = static_cast<struct wpe_view_backend_exportable_fdo*>(data);
        wpe_view_backend_exportable_fdo_destroy(exportable);
      },
      exportable_);

  wpe_view_backend_dispatch_set_device_scale_factor(wpe_backend_, scale_factor_);

  // Set initial activity state
  wpe_view_backend_add_activity_state(wpe_backend_, wpe_view_activity_state_visible);
  wpe_view_backend_add_activity_state(wpe_backend_, wpe_view_activity_state_in_window);
  wpe_view_backend_add_activity_state(wpe_backend_, wpe_view_activity_state_focused);

  // Set up fullscreen handler for DOM fullscreen requests
  wpe_view_backend_set_fullscreen_handler(
      wpe_backend_,
      [](void* data, bool fullscreen) -> bool {
        auto* self = static_cast<InAppWebView*>(data);
        return self->OnDomFullscreenRequest(fullscreen);
      },
      this);

  // Set up pointer lock handler for games/immersive applications
  wpe_view_backend_set_pointer_lock_handler(
      wpe_backend_,
      [](void* data, bool lock) -> bool {
        auto* self = static_cast<InAppWebView*>(data);
        return self->OnPointerLockRequest(lock);
      },
      this);
#endif
}

void InAppWebView::InitWebView(const InAppWebViewCreationParams& params) {
#ifdef HAVE_WPE_PLATFORM
  // === WPEPlatform API ===
  // With WPEPlatform, we pass the "display" property to create the WebView
  // The WPEView is automatically created by WebKit
  
  if (wpe_display_ == nullptr) {
    errorLog("InAppWebView: Cannot create webview without WPEDisplay");
    return;
  }
  
  // Create WebKit settings
  WebKitSettings* settings = webkit_settings_new();
  
  bool useIncognito = params.initialSettings && params.initialSettings->incognito;
  WebKitNetworkSession* networkSession = nullptr;
  
  if (useIncognito) {
    networkSession = webkit_network_session_new_ephemeral();
    debugLog("InAppWebView: Creating WebView with ephemeral (incognito) network session");
  }
  
  WebKitWebContext* webContext = params.webContext;
  
  // Check if we're creating a related webview (for multi-window support)
  if (params.relatedWebView != nullptr) {
    webview_ = WEBKIT_WEB_VIEW(g_object_new(WEBKIT_TYPE_WEB_VIEW,
        "display", wpe_display_,
        "user-content-manager", webkit_web_view_get_user_content_manager(params.relatedWebView),
        "settings", webkit_web_view_get_settings(params.relatedWebView),
        "related-view", params.relatedWebView,
        nullptr));
  } else if (webContext != nullptr) {
    if (networkSession != nullptr) {
      webview_ = WEBKIT_WEB_VIEW(g_object_new(WEBKIT_TYPE_WEB_VIEW,
          "display", wpe_display_,
          "web-context", webContext,
          "network-session", networkSession,
          "settings", settings,
          nullptr));
    } else {
      webview_ = WEBKIT_WEB_VIEW(g_object_new(WEBKIT_TYPE_WEB_VIEW,
          "display", wpe_display_,
          "web-context", webContext,
          "settings", settings,
          nullptr));
    }
  } else if (networkSession != nullptr) {
    webview_ = WEBKIT_WEB_VIEW(g_object_new(WEBKIT_TYPE_WEB_VIEW,
        "display", wpe_display_,
        "network-session", networkSession,
        "settings", settings,
        nullptr));
  } else {
    webview_ = WEBKIT_WEB_VIEW(g_object_new(WEBKIT_TYPE_WEB_VIEW,
        "display", wpe_display_,
        "settings", settings,
        nullptr));
  }
  
  g_object_unref(settings);
  
  if (webview_ == nullptr) {
    errorLog("InAppWebView: Failed to create WebKitWebView with WPEPlatform");
    if (networkSession != nullptr) {
      g_object_unref(networkSession);
    }
    return;
  }
  
  // Get WPEView from the WebView (created automatically by WebKit)
  wpe_view_ = webkit_web_view_get_wpe_view(webview_);
  if (wpe_view_ == nullptr) {
    errorLog("InAppWebView: Failed to get WPEView from WebView");
    g_object_unref(webview_);
    webview_ = nullptr;
    return;
  }
  
  // Note: Scale factor in WPEPlatform is read from the display, not set directly
  // The WPEDisplay handles scale factor automatically based on the output
  
  // IMPORTANT: Connect to buffer-rendered signal BEFORE mapping the view
  // This ensures we don't miss the first frame that WPE renders after mapping
  buffer_rendered_handler_ = g_signal_connect(wpe_view_, "buffer-rendered",
      G_CALLBACK(+[](WPEView* view, WPEBuffer* buffer, gpointer user_data) {
        auto* self = static_cast<InAppWebView*>(user_data);
        self->OnWpePlatformBufferRendered(buffer);
      }), this);
  
  // Get toplevel for size management (need this before setting scale)
  wpe_toplevel_ = wpe_view_get_toplevel(wpe_view_);
  
  // WPEDisplayHeadless doesn't track real display scale, so we need to get it from GTK
  // and manually notify WPE when it changes
  if (gtk_window_ != nullptr) {
    // Get initial scale from GTK window (which tracks the actual display scale)
    int gtk_scale = gtk_widget_get_scale_factor(GTK_WIDGET(gtk_window_));
    if (gtk_scale > 0 && static_cast<double>(gtk_scale) != scale_factor_) {
      scale_factor_ = static_cast<double>(gtk_scale);
      // Notify WPE about the real display scale
      if (wpe_toplevel_ != nullptr) {
        wpe_toplevel_scale_changed(wpe_toplevel_, scale_factor_);
      }
    }
    
    // Connect to GTK window's scale-factor changes (triggered for example by Ubuntu display settings)
    scale_changed_handler_ = g_signal_connect(gtk_window_, "notify::scale-factor",
        G_CALLBACK(+[](GObject* object, GParamSpec* pspec, gpointer user_data) {
          auto* self = static_cast<InAppWebView*>(user_data);
          auto* widget = GTK_WIDGET(object);
          int new_scale = gtk_widget_get_scale_factor(widget);
          
          if (new_scale > 0 && static_cast<double>(new_scale) != self->scale_factor_) {
            self->scale_factor_ = static_cast<double>(new_scale);
            
            // Notify WPE about the scale change so it renders at the correct resolution
            if (self->wpe_toplevel_ != nullptr) {
              wpe_toplevel_scale_changed(self->wpe_toplevel_, self->scale_factor_);
            }
            
            // Notify Flutter that dimensions may have changed
            if (self->on_frame_available_) {
              self->on_frame_available_();
            }
          }
        }), this);
  } else {
    debugLog("Warning: No GTK window available for scale detection");
  }
  
  // Map the view to start rendering
  wpe_view_map(wpe_view_);
  
  // Set focus so the view starts rendering and receiving input
  wpe_view_focus_in(wpe_view_);
  
  // Resize toplevel (already obtained earlier for scale setup)
  if (wpe_toplevel_ != nullptr) {
    wpe_toplevel_resize(wpe_toplevel_, width_, height_);
  }
  
  // Apply ITP setting if configured
  if (params.initialSettings != nullptr) {
    WebKitNetworkSession* session = webkit_web_view_get_network_session(webview_);
    if (session != nullptr && params.initialSettings->itpEnabled) {
      webkit_network_session_set_itp_enabled(session, TRUE);
    }
  }
  
#elif defined(HAVE_WPE_BACKEND_LEGACY)
  // === WPEBackend-FDO API (Legacy) ===
  
  if (backend_ == nullptr) {
    errorLog("InAppWebView: Cannot create webview without backend");
    return;
  }

  // Check if we're creating a related webview (for multi-window support)
  if (params.relatedWebView != nullptr) {
    webview_ = WEBKIT_WEB_VIEW(g_object_new(WEBKIT_TYPE_WEB_VIEW,
        "backend", backend_,
        "user-content-manager", webkit_web_view_get_user_content_manager(params.relatedWebView),
        "settings", webkit_web_view_get_settings(params.relatedWebView),
        "related-view", params.relatedWebView,
        nullptr));
    
    if (webview_ == nullptr) {
      errorLog("InAppWebView: Failed to create related WebKitWebView");
      return;
    }
  } else {
    // Create WebKit settings for a standalone webview
    WebKitSettings* settings = webkit_settings_new();

    // Check if incognito mode is enabled
    bool useIncognito = params.initialSettings && params.initialSettings->incognito;
    WebKitNetworkSession* networkSession = nullptr;

    if (useIncognito) {
      networkSession = webkit_network_session_new_ephemeral();
      debugLog("InAppWebView: Creating WebView with ephemeral (incognito) network session");
    }

    // Check if a custom WebKitWebContext is provided
    WebKitWebContext* webContext = params.webContext;

    if (webContext != nullptr) {
      debugLog("InAppWebView: Creating WebView with custom WebKitWebContext");
      
      if (networkSession != nullptr) {
        webview_ = WEBKIT_WEB_VIEW(g_object_new(WEBKIT_TYPE_WEB_VIEW,
            "backend", backend_,
            "web-context", webContext,
            "network-session", networkSession,
            nullptr));
      } else {
        webview_ = WEBKIT_WEB_VIEW(g_object_new(WEBKIT_TYPE_WEB_VIEW,
            "backend", backend_,
            "web-context", webContext,
            nullptr));
      }
    } else if (networkSession != nullptr) {
      webview_ = WEBKIT_WEB_VIEW(g_object_new(WEBKIT_TYPE_WEB_VIEW,
          "backend", backend_,
          "network-session", networkSession,
          nullptr));
    } else {
      webview_ = webkit_web_view_new(backend_);
    }

    if (webview_ == nullptr) {
      errorLog("InAppWebView: Failed to create WebKitWebView");
      if (settings != nullptr) {
        g_object_unref(settings);
      }
      if (networkSession != nullptr) {
        g_object_unref(networkSession);
      }
      return;
    }

    if (params.initialSettings != nullptr) {
      WebKitNetworkSession* session = webkit_web_view_get_network_session(webview_);
      if (session != nullptr && params.initialSettings->itpEnabled) {
        webkit_network_session_set_itp_enabled(session, TRUE);
        debugLog("InAppWebView: ITP enabled");
      }
    }

    webkit_web_view_set_settings(webview_, settings);
    g_object_unref(settings);
  }
#endif

  // === Common initialization (both APIs) ===
  
  WebKitColor bg = {1.0, 1.0, 1.0, 1.0};
  webkit_web_view_set_background_color(webview_, &bg);

  user_content_controller_ = std::make_unique<UserContentController>(webview_);

  findInteractionController_ = std::make_unique<FindInteractionController>(this);

  // Create content blocker handler for Safari-style content blocking rules
  WebKitUserContentManager* content_manager = webkit_web_view_get_user_content_manager(webview_);
  if (content_manager != nullptr) {
    content_blocker_handler_ = std::make_unique<ContentBlockerHandler>(content_manager);
  }
}

void InAppWebView::RegisterEventHandlers() {
  if (webview_ == nullptr) {
    return;
  }

  // Set up the script message handler callback
  if (user_content_controller_) {
    // Set up handler callback for the callHandler message handler
    // The registration is done via messageHandlerNames in plugin scripts (javascript_bridge_js.h)
    // This uses the with_reply API for proper Promise resolution in iframes
    user_content_controller_->setScriptMessageWithReplyHandler("callHandler",
        [this](const std::string& body, WebKitScriptMessageReply* reply) -> bool {
          return handleScriptMessageWithReply(body, reply);
        });

    // Add plugin scripts based on settings
    // The plugin scripts register their message handlers via messageHandlerNames
    PrepareAndAddUserScripts();
  }

  g_signal_connect(webview_, "load-changed", G_CALLBACK(OnLoadChanged), this);
  g_signal_connect(webview_, "decide-policy", G_CALLBACK(OnDecidePolicy), this);
  g_signal_connect(webview_, "notify::estimated-load-progress",
                   G_CALLBACK(OnNotifyEstimatedLoadProgress), this);
  g_signal_connect(webview_, "notify::title", G_CALLBACK(OnNotifyTitle), this);
  g_signal_connect(webview_, "notify::uri", G_CALLBACK(OnNotifyUri), this);
  g_signal_connect(webview_, "load-failed", G_CALLBACK(OnLoadFailed), this);
  g_signal_connect(webview_, "load-failed-with-tls-errors", G_CALLBACK(OnLoadFailedWithTlsErrors),
                   this);
  g_signal_connect(webview_, "close", G_CALLBACK(OnCloseRequest), this);
  g_signal_connect(webview_, "script-dialog", G_CALLBACK(OnScriptDialog), this);
  g_signal_connect(webview_, "permission-request", G_CALLBACK(OnPermissionRequest), this);
  g_signal_connect(webview_, "authenticate", G_CALLBACK(OnAuthenticate), this);
  g_signal_connect(webview_, "context-menu", G_CALLBACK(OnContextMenu), this);
  g_signal_connect(webview_, "context-menu-dismissed", G_CALLBACK(OnContextMenuDismissed), this);
  g_signal_connect(webview_, "enter-fullscreen", G_CALLBACK(OnEnterFullscreen), this);
  g_signal_connect(webview_, "leave-fullscreen", G_CALLBACK(OnLeaveFullscreen), this);
  g_signal_connect(webview_, "mouse-target-changed", G_CALLBACK(OnMouseTargetChanged), this);
  g_signal_connect(webview_, "create", G_CALLBACK(OnCreateWebView), this);
  g_signal_connect(webview_, "web-process-terminated", G_CALLBACK(OnWebProcessTerminated), this);
  g_signal_connect(webview_, "run-file-chooser", G_CALLBACK(OnRunFileChooser), this);
  g_signal_connect(webview_, "show-option-menu", G_CALLBACK(OnShowOptionMenu), this);

  // Connect to download-started signal on NetworkSession (WPE WebKit 2.40+ API)
  // Note: In WPE WebKit, download-started is on NetworkSession, not WebView
  WebKitNetworkSession* network_session = webkit_web_view_get_network_session(webview_);
  if (network_session != nullptr) {
    download_started_handler_id_ = g_signal_connect(network_session, "download-started", G_CALLBACK(OnDownloadStarted), this);
  }

  // Connect to back-forward-list changed signal for navigation state updates
  // This enables InAppBrowser back/forward button state tracking
  WebKitBackForwardList* bfList = webkit_web_view_get_back_forward_list(webview_);
  if (bfList != nullptr) {
    g_signal_connect(bfList, "changed", G_CALLBACK(OnBackForwardListChanged), this);
  }

  // Connect to notify::camera-capture-state signal for onCameraCaptureStateChanged
  // Available since WPE WebKit 2.34
  g_signal_connect(webview_, "notify::camera-capture-state",
                   G_CALLBACK(OnNotifyCameraCaptureState), this);

  // Connect to notify::microphone-capture-state signal for onMicrophoneCaptureStateChanged
  // Available since WPE WebKit 2.34
  g_signal_connect(webview_, "notify::microphone-capture-state",
                   G_CALLBACK(OnNotifyMicrophoneCaptureState), this);

  webkit_web_view_add_frame_displayed_callback(
      webview_,
      [](WebKitWebView*, gpointer data) {
        auto* self = static_cast<InAppWebView*>(data);
        self->OnFrameDisplayed(data);
      },
      this, nullptr);
}

void InAppWebView::PrepareAndAddUserScripts() {
  if (user_content_controller_ == nullptr) {
    return;
  }

  bool javaScriptBridgeEnabled = java_script_bridge_enabled_;
  if (settings_) {
    javaScriptBridgeEnabled = settings_->javaScriptBridgeEnabled;
  }

  if (!javaScriptBridgeEnabled) {
    return;
  }

  // Get plugin scripts settings
  std::optional<std::vector<std::string>> pluginScriptsOriginAllowList = std::nullopt;
  bool pluginScriptsForMainFrameOnly = false;

  if (settings_) {
    pluginScriptsOriginAllowList = settings_->pluginScriptsOriginAllowList;
    pluginScriptsForMainFrameOnly = settings_->pluginScriptsForMainFrameOnly;
  }

  // Get JavaScript bridge-specific settings
  // If javaScriptBridgeOriginAllowList is not set, fall back to pluginScriptsOriginAllowList
  std::optional<std::vector<std::string>> javaScriptBridgeOriginAllowList = pluginScriptsOriginAllowList;
  bool javaScriptBridgeForMainFrameOnly = pluginScriptsForMainFrameOnly;

  if (settings_) {
    if (settings_->javaScriptBridgeOriginAllowList.has_value()) {
      javaScriptBridgeOriginAllowList = settings_->javaScriptBridgeOriginAllowList;
    }
    if (settings_->javaScriptBridgeForMainFrameOnly.has_value()) {
      javaScriptBridgeForMainFrameOnly = settings_->javaScriptBridgeForMainFrameOnly.value();
    }
  }

  // === Add JavaScript Bridge Plugin Script ===
  // This is the core bridge for communication between web content and native code
  auto jsBridgeScript = JavaScriptBridgeJS::JAVASCRIPT_BRIDGE_JS_PLUGIN_SCRIPT(
      js_bridge_secret_, javaScriptBridgeOriginAllowList, javaScriptBridgeForMainFrameOnly);
  user_content_controller_->addPluginScript(std::move(jsBridgeScript));

  // === Add Console Log Interception Script ===
  // Note: Console log is always for main frame only to avoid issues
  // (see https://github.com/pichillilorenzo/flutter_inappwebview/issues/1738)
  auto consoleLogScript = ConsoleLogJS::CONSOLE_LOG_JS_PLUGIN_SCRIPT(pluginScriptsOriginAllowList);
  user_content_controller_->addPluginScript(std::move(consoleLogScript));

  // === Add Color Input Interception Script ===
  // WPE WebKit doesn't have the run-color-chooser signal, so we handle <input type="color">
  // via JavaScript interception
  auto colorInputScript =
      ColorInputJS::COLOR_INPUT_JS_PLUGIN_SCRIPT(pluginScriptsOriginAllowList, pluginScriptsForMainFrameOnly);
  user_content_controller_->addPluginScript(std::move(colorInputScript));

  // === Add Date Input Interception Script ===
  // WPE WebKit doesn't have date picker support, so we handle <input type="date/time/etc.>
  // via JavaScript interception
  auto dateInputScript =
      DateInputJS::DATE_INPUT_JS_PLUGIN_SCRIPT(pluginScriptsOriginAllowList, pluginScriptsForMainFrameOnly);
  user_content_controller_->addPluginScript(std::move(dateInputScript));

  // === Add Cursor Detection Script ===
  // WPE WebKit renders offscreen so we detect cursor style via JavaScript
  // This script handles CSS cursor detection and intelligent "auto" cursor resolution
  auto cursorDetectionScript =
      CursorDetectionJS::CURSOR_DETECTION_JS_PLUGIN_SCRIPT(pluginScriptsOriginAllowList, pluginScriptsForMainFrameOnly);
  user_content_controller_->addPluginScript(std::move(cursorDetectionScript));

  // === Add OnLoadResource Script ===
  // Uses PerformanceObserver API to track resource loading
  if (settings_ != nullptr && settings_->useOnLoadResource) {
    auto onLoadResourceScript = OnLoadResourceJS::ON_LOAD_RESOURCE_JS_PLUGIN_SCRIPT(
        pluginScriptsOriginAllowList, pluginScriptsForMainFrameOnly);
    user_content_controller_->addPluginScript(std::move(onLoadResourceScript));
  }

  // === Add AJAX Request Interception Script ===
  // Intercepts XMLHttpRequest calls for shouldInterceptAjaxRequest, onAjaxReadyStateChange, onAjaxProgress
  if (settings_ != nullptr && settings_->useShouldInterceptAjaxRequest) {
    auto ajaxInterceptScript = InterceptAjaxRequestJS::INTERCEPT_AJAX_REQUEST_JS_PLUGIN_SCRIPT(
        pluginScriptsOriginAllowList,
        pluginScriptsForMainFrameOnly,
        settings_->useOnAjaxReadyStateChange,
        settings_->useOnAjaxProgress);
    user_content_controller_->addPluginScript(std::move(ajaxInterceptScript));
  }

  // === Add Fetch Request Interception Script ===
  // Intercepts fetch() calls for shouldInterceptFetchRequest
  if (settings_ != nullptr && settings_->useShouldInterceptFetchRequest) {
    auto fetchInterceptScript = InterceptFetchRequestJS::INTERCEPT_FETCH_REQUEST_JS_PLUGIN_SCRIPT(
        pluginScriptsOriginAllowList, pluginScriptsForMainFrameOnly);
    user_content_controller_->addPluginScript(std::move(fetchInterceptScript));
  }

  // === Add Print Interception Script ===
  // WPE WebKit doesn't have a native print signal, so we intercept window.print()
  // via JavaScript and notify the Dart side
  auto printInterceptionScript = PrintInterceptionJS::PRINT_INTERCEPTION_JS_PLUGIN_SCRIPT(
      pluginScriptsOriginAllowList, pluginScriptsForMainFrameOnly);
  user_content_controller_->addPluginScript(std::move(printInterceptionScript));

  // TODO: Add additional plugin scripts as needed:
  // - FindTextHighlightJS
  // - etc.

  // === Add Initial User Scripts ===
  // These are scripts passed via initialUserScripts parameter from Dart
  for (const auto& userScript : initial_user_scripts_) {
    user_content_controller_->addUserScript(userScript);
  }
}

// === Monitor Change Handlers ===

void InAppWebView::SetupMonitorChangeHandlers() {
  if (registrar_ == nullptr) {
    return;
  }

  // Get the GdkDisplay to connect to monitors-changed signal
  GdkDisplay* display = gdk_display_get_default();
  if (display != nullptr) {
    // Connect to monitors-changed signal on the display
    // This fires when monitors are added, removed, or their properties change
    monitors_changed_handler_id_ = g_signal_connect(
        display, "monitor-added",
        G_CALLBACK(+[](GdkDisplay*, GdkMonitor*, gpointer user_data) {
          auto* self = static_cast<InAppWebView*>(user_data);
          self->UpdateMonitorRefreshRate();
        }),
        this);

    // Also connect to monitor-removed in case the window moves to another monitor
    g_signal_connect(
        display, "monitor-removed",
        G_CALLBACK(+[](GdkDisplay*, GdkMonitor*, gpointer user_data) {
          auto* self = static_cast<InAppWebView*>(user_data);
          self->UpdateMonitorRefreshRate();
        }),
        this);
  }

  // Connect to configure-event on the toplevel window to detect window moves/resizes
  // This helps us detect when the window moves between monitors
  if (gtk_window_ != nullptr) {
    configure_event_handler_id_ = g_signal_connect(
        gtk_window_, "configure-event",
        G_CALLBACK(+[](GtkWidget*, GdkEventConfigure*, gpointer user_data) -> gboolean {
          auto* self = static_cast<InAppWebView*>(user_data);
          self->UpdateMonitorRefreshRate();
          return FALSE;  // Continue event propagation
        }),
        this);
  }
}

void InAppWebView::CleanupMonitorChangeHandlers() {
  // Disconnect monitors-changed signal
  if (monitors_changed_handler_id_ != 0) {
    GdkDisplay* display = gdk_display_get_default();
    if (display != nullptr) {
      g_signal_handler_disconnect(display, monitors_changed_handler_id_);
    }
    monitors_changed_handler_id_ = 0;
  }

  // Disconnect configure-event signal
  if (configure_event_handler_id_ != 0 && gtk_window_ != nullptr) {
    g_signal_handler_disconnect(gtk_window_, configure_event_handler_id_);
    configure_event_handler_id_ = 0;
  }
}

void InAppWebView::UpdateMonitorRefreshRate() {
#ifdef HAVE_WPE_BACKEND_LEGACY
  if (gtk_window_ == nullptr || wpe_backend_ == nullptr) {
    return;
  }

  int refresh_rate_mhz = flutter_inappwebview_linux_plugin_get_monitor_refresh_rate_for_window(gtk_window_);
  if (refresh_rate_mhz > 0) {
    uint32_t new_rate = static_cast<uint32_t>(refresh_rate_mhz);
    // Only update if the rate has actually changed
    if (new_rate != target_refresh_rate_) {
      wpe_view_backend_set_target_refresh_rate(wpe_backend_, new_rate);
      target_refresh_rate_ = new_rate;
    }
  }
#endif
}

// === WPE Backend Callbacks ===

void InAppWebView::OnFrameDisplayed(void* data) {
  auto* self = static_cast<InAppWebView*>(data);

  if (self->on_frame_available_) {
    self->on_frame_available_();
  }
}

#ifdef HAVE_WPE_BACKEND_LEGACY
void InAppWebView::OnExportDmaBuf(::wpe_fdo_egl_exported_image* image) {
  if (image == nullptr) {
    return;
  }

  uint32_t img_width = wpe_fdo_egl_exported_image_get_width(image);
  uint32_t img_height = wpe_fdo_egl_exported_image_get_height(image);

  // Get the EGL image from the exported image
  EGLImageKHR egl_image = wpe_fdo_egl_exported_image_get_egl_image(image);

  // Only do pixel readback if:
  // 1. skip_pixel_readback_ is false (not using zero-copy mode)
  // 2. egl_display_ is available
  // 3. We have a valid EGL image
  if (!skip_pixel_readback_ && egl_image != EGL_NO_IMAGE_KHR && egl_display_ != nullptr) {
    ReadPixelsFromEglImage(egl_image, img_width, img_height);
  }

  // Protect exported_image_ access - this method is called from WPE's thread
  // while GetCurrentEglImage may be called from Flutter's rendering thread
  {
    std::lock_guard<std::mutex> lock(exported_image_mutex_);
    
    // Release previous exported image
    if (exported_image_ != nullptr && exportable_ != nullptr) {
      ::wpe_view_backend_exportable_fdo_egl_dispatch_release_exported_image(exportable_,
                                                                            exported_image_);
    }

    exported_image_ = image;
  }

  // Call on_frame_available BEFORE dispatch_frame_complete
  // This ensures the EGL image is captured before we signal WPE we're ready for more
  if (on_frame_available_) {
    on_frame_available_();
  }

  // Dispatch frame complete to allow WebKit to render next frame
  // Note: This is moved AFTER on_frame_available to ensure the EGL image is used first
  if (exportable_ != nullptr) {
    wpe_view_backend_exportable_fdo_dispatch_frame_complete(exportable_);
  }
}
#endif

#ifdef HAVE_WPE_PLATFORM
void InAppWebView::OnWpePlatformBufferRendered(WPEBuffer* buffer) {
  if (buffer == nullptr) {
    return;
  }
  
  // Don't process buffers during destruction
  if (is_disposing_.load()) {
    // Still need to release the buffer back to WPE
    if (wpe_view_ != nullptr) {
      wpe_view_buffer_released(wpe_view_, buffer);
    }
    return;
  }
  
  // Get buffer dimensions
  uint32_t buf_width = static_cast<uint32_t>(wpe_buffer_get_width(buffer));
  uint32_t buf_height = static_cast<uint32_t>(wpe_buffer_get_height(buffer));
  
  
  WPEBuffer* previous_buffer = nullptr;
  bool buffer_handled = false;
  
  // Track EGL import failures to avoid repeated attempts
  // Static because if EGL fails once, it will likely keep failing (e.g., no GPU)
  static bool egl_import_failed_permanently = false;
  
  {
    std::lock_guard<std::mutex> lock(wpe_buffer_mutex_);
    
    // Store reference to previous buffer - we'll release it AFTER importing the new one
    // This ensures the EGL image's backing memory stays valid until we have a new frame
    previous_buffer = current_buffer_;
    
    // Destroy previous EGL image if we created one
    if (current_egl_image_ != nullptr && egl_display_ != nullptr) {
      static PFNEGLDESTROYIMAGEKHRPROC eglDestroyImageKHR = nullptr;
      if (eglDestroyImageKHR == nullptr) {
        eglDestroyImageKHR = (PFNEGLDESTROYIMAGEKHRPROC)eglGetProcAddress("eglDestroyImageKHR");
      }
      if (eglDestroyImageKHR != nullptr) {
        eglDestroyImageKHR(static_cast<EGLDisplay>(egl_display_), 
                           static_cast<EGLImageKHR>(current_egl_image_));
      }
      current_egl_image_ = nullptr;
    }
    
    // Check buffer type to determine best rendering path
    bool is_dma_buf = WPE_IS_BUFFER_DMA_BUF(buffer);
    bool is_shm = WPE_IS_BUFFER_SHM(buffer);
    
    // === Priority 1: Try EGL image import (zero-copy, best performance) ===
    // Only attempt EGL for DMA-BUF buffers (SHM buffers cannot be imported via EGL)
    // Skip if previous EGL attempts failed
    if (egl_display_ != nullptr && 
        is_dma_buf && !egl_import_failed_permanently) {
      GError* error = nullptr;
      void* egl_image = wpe_buffer_import_to_egl_image(buffer, &error);
      
      if (egl_image != nullptr) {
        current_egl_image_ = egl_image;
        current_buffer_width_ = buf_width;
        current_buffer_height_ = buf_height;
        buffer_handled = true;
      } else {
        // Mark EGL as permanently failed so we don't keep trying
        // This is common in VMs or software-only environments
        egl_import_failed_permanently = true;
        if (error != nullptr) {
          g_clear_error(&error);
        }
      }
    }
    
    // === Priority 2: Direct SHM buffer access (no GBM required) ===
    // WPEBufferSHM provides direct pixel access without requiring GBM device
    if (!buffer_handled && is_shm) {
      WPEBufferSHM* shm_buffer = WPE_BUFFER_SHM(buffer);
      GBytes* data = wpe_buffer_shm_get_data(shm_buffer);
      
      if (data != nullptr) {
        guint stride = wpe_buffer_shm_get_stride(shm_buffer);
        WPEPixelFormat format = wpe_buffer_shm_get_format(shm_buffer);
        
        gsize size;
        const uint8_t* pixels = static_cast<const uint8_t*>(g_bytes_get_data(data, &size));
        
        if (pixels != nullptr && size > 0) {
          // Store in pixel buffer for software rendering
          size_t write_idx = write_buffer_index_.load(std::memory_order_relaxed);
          auto& pixel_buffer = pixel_buffers_[write_idx];
          
          if (pixel_buffer.data.size() != size) {
            pixel_buffer.data.resize(size);
          }
          memcpy(pixel_buffer.data.data(), pixels, size);
          
          // WPE SHM buffers use ARGB8888 format (BGRA in memory on little-endian)
          // Flutter expects RGBA8888, so we need to convert
          // ConvertARGB32ToRGBA handles the BGRA -> RGBA conversion
          if (format == WPE_PIXEL_FORMAT_ARGB8888) {
            ConvertARGB32ToRGBA(pixel_buffer.data.data(),    // source (in-place)
                                pixel_buffer.data.data(),    // destination (in-place)
                                buf_width, buf_height,
                                stride);
          }
          
          pixel_buffer.width = buf_width;
          pixel_buffer.height = buf_height;
          
          // Swap buffers
          {
            std::lock_guard<std::mutex> swap_lock(buffer_swap_mutex_);
            read_buffer_index_.store(write_idx, std::memory_order_release);
            write_buffer_index_.store((write_idx + 1) % kNumBuffers, std::memory_order_relaxed);
          }
          
          current_buffer_width_ = buf_width;
          current_buffer_height_ = buf_height;
          buffer_handled = true;
        }
        // Note: Don't unref data - it's borrowed from the buffer
      }
    }
    
    // === Priority 3: Generic pixel import (works for DMA-BUF with GBM device) ===
    // This is a fallback for DMA-BUF when EGL failed but GBM device is available
    if (!buffer_handled) {
      GError* error = nullptr;
      GBytes* pixels = wpe_buffer_import_to_pixels(buffer, &error);
      if (pixels != nullptr) {
        gsize size;
        const uint8_t* data = static_cast<const uint8_t*>(g_bytes_get_data(pixels, &size));
        
        // Store in pixel buffer for software rendering
        size_t write_idx = write_buffer_index_.load(std::memory_order_relaxed);
        auto& pixel_buffer = pixel_buffers_[write_idx];
        
        if (pixel_buffer.data.size() != size) {
          pixel_buffer.data.resize(size);
        }
        memcpy(pixel_buffer.data.data(), data, size);
        
        // GBM pixel import also returns ARGB8888, convert to RGBA
        uint32_t stride = buf_width * 4;
        ConvertARGB32ToRGBA(pixel_buffer.data.data(),
                            pixel_buffer.data.data(),
                            buf_width, buf_height,
                            stride);
        
        pixel_buffer.width = buf_width;
        pixel_buffer.height = buf_height;
        
        // Swap buffers
        {
          std::lock_guard<std::mutex> swap_lock(buffer_swap_mutex_);
          read_buffer_index_.store(write_idx, std::memory_order_release);
          write_buffer_index_.store((write_idx + 1) % kNumBuffers, std::memory_order_relaxed);
        }
        
        g_bytes_unref(pixels);
        current_buffer_width_ = buf_width;
        current_buffer_height_ = buf_height;
        buffer_handled = true;
      } else {
        if (error != nullptr) {
          g_clear_error(&error);
        }
      }
    }
    
    if (!buffer_handled) {
      debugLog("ERROR: No rendering method succeeded!");
    }
    
    // Store reference to current buffer - we keep it until the NEXT frame arrives
    // This ensures the EGL image's backing DMA-BUF memory stays valid
    current_buffer_ = buffer;
  }
  
  // Release the PREVIOUS buffer now that we have a new one
  // The previous EGL image has been destroyed and we have a new frame,
  // so it's safe to let WPE reuse the old buffer's memory
  if (previous_buffer != nullptr && wpe_view_ != nullptr && WPE_IS_BUFFER(previous_buffer)) {
    wpe_view_buffer_released(wpe_view_, previous_buffer);
  }
  
  if (buffer_handled && on_frame_available_) {
    on_frame_available_();
  }
}
#endif

void InAppWebView::ReadPixelsFromEglImage(void* egl_image, uint32_t width, uint32_t height) {
  // CRITICAL: Check for GL context before any GL operations
  // WPE WebKit calls this from its own thread which may not have a GL context
  if (!HasCurrentGLContext()) {
    return;
  }
  
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

  glBindTexture(GL_TEXTURE_2D, readback_texture_);

  // Use the OES_EGL_image extension to create texture from EGL image
  static PFNGLEGLIMAGETARGETTEXTURE2DOESPROC glEGLImageTargetTexture2DOES = nullptr;
  if (glEGLImageTargetTexture2DOES == nullptr) {
    glEGLImageTargetTexture2DOES =
        (PFNGLEGLIMAGETARGETTEXTURE2DOESPROC)eglGetProcAddress("glEGLImageTargetTexture2DOES");
  }

  if (glEGLImageTargetTexture2DOES != nullptr) {
    glEGLImageTargetTexture2DOES(GL_TEXTURE_2D, image);
  } else {
    glBindTexture(GL_TEXTURE_2D, 0);
    return;
  }

  glBindFramebuffer(GL_FRAMEBUFFER, fbo_);
  glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, readback_texture_, 0);

  GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
  if (status != GL_FRAMEBUFFER_COMPLETE) {
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glBindTexture(GL_TEXTURE_2D, 0);
    return;
  }

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

  {
    std::lock_guard<std::mutex> lock(buffer_swap_mutex_);
    read_buffer_index_.store(write_idx, std::memory_order_release);
    write_buffer_index_.store((write_idx + 1) % kNumBuffers, std::memory_order_relaxed);
  }

  glBindFramebuffer(GL_FRAMEBUFFER, 0);
  glBindTexture(GL_TEXTURE_2D, 0);
}

// === Navigation Methods ===

void InAppWebView::loadUrl(const std::string& url) {
  if (webview_ == nullptr)
    return;

  webkit_web_view_load_uri(webview_, url.c_str());
}

void InAppWebView::loadUrl(const std::shared_ptr<URLRequest>& urlRequest) {
  if (webview_ == nullptr || !urlRequest)
    return;

  if (!urlRequest->url.has_value()) {
    return;
  }

  std::string method = urlRequest->method.value_or("GET");

  if (method == "GET" && !urlRequest->body.has_value() && !urlRequest->headers.has_value()) {
    webkit_web_view_load_uri(webview_, urlRequest->url.value().c_str());
    return;
  }

  // Create a WebKitURIRequest for more complex requests
  WebKitURIRequest* request = webkit_uri_request_new(urlRequest->url.value().c_str());

  if (urlRequest->headers.has_value()) {
    SoupMessageHeaders* headers = webkit_uri_request_get_http_headers(request);
    for (const auto& header : urlRequest->headers.value()) {
      soup_message_headers_append(headers, header.first.c_str(), header.second.c_str());
    }
  }

  webkit_web_view_load_request(webview_, request);
  g_object_unref(request);
}

void InAppWebView::loadData(const std::string& data, const std::string& mime_type,
                            const std::string& encoding, const std::string& base_url) {
  if (webview_ == nullptr)
    return;

  g_message("InAppWebView: loadData() called while loading, stopping current load first");
  webkit_web_view_stop_loading(webview_);
  // Give WebKit/WPE FDO a moment to clean up pending operations
  while (g_main_context_iteration(NULL, FALSE)) { }

  GBytes* bytes = g_bytes_new(data.data(), data.size());
  webkit_web_view_load_bytes(webview_, bytes, mime_type.c_str(), encoding.c_str(),
                             base_url.c_str());
  g_bytes_unref(bytes);
}

void InAppWebView::loadFile(const std::string& asset_file_path) {
  if (webview_ == nullptr)
    return;

  g_message("InAppWebView: loadFile() called while loading, stopping current load first");
  webkit_web_view_stop_loading(webview_);
  // Give WebKit/WPE FDO a moment to clean up pending operations
  while (g_main_context_iteration(NULL, FALSE)) { }

  // Get the path to the running executable
  char exe_path[PATH_MAX];
  ssize_t len = readlink("/proc/self/exe", exe_path, sizeof(exe_path) - 1);
  if (len == -1) {
    debugLog("Failed to get executable path for loadFile");
    return;
  }
  exe_path[len] = '\0';

  // Build the absolute path to the Flutter asset
  std::filesystem::path exe_dir = std::filesystem::path(exe_path).parent_path();
  std::filesystem::path flutter_asset_path =
      exe_dir / "data" / "flutter_assets" / asset_file_path;

  if (!std::filesystem::exists(flutter_asset_path)) {
    debugLog("Asset file not found: " + flutter_asset_path.string());
    return;
  }

  std::string file_url = "file://" + flutter_asset_path.string();
  webkit_web_view_load_uri(webview_, file_url.c_str());
}

void InAppWebView::postUrl(const std::string& url, const std::vector<uint8_t>& postData) {
  if (webview_ == nullptr)
    return;

  g_message("InAppWebView: postUrl() called while loading, stopping current load first");
  webkit_web_view_stop_loading(webview_);
  // Give WebKit/WPE FDO a moment to clean up pending operations
  while (g_main_context_iteration(NULL, FALSE)) { }

  // WPE WebKit's webkit_web_view_load_request() doesn't support POST body directly.
  // We use JavaScript XMLHttpRequest to perform the POST and load the result.
  // This approach is similar to the Web platform implementation.

  // Convert post data to base64 for safe embedding in JavaScript
  gchar* base64_data = g_base64_encode(postData.data(), postData.size());

  // Escape URL for JavaScript string
  std::string escaped_url = url;
  replace_all(escaped_url, "\\", "\\\\");
  replace_all(escaped_url, "'", "\\'");
  replace_all(escaped_url, "\n", "\\n");
  replace_all(escaped_url, "\r", "\\r");

  // Create JavaScript that performs the POST request and loads the result
  std::string js = R"(
(function() {
  var xhr = new XMLHttpRequest();
  xhr.open('POST', ')" + escaped_url + R"(', true);
  xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
  xhr.onload = function() {
    if (xhr.status >= 200 && xhr.status < 300) {
      document.open();
      document.write(xhr.responseText);
      document.close();
    }
  };
  xhr.onerror = function() {
    console.error('postUrl XHR failed for: )" + escaped_url + R"(');
  };
  var postData = atob(')" + std::string(base64_data) + R"(');
  xhr.send(postData);
})();
)";

  g_free(base64_data);

  // First load about:blank to ensure we have a document context, then execute the XHR
  // We need to inject the script after a page load
  webkit_web_view_load_html(webview_, 
    "<!DOCTYPE html><html><head></head><body></body></html>", 
    url.c_str());

  // Use evaluateJavascript to run the XHR after the blank page loads
  // We need to wait for the load to complete, so we use a delayed approach
  std::string* js_copy = new std::string(js);
  g_timeout_add(100, [](gpointer user_data) -> gboolean {
    auto* data = static_cast<std::pair<InAppWebView*, std::string*>*>(user_data);
    if (data->first->webview() != nullptr) {
      webkit_web_view_evaluate_javascript(
          data->first->webview(),
          data->second->c_str(),
          -1,
          nullptr,  // world
          nullptr,  // source_uri
          nullptr,  // cancellable
          nullptr,  // callback
          nullptr); // user_data
    }
    delete data->second;
    delete data;
    return G_SOURCE_REMOVE;
  }, new std::pair<InAppWebView*, std::string*>(this, js_copy));
}

void InAppWebView::reload() {
  if (webview_ == nullptr)
    return;
  
  webkit_web_view_reload(webview_);
}

void InAppWebView::reloadFromOrigin() {
  if (webview_ == nullptr)
    return;

  g_message("InAppWebView: reloadFromOrigin() called while loading, stopping current load first");
  webkit_web_view_stop_loading(webview_);
  // Give WebKit/WPE FDO a moment to clean up pending operations
  while (g_main_context_iteration(NULL, FALSE)) { }
  
  webkit_web_view_reload_bypass_cache(webview_);
}

void InAppWebView::goBack() {
  if (webview_ == nullptr)
    return;
  
  webkit_web_view_go_back(webview_);
}

void InAppWebView::goForward() {
  if (webview_ == nullptr)
    return;
  
  webkit_web_view_go_forward(webview_);
}

bool InAppWebView::canGoBack() const {
  if (webview_ == nullptr)
    return false;
  return webkit_web_view_can_go_back(webview_);
}

bool InAppWebView::canGoForward() const {
  if (webview_ == nullptr)
    return false;
  return webkit_web_view_can_go_forward(webview_);
}

void InAppWebView::stopLoading() {
  if (webview_ == nullptr)
    return;
  webkit_web_view_stop_loading(webview_);
}

bool InAppWebView::isLoading() const {
  if (webview_ == nullptr)
    return false;
  return webkit_web_view_is_loading(webview_);
}

// === Navigation History ===

FlValue* InAppWebView::getCopyBackForwardList() const {
  if (webview_ == nullptr) {
    return fl_value_new_null();
  }

  WebKitBackForwardList* bfList = webkit_web_view_get_back_forward_list(webview_);
  if (bfList == nullptr) {
    return fl_value_new_null();
  }

  GList* backList = webkit_back_forward_list_get_back_list(bfList);
  WebKitBackForwardListItem* currentItem = webkit_back_forward_list_get_current_item(bfList);
  GList* forwardList = webkit_back_forward_list_get_forward_list(bfList);

  int currentIndex = g_list_length(backList);

  FlValue* historyList = fl_value_new_list();
  int index = 0;

  for (GList* l = backList; l != nullptr; l = l->next) {
    WebKitBackForwardListItem* item = WEBKIT_BACK_FORWARD_LIST_ITEM(l->data);

    const gchar* originalUri = webkit_back_forward_list_item_get_original_uri(item);
    const gchar* title = webkit_back_forward_list_item_get_title(item);
    const gchar* uri = webkit_back_forward_list_item_get_uri(item);

    FlValue* itemMap = to_fl_map({
      {"originalUrl", make_fl_value(originalUri ? originalUri : "")},
      {"title", make_fl_value(title ? title : "")},
      {"url", make_fl_value(uri ? uri : "")},
      {"index", make_fl_value(index)},
      {"offset", make_fl_value(index - currentIndex)},
    });

    fl_value_append_take(historyList, itemMap);
    index++;
  }

  if (currentItem != nullptr) {
    const gchar* originalUri = webkit_back_forward_list_item_get_original_uri(currentItem);
    const gchar* title = webkit_back_forward_list_item_get_title(currentItem);
    const gchar* uri = webkit_back_forward_list_item_get_uri(currentItem);

    FlValue* itemMap = to_fl_map({
      {"originalUrl", make_fl_value(originalUri ? originalUri : "")},
      {"title", make_fl_value(title ? title : "")},
      {"url", make_fl_value(uri ? uri : "")},
      {"index", make_fl_value(index)},
      {"offset", make_fl_value(index - currentIndex)},
    });

    fl_value_append_take(historyList, itemMap);
    index++;
  }

  for (GList* l = forwardList; l != nullptr; l = l->next) {
    WebKitBackForwardListItem* item = WEBKIT_BACK_FORWARD_LIST_ITEM(l->data);

    const gchar* originalUri = webkit_back_forward_list_item_get_original_uri(item);
    const gchar* title = webkit_back_forward_list_item_get_title(item);
    const gchar* uri = webkit_back_forward_list_item_get_uri(item);

    FlValue* itemMap = to_fl_map({
      {"originalUrl", make_fl_value(originalUri ? originalUri : "")},
      {"title", make_fl_value(title ? title : "")},
      {"url", make_fl_value(uri ? uri : "")},
      {"index", make_fl_value(index)},
      {"offset", make_fl_value(index - currentIndex)},
    });

    fl_value_append_take(historyList, itemMap);
    index++;
  }

  return to_fl_map({
    {"list", historyList},
    {"currentIndex", make_fl_value(currentIndex)},
  });
}

void InAppWebView::goBackOrForward(int steps) {
  if (webview_ == nullptr)
    return;

  WebKitBackForwardList* bfList = webkit_web_view_get_back_forward_list(webview_);
  if (bfList == nullptr)
    return;

  WebKitBackForwardListItem* item = webkit_back_forward_list_get_nth_item(bfList, steps);
  if (item != nullptr) {
    webkit_web_view_go_to_back_forward_list_item(webview_, item);
  }
}

bool InAppWebView::canGoBackOrForward(int steps) const {
  if (webview_ == nullptr)
    return false;

  WebKitBackForwardList* bfList = webkit_web_view_get_back_forward_list(webview_);
  if (bfList == nullptr)
    return false;

  WebKitBackForwardListItem* item = webkit_back_forward_list_get_nth_item(bfList, steps);
  return item != nullptr;
}

// === Getters ===

std::optional<std::string> InAppWebView::getUrl() const {
  if (webview_ == nullptr)
    return std::nullopt;
  const gchar* uri = webkit_web_view_get_uri(webview_);
  if (uri == nullptr)
    return std::nullopt;
  return std::string(uri);
}

std::optional<std::string> InAppWebView::getTitle() const {
  if (webview_ == nullptr)
    return std::nullopt;
  const gchar* title = webkit_web_view_get_title(webview_);
  if (title == nullptr)
    return std::nullopt;
  return std::string(title);
}

int64_t InAppWebView::getProgress() const {
  if (webview_ == nullptr)
    return 0;
  return static_cast<int64_t>(webkit_web_view_get_estimated_load_progress(webview_) * 100);
}

// === TLS/SSL Certificate ===

std::optional<SslCertificate> InAppWebView::getCertificate() const {
  if (webview_ == nullptr) {
    return std::nullopt;
  }

  GTlsCertificate* certificate = nullptr;
  GTlsCertificateFlags errors = static_cast<GTlsCertificateFlags>(0);
  
  if (!webkit_web_view_get_tls_info(webview_, &certificate, &errors)) {
    return std::nullopt;
  }

  if (certificate == nullptr) {
    return std::nullopt;
  }

  GByteArray* der_data = nullptr;
  g_object_get(certificate, "certificate", &der_data, nullptr);
  
  if (der_data == nullptr || der_data->len == 0) {
    if (der_data != nullptr) {
      g_byte_array_unref(der_data);
    }
    return std::nullopt;
  }

  std::vector<uint8_t> certData(der_data->data, der_data->data + der_data->len);
  g_byte_array_unref(der_data);
  
  return SslCertificate(certData);
}

HitTestResult InAppWebView::getHitTestResult() const {
  if (last_hit_test_result_ == nullptr) {
    return HitTestResult(HitTestResultType::UNKNOWN_TYPE);
  }
  return HitTestResult::fromWebKitHitTestResult(last_hit_test_result_);
}

// === JavaScript ===

void InAppWebView::evaluateJavascript(
    const std::string& source,
    const std::optional<std::string>& worldName,
    std::function<void(const std::optional<std::string>&)> callback) {
  if (webview_ == nullptr) {
    if (callback)
      callback(std::nullopt);
    return;
  }

  struct CallbackData {
    std::function<void(const std::optional<std::string>&)> callback;
  };

  auto* cb_data = new CallbackData{std::move(callback)};

  const char* world = worldName.has_value() ? worldName->c_str() : nullptr;

  webkit_web_view_evaluate_javascript(
      webview_, source.c_str(), source.length(),
      world,    // world name (for content world support)
      nullptr,  // source URI
      nullptr,  // cancellable
      [](GObject* source, GAsyncResult* result, gpointer user_data) {
        auto* data = static_cast<CallbackData*>(user_data);
        GError* error = nullptr;
        JSCValue* js_result =
            webkit_web_view_evaluate_javascript_finish(WEBKIT_WEB_VIEW(source), result, &error);

        if (error != nullptr) {
          if (data->callback)
            data->callback(std::nullopt);
          g_error_free(error);
        } else if (js_result != nullptr) {
          // Use JSON.stringify on the result via JSC to get proper JSON
          JSCContext* context = jsc_value_get_context(js_result);
          g_autoptr(JSCValue) json_stringify = jsc_context_evaluate(
              context,
              "(function(v) { return JSON.stringify(v); })",
              -1);
          g_autoptr(JSCValue) json_value = jsc_value_function_call(
              json_stringify, JSC_TYPE_VALUE, js_result, G_TYPE_NONE);
          
          if (json_value != nullptr && jsc_value_is_string(json_value)) {
            g_autofree gchar* str = jsc_value_to_string(json_value);
            if (data->callback) {
              if (str) {
                data->callback(std::string(str));
              } else {
                data->callback(std::nullopt);
              }
            }
          } else {
            if (data->callback)
              data->callback(std::nullopt);
          }
          g_object_unref(js_result);
        } else {
          if (data->callback)
            data->callback(std::nullopt);
        }

        delete data;
      },
      cb_data);
}

// Helper function to convert FlValue to GVariant
void InAppWebView::callAsyncJavaScript(
    const std::string& functionBody,
    const std::string& argumentsJson,
    const std::vector<std::string>& argumentKeys,
    const std::optional<std::string>& worldName,
    std::function<void(const std::string&)> callback) {
  if (webview_ == nullptr) {
    if (callback) {
      callback(R"({"value":null,"error":"WebView not available"})");
    }
    return;
  }

  // Build the wrapped function body that:
  // 1. Parses the JSON-encoded arguments
  // 2. Destructures them into local variables
  // 3. Executes the user's function body
  std::string wrappedBody;
  
  if (!argumentKeys.empty()) {
    // Build destructuring: const {key1, key2, ...} = JSON.parse(__args__);
    wrappedBody = "const {";
    for (size_t i = 0; i < argumentKeys.size(); i++) {
      if (i > 0) wrappedBody += ", ";
      wrappedBody += argumentKeys[i];
    }
    wrappedBody += "} = JSON.parse(__args__);\n";
  }
  wrappedBody += functionBody;

  // Pass the JSON string as a single __args__ argument
  GVariantBuilder builder;
  g_variant_builder_init(&builder, G_VARIANT_TYPE("a{sv}"));
  g_variant_builder_add(&builder, "{sv}", "__args__", g_variant_new_string(argumentsJson.c_str()));
  GVariant* gvariant_args = g_variant_builder_end(&builder);

  const char* world = worldName.has_value() ? worldName->c_str() : nullptr;

  struct CallbackData {
    std::function<void(const std::string&)> callback;
  };
  auto* cb_data = new CallbackData{std::move(callback)};

  webkit_web_view_call_async_javascript_function(
      webview_, wrappedBody.c_str(), -1,  // length: null-terminated
      gvariant_args, world,
      nullptr,  // source_uri
      nullptr,  // cancellable
      [](GObject* source, GAsyncResult* result, gpointer user_data) {
        auto* data = static_cast<CallbackData*>(user_data);
        GError* error = nullptr;
        JSCValue* js_result = webkit_web_view_call_async_javascript_function_finish(
            WEBKIT_WEB_VIEW(source), result, &error);

        std::string json_result;

        if (error != nullptr) {
          // Escape the error message for JSON
          std::string error_msg = error->message ? error->message : "Unknown error";
          // Simple JSON escaping for the error message
          std::string escaped_error;
          for (char c : error_msg) {
            switch (c) {
              case '"': escaped_error += "\\\""; break;
              case '\\': escaped_error += "\\\\"; break;
              case '\n': escaped_error += "\\n"; break;
              case '\r': escaped_error += "\\r"; break;
              case '\t': escaped_error += "\\t"; break;
              default: escaped_error += c; break;
            }
          }
          json_result = "{\"value\":null,\"error\":\"" + escaped_error + "\"}";
          g_error_free(error);
        } else if (js_result != nullptr) {
          // Use JSON.stringify on the result via JSC to get proper JSON
          JSCContext* context = jsc_value_get_context(js_result);
          g_autoptr(JSCValue) json_stringify = jsc_context_evaluate(
              context,
              "(function(v) { return JSON.stringify({value: v, error: null}); })",
              -1);
          g_autoptr(JSCValue) json_value = jsc_value_function_call(
              json_stringify, JSC_TYPE_VALUE, js_result, G_TYPE_NONE);
          
          if (json_value != nullptr && jsc_value_is_string(json_value)) {
            g_autofree gchar* str = jsc_value_to_string(json_value);
            json_result = str ? str : "{\"value\":null,\"error\":null}";
          } else {
            json_result = "{\"value\":null,\"error\":null}";
          }
          g_object_unref(js_result);
        } else {
          json_result = "{\"value\":null,\"error\":null}";
        }

        if (data->callback) {
          data->callback(json_result);
        }
        delete data;
      },
      cb_data);
}

void InAppWebView::injectJavascriptFileFromUrl(const std::string& urlFile) {
  std::string script =
      "(function() {"
      "  var script = document.createElement('script');"
      "  script.src = '" +
      urlFile +
      "';"
      "  document.head.appendChild(script);"
      "})();";
  evaluateJavascript(script, std::nullopt, nullptr);
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
      "  style.textContent = '" +
      escaped_source +
      "';"
      "  document.head.appendChild(style);"
      "})();";
  evaluateJavascript(script, std::nullopt, nullptr);
}

void InAppWebView::injectCSSFileFromUrl(const std::string& urlFile) {
  std::string script =
      "(function() {"
      "  var link = document.createElement('link');"
      "  link.rel = 'stylesheet';"
      "  link.href = '" +
      urlFile +
      "';"
      "  document.head.appendChild(link);"
      "})();";
  evaluateJavascript(script, std::nullopt, nullptr);
}

// === User Scripts ===

void InAppWebView::addUserScript(std::shared_ptr<UserScript> userScript) {
  if (user_content_controller_) {
    user_content_controller_->addUserScript(userScript);
  }
}

void InAppWebView::removeUserScriptAt(size_t index, UserScriptInjectionTime injectionTime) {
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

// === Web Message Listener ===

void InAppWebView::addWebMessageListener(const std::string& jsObjectName,
                                          const std::vector<std::string>& allowedOriginRules) {
  if (webview_ == nullptr || jsObjectName.empty() || messenger_ == nullptr) {
    return;
  }

  // Generate a unique ID for this listener
  static int64_t listener_counter = 0;
  std::string listenerId = std::to_string(g_get_monotonic_time()) + "_" +
                           std::to_string(++listener_counter);

  // Create the native WebMessageListener with its dedicated channel
  // This follows the federated plugin pattern
  std::set<std::string> originRulesSet(allowedOriginRules.begin(), allowedOriginRules.end());
  auto listener = std::make_unique<WebMessageListener>(
      messenger_, listenerId, jsObjectName, originRulesSet, this);

  // Store the listener by jsObjectName (so we can find it when JS posts a message)
  web_message_listeners_[jsObjectName] = std::move(listener);

  // Build the allowed origin rules JSON array for JavaScript injection
  std::string allowedOriginRulesJs = "[";
  for (size_t i = 0; i < allowedOriginRules.size(); ++i) {
    const std::string& rule = allowedOriginRules[i];
    if (rule == "*") {
      allowedOriginRulesJs += "'*'";
    } else {
      // Parse the rule to extract scheme, host, port
      // Format: scheme://host[:port]
      std::string scheme, host;
      int port = 0;

      size_t schemeEnd = rule.find("://");
      if (schemeEnd != std::string::npos) {
        scheme = rule.substr(0, schemeEnd);
        std::string rest = rule.substr(schemeEnd + 3);

        size_t portStart = rest.find(':');
        if (portStart != std::string::npos) {
          host = rest.substr(0, portStart);
          try {
            port = std::stoi(rest.substr(portStart + 1));
          } catch (...) {
            port = 0;
          }
        } else {
          host = rest;
        }
      }

      // Escape single quotes in host
      std::string hostEscaped = host;
      size_t pos = 0;
      while ((pos = hostEscaped.find("'", pos)) != std::string::npos) {
        hostEscaped.replace(pos, 1, "\\'");
        pos += 2;
      }

      allowedOriginRulesJs += "{scheme: '" + scheme + "', host: ";
      if (host.empty()) {
        allowedOriginRulesJs += "null";
      } else {
        allowedOriginRulesJs += "'" + hostEscaped + "'";
      }
      allowedOriginRulesJs += ", port: ";
      if (port == 0) {
        allowedOriginRulesJs += "null";
      } else {
        allowedOriginRulesJs += std::to_string(port);
      }
      allowedOriginRulesJs += "}";
    }
    if (i < allowedOriginRules.size() - 1) {
      allowedOriginRulesJs += ", ";
    }
  }
  allowedOriginRulesJs += "]";

  // Create the JavaScript to inject
  std::string jsSource = WebMessageListenerJS::createWebMessageListenerInjectionJs(
      jsObjectName, allowedOriginRulesJs);

  // Create a user script for this web message listener
  // We use a unique group name to allow removal if needed
  std::string groupName = "WebMessageListener-" + jsObjectName;

  auto userScript = std::make_shared<UserScript>(
      groupName,
      jsSource,
      UserScriptInjectionTime::atDocumentStart,
      true,  // forMainFrameOnly
      std::nullopt  // allowedOriginRules (already handled in JS)
  );

  // Add the script to the user content controller
  if (user_content_controller_) {
    user_content_controller_->addUserScript(userScript);
  }
}

// === Web Message Channel ===

void InAppWebView::createWebMessageChannel(
    std::function<void(const std::optional<std::string>&)> callback) {
  if (webview_ == nullptr || messenger_ == nullptr) {
    if (callback) callback(std::nullopt);
    return;
  }

  // Generate a unique channel ID using timestamp and random number
  static int64_t channel_counter = 0;
  std::string channelId = std::to_string(g_get_monotonic_time()) + "_" +
                          std::to_string(++channel_counter);

  // Create the JavaScript to create the MessageChannel
  std::string js = WebMessageChannelJS::createWebMessageChannelJs(channelId);

  // Capture variables for the callback
  InAppWebView* self = this;
  FlBinaryMessenger* messenger = messenger_;

  // Execute JavaScript to create the channel
  evaluateJavascript(js, std::nullopt, [self, callback, channelId, messenger](const std::optional<std::string>& result) {
    // If we got a result, the channel was created successfully
    if (result.has_value()) {
      // Create and store the WebMessageChannel object
      auto channel = std::make_unique<WebMessageChannel>(messenger, channelId, self);
      self->web_message_channels_[channelId] = std::move(channel);
      
      callback(channelId);
    } else {
      callback(std::nullopt);
    }
  });
}

WebMessageChannel* InAppWebView::getWebMessageChannel(const std::string& channelId) const {
  auto it = web_message_channels_.find(channelId);
  if (it != web_message_channels_.end()) {
    return it->second.get();
  }
  return nullptr;
}

void InAppWebView::postWebMessage(const std::string& messageData,
                                  const std::string& targetOrigin,
                                  int64_t messageType) {
  if (webview_ == nullptr) return;

  // Convert message data to JavaScript expression
  std::string messageDataJs;
  if (messageType == 1) {
    // ArrayBuffer - messageData contains comma-separated byte values
    messageDataJs = "new Uint8Array([" + messageData + "]).buffer";
  } else {
    // String - escape for JavaScript
    std::string escaped;
    escaped.reserve(messageData.size() * 2);
    for (char c : messageData) {
      switch (c) {
        case '\\': escaped += "\\\\"; break;
        case '"': escaped += "\\\""; break;
        case '\n': escaped += "\\n"; break;
        case '\r': escaped += "\\r"; break;
        case '\t': escaped += "\\t"; break;
        default: escaped += c; break;
      }
    }
    messageDataJs = "\"" + escaped + "\"";
  }

  // Post message to window (no ports for now - ports are handled via channel)
  std::string js = WebMessageChannelJS::postWebMessageJs(messageDataJs, targetOrigin, "");
  evaluateJavascript(js, std::nullopt, nullptr);
}

void InAppWebView::setWebMessageCallback(const std::string& channelId, int portIndex) {
  if (webview_ == nullptr || channelId.empty()) return;

  std::string js = WebMessageChannelJS::setWebMessageCallbackJs(channelId, portIndex);
  evaluateJavascript(js, std::nullopt, nullptr);
}

void InAppWebView::postWebMessageOnPort(const std::string& channelId, int portIndex,
                                         const std::string& messageData, int64_t messageType) {
  if (webview_ == nullptr || channelId.empty()) return;

  // Convert message data to JavaScript expression
  std::string messageDataJs;
  if (messageType == 1) {
    // ArrayBuffer - messageData contains comma-separated byte values
    messageDataJs = "new Uint8Array([" + messageData + "]).buffer";
  } else {
    // String - escape for JavaScript
    std::string escaped;
    escaped.reserve(messageData.size() * 2);
    for (char c : messageData) {
      switch (c) {
        case '\\': escaped += "\\\\"; break;
        case '"': escaped += "\\\""; break;
        case '\n': escaped += "\\n"; break;
        case '\r': escaped += "\\r"; break;
        case '\t': escaped += "\\t"; break;
        default: escaped += c; break;
      }
    }
    messageDataJs = "\"" + escaped + "\"";
  }

  std::string js = WebMessageChannelJS::postMessageJs(channelId, portIndex, messageDataJs);
  evaluateJavascript(js, std::nullopt, nullptr);
}

void InAppWebView::closeWebMessagePort(const std::string& channelId, int portIndex) {
  if (webview_ == nullptr || channelId.empty()) return;

  std::string js = WebMessageChannelJS::closePortJs(channelId, portIndex);
  evaluateJavascript(js, std::nullopt, nullptr);
}

void InAppWebView::disposeWebMessageChannel(const std::string& channelId) {
  if (channelId.empty()) return;

  // Execute JavaScript to clean up the channel
  if (webview_ != nullptr) {
    std::string js = WebMessageChannelJS::disposeChannelJs(channelId);
    evaluateJavascript(js, std::nullopt, nullptr);
  }

  // Remove the channel from our map
  web_message_channels_.erase(channelId);
}

// === HTML Content ===

void InAppWebView::getHtml(std::function<void(const std::optional<std::string>&)> callback) {
  evaluateJavascript("document.documentElement.outerHTML", std::nullopt, callback);
}

// === Screenshot ===

void InAppWebView::takeScreenshot(std::function<void(const std::optional<std::vector<uint8_t>>&)> callback) {
  if (webview_ == nullptr || callback == nullptr) {
    if (callback) {
      callback(std::nullopt);
    }
    return;
  }

  // Get the current pixel buffer dimensions
  uint32_t width = 0;
  uint32_t height = 0;
  size_t buffer_size = GetPixelBufferSize(&width, &height);

  if (buffer_size == 0 || width == 0 || height == 0) {
    callback(std::nullopt);
    return;
  }

  // Allocate a temporary buffer for the pixel data
  std::vector<uint8_t> pixel_data(buffer_size);

  if (!CopyPixelBufferTo(pixel_data.data(), buffer_size, &width, &height)) {
    callback(std::nullopt);
    return;
  }

  // Create a Cairo surface from the RGBA pixel data
  // Note: WPE provides RGBA data, but Cairo uses ARGB (pre-multiplied alpha in native byte order)
  // We need to convert RGBA -> ARGB32 format

  // Allocate buffer for Cairo ARGB32 format (same size)
  std::vector<uint8_t> argb_data(width * height * 4);

  // Convert RGBA -> ARGB32 (Cairo's native format)
  // Cairo ARGB32 format on little-endian: BGRA in memory
  for (uint32_t i = 0; i < width * height; ++i) {
    uint8_t r = pixel_data[i * 4 + 0];
    uint8_t g = pixel_data[i * 4 + 1];
    uint8_t b = pixel_data[i * 4 + 2];
    uint8_t a = pixel_data[i * 4 + 3];

    // Cairo ARGB32 on little-endian = BGRA in memory
    argb_data[i * 4 + 0] = b;
    argb_data[i * 4 + 1] = g;
    argb_data[i * 4 + 2] = r;
    argb_data[i * 4 + 3] = a;
  }

  // Create Cairo surface from the ARGB data
  cairo_surface_t* surface = cairo_image_surface_create_for_data(
      argb_data.data(),
      CAIRO_FORMAT_ARGB32,
      static_cast<int>(width),
      static_cast<int>(height),
      static_cast<int>(width * 4)  // stride
  );

  if (cairo_surface_status(surface) != CAIRO_STATUS_SUCCESS) {
    cairo_surface_destroy(surface);
    callback(std::nullopt);
    return;
  }

  // Write PNG to a memory buffer using cairo_surface_write_to_png_stream
  std::vector<uint8_t> png_data;

  cairo_status_t status = cairo_surface_write_to_png_stream(
      surface,
      [](void* closure, const unsigned char* data, unsigned int length) -> cairo_status_t {
        auto* output = static_cast<std::vector<uint8_t>*>(closure);
        output->insert(output->end(), data, data + length);
        return CAIRO_STATUS_SUCCESS;
      },
      &png_data
  );

  cairo_surface_destroy(surface);

  if (status != CAIRO_STATUS_SUCCESS || png_data.empty()) {
    callback(std::nullopt);
    return;
  }

  callback(png_data);
}

// === Session State ===

std::optional<std::vector<uint8_t>> InAppWebView::saveState() const {
  if (webview_ == nullptr) {
    return std::nullopt;
  }

  // Get the current session state from WPE WebKit
  WebKitWebViewSessionState* session_state = webkit_web_view_get_session_state(webview_);
  if (session_state == nullptr) {
    return std::nullopt;
  }

  // Serialize the session state to GBytes
  GBytes* bytes = webkit_web_view_session_state_serialize(session_state);
  webkit_web_view_session_state_unref(session_state);

  if (bytes == nullptr) {
    return std::nullopt;
  }

  // Copy the data to a vector
  gsize size = 0;
  gconstpointer data = g_bytes_get_data(bytes, &size);

  if (data == nullptr || size == 0) {
    g_bytes_unref(bytes);
    return std::nullopt;
  }

  std::vector<uint8_t> result(static_cast<const uint8_t*>(data),
                               static_cast<const uint8_t*>(data) + size);

  g_bytes_unref(bytes);
  return result;
}

bool InAppWebView::restoreState(const std::vector<uint8_t>& stateData) {
  if (webview_ == nullptr || stateData.empty()) {
    return false;
  }

  // Create GBytes from the state data
  GBytes* bytes = g_bytes_new(stateData.data(), stateData.size());
  if (bytes == nullptr) {
    return false;
  }

  // Create session state from the serialized data
  WebKitWebViewSessionState* session_state = webkit_web_view_session_state_new(bytes);
  g_bytes_unref(bytes);

  if (session_state == nullptr) {
    return false;
  }

  // Restore the session state
  webkit_web_view_restore_session_state(webview_, session_state);
  webkit_web_view_session_state_unref(session_state);

  return true;
}

// === Zoom ===

double InAppWebView::getZoomScale() const {
  if (webview_ == nullptr)
    return 1.0;
  return webkit_web_view_get_zoom_level(webview_);
}

void InAppWebView::setZoomScale(double zoomScale) {
  if (webview_ == nullptr)
    return;
  webkit_web_view_set_zoom_level(webview_, zoomScale);
}

// === Scroll ===

void InAppWebView::scrollTo(int64_t x, int64_t y, bool animated) {
  std::string script =
      animated ? "window.scrollTo({top: " + std::to_string(y) + ", left: " + std::to_string(x) +
                     ", behavior: 'smooth'});"
               : "window.scrollTo(" + std::to_string(x) + ", " + std::to_string(y) + ");";
  evaluateJavascript(script, std::nullopt, nullptr);
}

void InAppWebView::scrollBy(int64_t x, int64_t y, bool animated) {
  std::string script =
      animated ? "window.scrollBy({top: " + std::to_string(y) + ", left: " + std::to_string(x) +
                     ", behavior: 'smooth'});"
               : "window.scrollBy(" + std::to_string(x) + ", " + std::to_string(y) + ");";
  evaluateJavascript(script, std::nullopt, nullptr);
}

void InAppWebView::getScrollX(std::function<void(int64_t)> callback) {
  if (webview_ == nullptr || callback == nullptr) {
    if (callback) callback(0);
    return;
  }

  evaluateJavascript(
      "window.scrollX || window.pageXOffset || document.documentElement.scrollLeft || 0",
      std::nullopt,
      [callback](const std::optional<std::string>& result) {
        int64_t scrollX = 0;
        if (result.has_value()) {
          try {
            scrollX = std::stoll(*result);
          } catch (...) {
            scrollX = 0;
          }
        }
        callback(scrollX);
      });
}

void InAppWebView::getScrollY(std::function<void(int64_t)> callback) {
  if (webview_ == nullptr || callback == nullptr) {
    if (callback) callback(0);
    return;
  }

  evaluateJavascript(
      "window.scrollY || window.pageYOffset || document.documentElement.scrollTop || 0",
      std::nullopt,
      [callback](const std::optional<std::string>& result) {
        int64_t scrollY = 0;
        if (result.has_value()) {
          try {
            scrollY = std::stoll(*result);
          } catch (...) {
            scrollY = 0;
          }
        }
        callback(scrollY);
      });
}

void InAppWebView::canScrollVertically(std::function<void(bool)> callback) {
  if (webview_ == nullptr || callback == nullptr) {
    if (callback) callback(false);
    return;
  }

  evaluateJavascript(
      "document.documentElement.scrollHeight > document.documentElement.clientHeight",
      std::nullopt,
      [callback](const std::optional<std::string>& result) {
        bool canScroll = false;
        if (result.has_value() && *result == "true") {
          canScroll = true;
        }
        callback(canScroll);
      });
}

void InAppWebView::canScrollHorizontally(std::function<void(bool)> callback) {
  if (webview_ == nullptr || callback == nullptr) {
    if (callback) callback(false);
    return;
  }

  evaluateJavascript(
      "document.documentElement.scrollWidth > document.documentElement.clientWidth",
      std::nullopt,
      [callback](const std::optional<std::string>& result) {
        bool canScroll = false;
        if (result.has_value() && *result == "true") {
          canScroll = true;
        }
        callback(canScroll);
      });
}

// === Content Dimensions ===

void InAppWebView::getContentHeight(std::function<void(int64_t)> callback) {
  if (callback == nullptr) {
    return;
  }

  // Use JavaScript to get the document's scroll height
  evaluateJavascript(
      "Math.max(document.body.scrollHeight, document.documentElement.scrollHeight)",
      std::nullopt,
      [callback](const std::optional<std::string>& result) {
        if (result.has_value()) {
          try {
            int64_t height = std::stoll(result.value());
            callback(height);
            return;
          } catch (...) {
            // Fall through to default
          }
        }
        callback(0);
      });
}

void InAppWebView::getContentWidth(std::function<void(int64_t)> callback) {
  if (callback == nullptr) {
    return;
  }

  // Use JavaScript to get the document's scroll width
  evaluateJavascript(
      "Math.max(document.body.scrollWidth, document.documentElement.scrollWidth)",
      std::nullopt,
      [callback](const std::optional<std::string>& result) {
        if (result.has_value()) {
          try {
            int64_t width = std::stoll(result.value());
            callback(width);
            return;
          } catch (...) {
            // Fall through to default
          }
        }
        callback(0);
      });
}

// === Settings ===

FlValue* InAppWebView::getSettings() const {
  if (settings_) {
    return settings_->toFlValue();
  }
  return fl_value_new_null();
}

void InAppWebView::setSettings(const std::shared_ptr<InAppWebViewSettings> newSettings,
                               FlValue* newSettingsMap) {
  if (newSettings && webview_) {
    // Check if contentBlockers changed
    FlValue* newContentBlockers = newSettings->contentBlockers;

    // Apply content blockers if they have been updated
    if (content_blocker_handler_ != nullptr) {
      // If new settings have contentBlockers, apply them
      // This will replace any existing content blockers
      content_blocker_handler_->setContentBlockers(newContentBlockers, nullptr);
    }

    settings_ = newSettings;
    settings_->applyToWebView(webview_);
#ifdef HAVE_WPE_PLATFORM
    // Apply WPE Platform settings (dark mode, font settings, etc.)
    if (wpe_display_ != nullptr) {
      settings_->applyWpePlatformSettings(wpe_display_);
    }
#endif
  }
}

// === Size Management ===

void InAppWebView::setSize(int width, int height) {
  if (width == width_ && height == height_)
    return;

  // Hide all popups on resize
  HideAllPopups();

  width_ = width;
  height_ = height;

  // Resize the WPE backend
#ifdef HAVE_WPE_PLATFORM
  if (wpe_toplevel_ != nullptr) {
    wpe_toplevel_resize(wpe_toplevel_, width_, height_);
  }
#elif defined(HAVE_WPE_BACKEND_LEGACY)
  if (wpe_backend_ != nullptr) {
    wpe_view_backend_dispatch_set_size(wpe_backend_, width_, height_);
  }
#endif
}

void InAppWebView::setScaleFactor(double scale_factor) {
  if (scale_factor == scale_factor_)
    return;
  scale_factor_ = scale_factor;

  // WPE uses device scale factor
#ifdef HAVE_WPE_PLATFORM
  // WPEPlatform: Notify the toplevel about scale changes
  // This is needed for proper HiDPI rendering when scale changes dynamically
  if (wpe_toplevel_ != nullptr) {
    wpe_toplevel_scale_changed(wpe_toplevel_, scale_factor_);
  }
#endif
#ifdef HAVE_WPE_BACKEND_LEGACY
  if (wpe_backend_ != nullptr) {
    wpe_view_backend_dispatch_set_device_scale_factor(wpe_backend_, scale_factor_);
  }
#endif
}

// === Activity State Management (like Cog browser) ===

void InAppWebView::setFocused(bool focused) {
  if (focused == is_focused_)
    return;
  is_focused_ = focused;

  // Hide all popups when WebView loses focus
  if (!focused) {
    HideAllPopups();
  }

#ifdef HAVE_WPE_PLATFORM
  // WPEPlatform: Use wpe_view_focus_in/out API
  if (wpe_view_ != nullptr) {
    if (focused) {
      wpe_view_focus_in(wpe_view_);
    } else {
      wpe_view_focus_out(wpe_view_);
    }
  }
#elif defined(HAVE_WPE_BACKEND_LEGACY)
  if (wpe_backend_ != nullptr) {
    if (focused) {
      // Add focused state - also ensure visible and in_window are set
      wpe_view_backend_add_activity_state(wpe_backend_, wpe_view_activity_state_focused);
      wpe_view_backend_add_activity_state(wpe_backend_, wpe_view_activity_state_visible);
      wpe_view_backend_add_activity_state(wpe_backend_, wpe_view_activity_state_in_window);
    } else {
      // Remove only the focused state, keep visible and in_window so the webview
      // continues to render and process basic events
      wpe_view_backend_remove_activity_state(wpe_backend_, wpe_view_activity_state_focused);
    }
  }
#endif
}

void InAppWebView::setVisible(bool visible) {
  if (visible == is_visible_)
    return;
  is_visible_ = visible;

#ifdef HAVE_WPE_PLATFORM
  // WPEPlatform: Use wpe_view_set_visible and map/unmap
  if (wpe_view_ != nullptr) {
    wpe_view_set_visible(wpe_view_, visible);
    if (visible) {
      wpe_view_map(wpe_view_);
    } else {
      wpe_view_unmap(wpe_view_);
    }
  }
#elif defined(HAVE_WPE_BACKEND_LEGACY)
  if (wpe_backend_ != nullptr) {
    if (visible) {
      wpe_view_backend_add_activity_state(wpe_backend_, wpe_view_activity_state_visible);
      wpe_view_backend_add_activity_state(wpe_backend_, wpe_view_activity_state_in_window);
    } else {
      wpe_view_backend_remove_activity_state(wpe_backend_, wpe_view_activity_state_visible);
      wpe_view_backend_remove_activity_state(wpe_backend_, wpe_view_activity_state_in_window);
    }
  }
#endif
}

uint32_t InAppWebView::getActivityState() const {
#ifdef HAVE_WPE_BACKEND_LEGACY
  if (wpe_backend_ != nullptr) {
    return wpe_view_backend_get_activity_state(wpe_backend_);
  }
#endif
  // WPEPlatform doesn't expose activity state in the same way
  return 0;
}

// === Refresh Rate Management ===

void InAppWebView::setTargetRefreshRate(uint32_t rate) {
  target_refresh_rate_ = rate;
#ifdef HAVE_WPE_PLATFORM
  if (wpe_view_ != nullptr) {
    WPEScreen* screen = wpe_view_get_screen(wpe_view_);
    if (screen != nullptr) {
      wpe_screen_set_refresh_rate(screen, static_cast<int>(rate));
    }
  }
#endif
#ifdef HAVE_WPE_BACKEND_LEGACY
  if (wpe_backend_ != nullptr) {
    wpe_view_backend_set_target_refresh_rate(wpe_backend_, rate);
  }
#endif
}

uint32_t InAppWebView::getTargetRefreshRate() const {
#ifdef HAVE_WPE_PLATFORM
  if (wpe_view_ != nullptr) {
    WPEScreen* screen = wpe_view_get_screen(wpe_view_);
    if (screen != nullptr) {
      int refreshRate = wpe_screen_get_refresh_rate(screen);
      if (refreshRate > 0) {
        return static_cast<uint32_t>(refreshRate);
      }
    }
  }
#endif
#ifdef HAVE_WPE_BACKEND_LEGACY
  if (wpe_backend_ != nullptr) {
    return wpe_view_backend_get_target_refresh_rate(wpe_backend_);
  }
#endif
  return target_refresh_rate_;
}

// === Screen Scale Management ===

double InAppWebView::getScreenScale() const {
#ifdef HAVE_WPE_PLATFORM
  if (wpe_view_ != nullptr) {
    WPEScreen* screen = wpe_view_get_screen(wpe_view_);
    if (screen != nullptr) {
      return wpe_screen_get_scale(screen);
    }
  }
#endif
  // Legacy backend doesn't have screen scale API
  return 1.0;
}

void InAppWebView::setScreenScale(double scale) {
#ifdef HAVE_WPE_PLATFORM
  if (wpe_view_ != nullptr) {
    WPEScreen* screen = wpe_view_get_screen(wpe_view_);
    if (screen != nullptr) {
      wpe_screen_set_scale(screen, scale);
    }
  }
#endif
  // Legacy backend doesn't have screen scale API
}

// === Visibility Management ===

bool InAppWebView::isVisible() const {
#ifdef HAVE_WPE_PLATFORM
  if (wpe_view_ != nullptr) {
    return wpe_view_get_visible(wpe_view_);
  }
#endif
  // Legacy backend: return cached visibility state
  return is_visible_;
}

// === Fullscreen Control ===

void InAppWebView::requestEnterFullscreen() {
#ifdef HAVE_WPE_BACKEND_LEGACY
  if (wpe_backend_ != nullptr) {
    wpe_view_backend_dispatch_request_enter_fullscreen(wpe_backend_);
  }
#endif
  // Note: WPEPlatform uses WebKit enter-fullscreen/leave-fullscreen signals
}

void InAppWebView::requestExitFullscreen() {
#ifdef HAVE_WPE_BACKEND_LEGACY
  if (wpe_backend_ != nullptr) {
    wpe_view_backend_dispatch_request_exit_fullscreen(wpe_backend_);
  }
#endif
  // Note: WPEPlatform uses WebKit enter-fullscreen/leave-fullscreen signals
}

// === Pointer Lock Support (for games/immersive apps) ===

void InAppWebView::setPointerLockHandler(std::function<bool(bool)> handler) {
  pointer_lock_handler_ = std::move(handler);

#ifdef HAVE_WPE_BACKEND_LEGACY
  if (wpe_backend_ != nullptr) {
    wpe_view_backend_set_pointer_lock_handler(
        wpe_backend_,
        [](void* data, bool lock) -> bool {
          auto* self = static_cast<InAppWebView*>(data);
          return self->OnPointerLockRequest(lock);
        },
        this);
  }
#endif
  // Note: WPEPlatform uses wpe_view_lock_pointer/unlock_pointer APIs
}

bool InAppWebView::OnPointerLockRequest(bool lock) {
  if (pointer_lock_handler_) {
    bool result = pointer_lock_handler_(lock);
    if (result) {
      pointer_locked_ = lock;
    }
    return result;
  }
  // Default: allow pointer lock
  pointer_locked_ = lock;
  return true;
}

bool InAppWebView::requestPointerLock() {
#ifdef HAVE_WPE_PLATFORM
  if (wpe_view_ != nullptr) {
    bool result = wpe_view_lock_pointer(wpe_view_);
    if (result) {
      pointer_locked_ = true;
    }
    return result;
  }
#elif defined(HAVE_WPE_BACKEND_LEGACY)
  if (wpe_backend_ != nullptr) {
    bool result = wpe_view_backend_request_pointer_lock(wpe_backend_);
    if (result) {
      pointer_locked_ = true;
    }
    return result;
  }
#endif
  return false;
}

bool InAppWebView::requestPointerUnlock() {
#ifdef HAVE_WPE_PLATFORM
  if (wpe_view_ != nullptr) {
    bool result = wpe_view_unlock_pointer(wpe_view_);
    if (result) {
      pointer_locked_ = false;
    }
    return result;
  }
#elif defined(HAVE_WPE_BACKEND_LEGACY)
  if (wpe_backend_ != nullptr) {
    bool result = wpe_view_backend_request_pointer_unlock(wpe_backend_);
    if (result) {
      pointer_locked_ = false;
    }
    return result;
  }
#endif
  return false;
}

// === DOM Fullscreen Handler (like Cog browser on_dom_fullscreen_request) ===

bool InAppWebView::OnDomFullscreenRequest(bool fullscreen) {
  // This is called when JavaScript requests fullscreen via Element.requestFullscreen()
  // or exits via Document.exitFullscreen()

  if (waiting_fullscreen_notify_) {
    // Already processing a fullscreen transition
    return false;
  }

  if (fullscreen == is_fullscreen_) {
    // Already in the requested state - dispatch the event immediately
    // This handles cases where DOM fullscreen requests are mixed with
    // system fullscreen commands
#ifdef HAVE_WPE_BACKEND_LEGACY
    if (wpe_backend_ != nullptr) {
      if (is_fullscreen_) {
        wpe_view_backend_dispatch_did_enter_fullscreen(wpe_backend_);
      } else {
        wpe_view_backend_dispatch_did_exit_fullscreen(wpe_backend_);
      }
    }
#endif
    return true;
  }

  waiting_fullscreen_notify_ = true;
  is_fullscreen_ = fullscreen;

  // Notify the Dart side about the fullscreen request
  // The Dart side should handle the actual fullscreen transition
  if (channel_delegate_) {
    if (fullscreen) {
      channel_delegate_->onEnterFullscreen();
    } else {
      channel_delegate_->onExitFullscreen();
    }
  }

  // Dispatch the fullscreen state to WPE
#ifdef HAVE_WPE_BACKEND_LEGACY
  if (wpe_backend_ != nullptr) {
    if (fullscreen) {
      wpe_view_backend_dispatch_did_enter_fullscreen(wpe_backend_);
    } else {
      wpe_view_backend_dispatch_did_exit_fullscreen(wpe_backend_);
    }
  }
#endif

  waiting_fullscreen_notify_ = false;

  return true;
}

// === Input Handling ===

void InAppWebView::SetTextureOffset(double x, double y) {
  texture_offset_x_ = x;
  texture_offset_y_ = y;
}

void InAppWebView::SetCursorPos(double x, double y) {
  // Store logical coordinates
  cursor_x_ = x;
  cursor_y_ = y;

#ifdef HAVE_WPE_PLATFORM
  // Send pointer motion event using WPEPlatform API
  if (wpe_view_ != nullptr) {
    // Include button_state_ in modifiers so dragging (text selection) works correctly
    WPEModifiers modifiers = static_cast<WPEModifiers>(current_modifiers_ | button_state_);
    WPEEvent* event = wpe_event_pointer_move_new(
        WPE_EVENT_POINTER_MOVE,
        wpe_view_,
        WPE_INPUT_SOURCE_MOUSE,
        static_cast<guint32>(g_get_monotonic_time() / 1000),
        modifiers,
        x,  // Scale to physical pixels
        y,
        0.0,  // delta_x (no delta for absolute position)
        0.0   // delta_y
    );
    wpe_view_event(wpe_view_, event);
    wpe_event_unref(event);
  }
#elif defined(HAVE_WPE_BACKEND_LEGACY)
  // Send pointer motion event with scaled coordinates (logical -> physical)
  if (wpe_backend_ != nullptr) {
    struct wpe_input_pointer_event event = {};
    event.type = wpe_input_pointer_event_type_motion;
    event.time = g_get_monotonic_time() / 1000;  // Convert to milliseconds
    // Scale coordinates from logical to physical pixels
    event.x = static_cast<int>(x * scale_factor_);
    event.y = static_cast<int>(y * scale_factor_);
    event.state = 0;  // No button state change for motion events
    event.modifiers = current_modifiers_ | button_state_;  // Include pressed button modifiers
    wpe_view_backend_dispatch_pointer_event(wpe_backend_, &event);
  }
#endif
}

void InAppWebView::SetPointerButton(int kind, int button, int clickCount) {
  // Hide all popups on any button DOWN (kind=1 is Down per WpePointerEventKind enum)
  if (kind == static_cast<int>(WpePointerEventKind::Down)) {
    HideAllPopups();
  }

#ifdef HAVE_WPE_PLATFORM
  if (wpe_view_ == nullptr)
    return;

  // No need to scale coordinates from logical to physical pixels as WPEPlatform handles this internally.
  double scaled_x = cursor_x_;
  double scaled_y = cursor_y_;

  // Map button: Flutter uses 0=none, 1=primary, 2=secondary, 3=tertiary
  // WPE/GDK uses: 1=Left, 2=Middle, 3=Right
  guint wpe_button;
  switch (button) {
    case 1:
      wpe_button = 1;
      break;  // Primary -> Left
    case 2:
      wpe_button = 3;
      break;  // Secondary -> Right (context menu)
    case 3:
      wpe_button = 2;
      break;  // Tertiary -> Middle
    default:
      wpe_button = 1;
      break;  // Default to primary
  }

  // WPEPlatform button modifier bits: WPE_MODIFIER_POINTER_BUTTON1 = 1 << 8, etc.
  // Button 1 -> bit 8, Button 2 -> bit 9, Button 3 -> bit 10
  const uint32_t button_modifier_bit = 1u << (7 + wpe_button);

  guint32 time = static_cast<guint32>(g_get_monotonic_time() / 1000);
  WPEEventType event_type;

  switch (static_cast<WpePointerEventKind>(kind)) {
    case WpePointerEventKind::Down:
      event_type = WPE_EVENT_POINTER_DOWN;
      // Update button state BEFORE creating the event
      button_state_ |= button_modifier_bit;
      break;
    case WpePointerEventKind::Up:
      event_type = WPE_EVENT_POINTER_UP;
      // Update button state AFTER the event (but include in modifiers)
      break;
    default:
      // Ignore enter/leave/cancel etc for button events
      return;
  }

  // Include button state in modifiers for proper drag detection
  WPEModifiers modifiers = static_cast<WPEModifiers>(current_modifiers_ | button_state_);

  // First send a motion event to ensure WebKit has the correct cursor position
  WPEEvent* motion_event = wpe_event_pointer_move_new(
      WPE_EVENT_POINTER_MOVE,
      wpe_view_,
      WPE_INPUT_SOURCE_MOUSE,
      time,
      modifiers,
      scaled_x,
      scaled_y,
      0.0,
      0.0
  );
  wpe_view_event(wpe_view_, motion_event);
  wpe_event_unref(motion_event);

  // Send button event
  // CRITICAL: press_count must be 0 for UP events, only non-zero for DOWN events
  // (WPEPlatform assertion: !pressCount || type == WPE_EVENT_POINTER_DOWN)
  guint press_count = (event_type == WPE_EVENT_POINTER_DOWN) 
      ? static_cast<guint>(clickCount) 
      : 0;
  
  WPEEvent* button_event = wpe_event_pointer_button_new(
      event_type,
      wpe_view_,
      WPE_INPUT_SOURCE_MOUSE,
      time,
      modifiers,
      wpe_button,
      scaled_x,
      scaled_y,
      press_count
  );
  wpe_view_event(wpe_view_, button_event);
  wpe_event_unref(button_event);

  // Clear button state AFTER sending the UP event
  if (event_type == WPE_EVENT_POINTER_UP) {
    button_state_ &= ~button_modifier_bit;
  }

#elif defined(HAVE_WPE_BACKEND_LEGACY)
  if (wpe_backend_ == nullptr)
    return;

  // Scale coordinates from logical to physical pixels
  int scaled_x = static_cast<int>(cursor_x_ * scale_factor_);
  int scaled_y = static_cast<int>(cursor_y_ * scale_factor_);

  // Map button: Flutter uses 0=none, 1=primary, 2=secondary, 3=tertiary
  // WPE/WebKit uses: 1=Left, 2=Right, 3=Middle (see WebEventFactory.cpp)
  // This is a 1:1 mapping for Flutter -> WPE
  uint32_t wpe_button;
  switch (button) {
    case 1:
      wpe_button = 1;
      break;  // Primary -> Left
    case 2:
      wpe_button = 2;
      break;  // Secondary -> Right (context menu)
    case 3:
      wpe_button = 3;
      break;  // Tertiary -> Middle
    default:
      wpe_button = 1;
      break;  // Default to primary
  }

  // WPE button modifier bits for tracking pressed buttons in modifiers field
  // See wpe_input_pointer_modifier_button* in wpe/input.h: button1=1<<20, button2=1<<21,
  // button3=1<<22
  const uint32_t button_modifier_bit = 1u << (19 + wpe_button);

  // First send a motion event to ensure WebKit has the correct cursor position
  // This is important because the button event needs to know where the click occurred
  {
    struct wpe_input_pointer_event motion_event = {};
    motion_event.type = wpe_input_pointer_event_type_motion;
    motion_event.time = g_get_monotonic_time() / 1000;
    motion_event.x = scaled_x;
    motion_event.y = scaled_y;
    motion_event.button = 0;
    motion_event.state = 0;
    motion_event.modifiers = current_modifiers_ | button_state_;
    wpe_view_backend_dispatch_pointer_event(wpe_backend_, &motion_event);
  }

  struct wpe_input_pointer_event event = {};
  event.time = g_get_monotonic_time() / 1000;
  event.x = scaled_x;
  event.y = scaled_y;
  event.button = wpe_button;

  switch (static_cast<WpePointerEventKind>(kind)) {
    case WpePointerEventKind::Down:
      event.type = wpe_input_pointer_event_type_button;
      // state=1 means button is pressed (see WebEventFactory: event->state ? MouseDown : MouseUp)
      event.state = 1;
      button_state_ |= button_modifier_bit;
      event.modifiers = current_modifiers_ | button_state_;
      break;
    case WpePointerEventKind::Up:
      event.type = wpe_input_pointer_event_type_button;
      // state=0 means button is released
      event.state = 0;
      button_state_ &= ~button_modifier_bit;
      event.modifiers = current_modifiers_ | button_state_;
      break;
    default:
      // Ignore enter/leave/cancel etc for button events
      return;
  }

  wpe_view_backend_dispatch_pointer_event(wpe_backend_, &event);
#endif
}

void InAppWebView::SetScrollDelta(double dx, double dy) {
  // Hide all popups when scrolling
  HideAllPopups();

#ifdef HAVE_WPE_PLATFORM
  if (wpe_view_ == nullptr)
    return;

  // No need to scale coordinates from logical to physical pixels as WPEPlatform handles this internally.
  double scaled_x = cursor_x_;
  double scaled_y = cursor_y_;

  WPEModifiers modifiers = static_cast<WPEModifiers>(current_modifiers_);
  guint32 time = static_cast<guint32>(g_get_monotonic_time() / 1000);

  // Flutter provides delta in logical pixels.
  // No need to scale coordinates from logical to physical pixels as WPEPlatform handles this internally.
  double delta_x = dx;
  double delta_y = dy;

  WPEEvent* event = wpe_event_scroll_new(
      wpe_view_,
      WPE_INPUT_SOURCE_MOUSE,
      time,
      modifiers,
      delta_x,
      delta_y,
      TRUE,   // precise_deltas - we have exact pixel values
      FALSE,  // is_stop - this is not a scroll stop event
      scaled_x,
      scaled_y
  );
  wpe_view_event(wpe_view_, event);
  wpe_event_unref(event);

#elif defined(HAVE_WPE_BACKEND_LEGACY)
  if (wpe_backend_ == nullptr)
    return;

  // Scale coordinates from logical to physical pixels
  int scaled_x = static_cast<int>(cursor_x_ * scale_factor_);
  int scaled_y = static_cast<int>(cursor_y_ * scale_factor_);

  // Use the 2D axis event with smooth scrolling for proper pixel-based scrolling
  // The wpe_input_axis_2d_event provides x_axis and y_axis as doubles
  // With wpe_input_axis_event_type_motion_smooth | wpe_input_axis_event_type_mask_2d,
  // WebKit will use the raw pixel values for smooth scrolling

  struct wpe_input_axis_2d_event event = {};
  event.base.type = static_cast<wpe_input_axis_event_type>(wpe_input_axis_event_type_motion_smooth |
                                                           wpe_input_axis_event_type_mask_2d);
  event.base.time = g_get_monotonic_time() / 1000;
  event.base.x = scaled_x;
  event.base.y = scaled_y;
  event.base.modifiers = current_modifiers_;

  // Flutter provides delta in logical pixels, scale to physical and apply sensitivity
  // The scale factor converts logical to physical pixels
  event.x_axis = dx * scale_factor_;
  event.y_axis = dy * scale_factor_;

  wpe_view_backend_dispatch_axis_event(wpe_backend_, &event.base);
#endif
}

void InAppWebView::SendKeyEvent(int type, int64_t keyCode, int scanCode, int modifiers,
                                const std::string& characters) {
  // Intercept clipboard shortcuts on key down (type=0)
  // Modifiers: Control=1, Shift=2, Alt=4, Meta=8
  const bool isCtrl = (modifiers & 1) != 0;
  const bool isShift = (modifiers & 2) != 0;
  const bool isKeyDown = (type == 0);

  if (isCtrl && isKeyDown && webview_ != nullptr) {
    // Check for clipboard and common editing shortcuts
    // keyCode is XKB keysym, lowercase letters are 0x61-0x7a
    switch (keyCode) {
      case 0x63:  // 'c' - Copy
        copyToClipboard();
        return;  // Don't send the key event to WebKit
      case 0x78:  // 'x' - Cut
        cutToClipboard();
        return;
      case 0x76:  // 'v' - Paste (Ctrl+Shift+V = paste as plain text)
        if (isShift) {
          pasteAsPlainText();
        } else {
          pasteFromClipboard();
        }
        return;
      case 0x61:  // 'a' - Select All
        selectAll();
        return;
      case 0x7a:  // 'z' - Undo (Ctrl+Shift+Z = Redo on some systems)
        if (isShift) {
          redo();
        } else {
          undo();
        }
        return;
      case 0x79:  // 'y' - Redo
        redo();
        return;
    }
  }

  current_modifiers_ = static_cast<uint32_t>(modifiers);

#ifdef HAVE_WPE_PLATFORM
  if (wpe_view_ == nullptr)
    return;

  WPEModifiers wpe_modifiers = static_cast<WPEModifiers>(current_modifiers_);
  guint32 time = static_cast<guint32>(g_get_monotonic_time() / 1000);

  // type: 0=down, 1=up, 2=repeat
  WPEEventType event_type;
  switch (type) {
    case 0:  // down
    case 2:  // repeat (also treated as key down in WPE)
      event_type = WPE_EVENT_KEYBOARD_KEY_DOWN;
      break;
    case 1:  // up
      event_type = WPE_EVENT_KEYBOARD_KEY_UP;
      break;
    default:
      return;
  }

  WPEEvent* event = wpe_event_keyboard_new(
      event_type,
      wpe_view_,
      WPE_INPUT_SOURCE_KEYBOARD,
      time,
      wpe_modifiers,
      static_cast<guint>(scanCode),   // hardware keycode
      static_cast<guint>(keyCode)     // keyval (XKB keysym)
  );
  wpe_view_event(wpe_view_, event);
  wpe_event_unref(event);

#elif defined(HAVE_WPE_BACKEND_LEGACY)
  if (wpe_backend_ == nullptr)
    return;

  struct wpe_input_keyboard_event event = {};
  event.time = g_get_monotonic_time() / 1000;
  event.key_code = static_cast<uint32_t>(keyCode);
  event.hardware_key_code = static_cast<uint32_t>(scanCode);
  // type: 0=down, 1=up, 2=repeat
  event.pressed = (type == 0 || type == 2);

  // Modifiers from Dart are already in WPE format:
  // Control=1, Shift=2, Alt=4, Meta=8
  event.modifiers = current_modifiers_;

  wpe_view_backend_dispatch_keyboard_event(wpe_backend_, &event);
#endif
}

void InAppWebView::SendTouchEvent(
    int type, int id, double x, double y,
    const std::vector<std::tuple<int, double, double, int>>& touchPoints) {
#ifdef HAVE_WPE_PLATFORM
  if (wpe_view_ == nullptr)
    return;

  WPEModifiers modifiers = static_cast<WPEModifiers>(current_modifiers_);
  guint32 time = static_cast<guint32>(g_get_monotonic_time() / 1000);

  // Map Dart touch event types to WPE types
  // Dart: 0=down, 1=up, 2=move, 3=cancel
  WPEEventType event_type;
  switch (type) {
    case 0:
      event_type = WPE_EVENT_TOUCH_DOWN;
      break;
    case 1:
      event_type = WPE_EVENT_TOUCH_UP;
      break;
    case 2:
      event_type = WPE_EVENT_TOUCH_MOVE;
      break;
    case 3:
      event_type = WPE_EVENT_TOUCH_CANCEL;
      break;
    default:
      return;
  }

  // For WPEPlatform, we send individual touch events for each point.
  // The main touch point is the one that triggered this event.
  // No need to scale coordinates from logical to physical pixels as WPEPlatform handles this internally.
  double scaled_x = x;
  double scaled_y = y;

  WPEEvent* event = wpe_event_touch_new(
      event_type,
      wpe_view_,
      WPE_INPUT_SOURCE_TOUCHSCREEN,
      time,
      modifiers,
      static_cast<guint32>(id),
      scaled_x,
      scaled_y
  );
  wpe_view_event(wpe_view_, event);
  wpe_event_unref(event);

#elif defined(HAVE_WPE_BACKEND_LEGACY)
  if (wpe_backend_ == nullptr)
    return;

  // Map Dart touch event types to WPE types
  // Dart: 0=down, 1=up, 2=move, 3=cancel
  // WPE: wpe_input_touch_event_type_down=1, up=3, motion=2
  enum wpe_input_touch_event_type wpe_type;
  switch (type) {
    case 0:
      wpe_type = wpe_input_touch_event_type_down;
      break;
    case 1:
      wpe_type = wpe_input_touch_event_type_up;
      break;
    case 2:
      wpe_type = wpe_input_touch_event_type_motion;
      break;
    default:
      wpe_type = wpe_input_touch_event_type_null;
      break;  // cancel
  }

  // Build the raw touchpoints array
  std::vector<struct wpe_input_touch_event_raw> raw_points;
  raw_points.reserve(touchPoints.size());

  for (const auto& point : touchPoints) {
    struct wpe_input_touch_event_raw raw = {};
    raw.id = std::get<0>(point);
    raw.x = static_cast<int32_t>(std::get<1>(point) * scale_factor_);
    raw.y = static_cast<int32_t>(std::get<2>(point) * scale_factor_);

    // Map point type
    int pointType = std::get<3>(point);
    switch (pointType) {
      case 0:
        raw.type = wpe_input_touch_event_type_down;
        break;
      case 1:
        raw.type = wpe_input_touch_event_type_up;
        break;
      case 2:
        raw.type = wpe_input_touch_event_type_motion;
        break;
      default:
        raw.type = wpe_input_touch_event_type_null;
        break;
    }
    raw.time = g_get_monotonic_time() / 1000;

    raw_points.push_back(raw);
  }

  // Build the touch event
  struct wpe_input_touch_event event = {};
  event.touchpoints = raw_points.data();
  event.touchpoints_length = raw_points.size();
  event.type = wpe_type;
  event.id = id;
  event.time = g_get_monotonic_time() / 1000;
  event.modifiers = current_modifiers_;

  wpe_view_backend_dispatch_touch_event(wpe_backend_, &event);
#endif
}

// === Pixel Buffer Access ===

size_t InAppWebView::GetPixelBufferSize(uint32_t* out_width, uint32_t* out_height) const {
  // With WPE + FDO, we typically use DMA-BUF export instead of CPU copy
  // This is a fallback for when DMA-BUF is not available
  std::lock_guard<std::mutex> lock(buffer_swap_mutex_);

  size_t read_idx = read_buffer_index_.load(std::memory_order_acquire);
  const auto& buffer = pixel_buffers_[read_idx];

  if (out_width)
    *out_width = static_cast<uint32_t>(buffer.width);
  if (out_height)
    *out_height = static_cast<uint32_t>(buffer.height);

  return buffer.data.size();
}

bool InAppWebView::CopyPixelBufferTo(uint8_t* dst, size_t dst_size, uint32_t* out_width,
                                     uint32_t* out_height) const {
  std::lock_guard<std::mutex> lock(buffer_swap_mutex_);

  size_t read_idx = read_buffer_index_.load(std::memory_order_acquire);
  const auto& buffer = pixel_buffers_[read_idx];

  if (buffer.data.empty() || dst_size < buffer.data.size()) {
    return false;
  }

  // Use SIMD-optimized memory copy for better performance
  FastMemcpy(dst, buffer.data.data(), buffer.data.size());

  if (out_width)
    *out_width = static_cast<uint32_t>(buffer.width);
  if (out_height)
    *out_height = static_cast<uint32_t>(buffer.height);

  return true;
}

bool InAppWebView::HasDmaBufExport() const {
#ifdef HAVE_WPE_PLATFORM
  std::lock_guard<std::mutex> lock(wpe_buffer_mutex_);
  return current_egl_image_ != nullptr;
#elif defined(HAVE_WPE_BACKEND_LEGACY)
  std::lock_guard<std::mutex> lock(exported_image_mutex_);
  return exported_image_ != nullptr;
#else
  return false;
#endif
}

bool InAppWebView::GetDmaBufFd(int* fd, uint32_t* stride, uint32_t* width, uint32_t* height) const {
#ifdef HAVE_WPE_BACKEND_LEGACY
  std::lock_guard<std::mutex> lock(exported_image_mutex_);
  if (exported_image_ == nullptr) {
    return false;
  }

  // Get DMA-BUF file descriptor from the exported image
  // This allows zero-copy sharing with Flutter's texture system
  // Note: The actual API depends on the WPE version
  // This is a simplified version

  if (width)
    *width = static_cast<uint32_t>(width_);
  if (height)
    *height = static_cast<uint32_t>(height_);

  // In a real implementation, you'd get the DMA-BUF FD from the EGL image
  // For now, return false to indicate not implemented
  return false;
#else
  // WPEPlatform uses a different rendering model
  return false;
#endif
}

void* InAppWebView::GetCurrentEglImage(uint32_t* out_width, uint32_t* out_height) const {
#ifdef HAVE_WPE_PLATFORM
  // WPEPlatform: Return the EGL image from our buffer-rendered callback
  std::lock_guard<std::mutex> lock(wpe_buffer_mutex_);
  
  if (current_egl_image_ == nullptr) {
    if (out_width)
      *out_width = 0;
    if (out_height)
      *out_height = 0;
    return nullptr;
  }
  
  if (out_width)
    *out_width = current_buffer_width_;
  if (out_height)
    *out_height = current_buffer_height_;
  
  return current_egl_image_;
  
#elif defined(HAVE_WPE_BACKEND_LEGACY)
  // Protect exported_image_ access - OnExportDmaBuf may be called from WPE's thread
  std::lock_guard<std::mutex> lock(exported_image_mutex_);
  
  if (exported_image_ == nullptr) {
    if (out_width)
      *out_width = 0;
    if (out_height)
      *out_height = 0;
    return nullptr;
  }

  // Get dimensions from the exported image
  uint32_t img_width = wpe_fdo_egl_exported_image_get_width(exported_image_);
  uint32_t img_height = wpe_fdo_egl_exported_image_get_height(exported_image_);

  if (out_width)
    *out_width = img_width;
  if (out_height)
    *out_height = img_height;

  // Return the EGL image handle (EGLImageKHR)
  return wpe_fdo_egl_exported_image_get_egl_image(exported_image_);
#else
  // No backend available
  if (out_width)
    *out_width = 0;
  if (out_height)
    *out_height = 0;
  return nullptr;
#endif
}

void InAppWebView::SetOnFrameAvailable(std::function<void()> callback) {
  on_frame_available_ = std::move(callback);
  
#ifdef HAVE_WPE_PLATFORM
  // Force WPE to render a new frame by triggering a resize.
  // This is needed because:
  // 1. The first frame may have been rendered before this callback was set
  // 2. We release buffers immediately in OnWpePlatformBufferRendered, so
  //    old EGL images may be invalid
  // 3. A resize notification causes WPE to re-render with the current content
  //
  // We use g_idle_add to defer this slightly, ensuring the texture registration
  // is complete before we trigger the new frame.
  if (on_frame_available_ && wpe_toplevel_ != nullptr) {
    WPEToplevel* toplevel = wpe_toplevel_;
    int w = width_;
    int h = height_;
    g_idle_add_full(G_PRIORITY_HIGH, [](gpointer user_data) -> gboolean {
      auto* data = static_cast<std::tuple<WPEToplevel*, int, int>*>(user_data);
      WPEToplevel* tl = std::get<0>(*data);
      int width = std::get<1>(*data);
      int height = std::get<2>(*data);
      // Trigger a resize to force WPE to render a new frame
      if (tl != nullptr) {
        wpe_toplevel_resize(tl, width, height);
      }
      delete data;
      return G_SOURCE_REMOVE;
    }, new std::tuple<WPEToplevel*, int, int>(toplevel, w, h), nullptr);
  }
#endif
}

void InAppWebView::SetOnCursorChanged(std::function<void(const std::string&)> callback) {
  on_cursor_changed_ = std::move(callback);
}

void InAppWebView::SetOnProgressChanged(std::function<void(double)> callback) {
  on_progress_changed_ = std::move(callback);
}

void InAppWebView::SetOnNavigationStateChanged(std::function<void()> callback) {
  on_navigation_state_changed_ = std::move(callback);
}

void InAppWebView::OnShouldOverrideUrlLoadingDecision(int64_t decision_id, bool allow) {
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

void InAppWebView::OnLoadChanged(WebKitWebView* web_view, WebKitLoadEvent load_event,
                                 gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);
  
  // Check if WebView is still valid (WebProcess may have crashed)
  if (!WEBKIT_IS_WEB_VIEW(web_view)) {
    return;
  }
  
  if (self->channel_delegate_ == nullptr) {
    return;
  }

  switch (load_event) {
    case WEBKIT_LOAD_STARTED: {
      // Hide all popups when a new page starts loading
      self->HideAllPopups();
      
      std::string current_url = self->getUrl().value_or("");
      self->channel_delegate_->onLoadStart(current_url);
      break;
    }
    case WEBKIT_LOAD_REDIRECTED:
      // Redirects are handled internally by WebKit
      break;
    case WEBKIT_LOAD_COMMITTED:
      // Notify that page content is starting to be visible
      self->channel_delegate_->onPageCommitVisible(self->getUrl().value_or(""));
      break;
    case WEBKIT_LOAD_FINISHED:
      self->channel_delegate_->onLoadStop(self->getUrl().value_or(""));
      break;
    default:
      break;
  }
}

gboolean InAppWebView::OnDecidePolicy(WebKitWebView* web_view, WebKitPolicyDecision* decision,
                                      WebKitPolicyDecisionType decision_type, gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);

  // Handle response policy decisions (for onNavigationResponse and downloads)
  if (decision_type == WEBKIT_POLICY_DECISION_TYPE_RESPONSE) {
    auto* response_decision = WEBKIT_RESPONSE_POLICY_DECISION(decision);
    
    // Get response information for onNavigationResponse
    WebKitURIResponse* response = webkit_response_policy_decision_get_response(response_decision);
    gboolean is_mime_type_supported = webkit_response_policy_decision_is_mime_type_supported(response_decision);
    gboolean is_main_frame = webkit_response_policy_decision_is_main_frame_main_resource(response_decision);
    
    const gchar* uri = webkit_uri_response_get_uri(response);
    const gchar* mimeType = webkit_uri_response_get_mime_type(response);
    gint64 contentLength = webkit_uri_response_get_content_length(response);
    guint statusCode = webkit_uri_response_get_status_code(response);
    
    // If channel_delegate exists and settings permit, send onNavigationResponse event
    if (self->channel_delegate_ && self->settings_ && self->settings_->useOnNavigationResponse) {
      // Keep decision alive for async callback
      g_object_ref(decision);
      
      auto callback = std::make_unique<WebViewChannelDelegate::NavigationResponseCallback>();
      
      callback->nonNullSuccess = [self, decision, is_mime_type_supported](int action) -> bool {
        // NavigationResponseAction: CANCEL=0, ALLOW=1, DOWNLOAD=2
        switch (action) {
          case 0:  // CANCEL
            webkit_policy_decision_ignore(decision);
            break;
          case 2:  // DOWNLOAD
            webkit_policy_decision_download(decision);
            break;
          case 1:  // ALLOW (default)
          default:
            if (!is_mime_type_supported && self->settings_ && self->settings_->useOnDownloadStart) {
              // WebKit can't display this - convert to download
              webkit_policy_decision_download(decision);
            } else {
              webkit_policy_decision_use(decision);
            }
            break;
        }
        g_object_unref(decision);
        return false;  // Don't run defaultBehaviour
      };
      
      callback->defaultBehaviour = [decision, is_mime_type_supported, self](const std::optional<int>& action) {
        // Default: allow navigation (or download if MIME not supported and download enabled)
        if (!is_mime_type_supported && self->settings_ && self->settings_->useOnDownloadStart) {
          webkit_policy_decision_download(decision);
        } else {
          webkit_policy_decision_use(decision);
        }
        g_object_unref(decision);
      };
      
      callback->error = [decision, is_mime_type_supported, self](const std::string& code, const std::string& message) {
        debugLog("Error in onNavigationResponse: " + code + " - " + message);
        // On error, allow navigation
        if (!is_mime_type_supported && self->settings_ && self->settings_->useOnDownloadStart) {
          webkit_policy_decision_download(decision);
        } else {
          webkit_policy_decision_use(decision);
        }
        g_object_unref(decision);
      };
      
      self->channel_delegate_->onNavigationResponse(
          uri != nullptr ? std::string(uri) : "",
          mimeType != nullptr ? std::optional<std::string>(mimeType) : std::nullopt,
          contentLength,
          static_cast<int>(statusCode),
          is_main_frame != FALSE,
          is_mime_type_supported != FALSE,
          std::move(callback));
      
      return TRUE;  // We're handling this asynchronously
    }
    
    // Fallback: check if the response should trigger a download (no onNavigationResponse handler)
    // This happens when:
    // 1. Content-Disposition header is "attachment"
    // 2. WebKit can't display the MIME type
    if (!is_mime_type_supported) {
      // WebKit can't display this MIME type - convert to download
      // This will trigger the download-started signal on NetworkSession
      if (self->settings_ && self->settings_->useOnDownloadStart) {
        webkit_policy_decision_download(decision);
        return TRUE;
      }
    }
    
    return FALSE;  // Let WebKit handle the response normally
  }

  if (decision_type != WEBKIT_POLICY_DECISION_TYPE_NAVIGATION_ACTION) {
    return FALSE;  // Let WebKit handle other decision types
  }

  auto* nav_decision = WEBKIT_NAVIGATION_POLICY_DECISION(decision);
  auto* nav_action = webkit_navigation_policy_decision_get_navigation_action(nav_decision);
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
          urlRequest, is_for_main_frame,
          std::nullopt,  // isRedirect - not easily available in WebKit
          navActionType);

      // Create callback to handle the response
      auto callback = std::make_unique<WebViewChannelDelegate::ShouldOverrideUrlLoadingCallback>();
      
      // CRITICAL: Set error handler to prevent navigation from being blocked on channel errors
      // Allow navigation on error to prevent page from being stuck
      callback->error = [self, decision_id](const std::string& code, const std::string& message) {
        g_warning("shouldOverrideUrlLoading channel error: %s - %s", code.c_str(), message.c_str());
        // Allow navigation on error to prevent page from being stuck
        self->OnShouldOverrideUrlLoadingDecision(decision_id, true);
      };
      
      callback->defaultBehaviour =
          [self, decision_id](const std::optional<NavigationActionPolicy> result) {
            bool allow = result.has_value() && result.value() == NavigationActionPolicy::allow;
            self->OnShouldOverrideUrlLoadingDecision(decision_id, allow);
          };

      // Notify Dart side with callback
      self->channel_delegate_->shouldOverrideUrlLoading(navigationAction, std::move(callback));

      return TRUE;  // We're handling this asynchronously
    }
  }

  return FALSE;  // Let WebKit proceed with navigation
}

void InAppWebView::OnNotifyEstimatedLoadProgress(GObject* object, GParamSpec* pspec,
                                                 gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);

  double progress = webkit_web_view_get_estimated_load_progress(WEBKIT_WEB_VIEW(object));
  int progress_percent = static_cast<int>(progress * 100);

  // Notify Dart via channel delegate
  if (self->channel_delegate_) {
    self->channel_delegate_->onProgressChanged(progress_percent);
  }

  // Notify native progress callback (for InAppBrowser)
  if (self->on_progress_changed_) {
    self->on_progress_changed_(progress);
  }
}

void InAppWebView::OnNotifyTitle(GObject* object, GParamSpec* pspec, gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);
  if (self->channel_delegate_ == nullptr)
    return;

  const gchar* title = webkit_web_view_get_title(WEBKIT_WEB_VIEW(object));
  if (title != nullptr) {
    self->channel_delegate_->onTitleChanged(std::string(title));
  }
}

void InAppWebView::OnNotifyUri(GObject* object, GParamSpec* pspec, gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);
  if (self->channel_delegate_ == nullptr)
    return;

  const gchar* uri = webkit_web_view_get_uri(WEBKIT_WEB_VIEW(object));
  std::optional<std::string> url = uri ? std::optional<std::string>(uri) : std::nullopt;
  
  // isReload is not easily detectable - pass false by default
  self->channel_delegate_->onUpdateVisitedHistory(url, false);
}

gboolean InAppWebView::OnLoadFailed(WebKitWebView* web_view, WebKitLoadEvent load_event,
                                    gchar* failing_uri, GError* error, gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);
  
  if (self->channel_delegate_ == nullptr)
    return FALSE;

  // Create WebResourceRequest for the failing URL
  auto request = std::make_shared<WebResourceRequest>(
      failing_uri ? std::optional<std::string>(failing_uri) : std::nullopt,
      std::optional<std::string>("GET"),  // Default method
      std::nullopt,                       // headers
      std::optional<bool>(true)           // isForMainFrame - load failures are typically main frame
  );

  // Create WebResourceError from GError
  auto webError =
      std::make_shared<WebResourceError>(error ? std::string(error->message) : "Unknown error",
                                         error ? static_cast<int64_t>(error->code) : -1);

  self->channel_delegate_->onReceivedError(request, webError);

  return FALSE;
}

gboolean InAppWebView::OnLoadFailedWithTlsErrors(WebKitWebView* web_view, gchar* failing_uri,
                                                 GTlsCertificate* certificate,
                                                 GTlsCertificateFlags errors, gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);

  if (!self->channel_delegate_) {
    return FALSE;
  }

  // Create the challenge from TLS error info
  auto challenge = ServerTrustChallenge::fromTlsError(
      std::string(failing_uri != nullptr ? failing_uri : ""),
      certificate, errors);

  // Keep a reference to the certificate and web view for later use
  g_object_ref(certificate);
  g_object_ref(web_view);

  auto callback = std::make_unique<WebViewChannelDelegate::ServerTrustAuthRequestCallback>();
  callback->nonNullSuccess = [web_view, failing_uri, certificate](
      const ServerTrustAuthResponse& response) -> bool {
    if (response.action == ServerTrustAuthResponseAction::PROCEED) {
      // Allow the certificate for this host
      // Extract host from failing_uri
      std::string host = get_host_from_url(std::string(failing_uri != nullptr ? failing_uri : ""));
      if (!host.empty()) {
        // Get the network session from the web view
        WebKitNetworkSession* network_session = webkit_web_view_get_network_session(web_view);
        webkit_network_session_allow_tls_certificate_for_host(network_session, certificate, host.c_str());
        // Reload the page to retry with the allowed certificate
        webkit_web_view_reload(web_view);
      }
    }
    g_object_unref(certificate);
    g_object_unref(web_view);
    return false;
  };

  callback->defaultBehaviour = [certificate, web_view](const std::optional<ServerTrustAuthResponse>& response) {
    // Default: cancel the request (do nothing, WebKit will handle the error)
    g_object_unref(certificate);
    g_object_unref(web_view);
  };

  callback->error = [certificate, web_view](const std::string& code, const std::string& message) {
    debugLog("Error in onReceivedServerTrustAuthRequest: " + code + " - " + message);
    g_object_unref(certificate);
    g_object_unref(web_view);
  };

  self->channel_delegate_->onReceivedServerTrustAuthRequest(std::move(challenge), std::move(callback));

  // Return TRUE to indicate we're handling this asynchronously
  return TRUE;
}

void InAppWebView::OnCloseRequest(WebKitWebView* web_view, gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);
  if (self->channel_delegate_) {
    self->channel_delegate_->onCloseWindow();
  }
}

// WPE WebKit create signal handler - returns WebKitWebView* (not GtkWidget*)
// 
// In WPE WebKit, creating a new WebView requires a WebKitWebViewBackend which
// is tightly coupled with the WPE FDO exportable pipeline. Unlike WebKitGTK,
// we cannot easily create a related view without the full backend setup.
// 
// Multi-Window Support
//
// When JavaScript calls window.open() or a link has target="_blank", WebKit emits
// the "create" signal. We must create a new WebView that shares the web process
// with the parent (for session/cookies) and return it to WebKit.
//
// The pattern used here:
// 1. Get a window ID from the manager
// 2. Create a new InAppWebView with the parent webview as "related view"
// 3. Store the InAppWebView in windowWebViews for later attachment by Dart
// 4. Notify Dart via onCreateWindow callback
// 5. Return the new WebKitWebView* to WebKit (so window.open() returns a real window)
//
// If Dart doesn't handle it, the default behaviour loads the URL in the parent view.
WebKitWebView* InAppWebView::OnCreateWebView(WebKitWebView* web_view,
                                             WebKitNavigationAction* navigation_action,
                                             gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);

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

  // Get window ID from manager
  int64_t windowId = 0;
  if (self->manager_ != nullptr) {
    windowId = self->manager_->GetNextWindowId();
  } else {
    // Fallback to static counter if no manager
    static int64_t window_autoincrement_id = 0;
    windowId = ++window_autoincrement_id;
  }

  // Get the URL from the navigation action
  WebKitURIRequest* request = webkit_navigation_action_get_request(navigation_action);
  std::optional<std::string> url_to_load;
  if (request != nullptr) {
    const gchar* uri = webkit_uri_request_get_uri(request);
    if (uri != nullptr) {
      url_to_load = std::string(uri);
    }
  }

  // Create a new InAppWebView that shares the web process with the parent
  // This is the key difference from the old implementation - we actually create
  // a real WebView that WebKit can use for the popup window
  InAppWebViewCreationParams windowParams;
  windowParams.id = windowId;
  windowParams.gtkWindow = self->gtk_window_;
  windowParams.flView = self->fl_view_;  // Pass FlView for focus restoration
  windowParams.manager = self->manager_;
  windowParams.initialSettings = self->settings_;  // Share parent settings
  windowParams.windowId = windowId;
  windowParams.relatedWebView = self->webview_;  // Share web process with parent
  
  // Create the new InAppWebView for the popup window
  auto windowWebView = std::make_unique<InAppWebView>(
      self->registrar_, nullptr, windowId, windowParams);
  
  // Get the WebKitWebView* to return to WebKit BEFORE moving the unique_ptr
  WebKitWebView* newWebKitWebView = windowWebView->webview();
  
  if (newWebKitWebView == nullptr) {
    errorLog("InAppWebView::OnCreateWebView: Failed to create popup WebView");
    // Fall back to loading in parent
    if (url_to_load.has_value() && self->webview_ != nullptr) {
      webkit_web_view_load_uri(self->webview_, url_to_load.value().c_str());
    }
    return nullptr;
  }

  // Store the InAppWebView in the manager for later attachment by Dart
  if (self->manager_ != nullptr) {
    auto transport = std::make_unique<WebViewTransport>(std::move(windowWebView), url_to_load);
    self->manager_->AddWindowWebView(windowId, std::move(transport));
  }

  auto createWindowAction =
      std::make_unique<CreateWindowAction>(navigation_action, windowId, nullptr);

  auto callback = std::make_unique<WebViewChannelDelegate::CreateWindowCallback>();

  callback->nonNullSuccess = [](bool handledByClient) { return !handledByClient; };

  // Capture for cleanup on default behaviour
  auto* manager = self->manager_;
  auto* parentWebview = self->webview_;
  std::string captured_url = url_to_load.value_or("");
  int64_t capturedWindowId = windowId;
  
  callback->defaultBehaviour = [manager, parentWebview, captured_url, capturedWindowId](std::optional<bool>) {
    // If the Dart side doesn't handle the window, clean up and load in current view
    if (manager != nullptr) {
      manager->RemoveWindowWebView(capturedWindowId);
    }
    // Load the URL in the parent view instead
    if (!captured_url.empty() && parentWebview != nullptr) {
      webkit_web_view_load_uri(parentWebview, captured_url.c_str());
    }
  };

  if (self->channel_delegate_) {
    self->channel_delegate_->onCreateWindow(std::move(createWindowAction), std::move(callback));
  } else {
    callback->defaultBehaviour(std::nullopt);
  }

  // Return the new WebKitWebView* to WebKit
  // This allows window.open() to return a real window object to JavaScript
  return newWebKitWebView;
}

gboolean InAppWebView::OnScriptDialog(WebKitWebView* web_view, WebKitScriptDialog* dialog,
                                      gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);

  WebKitScriptDialogType dialogType = webkit_script_dialog_get_dialog_type(dialog);
  const gchar* message = webkit_script_dialog_get_message(dialog);

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

      callback->nonNullSuccess = [](JsAlertResponse response) { return !response.handledByClient; };

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

      callback->defaultBehaviour = [pendingDialogs,
                                    capturedId](std::optional<JsBeforeUnloadResponse>) {
        auto it = pendingDialogs->find(capturedId);
        if (it != pendingDialogs->end()) {
          webkit_script_dialog_confirm_set_confirmed(it->second, TRUE);
          webkit_script_dialog_close(it->second);
          webkit_script_dialog_unref(it->second);
          pendingDialogs->erase(it);
        }
      };

      self->channel_delegate_->onJsBeforeUnload(
          url, messageStr.empty() ? std::nullopt : std::make_optional(messageStr),
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
                                           WebKitPermissionRequest* request, gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);

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

gboolean InAppWebView::OnAuthenticate(WebKitWebView* web_view, WebKitAuthenticationRequest* request,
                                      gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);

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

  // Build protection space for URL credential lookup
  URLProtectionSpace protectionSpace(host ? std::string(host) : "", static_cast<int64_t>(port),
                                     std::nullopt,  // protocol not directly available
                                     realm ? std::make_optional(std::string(realm)) : std::nullopt,
                                     URLProtectionSpace::fromWebKitScheme(scheme), isProxy);

  // Check if this is a client certificate request
  if (scheme == WEBKIT_AUTHENTICATION_SCHEME_CLIENT_CERTIFICATE_REQUESTED) {
    // Handle client certificate request
    auto challenge = std::make_unique<ClientCertChallenge>(protectionSpace, isProxy);
    
    // Keep reference to the request
    g_object_ref(request);
    int64_t requestId = self->next_auth_id_++;
    self->pending_auth_requests_[requestId] = request;
    
    auto callback = std::make_unique<WebViewChannelDelegate::ClientCertRequestCallback>();
    
    auto* pendingRequests = &self->pending_auth_requests_;
    int64_t capturedId = requestId;
    
    callback->nonNullSuccess = [pendingRequests, capturedId](ClientCertResponse response) {
      auto it = pendingRequests->find(capturedId);
      if (it != pendingRequests->end()) {
        switch (response.action) {
          case ClientCertResponseAction::PROCEED: {
            // WPE WebKit's webkit_credential_new_for_certificate() API (since 2.34)
            // allows providing a client certificate.
            // GTlsCertificate constructors (from docs.gtk.org/gio/class.TlsCertificate.html):
            // - g_tls_certificate_new_from_file: PEM file containing cert + optionally private key
            // - g_tls_certificate_new_from_file_with_password: Password-protected file (since 2.72)
            // - g_tls_certificate_new_from_files: Separate cert and key files
            // - g_tls_certificate_new_from_pkcs12: PKCS#12 data with password (since 2.72)
            if (response.certificatePath.has_value() && !response.certificatePath->empty()) {
              GError* error = nullptr;
              GTlsCertificate* cert = nullptr;
              
              std::string keyStoreType = response.keyStoreType.value_or("");
              std::string certPath = response.certificatePath.value();
              std::optional<std::string> password = response.certificatePassword;
              
              if (keyStoreType == "PKCS12" || keyStoreType == "pkcs12") {
                // For PKCS12, we need to read the file and use g_tls_certificate_new_from_pkcs12
                // which requires GLib 2.72+
                #if GLIB_CHECK_VERSION(2, 72, 0)
                // Read the PKCS12 file
                gchar* data = nullptr;
                gsize length = 0;
                if (g_file_get_contents(certPath.c_str(), &data, &length, &error)) {
                  cert = g_tls_certificate_new_from_pkcs12(
                      reinterpret_cast<const guint8*>(data),
                      length,
                      password.has_value() ? password->c_str() : nullptr,
                      &error);
                  g_free(data);
                }
                #else
                debugLog("PKCS12 certificates require GLib 2.72+. Trying PEM fallback...");
                // Fallback to trying as PEM
                cert = g_tls_certificate_new_from_file(certPath.c_str(), &error);
                #endif
              } else if (password.has_value() && !password->empty()) {
                // Password-protected file (e.g., encrypted PEM) - requires GLib 2.72+
                #if GLIB_CHECK_VERSION(2, 72, 0)
                cert = g_tls_certificate_new_from_file_with_password(
                    certPath.c_str(),
                    password->c_str(),
                    &error);
                #else
                debugLog("Password-protected certificates require GLib 2.72+. Trying without password...");
                cert = g_tls_certificate_new_from_file(certPath.c_str(), &error);
                #endif
              } else {
                // Standard PEM file (certificate + optional private key in same file)
                cert = g_tls_certificate_new_from_file(certPath.c_str(), &error);
              }
              
              if (cert != nullptr) {
                // Create credential from certificate
                WebKitCredential* credential = webkit_credential_new_for_certificate(
                    cert, WEBKIT_CREDENTIAL_PERSISTENCE_FOR_SESSION);
                webkit_authentication_request_authenticate(it->second, credential);
                webkit_credential_free(credential);
                g_object_unref(cert);
              } else {
                if (error != nullptr) {
                  debugLog("Failed to load client certificate: " + std::string(error->message));
                  g_error_free(error);
                }
                webkit_authentication_request_cancel(it->second);
              }
            } else {
              // No certificate path provided, cancel
              debugLog("Client certificate PROCEED without certificate path - canceling");
              webkit_authentication_request_cancel(it->second);
            }
            break;
          }
          
          case ClientCertResponseAction::IGNORE:
            // Ignore means don't handle this request (let WebKit handle or retry later)
            webkit_authentication_request_cancel(it->second);
            break;
          
          case ClientCertResponseAction::CANCEL:
          default:
            webkit_authentication_request_cancel(it->second);
            break;
        }
        
        g_object_unref(it->second);
        pendingRequests->erase(it);
      }
      return false;
    };
    
    callback->defaultBehaviour = [pendingRequests, capturedId](std::optional<ClientCertResponse>) {
      auto it = pendingRequests->find(capturedId);
      if (it != pendingRequests->end()) {
        webkit_authentication_request_cancel(it->second);
        g_object_unref(it->second);
        pendingRequests->erase(it);
      }
    };
    
    self->channel_delegate_->onReceivedClientCertRequest(std::move(challenge), std::move(callback));
    
    return TRUE;  // We're handling the request
  }

  // Build ProtectionSpace for libsecret lookup (for HTTP auth)
  ProtectionSpace credProtectionSpace;
  credProtectionSpace.host = host ? std::string(host) : "";
  credProtectionSpace.port = static_cast<int>(port);
  credProtectionSpace.realm = realm ? std::make_optional(std::string(realm)) : std::nullopt;
  // Map scheme to protocol for libsecret
  if (scheme == WEBKIT_AUTHENTICATION_SCHEME_HTTP_BASIC ||
      scheme == WEBKIT_AUTHENTICATION_SCHEME_HTTP_DIGEST ||
      scheme == WEBKIT_AUTHENTICATION_SCHEME_DEFAULT) {
    credProtectionSpace.protocol = "http";
  }

  auto challenge = std::make_unique<HttpAuthenticationChallenge>(protectionSpace, isRetry);

  // Keep reference to the request
  g_object_ref(request);
  int64_t requestId = self->next_auth_id_++;
  self->pending_auth_requests_[requestId] = request;

  auto callback = std::make_unique<WebViewChannelDelegate::HttpAuthRequestCallback>();

  auto* pendingRequests = &self->pending_auth_requests_;
  int64_t capturedId = requestId;
  ProtectionSpace capturedPs = credProtectionSpace;
  PluginInstance* capturedPlugin = self->plugin_;

  callback->nonNullSuccess = [pendingRequests, capturedId, capturedPs, capturedPlugin](HttpAuthResponse response) {
    auto it = pendingRequests->find(capturedId);
    if (it != pendingRequests->end()) {
      switch (response.action) {
        case HttpAuthResponseAction::PROCEED:
          if (response.username.has_value() && response.password.has_value()) {
            WebKitCredential* credential = webkit_credential_new(
                response.username.value().c_str(), response.password.value().c_str(),
                response.permanentPersistence ? WEBKIT_CREDENTIAL_PERSISTENCE_PERMANENT
                                              : WEBKIT_CREDENTIAL_PERSISTENCE_FOR_SESSION);
            webkit_authentication_request_authenticate(it->second, credential);
            
            // Save credential to libsecret if permanent persistence requested
            if (response.permanentPersistence) {
              auto* credDb = capturedPlugin ? capturedPlugin->credentialDatabase : nullptr;
              if (credDb != nullptr) {
                Credential cred(response.username.value(), response.password.value());
                credDb->setHttpAuthCredential(capturedPs, cred);
              }
            }
            
            webkit_credential_free(credential);
          } else {
            webkit_authentication_request_cancel(it->second);
          }
          break;

        case HttpAuthResponseAction::USE_SAVED_CREDENTIAL: {
          // Look up credential from our secure storage
          auto* credDb = capturedPlugin ? capturedPlugin->credentialDatabase : nullptr;
          std::optional<Credential> savedCred = std::nullopt;
          
          if (credDb != nullptr) {
            // Try to get a saved credential
            savedCred = credDb->lookupFirstCredential(capturedPs);
          }

          // Fall back to WebKit's proposed credential if we don't have one
          if (!savedCred.has_value()) {
            WebKitCredential* proposed = webkit_authentication_request_get_proposed_credential(it->second);
            if (proposed != nullptr) {
              const gchar* username = webkit_credential_get_username(proposed);
              const gchar* password = webkit_credential_get_password(proposed);
              if (username != nullptr && password != nullptr) {
                savedCred = Credential(username, password);
              }
              webkit_credential_free(proposed);
            }
          }

          if (savedCred.has_value()) {
            WebKitCredential* credential = webkit_credential_new(
                savedCred->username.c_str(),
                savedCred->password.c_str(),
                WEBKIT_CREDENTIAL_PERSISTENCE_FOR_SESSION);
            webkit_authentication_request_authenticate(it->second, credential);
            webkit_credential_free(credential);
          } else {
            // No saved credential found, cancel
            webkit_authentication_request_cancel(it->second);
          }
          break;
        }

        case HttpAuthResponseAction::CANCEL:
        default:
          webkit_authentication_request_cancel(it->second);
          break;
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

// NOTE: WPE WebKit renders offscreen without a GDK window.
// We use the Flutter window's GDK window to display the native GTK context menu.

gboolean InAppWebView::OnContextMenu(WebKitWebView* web_view, WebKitContextMenu* context_menu,
                                     WebKitHitTestResult* hit_test_result, gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);

  // Disable context menu if setting is enabled
  if (self->settings_ && self->settings_->disableContextMenu) {
    return TRUE;  // Suppress context menu
  }

  // Store the context menu and hit test result for native menu display
  // We need to ref these because WebKit may release them after this callback returns
  if (self->pending_context_menu_ != nullptr) {
    g_object_unref(self->pending_context_menu_);
  }
  self->pending_context_menu_ = context_menu;
  g_object_ref(context_menu);

  if (self->pending_hit_test_result_ != nullptr) {
    g_object_unref(self->pending_hit_test_result_);
  }
  self->pending_hit_test_result_ = hit_test_result;
  if (hit_test_result != nullptr) {
    g_object_ref(hit_test_result);
  }

  // Notify Dart side that context menu is being created
  if (self->channel_delegate_) {
    HitTestResult hitTestResult = HitTestResult::fromWebKitHitTestResult(self->pending_hit_test_result_);
    self->channel_delegate_->onCreateContextMenu(hitTestResult);
  }

  // Store the current cursor position for the context menu
  self->context_menu_x_ = self->cursor_x_;
  self->context_menu_y_ = self->cursor_y_;

  // Show the context menu
  self->ShowNativeContextMenu();

  // Return TRUE to suppress WebKit's default context menu handling
  return TRUE;
}

void InAppWebView::OnContextMenuDismissed(WebKitWebView* web_view, gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);

  // Hide our custom context menu popup when WebKit signals dismissal
  self->HideContextMenu();
}

void InAppWebView::ShowNativeContextMenu() {
  // Use cached GTK window for the popup menu
  if (gtk_window_ == nullptr) {
    errorLog("InAppWebView: Cannot show context menu - no window available");
    return;
  }

  // Create context menu popup if needed
  if (!context_menu_popup_) {
    context_menu_popup_ = std::make_unique<ContextMenuPopup>(gtk_window_);

    // Set up callbacks
    context_menu_popup_->SetItemCallback(
        [this](const std::string& id, const std::string& title) {
          // Try to execute the action directly using WebKit APIs
          int action_id = 0;
          try {
            action_id = std::stoi(id);
          } catch (...) {
            action_id = 0;
          }

          if (action_id > 0 && webview_ != nullptr) {
            // Execute stock actions directly via WebKit API
            WebKitContextMenuAction action = static_cast<WebKitContextMenuAction>(action_id);
            switch (action) {
              case WEBKIT_CONTEXT_MENU_ACTION_NO_ACTION:
                // No action, used by separator menu items
                break;

              // === Link Actions ===
              case WEBKIT_CONTEXT_MENU_ACTION_OPEN_LINK:
                // Open the link in current view
                if (pending_hit_test_result_ != nullptr) {
                  const gchar* uri = webkit_hit_test_result_get_link_uri(pending_hit_test_result_);
                  if (uri != nullptr) {
                    webkit_web_view_load_uri(webview_, uri);
                  }
                }
                break;

              case WEBKIT_CONTEXT_MENU_ACTION_OPEN_LINK_IN_NEW_WINDOW:
                // Open link in new window - notify Dart side to handle
                if (pending_hit_test_result_ != nullptr && channel_delegate_) {
                  const gchar* uri = webkit_hit_test_result_get_link_uri(pending_hit_test_result_);
                  if (uri != nullptr) {
                    // For now, just open in current view (Dart can handle new window logic)
                    webkit_web_view_load_uri(webview_, uri);
                  }
                }
                break;

              case WEBKIT_CONTEXT_MENU_ACTION_DOWNLOAD_LINK_TO_DISK:
                // Download link - trigger download
                if (pending_hit_test_result_ != nullptr) {
                  const gchar* uri = webkit_hit_test_result_get_link_uri(pending_hit_test_result_);
                  if (uri != nullptr) {
                    webkit_web_view_download_uri(webview_, uri);
                  }
                }
                break;

              case WEBKIT_CONTEXT_MENU_ACTION_COPY_LINK_TO_CLIPBOARD:
                // Copy link URI to both system and WebView clipboard
                if (pending_hit_test_result_ != nullptr) {
                  const gchar* uri = webkit_hit_test_result_get_link_uri(pending_hit_test_result_);
                  if (uri != nullptr) {
                    copyTextToClipboard(uri);
                  }
                }
                break;

              // === Image Actions ===
              case WEBKIT_CONTEXT_MENU_ACTION_OPEN_IMAGE_IN_NEW_WINDOW:
                // Open image in new window
                if (pending_hit_test_result_ != nullptr) {
                  const gchar* uri = webkit_hit_test_result_get_image_uri(pending_hit_test_result_);
                  if (uri != nullptr) {
                    webkit_web_view_load_uri(webview_, uri);
                  }
                }
                break;

              case WEBKIT_CONTEXT_MENU_ACTION_DOWNLOAD_IMAGE_TO_DISK:
                // Download image
                if (pending_hit_test_result_ != nullptr) {
                  const gchar* uri = webkit_hit_test_result_get_image_uri(pending_hit_test_result_);
                  if (uri != nullptr) {
                    webkit_web_view_download_uri(webview_, uri);
                  }
                }
                break;

              case WEBKIT_CONTEXT_MENU_ACTION_COPY_IMAGE_TO_CLIPBOARD:
                // Copy image URI to both system and WebView clipboard
                if (pending_hit_test_result_ != nullptr) {
                  const gchar* uri = webkit_hit_test_result_get_image_uri(pending_hit_test_result_);
                  if (uri != nullptr) {
                    copyTextToClipboard(uri);
                  }
                }
                break;

              // === Frame Actions ===
              case WEBKIT_CONTEXT_MENU_ACTION_OPEN_FRAME_IN_NEW_WINDOW:
                // Open frame in new window - use GAction fallback
                break;

              // === Navigation Actions ===
              case WEBKIT_CONTEXT_MENU_ACTION_GO_BACK:
                webkit_web_view_go_back(webview_);
                break;

              case WEBKIT_CONTEXT_MENU_ACTION_GO_FORWARD:
                webkit_web_view_go_forward(webview_);
                break;

              case WEBKIT_CONTEXT_MENU_ACTION_STOP:
                webkit_web_view_stop_loading(webview_);
                break;

              case WEBKIT_CONTEXT_MENU_ACTION_RELOAD:
                webkit_web_view_reload(webview_);
                break;

              // === Editing Actions ===
              // These use the clipboard methods that sync WPE WebKit with system clipboard
              case WEBKIT_CONTEXT_MENU_ACTION_COPY:
                copyToClipboard();
                break;

              case WEBKIT_CONTEXT_MENU_ACTION_CUT:
                cutToClipboard();
                break;

              case WEBKIT_CONTEXT_MENU_ACTION_PASTE:
                pasteFromClipboard();
                break;

              // === Spelling Actions ===
              case WEBKIT_CONTEXT_MENU_ACTION_SPELLING_GUESS:
                // Spelling suggestion - use GAction fallback
                break;

              case WEBKIT_CONTEXT_MENU_ACTION_NO_GUESSES_FOUND:
                // No spelling guesses - informational only
                break;

              case WEBKIT_CONTEXT_MENU_ACTION_IGNORE_SPELLING:
                // Ignore spelling - use GAction fallback
                break;

              case WEBKIT_CONTEXT_MENU_ACTION_LEARN_SPELLING:
                // Learn spelling - use GAction fallback
                break;

              case WEBKIT_CONTEXT_MENU_ACTION_IGNORE_GRAMMAR:
                // Ignore grammar - use GAction fallback
                break;

              // === Font Actions ===
              case WEBKIT_CONTEXT_MENU_ACTION_FONT_MENU:
                // Font submenu - use GAction fallback
                break;

              case WEBKIT_CONTEXT_MENU_ACTION_BOLD:
                webkit_web_view_execute_editing_command(webview_, "Bold");
                break;

              case WEBKIT_CONTEXT_MENU_ACTION_ITALIC:
                webkit_web_view_execute_editing_command(webview_, "Italic");
                break;

              case WEBKIT_CONTEXT_MENU_ACTION_UNDERLINE:
                webkit_web_view_execute_editing_command(webview_, "Underline");
                break;

              case WEBKIT_CONTEXT_MENU_ACTION_OUTLINE:
                // Outline - use GAction fallback
                break;

              // === Developer Tools ===
              case WEBKIT_CONTEXT_MENU_ACTION_INSPECT_ELEMENT:
                // Inspect element - not available in WPE WebKit without GTK inspector
                // Fall through to GAction fallback
                break;

              // === Video Actions ===
              case WEBKIT_CONTEXT_MENU_ACTION_OPEN_VIDEO_IN_NEW_WINDOW:
                if (pending_hit_test_result_ != nullptr) {
                  const gchar* uri = webkit_hit_test_result_get_media_uri(pending_hit_test_result_);
                  if (uri != nullptr) {
                    webkit_web_view_load_uri(webview_, uri);
                  }
                }
                break;

              case WEBKIT_CONTEXT_MENU_ACTION_COPY_VIDEO_LINK_TO_CLIPBOARD:
                // Copy video URI to both system and WebView clipboard
                if (pending_hit_test_result_ != nullptr) {
                  const gchar* uri = webkit_hit_test_result_get_media_uri(pending_hit_test_result_);
                  if (uri != nullptr) {
                    copyTextToClipboard(uri);
                  }
                }
                break;

              case WEBKIT_CONTEXT_MENU_ACTION_DOWNLOAD_VIDEO_TO_DISK:
                if (pending_hit_test_result_ != nullptr) {
                  const gchar* uri = webkit_hit_test_result_get_media_uri(pending_hit_test_result_);
                  if (uri != nullptr) {
                    webkit_web_view_download_uri(webview_, uri);
                  }
                }
                break;

              // === Audio Actions ===
              case WEBKIT_CONTEXT_MENU_ACTION_OPEN_AUDIO_IN_NEW_WINDOW:
                if (pending_hit_test_result_ != nullptr) {
                  const gchar* uri = webkit_hit_test_result_get_media_uri(pending_hit_test_result_);
                  if (uri != nullptr) {
                    webkit_web_view_load_uri(webview_, uri);
                  }
                }
                break;

              case WEBKIT_CONTEXT_MENU_ACTION_COPY_AUDIO_LINK_TO_CLIPBOARD:
                // Copy audio URI to both system and WebView clipboard
                if (pending_hit_test_result_ != nullptr) {
                  const gchar* uri = webkit_hit_test_result_get_media_uri(pending_hit_test_result_);
                  if (uri != nullptr) {
                    copyTextToClipboard(uri);
                  }
                }
                break;

              case WEBKIT_CONTEXT_MENU_ACTION_DOWNLOAD_AUDIO_TO_DISK:
                if (pending_hit_test_result_ != nullptr) {
                  const gchar* uri = webkit_hit_test_result_get_media_uri(pending_hit_test_result_);
                  if (uri != nullptr) {
                    webkit_web_view_download_uri(webview_, uri);
                  }
                }
                break;

              // === Media Control Actions ===
              case WEBKIT_CONTEXT_MENU_ACTION_TOGGLE_MEDIA_CONTROLS:
                // Toggle media controls - use JavaScript
                evaluateJavascript(
                    "if(document.activeElement && document.activeElement.controls !== undefined) {"
                    "  document.activeElement.controls = !document.activeElement.controls;"
                    "}",
                    std::nullopt,
                    nullptr);
                break;

              case WEBKIT_CONTEXT_MENU_ACTION_TOGGLE_MEDIA_LOOP:
                // Toggle media loop - use JavaScript
                evaluateJavascript(
                    "if(document.activeElement && document.activeElement.loop !== undefined) {"
                    "  document.activeElement.loop = !document.activeElement.loop;"
                    "}",
                    std::nullopt,
                    nullptr);
                break;

              case WEBKIT_CONTEXT_MENU_ACTION_ENTER_VIDEO_FULLSCREEN:
                // Enter video fullscreen - use JavaScript
                evaluateJavascript(
                    "if(document.activeElement && document.activeElement.requestFullscreen) {"
                    "  document.activeElement.requestFullscreen();"
                    "} else if(document.activeElement && document.activeElement.webkitEnterFullscreen) {"
                    "  document.activeElement.webkitEnterFullscreen();"
                    "}",
                    std::nullopt,
                    nullptr);
                break;

              case WEBKIT_CONTEXT_MENU_ACTION_MEDIA_PLAY:
                // Play media - use JavaScript
                evaluateJavascript(
                    "if(document.activeElement && document.activeElement.play) {"
                    "  document.activeElement.play();"
                    "}",
                    std::nullopt,
                    nullptr);
                break;

              case WEBKIT_CONTEXT_MENU_ACTION_MEDIA_PAUSE:
                // Pause media - use JavaScript
                evaluateJavascript(
                    "if(document.activeElement && document.activeElement.pause) {"
                    "  document.activeElement.pause();"
                    "}",
                    std::nullopt,
                    nullptr);
                break;

              case WEBKIT_CONTEXT_MENU_ACTION_MEDIA_MUTE:
                // Toggle mute - use JavaScript
                evaluateJavascript(
                    "if(document.activeElement && document.activeElement.muted !== undefined) {"
                    "  document.activeElement.muted = !document.activeElement.muted;"
                    "}",
                    std::nullopt,
                    nullptr);
                break;

              // === Custom Actions ===
              case WEBKIT_CONTEXT_MENU_ACTION_CUSTOM:
                // Custom action - handled by Dart side
                break;

              default:
                // For any unhandled actions, try the GAction approach as fallback
                if (pending_context_menu_ != nullptr) {
                  GList* items = webkit_context_menu_get_items(pending_context_menu_);
                  for (GList* l = items; l != nullptr; l = l->next) {
                    WebKitContextMenuItem* webkit_item = WEBKIT_CONTEXT_MENU_ITEM(l->data);
                    WebKitContextMenuAction stock_action =
                        webkit_context_menu_item_get_stock_action(webkit_item);
                    if (static_cast<int>(stock_action) == action_id) {
                      GAction* gaction = webkit_context_menu_item_get_gaction(webkit_item);
                      if (gaction != nullptr && g_action_get_enabled(gaction)) {
                        g_action_activate(gaction, nullptr);
                      }
                      break;
                    }
                  }
                }
                break;
            }
          }

          // Notify Dart side about the menu item click
          if (channel_delegate_) {
            channel_delegate_->onContextMenuActionItemClicked(id, title);
          }
        });

    context_menu_popup_->SetDismissedCallback([this]() {
      // Only notify if the popup was actually visible (prevents duplicate notifications)
      if (context_menu_popup_ && context_menu_popup_->IsVisible() && channel_delegate_) {
        channel_delegate_->onHideContextMenu();
      }
    });
  }

  // Clear and rebuild the menu
  context_menu_popup_->Clear();

  // Get context menu settings
  bool hideDefaultItems = false;
  if (context_menu_config_ != nullptr) {
    hideDefaultItems = context_menu_config_->settings.hideDefaultSystemContextMenuItems;
  }

  bool hasItems = false;

  // Add items from the WebKit context menu if available and not hiding default items
  if (pending_context_menu_ != nullptr && !hideDefaultItems) {
    GList* items = webkit_context_menu_get_items(pending_context_menu_);
    for (GList* l = items; l != nullptr; l = l->next) {
      WebKitContextMenuItem* webkit_item = WEBKIT_CONTEXT_MENU_ITEM(l->data);

      // Get the stock action to determine the menu item type
      WebKitContextMenuAction stock_action = webkit_context_menu_item_get_stock_action(webkit_item);

      // Skip separator and custom actions for now
      if (stock_action == WEBKIT_CONTEXT_MENU_ACTION_NO_ACTION) {
        context_menu_popup_->AddSeparator();
        continue;
      }

      // Get action using GAction API (WPE WebKit uses GAction, not GtkAction)
      GAction* gaction = webkit_context_menu_item_get_gaction(webkit_item);
      bool enabled = (gaction != nullptr) ? g_action_get_enabled(gaction) : true;

      // Map stock actions to labels
      const char* stock_label = nullptr;
      switch (stock_action) {
        case WEBKIT_CONTEXT_MENU_ACTION_OPEN_LINK:
          stock_label = "Open Link";
          break;
        case WEBKIT_CONTEXT_MENU_ACTION_OPEN_LINK_IN_NEW_WINDOW:
          stock_label = "Open Link in New Window";
          break;
        case WEBKIT_CONTEXT_MENU_ACTION_DOWNLOAD_LINK_TO_DISK:
          stock_label = "Download Link";
          break;
        case WEBKIT_CONTEXT_MENU_ACTION_COPY_LINK_TO_CLIPBOARD:
          stock_label = "Copy Link";
          break;
        case WEBKIT_CONTEXT_MENU_ACTION_OPEN_IMAGE_IN_NEW_WINDOW:
          stock_label = "Open Image in New Window";
          break;
        case WEBKIT_CONTEXT_MENU_ACTION_DOWNLOAD_IMAGE_TO_DISK:
          stock_label = "Download Image";
          break;
        case WEBKIT_CONTEXT_MENU_ACTION_COPY_IMAGE_TO_CLIPBOARD:
          stock_label = "Copy Image";
          break;
        case WEBKIT_CONTEXT_MENU_ACTION_GO_BACK:
          stock_label = "Back";
          break;
        case WEBKIT_CONTEXT_MENU_ACTION_GO_FORWARD:
          stock_label = "Forward";
          break;
        case WEBKIT_CONTEXT_MENU_ACTION_STOP:
          stock_label = "Stop";
          break;
        case WEBKIT_CONTEXT_MENU_ACTION_RELOAD:
          stock_label = "Reload";
          break;
        case WEBKIT_CONTEXT_MENU_ACTION_COPY:
          stock_label = "Copy";
          break;
        case WEBKIT_CONTEXT_MENU_ACTION_CUT:
          stock_label = "Cut";
          break;
        case WEBKIT_CONTEXT_MENU_ACTION_PASTE:
          stock_label = "Paste";
          break;
        case WEBKIT_CONTEXT_MENU_ACTION_INSPECT_ELEMENT:
          stock_label = "Inspect Element";
          break;
        default:
          continue;
      }

      if (stock_label != nullptr) {
        context_menu_popup_->AddItem(std::to_string(static_cast<int>(stock_action)), stock_label,
                                     enabled);
        hasItems = true;
      }
    }
  }

  // Add custom menu items from context_menu_config_
  if (context_menu_config_ != nullptr && !context_menu_config_->menuItems.empty()) {
    if (hasItems) {
      context_menu_popup_->AddSeparator();
    }

    for (const auto& customItem : context_menu_config_->menuItems) {
      if (!customItem.title.empty()) {
        context_menu_popup_->AddItem(customItem.getIdAsString(), customItem.title, true);
        hasItems = true;
      }
    }
  }

  if (!hasItems) {
    return;
  }

  // Get screen position of the cursor using the pointer device
  // This works reliably on both X11 and Wayland
  gint screen_x = 0, screen_y = 0;
  
  GdkDisplay* gdk_display = gdk_display_get_default();
  if (gdk_display != nullptr) {
    GdkSeat* seat = gdk_display_get_default_seat(gdk_display);
    if (seat != nullptr) {
      GdkDevice* pointer = gdk_seat_get_pointer(seat);
      if (pointer != nullptr) {
        gdk_device_get_position(pointer, nullptr, &screen_x, &screen_y);
      }
    }
  }

  context_menu_popup_->Show(screen_x, screen_y);
}

void InAppWebView::HideContextMenu() {
  // Check if context menu is actually visible before proceeding
  bool wasVisible = context_menu_popup_ && context_menu_popup_->IsVisible();

  // Hide the context menu popup
  if (context_menu_popup_) {
    context_menu_popup_->Hide();
  }

  // Clean up pending menu references
  if (pending_context_menu_ != nullptr) {
    g_object_unref(pending_context_menu_);
    pending_context_menu_ = nullptr;
  }

  if (pending_hit_test_result_ != nullptr) {
    g_object_unref(pending_hit_test_result_);
    pending_hit_test_result_ = nullptr;
  }

  // Notify Dart side only if context menu was actually visible
  if (wasVisible && channel_delegate_) {
    channel_delegate_->onHideContextMenu();
  }
}

// === Color Picker for <input type="color"> ===
// WPE WebKit doesn't have the run-color-chooser signal that WebKitGTK has,
// so we implement color input support via JavaScript interception and a native GTK3 dialog.

// Helper function to parse hex color string to GdkRGBA
static bool ParseHexColor(const std::string& hexColor, GdkRGBA* rgba) {
  if (hexColor.empty() || hexColor[0] != '#') {
    return false;
  }

  std::string hex = hexColor.substr(1);  // Remove '#'
  
  unsigned int r = 0, g = 0, b = 0, a = 255;
  
  if (hex.length() == 6) {
    // #RRGGBB
    if (sscanf(hex.c_str(), "%02x%02x%02x", &r, &g, &b) != 3) {
      return false;
    }
  } else if (hex.length() == 8) {
    // #RRGGBBAA
    if (sscanf(hex.c_str(), "%02x%02x%02x%02x", &r, &g, &b, &a) != 4) {
      return false;
    }
  } else if (hex.length() == 3) {
    // #RGB (shorthand)
    if (sscanf(hex.c_str(), "%1x%1x%1x", &r, &g, &b) != 3) {
      return false;
    }
    r = r * 17;  // Expand 0-15 to 0-255
    g = g * 17;
    b = b * 17;
  } else {
    return false;
  }
  
  rgba->red = r / 255.0;
  rgba->green = g / 255.0;
  rgba->blue = b / 255.0;
  rgba->alpha = a / 255.0;
  
  return true;
}

// Helper function to convert GdkRGBA to hex color string
static std::string RgbaToHexColor(const GdkRGBA* rgba, bool includeAlpha) {
  int r = static_cast<int>(rgba->red * 255.0 + 0.5);
  int g = static_cast<int>(rgba->green * 255.0 + 0.5);
  int b = static_cast<int>(rgba->blue * 255.0 + 0.5);
  int a = static_cast<int>(rgba->alpha * 255.0 + 0.5);
  
  // Clamp values
  r = std::max(0, std::min(255, r));
  g = std::max(0, std::min(255, g));
  b = std::max(0, std::min(255, b));
  a = std::max(0, std::min(255, a));
  
  char hexColor[10];
  if (includeAlpha && a != 255) {
    snprintf(hexColor, sizeof(hexColor), "#%02X%02X%02X%02X", r, g, b, a);
  } else {
    snprintf(hexColor, sizeof(hexColor), "#%02X%02X%02X", r, g, b);
  }
  
  return std::string(hexColor);
}

// Static callback for non-blocking color dialog response
static void OnColorDialogResponse(GtkDialog* dialog, gint response_id, gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);
  
  // Capture and clear reply before resolving (to prevent use after cleanup)
  WebKitScriptMessageReply* reply = self->pending_color_reply_;
  self->pending_color_reply_ = nullptr;
  
  if (reply == nullptr) {
    // No reply object - just cleanup
    gtk_widget_destroy(GTK_WIDGET(dialog));
    g_object_unref(dialog);
    self->active_color_dialog_ = nullptr;
    self->color_dialog_show_time_ = 0;
    return;
  }
  
  if (response_id == GTK_RESPONSE_OK) {
    // User selected a color
    GdkRGBA selectedRgba;
    gtk_color_chooser_get_rgba(GTK_COLOR_CHOOSER(dialog), &selectedRgba);
    
    std::string hexColor = RgbaToHexColor(&selectedRgba, self->active_color_alpha_enabled_);
    // Resolve the Promise with the selected color via webkit reply
    self->ResolveInternalHandlerWithReply(reply, "\"" + hexColor + "\"");
  } else {
    // User cancelled or closed the dialog - resolve with null
    self->ResolveInternalHandlerWithReply(reply, "null");
  }
  
  // Cleanup
  gtk_widget_destroy(GTK_WIDGET(dialog));
  g_object_unref(dialog);  // Release our extra reference
  self->active_color_dialog_ = nullptr;
  self->color_dialog_show_time_ = 0;
}

void InAppWebView::ShowColorPicker(const std::string& initialColor, int x, int y,
                                   const std::vector<std::string>& predefinedColors,
                                   bool alphaEnabled,
                                   const std::string& colorSpace) {
  (void)x;  // Position not used for non-modal dialog
  (void)y;
  (void)colorSpace;  // GTK3 color chooser doesn't support color spaces
  
  // Close any existing color dialog first
  if (active_color_dialog_ != nullptr) {
    gtk_widget_destroy(active_color_dialog_);
    g_object_unref(active_color_dialog_);
    active_color_dialog_ = nullptr;
  }
  
  // Store the initial color for cancel restoration
  pending_color_input_value_ = initialColor;
  active_color_alpha_enabled_ = alphaEnabled;
  
  // Create the color chooser dialog with parent window
  GtkWidget* dialog = gtk_color_chooser_dialog_new("Select Color", gtk_window_);
  active_color_dialog_ = dialog;
  
  // Set dialog as transient for parent (floats above but doesn't block)
  if (gtk_window_) {
    gtk_window_set_transient_for(GTK_WINDOW(dialog), gtk_window_);
  }
  
  // Take an extra reference to prevent premature destruction
  g_object_ref(dialog);
  
  GtkColorChooser* chooser = GTK_COLOR_CHOOSER(dialog);
  
  // Set the initial color
  GdkRGBA initialRgba = {0.0, 0.0, 0.0, 1.0};  // Default to black
  if (ParseHexColor(initialColor, &initialRgba)) {
    gtk_color_chooser_set_rgba(chooser, &initialRgba);
  }
  
  // Enable/disable alpha channel
  gtk_color_chooser_set_use_alpha(chooser, alphaEnabled ? TRUE : FALSE);
  
  // Add predefined colors if provided
  if (!predefinedColors.empty()) {
    std::vector<GdkRGBA> rgbaColors;
    rgbaColors.reserve(predefinedColors.size());
    
    for (const auto& hexColor : predefinedColors) {
      GdkRGBA rgba;
      if (ParseHexColor(hexColor, &rgba)) {
        rgbaColors.push_back(rgba);
      }
    }
    
    if (!rgbaColors.empty()) {
      gtk_color_chooser_add_palette(chooser, GTK_ORIENTATION_HORIZONTAL,
                                    static_cast<gint>(rgbaColors.size()),
                                    static_cast<gint>(rgbaColors.size()),
                                    rgbaColors.data());
    }
  }
  
  // Connect to response signal for non-blocking behavior
  g_signal_connect(dialog, "response", G_CALLBACK(OnColorDialogResponse), this);
  
  // Show the dialog and all its children (non-blocking)
  gtk_widget_show_all(dialog);
  
  // Record show time to prevent immediate close by pointer events
  color_dialog_show_time_ = g_get_monotonic_time();
}

void InAppWebView::HideColorPicker() {
  // Don't hide the color dialog when called from HideAllPopups during focus changes.
  // The color dialog is a separate GTK window that should remain open until the user
  // explicitly closes it (OK/Cancel). The dialog's response handler will clean up properly.
  // This is intentionally a no-op - the dialog manages its own lifecycle.
}

void InAppWebView::HideFileChooser() {
  if (active_file_dialog_ != nullptr) {
    // Don't close the dialog if it was just shown (within 200ms)
    // This prevents the click that triggered the file chooser from immediately closing it
    int64_t now = g_get_monotonic_time();
    int64_t elapsed_us = now - file_dialog_show_time_;
    if (elapsed_us < 200000) {
      return;
    }
    
    // Cancel the WebKit request if we have context
    if (file_chooser_context_ != nullptr) {
      auto* context = static_cast<FileChooserContext*>(file_chooser_context_);
      // Disconnect the signal handler to prevent callback from being called
      if (context->response_handler_id != 0) {
        g_signal_handler_disconnect(active_file_dialog_, context->response_handler_id);
        context->response_handler_id = 0;
      }
      // Cancel the WebKit request so future file chooser signals work
      webkit_file_chooser_request_cancel(context->request);
      delete context;
      file_chooser_context_ = nullptr;
    }
    
    gtk_widget_destroy(active_file_dialog_);
    g_object_unref(active_file_dialog_);
    active_file_dialog_ = nullptr;
    file_dialog_show_time_ = 0;
  }
}

void InAppWebView::HideOptionMenu() {
  if (option_menu_popup_ && option_menu_popup_->IsVisible()) {
    option_menu_popup_->Hide();
  }
}

void InAppWebView::HideAllPopups() {
  // Hide all custom popups - add new popup types here as they are implemented
  HideContextMenu();
  HideColorPicker();
  HideFileChooser();
  HideOptionMenu();
  HideDatePicker();
}

void InAppWebView::ResolveInternalHandlerWithReply(WebKitScriptMessageReply* reply, const std::string& jsonResult) {
  if (reply == nullptr) {
    debugLog("ResolveInternalHandlerWithReply: reply is NULL, cannot respond");
    return;
  }

  // Create a JSCContext to build the reply value
  JSCContext* context = jsc_context_new();
  if (context == nullptr) {
    webkit_script_message_reply_return_error_message(reply, "Failed to create JSC context");
    webkit_script_message_reply_unref(reply);
    return;
  }
  
  // Parse the JSON result and create a JSCValue
  JSCValue* replyValue = nullptr;
  
  if (jsonResult == "null" || jsonResult.empty()) {
    replyValue = jsc_value_new_null(context);
  } else if (jsonResult[0] == '"') {
    // It's a quoted string - evaluate it to get the actual string value
    replyValue = jsc_context_evaluate(context, jsonResult.c_str(), -1);
  } else {
    // Parse as JSON
    std::string parseScript = "(" + jsonResult + ")";
    replyValue = jsc_context_evaluate(context, parseScript.c_str(), -1);
  }
  
  if (replyValue == nullptr) {
    // Fallback: return the raw string
    replyValue = jsc_value_new_string(context, jsonResult.c_str());
  }
  
  // Send the reply back to JavaScript
  webkit_script_message_reply_return_value(reply, replyValue);
  
  // Cleanup
  g_object_unref(replyValue);
  g_object_unref(context);
  webkit_script_message_reply_unref(reply);
}

void InAppWebView::RejectInternalHandlerWithReply(WebKitScriptMessageReply* reply, const std::string& errorMessage) {
  if (reply == nullptr) {
    return;
  }
  webkit_script_message_reply_return_error_message(reply, errorMessage.c_str());
  webkit_script_message_reply_unref(reply);
}

// === Date/Time Picker Methods ===
// WPE WebKit doesn't have date picker support, so we handle <input type="date/time/etc.>
// natively using GTK3 widgets

// Helper to parse ISO date string to component values
static bool ParseIsoDate(const std::string& isoDate, int* year, int* month, int* day,
                         int* hour, int* minute) {
  if (isoDate.empty()) return false;
  
  *year = 0; *month = 0; *day = 0; *hour = 0; *minute = 0;
  
  // Try YYYY-MM-DD format (date)
  if (sscanf(isoDate.c_str(), "%d-%d-%d", year, month, day) == 3) {
    return true;
  }
  
  // Try YYYY-MM-DDTHH:MM format (datetime-local)
  if (sscanf(isoDate.c_str(), "%d-%d-%dT%d:%d", year, month, day, hour, minute) == 5) {
    return true;
  }
  
  // Try HH:MM format (time)
  if (sscanf(isoDate.c_str(), "%d:%d", hour, minute) == 2) {
    *year = 2000; *month = 1; *day = 1;  // Dummy date
    return true;
  }
  
  // Try YYYY-MM format (month)
  if (sscanf(isoDate.c_str(), "%d-%d", year, month) == 2 && *month >= 1 && *month <= 12) {
    *day = 1;
    return true;
  }
  
  // Try YYYY-Www format (week)
  int week = 0;
  if (sscanf(isoDate.c_str(), "%d-W%d", year, &week) == 2) {
    // Set to first day of the week
    *month = 1;
    *day = 1 + (week - 1) * 7;  // Approximate
    return true;
  }
  
  return false;
}

// Context struct for date dialog callback
struct DateDialogContext {
  InAppWebView* webview;
  std::string inputType;
  GtkWidget* calendar;     // GtkCalendar widget (may be null for time-only)
  GtkWidget* hourSpin;     // Hour spinner (for time/datetime-local)
  GtkWidget* minuteSpin;   // Minute spinner (for time/datetime-local)
  GtkWidget* dialog;       // Reference to the dialog for validation
  // Min/max constraints (parsed)
  int minYear, minMonth, minDay, minHour, minMinute;
  int maxYear, maxMonth, maxDay, maxHour, maxMinute;
  bool hasMin, hasMax;
};

// Helper to compare dates
static int CompareDates(int y1, int m1, int d1, int y2, int m2, int d2) {
  if (y1 != y2) return y1 - y2;
  if (m1 != m2) return m1 - m2;
  return d1 - d2;
}

// Helper to compare times (for future use with time validation)
[[maybe_unused]]
static int CompareTimes(int h1, int m1, int h2, int m2) {
  if (h1 != h2) return h1 - h2;
  return m1 - m2;
}

// Callback for calendar day selection to validate against min/max
static void OnCalendarDaySelected(GtkCalendar* calendar, gpointer user_data) {
  auto* ctx = static_cast<DateDialogContext*>(user_data);
  
  guint year, month, day;
  gtk_calendar_get_date(calendar, &year, &month, &day);
  month += 1;  // GtkCalendar months are 0-based
  
  bool valid = true;
  
  // Check min constraint
  if (ctx->hasMin) {
    if (CompareDates(static_cast<int>(year), static_cast<int>(month), static_cast<int>(day),
                     ctx->minYear, ctx->minMonth, ctx->minDay) < 0) {
      valid = false;
    }
  }
  
  // Check max constraint
  if (ctx->hasMax) {
    if (CompareDates(static_cast<int>(year), static_cast<int>(month), static_cast<int>(day),
                     ctx->maxYear, ctx->maxMonth, ctx->maxDay) > 0) {
      valid = false;
    }
  }
  
  // Enable/disable OK button based on validity
  if (ctx->dialog) {
    gtk_dialog_set_response_sensitive(GTK_DIALOG(ctx->dialog), GTK_RESPONSE_OK, valid ? TRUE : FALSE);
  }
}

// Static callback for date dialog response
static void OnDateDialogResponse(GtkDialog* dialog, gint response_id, gpointer user_data) {
  auto* ctx = static_cast<DateDialogContext*>(user_data);
  InAppWebView* self = ctx->webview;
  
  // Capture and clear reply before resolving (to prevent use after cleanup)
  WebKitScriptMessageReply* reply = self->pending_date_reply_;
  self->pending_date_reply_ = nullptr;
  
  // Helper lambda for cleanup
  auto cleanup = [&]() {
    delete ctx;
    gtk_widget_destroy(GTK_WIDGET(dialog));
    g_object_unref(dialog);
    self->active_date_dialog_ = nullptr;
    self->date_dialog_show_time_ = 0;
  };
  
  if (reply == nullptr) {
    // No reply object - just cleanup
    cleanup();
    return;
  }
  
  if (response_id == GTK_RESPONSE_OK) {
    std::string result;
    
    if (ctx->inputType == "time") {
      // Time only
      int hour = gtk_spin_button_get_value_as_int(GTK_SPIN_BUTTON(ctx->hourSpin));
      int minute = gtk_spin_button_get_value_as_int(GTK_SPIN_BUTTON(ctx->minuteSpin));
      char buf[16];
      snprintf(buf, sizeof(buf), "%02d:%02d", hour, minute);
      result = buf;
    } else if (ctx->calendar != nullptr) {
      // Get date from calendar
      guint year, month, day;
      gtk_calendar_get_date(GTK_CALENDAR(ctx->calendar), &year, &month, &day);
      month += 1;  // GtkCalendar months are 0-based
      
      if (ctx->inputType == "date") {
        char buf[16];
        snprintf(buf, sizeof(buf), "%04d-%02d-%02d", year, month, day);
        result = buf;
      } else if (ctx->inputType == "datetime-local") {
        int hour = gtk_spin_button_get_value_as_int(GTK_SPIN_BUTTON(ctx->hourSpin));
        int minute = gtk_spin_button_get_value_as_int(GTK_SPIN_BUTTON(ctx->minuteSpin));
        char buf[32];
        snprintf(buf, sizeof(buf), "%04d-%02d-%02dT%02d:%02d", year, month, day, hour, minute);
        result = buf;
      } else if (ctx->inputType == "month") {
        char buf[16];
        snprintf(buf, sizeof(buf), "%04d-%02d", year, month);
        result = buf;
      } else if (ctx->inputType == "week") {
        // Calculate ISO week number
        GDateTime* dt = g_date_time_new_local(year, month, day, 0, 0, 0);
        if (dt) {
          int isoYear = g_date_time_get_year(dt);
          int weekNum = g_date_time_get_week_of_year(dt);
          g_date_time_unref(dt);
          char buf[16];
          snprintf(buf, sizeof(buf), "%04d-W%02d", isoYear, weekNum);
          result = buf;
        }
      }
    }
    
    if (!result.empty()) {
      // Resolve the Promise with the selected value via webkit reply
      self->ResolveInternalHandlerWithReply(reply, "\"" + result + "\"");
    } else {
      // No valid result - resolve with null
      self->ResolveInternalHandlerWithReply(reply, "null");
    }
  } else {
    // User cancelled - resolve with null
    self->ResolveInternalHandlerWithReply(reply, "null");
  }
  
  // Cleanup
  cleanup();
}

void InAppWebView::ShowDatePicker(const std::string& inputType, const std::string& value,
                                   const std::string& min, const std::string& max,
                                   const std::string& step, int x, int y) {
  (void)x;     // Position not used - GTK handles dialog placement
  (void)y;
  
  // Close any existing date dialog
  if (active_date_dialog_ != nullptr) {
    gtk_widget_destroy(active_date_dialog_);
    g_object_unref(active_date_dialog_);
    active_date_dialog_ = nullptr;
  }
  
  pending_date_input_value_ = value;
  pending_date_input_type_ = inputType;
  pending_date_input_min_ = min;
  pending_date_input_max_ = max;
  
  // Determine dialog title
  std::string title;
  if (inputType == "date") title = "Select Date";
  else if (inputType == "datetime-local") title = "Select Date and Time";
  else if (inputType == "time") title = "Select Time";
  else if (inputType == "month") title = "Select Month";
  else if (inputType == "week") title = "Select Week";
  else title = "Select Date";
  
  // Create a dialog with the parent window
  GtkWidget* dialog = gtk_dialog_new_with_buttons(
      title.c_str(),
      gtk_window_,
      GTK_DIALOG_DESTROY_WITH_PARENT,
      "_Cancel", GTK_RESPONSE_CANCEL,
      "_OK", GTK_RESPONSE_OK,
      nullptr);
  
  active_date_dialog_ = dialog;
  g_object_ref(dialog);
  
  // Set dialog as transient for parent (floats above but doesn't block)
  if (gtk_window_) {
    gtk_window_set_transient_for(GTK_WINDOW(dialog), gtk_window_);
  }
  
  // Make the window non-resizable
  gtk_window_set_resizable(GTK_WINDOW(dialog), FALSE);
  
  GtkWidget* content_area = gtk_dialog_get_content_area(GTK_DIALOG(dialog));
  gtk_container_set_border_width(GTK_CONTAINER(content_area), 10);
  
  // Create context for callback
  auto* ctx = new DateDialogContext();
  ctx->webview = this;
  ctx->inputType = inputType;
  ctx->calendar = nullptr;
  ctx->hourSpin = nullptr;
  ctx->minuteSpin = nullptr;
  ctx->dialog = dialog;
  
  // Parse min/max constraints
  ctx->hasMin = ParseIsoDate(min, &ctx->minYear, &ctx->minMonth, &ctx->minDay, &ctx->minHour, &ctx->minMinute);
  ctx->hasMax = ParseIsoDate(max, &ctx->maxYear, &ctx->maxMonth, &ctx->maxDay, &ctx->maxHour, &ctx->maxMinute);
  
  // Parse step value for time inputs (step is in seconds)
  int stepMinutes = 1;  // Default minute step
  if (!step.empty()) {
    int stepSeconds = std::atoi(step.c_str());
    if (stepSeconds >= 60) {
      stepMinutes = stepSeconds / 60;
    }
  }
  
  // Parse initial value
  int initialYear = 2024, initialMonth = 1, initialDay = 1;
  int initialHour = 12, initialMinute = 0;
  ParseIsoDate(value, &initialYear, &initialMonth, &initialDay, &initialHour, &initialMinute);
  
  // Add calendar for date-related types
  if (inputType == "date" || inputType == "datetime-local" || 
      inputType == "month" || inputType == "week") {
    GtkWidget* calendar = gtk_calendar_new();
    ctx->calendar = calendar;
    
    // Set initial date (GtkCalendar months are 0-based)
    gtk_calendar_select_month(GTK_CALENDAR(calendar), initialMonth - 1, initialYear);
    gtk_calendar_select_day(GTK_CALENDAR(calendar), initialDay);
    
    // For month picker, hide day selection styling (user can still click but day isn't important)
    if (inputType == "month") {
      gtk_calendar_set_display_options(GTK_CALENDAR(calendar),
          static_cast<GtkCalendarDisplayOptions>(
              GTK_CALENDAR_SHOW_HEADING | GTK_CALENDAR_SHOW_DAY_NAMES));
    }
    
    // For week picker, show week numbers
    if (inputType == "week") {
      gtk_calendar_set_display_options(GTK_CALENDAR(calendar),
          static_cast<GtkCalendarDisplayOptions>(
              GTK_CALENDAR_SHOW_HEADING | GTK_CALENDAR_SHOW_DAY_NAMES | 
              GTK_CALENDAR_SHOW_WEEK_NUMBERS));
    }
    
    gtk_box_pack_start(GTK_BOX(content_area), calendar, TRUE, TRUE, 5);
    
    // Connect day-selected signal to validate against min/max
    g_signal_connect(calendar, "day-selected", G_CALLBACK(OnCalendarDaySelected), ctx);
    
    // Add constraint info label if min or max is set
    if (ctx->hasMin || ctx->hasMax) {
      std::string constraintText;
      if (ctx->hasMin && ctx->hasMax) {
        char buf[64];
        snprintf(buf, sizeof(buf), "Range: %04d-%02d-%02d to %04d-%02d-%02d",
                 ctx->minYear, ctx->minMonth, ctx->minDay,
                 ctx->maxYear, ctx->maxMonth, ctx->maxDay);
        constraintText = buf;
      } else if (ctx->hasMin) {
        char buf[32];
        snprintf(buf, sizeof(buf), "Min: %04d-%02d-%02d", ctx->minYear, ctx->minMonth, ctx->minDay);
        constraintText = buf;
      } else {
        char buf[32];
        snprintf(buf, sizeof(buf), "Max: %04d-%02d-%02d", ctx->maxYear, ctx->maxMonth, ctx->maxDay);
        constraintText = buf;
      }
      GtkWidget* constraintLabel = gtk_label_new(constraintText.c_str());
      gtk_widget_set_opacity(constraintLabel, 0.7);
      gtk_box_pack_start(GTK_BOX(content_area), constraintLabel, FALSE, FALSE, 2);
    }
    
    // For date type with no time, double-click on day to confirm quickly
    if (inputType == "date") {
      g_signal_connect(calendar, "day-selected-double-click",
          G_CALLBACK(+[](GtkCalendar*, gpointer user_data) {
            auto* dialog = GTK_DIALOG(user_data);
            gtk_dialog_response(dialog, GTK_RESPONSE_OK);
          }), dialog);
    }
  }
  
  // Add time spinners for time-related types
  if (inputType == "time" || inputType == "datetime-local") {
    GtkWidget* timeBox = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 5);
    gtk_widget_set_halign(timeBox, GTK_ALIGN_CENTER);
    
    // Hour spinner
    GtkAdjustment* hourAdj = gtk_adjustment_new(initialHour, 0, 23, 1, 1, 0);
    GtkWidget* hourSpin = gtk_spin_button_new(hourAdj, 1, 0);
    gtk_spin_button_set_wrap(GTK_SPIN_BUTTON(hourSpin), TRUE);
    gtk_entry_set_width_chars(GTK_ENTRY(hourSpin), 2);
    ctx->hourSpin = hourSpin;
    
    // Separator
    GtkWidget* separator = gtk_label_new(":");
    
    // Minute spinner (use step if provided)
    GtkAdjustment* minuteAdj = gtk_adjustment_new(initialMinute, 0, 59, stepMinutes, stepMinutes * 5, 0);
    GtkWidget* minuteSpin = gtk_spin_button_new(minuteAdj, 1, 0);
    gtk_spin_button_set_wrap(GTK_SPIN_BUTTON(minuteSpin), TRUE);
    gtk_entry_set_width_chars(GTK_ENTRY(minuteSpin), 2);
    gtk_spin_button_set_snap_to_ticks(GTK_SPIN_BUTTON(minuteSpin), stepMinutes > 1 ? TRUE : FALSE);
    ctx->minuteSpin = minuteSpin;
    
    gtk_box_pack_start(GTK_BOX(timeBox), gtk_label_new("Time:"), FALSE, FALSE, 5);
    gtk_box_pack_start(GTK_BOX(timeBox), hourSpin, FALSE, FALSE, 0);
    gtk_box_pack_start(GTK_BOX(timeBox), separator, FALSE, FALSE, 2);
    gtk_box_pack_start(GTK_BOX(timeBox), minuteSpin, FALSE, FALSE, 0);
    
    gtk_box_pack_start(GTK_BOX(content_area), timeBox, FALSE, FALSE, 10);
    
    // Add time constraint info for time-only input
    if (inputType == "time" && (ctx->hasMin || ctx->hasMax)) {
      std::string timeConstraint;
      if (ctx->hasMin && ctx->hasMax) {
        char buf[32];
        snprintf(buf, sizeof(buf), "Range: %02d:%02d to %02d:%02d",
                 ctx->minHour, ctx->minMinute, ctx->maxHour, ctx->maxMinute);
        timeConstraint = buf;
      } else if (ctx->hasMin) {
        char buf[16];
        snprintf(buf, sizeof(buf), "Min: %02d:%02d", ctx->minHour, ctx->minMinute);
        timeConstraint = buf;
      } else {
        char buf[16];
        snprintf(buf, sizeof(buf), "Max: %02d:%02d", ctx->maxHour, ctx->maxMinute);
        timeConstraint = buf;
      }
      GtkWidget* timeConstraintLabel = gtk_label_new(timeConstraint.c_str());
      gtk_widget_set_opacity(timeConstraintLabel, 0.7);
      gtk_box_pack_start(GTK_BOX(content_area), timeConstraintLabel, FALSE, FALSE, 2);
    }
  }
  
  // Connect response signal
  g_signal_connect(dialog, "response", G_CALLBACK(OnDateDialogResponse), ctx);
  
  // Handle focus-out to auto-close (like a dropdown)
  g_signal_connect(dialog, "focus-out-event",
      G_CALLBACK(+[](GtkWidget* widget, GdkEventFocus*, gpointer) -> gboolean {
        // Don't auto-close - let user interact freely
        // They can click Cancel or click outside to dismiss
        (void)widget;
        return FALSE;  // Don't consume the event
      }), nullptr);
  
  // Show the dialog and all its children
  gtk_widget_show_all(dialog);
  
  date_dialog_show_time_ = g_get_monotonic_time();
}

void InAppWebView::HideDatePicker() {
  if (active_date_dialog_ != nullptr) {
    int64_t now = g_get_monotonic_time();
    int64_t elapsed_us = now - date_dialog_show_time_;
    if (elapsed_us < 200000) {
      return;  // Don't close if just shown
    }
    
    // Capture and clear reply before resolving
    WebKitScriptMessageReply* reply = pending_date_reply_;
    pending_date_reply_ = nullptr;
    
    // Resolve the pending Promise with null when hiding the picker
    if (reply != nullptr) {
      ResolveInternalHandlerWithReply(reply, "null");
    }
    
    gtk_widget_destroy(active_date_dialog_);
    g_object_unref(active_date_dialog_);
    active_date_dialog_ = nullptr;
    date_dialog_show_time_ = 0;
  }
}

// === Clipboard Operations ===
// WPE WebKit runs offscreen and doesn't share clipboard with the system by default.
// These methods sync WebKit's internal clipboard with the GTK/system clipboard.

void InAppWebView::getSelectedText(std::function<void(const std::optional<std::string>&)> callback) {
  if (webview_ == nullptr || callback == nullptr) {
    if (callback) callback(std::nullopt);
    return;
  }

  evaluateJavascript(
      "window.getSelection().toString()",
      std::nullopt,
      [callback](const std::optional<std::string>& result) {
        if (!result.has_value() || result->empty() || *result == "null") {
          callback(std::nullopt);
          return;
        }

        std::string text = *result;
        
        // Parse JSON string result using nlohmann/json
        try {
          auto parsed = json::parse(text);
          if (parsed.is_string()) {
            text = parsed.get<std::string>();
          }
        } catch (const json::exception&) {
          // If parsing fails, try manual unquoting for simple cases
          if (text.size() >= 2 && text.front() == '"' && text.back() == '"') {
            text = text.substr(1, text.size() - 2);
          }
        }

        if (text.empty()) {
          callback(std::nullopt);
        } else {
          callback(text);
        }
      });
}

void InAppWebView::isSecureContext(std::function<void(bool)> callback) {
  if (webview_ == nullptr || callback == nullptr) {
    if (callback) callback(false);
    return;
  }

  evaluateJavascript("window.isSecureContext",
                     std::nullopt,
                     [callback](const std::optional<std::string>& result) {
                       bool isSecure = false;
                       if (result.has_value() && *result == "true") {
                         isSecure = true;
                       }
                       callback(isSecure);
                     });
}

// === Media Playback Control ===

void InAppWebView::pauseAllMediaPlayback() {
  if (webview_ == nullptr) return;
  
  // Pause all audio and video elements in the page
  const char* script = R"(
    (function() {
      var mediaElements = document.querySelectorAll('audio, video');
      mediaElements.forEach(function(el) {
        if (!el.paused) {
          el.pause();
        }
      });
    })();
  )";
  evaluateJavascript(script, std::nullopt, nullptr);
}

void InAppWebView::setAllMediaPlaybackSuspended(bool suspended) {
  if (webview_ == nullptr) return;
  
  // Suspend or resume all media elements
  // When suspended=true, pause all and mark with a data attribute
  // When suspended=false, resume only those that were playing before
  std::string script;
  if (suspended) {
    script = R"(
      (function() {
        var mediaElements = document.querySelectorAll('audio, video');
        mediaElements.forEach(function(el) {
          if (!el.paused) {
            el.dataset.wasPlaying = 'true';
            el.pause();
          } else {
            el.dataset.wasPlaying = 'false';
          }
        });
      })();
    )";
  } else {
    script = R"(
      (function() {
        var mediaElements = document.querySelectorAll('audio, video');
        mediaElements.forEach(function(el) {
          if (el.dataset.wasPlaying === 'true') {
            el.play().catch(function() {});
            delete el.dataset.wasPlaying;
          }
        });
      })();
    )";
  }
  evaluateJavascript(script, std::nullopt, nullptr);
}

void InAppWebView::closeAllMediaPresentations() {
  if (webview_ == nullptr) return;
  
  // Exit fullscreen if any media is in fullscreen, and exit picture-in-picture
  const char* script = R"(
    (function() {
      // Exit fullscreen
      if (document.fullscreenElement) {
        document.exitFullscreen().catch(function() {});
      }
      // Exit picture-in-picture
      if (document.pictureInPictureElement) {
        document.exitPictureInPicture().catch(function() {});
      }
      // Also pause all media
      var mediaElements = document.querySelectorAll('audio, video');
      mediaElements.forEach(function(el) {
        if (!el.paused) {
          el.pause();
        }
      });
    })();
  )";
  evaluateJavascript(script, std::nullopt, nullptr);
}

void InAppWebView::requestMediaPlaybackState(std::function<void(int)> callback) {
  if (webview_ == nullptr || callback == nullptr) {
    if (callback) callback(0);  // NONE
    return;
  }
  
  // Use native WPE WebKit API for PLAYING detection (webkit_web_view_is_playing_audio)
  // This is more accurate than JavaScript as it's tracked at the browser level
  // Returns: 0 = NONE, 1 = PAUSED, 2 = SUSPENDED, 3 = PLAYING
  
  gboolean isPlayingAudio = webkit_web_view_is_playing_audio(webview_);
  
  if (isPlayingAudio) {
    // Native API confirms audio is playing - return PLAYING immediately
    callback(3);  // PLAYING
    return;
  }
  
  // If not playing, use JavaScript to determine if we have media elements
  // and whether they are paused normally or suspended via our API
  const char* script = R"(
    (function() {
      var mediaElements = document.querySelectorAll('audio, video');
      if (mediaElements.length === 0) {
        return 0; // NONE - no media elements
      }
      var hasSuspended = false;
      var hasPaused = false;
      mediaElements.forEach(function(el) {
        if (el.dataset.wasPlaying === 'true') {
          hasSuspended = true;
        } else if (el.paused || el.ended) {
          hasPaused = true;
        }
      });
      if (hasSuspended) return 2; // SUSPENDED (paused via setAllMediaPlaybackSuspended)
      if (hasPaused) return 1; // PAUSED (normal pause)
      return 0; // NONE
    })();
  )";
  
  evaluateJavascript(script, std::nullopt, [callback](const std::optional<std::string>& result) {
    int state = 0;  // NONE
    if (result.has_value()) {
      try {
        state = std::stoi(*result);
      } catch (...) {
        state = 0;
      }
    }
    callback(state);
  });
}

// === Media Capture State (Camera and Microphone) ===

int InAppWebView::getCameraCaptureState() const {
  if (webview_ == nullptr) return 0;  // NONE
  
  // WPE WebKit returns WebKitMediaCaptureState enum:
  // WEBKIT_MEDIA_CAPTURE_STATE_NONE = 0
  // WEBKIT_MEDIA_CAPTURE_STATE_ACTIVE = 1
  // WEBKIT_MEDIA_CAPTURE_STATE_MUTED = 2
  WebKitMediaCaptureState state = webkit_web_view_get_camera_capture_state(webview_);
  return static_cast<int>(state);
}

void InAppWebView::setCameraCaptureState(int state) {
  if (webview_ == nullptr) return;
  
  // state: 0 = NONE, 1 = ACTIVE, 2 = MUTED
  // Note: Once state is set to NONE, it cannot be changed back (per WPE docs)
  // The page can request capture again using mediaDevices API
  WebKitMediaCaptureState captureState = static_cast<WebKitMediaCaptureState>(state);
  webkit_web_view_set_camera_capture_state(webview_, captureState);
}

int InAppWebView::getMicrophoneCaptureState() const {
  if (webview_ == nullptr) return 0;  // NONE
  
  WebKitMediaCaptureState state = webkit_web_view_get_microphone_capture_state(webview_);
  return static_cast<int>(state);
}

void InAppWebView::setMicrophoneCaptureState(int state) {
  if (webview_ == nullptr) return;
  
  WebKitMediaCaptureState captureState = static_cast<WebKitMediaCaptureState>(state);
  webkit_web_view_set_microphone_capture_state(webview_, captureState);
}

// === Theme Color ===

std::optional<std::string> InAppWebView::getMetaThemeColor() const {
  if (webview_ == nullptr) return std::nullopt;
  
  WebKitColor color;
  gboolean hasColor = webkit_web_view_get_theme_color(webview_, &color);
  
  if (!hasColor) {
    return std::nullopt;
  }
  
  // Convert WebKitColor (RGBA in 0.0-1.0 range) to hex string format #RRGGBBAA
  // Note: WebKitColor has red, green, blue, alpha as gdouble (0.0-1.0)
  int r = static_cast<int>(color.red * 255.0 + 0.5);
  int g = static_cast<int>(color.green * 255.0 + 0.5);
  int b = static_cast<int>(color.blue * 255.0 + 0.5);
  int a = static_cast<int>(color.alpha * 255.0 + 0.5);
  
  // Clamp values to 0-255
  r = std::max(0, std::min(255, r));
  g = std::max(0, std::min(255, g));
  b = std::max(0, std::min(255, b));
  a = std::max(0, std::min(255, a));
  
  char hexColor[10];
  if (a == 255) {
    snprintf(hexColor, sizeof(hexColor), "#%02X%02X%02X", r, g, b);
  } else {
    snprintf(hexColor, sizeof(hexColor), "#%02X%02X%02X%02X", r, g, b, a);
  }
  
  return std::string(hexColor);
}

// === Audio State (Playing and Mute) ===

bool InAppWebView::isPlayingAudio() const {
  if (webview_ == nullptr) return false;
  
  // WPE WebKit 2.8+
  return webkit_web_view_is_playing_audio(webview_) == TRUE;
}

bool InAppWebView::isMuted() const {
  if (webview_ == nullptr) return false;
  
  // WPE WebKit 2.30+
  return webkit_web_view_get_is_muted(webview_) == TRUE;
}

void InAppWebView::setMuted(bool muted) {
  if (webview_ == nullptr) return;
  
  // WPE WebKit 2.30+
  webkit_web_view_set_is_muted(webview_, muted ? TRUE : FALSE);
}

// === Web Process Control ===

void InAppWebView::terminateWebProcess() {
  if (webview_ == nullptr) return;
  
  // WPE WebKit 2.34+
  // Terminates the web process. The web-process-terminated signal will be emitted
  // with WEBKIT_WEB_PROCESS_TERMINATED_BY_API as the reason.
  webkit_web_view_terminate_web_process(webview_);
}

// === Focus Control ===

bool InAppWebView::clearFocus() {
  if (webview_ == nullptr) return false;
  
  // Remove focused state from WPE backend
  setFocused(false);
  
  return true;
}

bool InAppWebView::requestFocus() {
  if (webview_ == nullptr) return false;
  
  // Add focused state to WPE backend
  setFocused(true);
  
  return true;
}

// === Web Archive ===

void InAppWebView::saveWebArchive(const std::string& filePath, bool autoname,
                                   std::function<void(const std::optional<std::string>&)> callback) {
  if (webview_ == nullptr || callback == nullptr) {
    if (callback) callback(std::nullopt);
    return;
  }
  
  std::string finalPath = filePath;
  
  // If autoname is true, generate a filename based on the current URL
  if (autoname) {
    const gchar* uri = webkit_web_view_get_uri(webview_);
    if (uri == nullptr) {
      callback(std::nullopt);
      return;
    }
    
    // Clean the URL to create a valid filename
    std::string urlStr(uri);
    // Replace invalid filename characters
    std::string filename;
    for (char c : urlStr) {
      if (c == '/' || c == '\\' || c == ':' || c == '*' || 
          c == '?' || c == '"' || c == '<' || c == '>' || c == '|') {
        filename += '_';
      } else {
        filename += c;
      }
    }
    
    // Limit filename length
    if (filename.length() > 200) {
      filename = filename.substr(0, 200);
    }
    
    // Append .mht extension (WPE WebKit saves as MHTML)
    finalPath = filePath + "/" + filename + ".mht";
  }
  
  // Create GFile for the destination
  GFile* file = g_file_new_for_path(finalPath.c_str());
  if (file == nullptr) {
    callback(std::nullopt);
    return;
  }
  
  // Create callback data structure
  struct SaveCallbackData {
    std::function<void(const std::optional<std::string>&)> callback;
    std::string filePath;
    InAppWebView* self;
  };
  
  auto* data = new SaveCallbackData{callback, finalPath, this};
  
  // Use webkit_web_view_save_to_file with MHTML format
  webkit_web_view_save_to_file(
      webview_,
      file,
      WEBKIT_SAVE_MODE_MHTML,
      nullptr,  // GCancellable
      [](GObject* source_object, GAsyncResult* result, gpointer user_data) {
        auto* callbackData = static_cast<SaveCallbackData*>(user_data);
        WebKitWebView* webView = WEBKIT_WEB_VIEW(source_object);
        
        GError* error = nullptr;
        gboolean success = webkit_web_view_save_to_file_finish(webView, result, &error);
        
        if (success) {
          callbackData->callback(callbackData->filePath);
        } else {
          if (error != nullptr) {
            debugLog("InAppWebView::saveWebArchive failed: " + std::string(error->message));
            g_error_free(error);
          }
          callbackData->callback(std::nullopt);
        }
        
        delete callbackData;
      },
      data
  );
  
  g_object_unref(file);
}

void InAppWebView::copyToClipboard() {
  if (webview_ == nullptr) return;

  getSelectedText([this](const std::optional<std::string>& text) {
    if (text.has_value() && !text->empty()) {
      copyTextToClipboard(*text);
    }
  });

  // Also execute WebKit's copy command for internal state
  webkit_web_view_execute_editing_command(webview_, WEBKIT_EDITING_COMMAND_COPY);
}

void InAppWebView::cutToClipboard() {
  if (webview_ == nullptr) return;

  getSelectedText([this](const std::optional<std::string>& text) {
    if (text.has_value() && !text->empty()) {
      copyTextToClipboard(*text);
    }
  });

  // Execute WebKit's cut command to remove the selection
  webkit_web_view_execute_editing_command(webview_, WEBKIT_EDITING_COMMAND_CUT);
}

void InAppWebView::pasteFromClipboard() {
  if (webview_ == nullptr) return;

  // Check if JavaScript is disabled - use WebKit's paste command as fallback
  bool jsEnabled = settings_ ? settings_->javaScriptEnabled : true;

  // Get text from system clipboard
  GtkClipboard* clipboard = gtk_clipboard_get(GDK_SELECTION_CLIPBOARD);
  gchar* text = gtk_clipboard_wait_for_text(clipboard);
  
  if (text != nullptr && strlen(text) > 0) {
    if (jsEnabled) {
      // Use JavaScript to insert text
      std::string escaped;
      escaped.reserve(strlen(text) * 2);
      for (const char* p = text; *p; ++p) {
        switch (*p) {
          case '\\': escaped += "\\\\"; break;
          case '"': escaped += "\\\""; break;
          case '\n': escaped += "\\n"; break;
          case '\r': escaped += "\\r"; break;
          case '\t': escaped += "\\t"; break;
          default: escaped += *p; break;
        }
      }
      g_free(text);
      
      // Insert text at current cursor position using execCommand
      std::string js = "document.execCommand('insertText', false, \"" + escaped + "\")";
      evaluateJavascript(js, std::nullopt, nullptr);
    } else {
      // JavaScript disabled - use WebKit's paste command
      g_free(text);
      webkit_web_view_execute_editing_command(webview_, WEBKIT_EDITING_COMMAND_PASTE);
    }
  } else {
    if (text) g_free(text);
    // If system clipboard is empty, try WebKit's paste (may have its own content)
    webkit_web_view_execute_editing_command(webview_, WEBKIT_EDITING_COMMAND_PASTE);
  }
}

void InAppWebView::copyTextToClipboard(const std::string& text) {
  if (text.empty()) return;

  // 1. Copy to GTK/system clipboard
  GtkClipboard* clipboard = gtk_clipboard_get(GDK_SELECTION_CLIPBOARD);
  gtk_clipboard_set_text(clipboard, text.c_str(), -1);
  gtk_clipboard_store(clipboard);

  // 2. Copy to WebView's internal clipboard using the Clipboard API
  // This ensures the text is available for paste within the webview
  if (webview_ != nullptr) {
    // Escape text for JavaScript
    std::string escaped;
    escaped.reserve(text.size() * 2);
    for (char c : text) {
      switch (c) {
        case '\\': escaped += "\\\\"; break;
        case '"': escaped += "\\\""; break;
        case '\n': escaped += "\\n"; break;
        case '\r': escaped += "\\r"; break;
        case '\t': escaped += "\\t"; break;
        case '`': escaped += "\\`"; break;
        case '$': escaped += "\\$"; break;
        default: escaped += c; break;
      }
    }

    // Use the modern Clipboard API with fallback
    std::string js = R"(
      (async function() {
        const text = ")" + escaped + R"(";
        try {
          if (navigator.clipboard && navigator.clipboard.writeText) {
            await navigator.clipboard.writeText(text);
          }
        } catch (e) {
          // Fallback: create temporary textarea and use execCommand
          const textarea = document.createElement('textarea');
          textarea.value = text;
          textarea.style.position = 'fixed';
          textarea.style.opacity = '0';
          document.body.appendChild(textarea);
          textarea.select();
          document.execCommand('copy');
          document.body.removeChild(textarea);
        }
      })();
    )";
    evaluateJavascript(js, std::nullopt, nullptr);
  }
}

void InAppWebView::pasteAsPlainText() {
  if (webview_ == nullptr) return;

  // Check if JavaScript is disabled - use WebKit's paste as plain text command as fallback
  bool jsEnabled = settings_ ? settings_->javaScriptEnabled : true;

  // Get text from system clipboard
  GtkClipboard* clipboard = gtk_clipboard_get(GDK_SELECTION_CLIPBOARD);
  gchar* text = gtk_clipboard_wait_for_text(clipboard);
  
  if (text != nullptr && strlen(text) > 0) {
    if (jsEnabled) {
      // Use JavaScript to insert text (already plain text from gtk_clipboard_wait_for_text)
      std::string escaped;
      escaped.reserve(strlen(text) * 2);
      for (const char* p = text; *p; ++p) {
        switch (*p) {
          case '\\': escaped += "\\\\"; break;
          case '"': escaped += "\\\""; break;
          case '\n': escaped += "\\n"; break;
          case '\r': escaped += "\\r"; break;
          case '\t': escaped += "\\t"; break;
          default: escaped += *p; break;
        }
      }
      g_free(text);
      
      // Insert text at current cursor position using execCommand
      std::string js = "document.execCommand('insertText', false, \"" + escaped + "\")";
      evaluateJavascript(js, std::nullopt, nullptr);
    } else {
      // JavaScript disabled - use WebKit's paste as plain text command
      g_free(text);
      webkit_web_view_execute_editing_command(webview_, WEBKIT_EDITING_COMMAND_PASTE_AS_PLAIN_TEXT);
    }
  } else {
    if (text) g_free(text);
    // If system clipboard is empty, try WebKit's paste as plain text
    webkit_web_view_execute_editing_command(webview_, WEBKIT_EDITING_COMMAND_PASTE_AS_PLAIN_TEXT);
  }
}

void InAppWebView::selectAll() {
  if (webview_ == nullptr) return;
  webkit_web_view_execute_editing_command(webview_, WEBKIT_EDITING_COMMAND_SELECT_ALL);
}

void InAppWebView::undo() {
  if (webview_ == nullptr) return;
  webkit_web_view_execute_editing_command(webview_, WEBKIT_EDITING_COMMAND_UNDO);
}

void InAppWebView::redo() {
  if (webview_ == nullptr) return;
  webkit_web_view_execute_editing_command(webview_, WEBKIT_EDITING_COMMAND_REDO);
}

void InAppWebView::insertImage(const std::string& imageUri) {
  if (webview_ == nullptr || imageUri.empty()) return;
  webkit_web_view_execute_editing_command_with_argument(
      webview_, WEBKIT_EDITING_COMMAND_INSERT_IMAGE, imageUri.c_str());
}

void InAppWebView::createLink(const std::string& linkUri) {
  if (webview_ == nullptr || linkUri.empty()) return;
  webkit_web_view_execute_editing_command_with_argument(
      webview_, WEBKIT_EDITING_COMMAND_CREATE_LINK, linkUri.c_str());
}

gboolean InAppWebView::OnEnterFullscreen(WebKitWebView* web_view, gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);
  self->is_fullscreen_ = true;

  // Notify WPE backend that we entered fullscreen
#ifdef HAVE_WPE_BACKEND_LEGACY
  if (self->wpe_backend_ != nullptr) {
    wpe_view_backend_dispatch_did_enter_fullscreen(self->wpe_backend_);
  }
#endif

  if (self->channel_delegate_) {
    self->channel_delegate_->onEnterFullscreen();
  }
  return TRUE;  // We handled the fullscreen request
}

gboolean InAppWebView::OnLeaveFullscreen(WebKitWebView* web_view, gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);
  self->is_fullscreen_ = false;

  // Notify WPE backend that we exited fullscreen
#ifdef HAVE_WPE_BACKEND_LEGACY
  if (self->wpe_backend_ != nullptr) {
    wpe_view_backend_dispatch_did_exit_fullscreen(self->wpe_backend_);
  }
#endif

  if (self->channel_delegate_) {
    self->channel_delegate_->onExitFullscreen();
  }
  return TRUE;  // We handled the fullscreen exit
}

void InAppWebView::OnMouseTargetChanged(WebKitWebView* web_view,
                                        WebKitHitTestResult* hit_test_result, guint modifiers,
                                        gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);

  // Store the hit test result for getHitTestResult()
  // Release previous result and ref new one (if not null)
  if (self->last_hit_test_result_ != nullptr) {
    g_object_unref(self->last_hit_test_result_);
    self->last_hit_test_result_ = nullptr;
  }
  if (hit_test_result != nullptr) {
    self->last_hit_test_result_ = hit_test_result;
    g_object_ref(hit_test_result);
  }

  // Determine cursor based on hit test result
  // Use CSS cursor names which gdk_cursor_new_from_name() supports
  std::string cursor_name = "default";

  if (hit_test_result == nullptr) {
    // No hit test result, use default cursor
  } else if (webkit_hit_test_result_context_is_link(hit_test_result)) {
    cursor_name = "pointer";  // Hand cursor for links
  } else if (webkit_hit_test_result_context_is_editable(hit_test_result)) {
    cursor_name = "text";  // Text cursor for editable content
  } else if (webkit_hit_test_result_context_is_selection(hit_test_result)) {
    cursor_name = "text";  // Text cursor for selection
  } else if (webkit_hit_test_result_context_is_image(hit_test_result)) {
    // Check if image is also a link
    if (webkit_hit_test_result_context_is_link(hit_test_result)) {
      cursor_name = "pointer";
    }
  } else if (webkit_hit_test_result_context_is_media(hit_test_result)) {
    cursor_name = "default";
  } else if (webkit_hit_test_result_context_is_scrollbar(hit_test_result)) {
    cursor_name = "default";
  }

  // Only emit if cursor changed
  if (cursor_name != self->last_cursor_name_) {
    self->last_cursor_name_ = cursor_name;
    if (self->on_cursor_changed_) {
      self->on_cursor_changed_(cursor_name);
    }
  }
}

void InAppWebView::OnWebProcessTerminated(WebKitWebView* web_view,
                                          WebKitWebProcessTerminationReason reason,
                                          gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);

  // Determine if this was a crash or a kill
  // - WEBKIT_WEB_PROCESS_CRASHED: The web process crashed -> didCrash = true
  // - WEBKIT_WEB_PROCESS_EXCEEDED_MEMORY_LIMIT: Killed by system due to memory -> didCrash = false
  // - WEBKIT_WEB_PROCESS_TERMINATED_BY_API: Terminated via API call -> didCrash = false
  bool didCrash = (reason == WEBKIT_WEB_PROCESS_CRASHED);

  // Log the termination with detailed information
  const char* reason_str = "unknown";
  switch (reason) {
    case WEBKIT_WEB_PROCESS_CRASHED:
      reason_str = "CRASHED";
      break;
    case WEBKIT_WEB_PROCESS_EXCEEDED_MEMORY_LIMIT:
      reason_str = "EXCEEDED_MEMORY_LIMIT";
      break;
    case WEBKIT_WEB_PROCESS_TERMINATED_BY_API:
      reason_str = "TERMINATED_BY_API";
      break;
    default:
      break;
  }

  g_warning("InAppWebView[%ld]: WebProcess terminated (reason=%s, didCrash=%s)",
            self->id_, reason_str, didCrash ? "true" : "false");

#ifdef HAVE_WPE_BACKEND_LEGACY
  // IMPORTANT: When WebProcess crashes (especially from "Failed to bind wl_compositor"),
  // the WPE FDO connection is broken. We should NOT call any WPE FDO functions here
  // as they may cause additional errors or hangs. Simply null out the pointer.
  //
  // The exported_image_ was being used by the crashed WebProcess, and its underlying
  // Wayland resources are now invalid. Calling wpe_view_backend_exportable_fdo_egl_dispatch_release_exported_image
  // on a broken connection can cause further issues.
  {
    std::lock_guard<std::mutex> lock(self->exported_image_mutex_);
    if (self->exported_image_ != nullptr) {
      g_message("InAppWebView[%ld]: Nulling stale EGL image %p after WebProcess termination (not releasing via WPE FDO)",
                self->id_, (void*)self->exported_image_);
      // Don't call WPE FDO release - the connection is broken
      self->exported_image_ = nullptr;
    }
  }
#endif  // HAVE_WPE_BACKEND_LEGACY

  if (self->channel_delegate_) {
    self->channel_delegate_->onRenderProcessGone(didCrash);
  }
}

// Static callback for non-blocking file chooser dialog response
static void OnFileChooserDialogResponse(GtkDialog* dialog, gint response_id, gpointer user_data) {
  auto* context = static_cast<FileChooserContext*>(user_data);
  
  // Check if this dialog is still the active one (prevents double-cleanup)
  if (context->webview && context->webview->active_file_dialog_ != GTK_WIDGET(dialog)) {
    // Dialog was already cleaned up by HideFileChooser(), just delete context
    delete context;
    return;
  }
  
  GtkFileChooser* chooser = GTK_FILE_CHOOSER(dialog);

  if (response_id == GTK_RESPONSE_ACCEPT) {
    if (context->selectMultiple) {
      // Get multiple files
      GSList* files = gtk_file_chooser_get_filenames(chooser);
      if (files != nullptr) {
        std::vector<std::string> filePaths;
        for (GSList* item = files; item != nullptr; item = item->next) {
          gchar* filename = static_cast<gchar*>(item->data);
          if (filename != nullptr) {
            // Convert to file:// URI
            gchar* uri = g_filename_to_uri(filename, nullptr, nullptr);
            if (uri != nullptr) {
              filePaths.push_back(uri);
              g_free(uri);
            }
            g_free(filename);
          }
        }
        g_slist_free(files);

        // Convert to gchar** format for WebKit
        std::vector<const gchar*> uris;
        for (const auto& path : filePaths) {
          uris.push_back(path.c_str());
        }
        uris.push_back(nullptr);  // NULL-terminated
        webkit_file_chooser_request_select_files(context->request, uris.data());
      } else {
        webkit_file_chooser_request_cancel(context->request);
      }
    } else {
      // Get single file
      gchar* filename = gtk_file_chooser_get_filename(chooser);
      if (filename != nullptr) {
        gchar* uri = g_filename_to_uri(filename, nullptr, nullptr);
        if (uri != nullptr) {
          const gchar* uris[] = {uri, nullptr};
          webkit_file_chooser_request_select_files(context->request, uris);
          g_free(uri);
        } else {
          webkit_file_chooser_request_cancel(context->request);
        }
        g_free(filename);
      } else {
        webkit_file_chooser_request_cancel(context->request);
      }
    }
  } else {
    // User cancelled (Cancel button, X button, or Escape key)
    webkit_file_chooser_request_cancel(context->request);
  }

  // Clear tracking in webview
  if (context->webview) {
    context->webview->active_file_dialog_ = nullptr;
    context->webview->file_dialog_show_time_ = 0;
    context->webview->file_chooser_context_ = nullptr;
  }

  gtk_widget_destroy(GTK_WIDGET(dialog));
  g_object_unref(dialog);  // Release our extra reference
  delete context;
}

// Helper function to show native GTK file chooser dialog (non-blocking)
static void ShowNativeFileChooser(InAppWebView* webview,
                                   WebKitFileChooserRequest* request,
                                   bool selectMultiple,
                                   const std::vector<std::string>& mimeTypes,
                                   GtkWindow* parentWindow) {
  // Close any existing file dialog first
  if (webview && webview->active_file_dialog_ != nullptr) {
    // Clean up old context if it exists
    if (webview->file_chooser_context_ != nullptr) {
      auto* old_context = static_cast<FileChooserContext*>(webview->file_chooser_context_);
      if (old_context->response_handler_id != 0) {
        g_signal_handler_disconnect(webview->active_file_dialog_, old_context->response_handler_id);
      }
      webkit_file_chooser_request_cancel(old_context->request);
      delete old_context;
      webview->file_chooser_context_ = nullptr;
    }
    gtk_widget_destroy(webview->active_file_dialog_);
    g_object_unref(webview->active_file_dialog_);
    webview->active_file_dialog_ = nullptr;
  }

  // Create the file chooser dialog with parent window
  GtkWidget* dialog = gtk_file_chooser_dialog_new(
      "Select File",
      parentWindow,
      GTK_FILE_CHOOSER_ACTION_OPEN,
      "_Cancel", GTK_RESPONSE_CANCEL,
      "_Open", GTK_RESPONSE_ACCEPT,
      nullptr);

  // Track the dialog in webview
  if (webview) {
    webview->active_file_dialog_ = dialog;
  }

  // Set dialog as transient for parent (floats above but doesn't block)
  if (parentWindow) {
    gtk_window_set_transient_for(GTK_WINDOW(dialog), parentWindow);
  }

  // Take an extra reference to prevent premature destruction
  g_object_ref(dialog);

  GtkFileChooser* chooser = GTK_FILE_CHOOSER(dialog);

  // Enable multiple selection if requested
  gtk_file_chooser_set_select_multiple(chooser, selectMultiple ? TRUE : FALSE);

  // Add file filters based on MIME types
  if (!mimeTypes.empty()) {
    GtkFileFilter* filter = gtk_file_filter_new();
    gtk_file_filter_set_name(filter, "Allowed files");
    for (const auto& mimeType : mimeTypes) {
      gtk_file_filter_add_mime_type(filter, mimeType.c_str());
    }
    gtk_file_chooser_add_filter(chooser, filter);

    // Also add an "All files" filter
    GtkFileFilter* allFilter = gtk_file_filter_new();
    gtk_file_filter_set_name(allFilter, "All files");
    gtk_file_filter_add_pattern(allFilter, "*");
    gtk_file_chooser_add_filter(chooser, allFilter);
  }

  // Create context for the callback
  auto* context = new FileChooserContext(request, selectMultiple, webview);
  
  // Store context pointer in webview for cleanup in HideFileChooser
  if (webview) {
    webview->file_chooser_context_ = context;
  }
  
  // Connect to response signal for non-blocking behavior
  context->response_handler_id = g_signal_connect(dialog, "response", 
      G_CALLBACK(OnFileChooserDialogResponse), context);
  
  // Show the dialog and all its children (non-blocking)
  gtk_widget_show_all(dialog);

  // Record show time to prevent immediate close by pointer events
  if (webview) {
    webview->file_dialog_show_time_ = g_get_monotonic_time();
  }
}

gboolean InAppWebView::OnRunFileChooser(WebKitWebView* web_view,
                                        WebKitFileChooserRequest* request,
                                        gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);

  // Get file chooser properties
  gboolean select_multiple = webkit_file_chooser_request_get_select_multiple(request);
  const gchar* const* mime_types = webkit_file_chooser_request_get_mime_types(request);

  // Build accept types list
  std::vector<std::string> acceptTypes;
  if (mime_types) {
    for (int i = 0; mime_types[i] != nullptr; i++) {
      acceptTypes.push_back(mime_types[i]);
    }
  }

  // If no channel delegate, show native dialog directly
  if (!self->channel_delegate_) {
    ShowNativeFileChooser(self, request, select_multiple, acceptTypes, self->gtk_window_);
    return TRUE;
  }

  // Keep request alive during async callback
  g_object_ref(request);

  // Determine mode: OPEN or OPEN_MULTIPLE (WPE doesn't have folder/save modes in this API)
  int mode = select_multiple ? 1 : 0;  // 0 = OPEN, 1 = OPEN_MULTIPLE

  // Capture variables for the lambda
  bool selectMultipleCopy = select_multiple;
  std::vector<std::string> acceptTypesCopy = acceptTypes;
  GtkWindow* parentWindow = self->gtk_window_;

  self->channel_delegate_->onShowFileChooser(
      mode,
      acceptTypes,
      false,  // isCaptureEnabled - not exposed by WPE API
      std::nullopt,  // title
      std::nullopt,  // filenameHint
      [self, request, selectMultipleCopy, acceptTypesCopy, parentWindow](ShowFileChooserResponse response) {
        if (response.handledByClient) {
          // Client handled it - use the file paths from Dart
          if (response.filePaths.has_value() && !response.filePaths->empty()) {
            // Convert to gchar** format
            std::vector<const gchar*> files;
            for (const auto& path : *response.filePaths) {
              files.push_back(path.c_str());
            }
            files.push_back(nullptr);  // NULL-terminated
            webkit_file_chooser_request_select_files(request, files.data());
          } else {
            // Client handled but no files selected (cancelled)
            webkit_file_chooser_request_cancel(request);
          }
        } else {
          // Client didn't handle it - show native GTK file chooser
          ShowNativeFileChooser(self, request, selectMultipleCopy, acceptTypesCopy, parentWindow);
        }
        g_object_unref(request);
      });

  return TRUE;  // We handled it
}

// === Option Menu (HTML <select>) Handler ===

gboolean InAppWebView::OnShowOptionMenu(WebKitWebView* web_view,
                                        WebKitOptionMenu* menu,
                                        WebKitRectangle* rectangle,
                                        gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);
  
  // Hide any existing option menu first
  if (self->option_menu_popup_) {
    self->option_menu_popup_->Hide();
  }
  
  // Get the parent GTK window
  GtkWindow* parent_window = self->gtk_window_;
  if (parent_window == nullptr) {
    return FALSE;
  }
  
  // Create the popup if needed
  if (!self->option_menu_popup_) {
    self->option_menu_popup_ = std::make_unique<OptionMenuPopup>(parent_window);
  }
  
  // Take a reference to the WebKit option menu to keep it alive
  g_object_ref(menu);
  self->webkit_option_menu_ = menu;
  
  // Set the option menu data
  self->option_menu_popup_->SetOptionMenu(menu);
  
  // Set callbacks
  self->option_menu_popup_->SetItemSelectedCallback([self](guint index) {
    // Activate the selected item
    if (self->webkit_option_menu_ != nullptr) {
      webkit_option_menu_activate_item(self->webkit_option_menu_, index);
    }
  });
  
  self->option_menu_popup_->SetDismissedCallback([self]() {
    // Close the WebKit option menu
    if (self->webkit_option_menu_ != nullptr) {
      webkit_option_menu_close(self->webkit_option_menu_);
      g_object_unref(self->webkit_option_menu_);
      self->webkit_option_menu_ = nullptr;
    }
  });
  
  // Calculate popup position
  // On Wayland, absolute window positions aren't available (gdk_window_get_origin returns 0,0).
  // Instead, we use the current pointer screen position and calculate the offset needed
  // to position the popup at the bottom-left of the select element.
  //
  // The rectangle is in web content coordinates.
  // cursor_x_/cursor_y_ contains where the click happened in WebView coordinates.
  // We calculate where the popup should appear relative to the click position.
  
  // Get the current pointer screen position (where user clicked)
  gint pointer_x = 0, pointer_y = 0;
  GdkDisplay* gdk_display = gdk_display_get_default();
  if (gdk_display != nullptr) {
    GdkSeat* seat = gdk_display_get_default_seat(gdk_display);
    if (seat != nullptr) {
      GdkDevice* pointer = gdk_seat_get_pointer(seat);
      if (pointer != nullptr) {
        gdk_device_get_position(pointer, nullptr, &pointer_x, &pointer_y);
      }
    }
  }
  
  // The click was at (cursor_x_, cursor_y_) in WebView coordinates
  // The rectangle is in web content coordinates (same as WebView coordinates for our purpose)
  // Calculate how far the click was from the left edge and bottom of the element
  double click_offset_from_left = self->cursor_x_ - rectangle->x;
  double click_offset_from_bottom = (rectangle->y + rectangle->height) - self->cursor_y_;
  
  // Position popup: left-aligned with element, just below element
  int popup_x = pointer_x - static_cast<int>(click_offset_from_left);
  int popup_y = pointer_y + static_cast<int>(click_offset_from_bottom);
  
  // Show the popup - use rectangle->width as the exact width to match the select element
  self->option_menu_popup_->Show(popup_x, popup_y, rectangle->width);
  
  return TRUE;  // We handled it
}

// === Navigation State Signal Handler ===

void InAppWebView::OnBackForwardListChanged(WebKitBackForwardList* list,
                                            WebKitBackForwardListItem* item_added,
                                            gpointer items_removed,
                                            gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);
  if (self && self->on_navigation_state_changed_) {
    self->on_navigation_state_changed_();
  }
}

// === Media Capture State Signal Handlers ===

void InAppWebView::OnNotifyCameraCaptureState(GObject* object, GParamSpec* pspec,
                                               gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);
  if (!self || !self->channel_delegate_) {
    return;
  }

  WebKitWebView* webview = WEBKIT_WEB_VIEW(object);
  WebKitMediaCaptureState newState = webkit_web_view_get_camera_capture_state(webview);

  int oldStateInt = self->last_camera_capture_state_;
  int newStateInt = static_cast<int>(newState);

  // Only fire event if state actually changed
  if (oldStateInt != newStateInt) {
    self->last_camera_capture_state_ = newStateInt;
    self->channel_delegate_->onCameraCaptureStateChanged(oldStateInt, newStateInt);
  }
}

void InAppWebView::OnNotifyMicrophoneCaptureState(GObject* object, GParamSpec* pspec,
                                                   gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);
  if (!self || !self->channel_delegate_) {
    return;
  }

  WebKitWebView* webview = WEBKIT_WEB_VIEW(object);
  WebKitMediaCaptureState newState = webkit_web_view_get_microphone_capture_state(webview);

  int oldStateInt = self->last_microphone_capture_state_;
  int newStateInt = static_cast<int>(newState);

  // Only fire event if state actually changed
  if (oldStateInt != newStateInt) {
    self->last_microphone_capture_state_ = newStateInt;
    self->channel_delegate_->onMicrophoneCaptureStateChanged(oldStateInt, newStateInt);
  }
}

// === Download Signal Handler ===

void InAppWebView::OnDownloadStarted(WebKitNetworkSession* network_session,
                                     WebKitDownload* download,
                                     gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);

  // Check if download callback is enabled via settings
  if (!self->settings_ || !self->settings_->useOnDownloadStart) {
    // If not enabled, just cancel the download since we don't handle it
    webkit_download_cancel(download);
    return;
  }

  if (!self->channel_delegate_) {
    webkit_download_cancel(download);
    return;
  }

  // Create DownloadStartRequest from WebKitDownload
  auto request = std::make_unique<DownloadStartRequest>(download);

  // Create callback for async response
  auto callback = std::make_unique<WebViewChannelDelegate::DownloadStartCallback>();

  // Keep download reference alive during async callback
  g_object_ref(download);

  callback->nonNullSuccess = [download](DownloadStartResponse response) -> bool {
    // Cancel the download regardless of response - we just notify Dart
    // The Dart side is responsible for handling the actual download if needed
    webkit_download_cancel(download);
    g_object_unref(download);
    return false;  // Return false to prevent defaultBehaviour from running
  };

  callback->defaultBehaviour = [download](const std::optional<DownloadStartResponse>& response) {
    // Default: cancel the download
    webkit_download_cancel(download);
    g_object_unref(download);
  };

  callback->error = [download](const std::string& code, const std::string& message) {
    debugLog("Error in onDownloadStarting: " + code + " - " + message);
    webkit_download_cancel(download);
    g_object_unref(download);
  };

  // Call onDownloadStarting to match the Dart side callback
  self->channel_delegate_->onDownloadStarting(std::move(request), std::move(callback));
}

// NOTE: OnMotionNotify and OnNotifyFavicon have been removed because:
// - motion-notify-event is a GTK widget signal (WPE WebView is NOT a GTK widget)
// - notify::favicon property does not exist in WPE WebKit (GTK-only)
// Cursor detection in WPE is handled via mouse-target-changed and CursorDetectionJS plugin script.

// === Cursor Detection ===

void InAppWebView::updateCursorFromCssStyle(const std::string& cursor_style) {
  // Use CSS cursor names - supported by both GDK and Flutter cursor mapping
  std::string cursor_name = "default";

  if (cursor_style == "pointer" || cursor_style == "hand") {
    cursor_name = "pointer";
  } else if (cursor_style == "text") {
    cursor_name = "text";
  } else if (cursor_style == "vertical-text") {
    cursor_name = "vertical-text";
  } else if (cursor_style == "wait") {
    cursor_name = "wait";
  } else if (cursor_style == "progress") {
    cursor_name = "progress";
  } else if (cursor_style == "help") {
    cursor_name = "help";
  } else if (cursor_style == "crosshair") {
    cursor_name = "crosshair";
  } else if (cursor_style == "move") {
    cursor_name = "move";
  } else if (cursor_style == "all-scroll") {
    cursor_name = "all-scroll";
  } else if (cursor_style == "grab") {
    cursor_name = "grab";
  } else if (cursor_style == "grabbing") {
    cursor_name = "grabbing";
  } else if (cursor_style == "not-allowed") {
    cursor_name = "not-allowed";
  } else if (cursor_style == "no-drop") {
    cursor_name = "no-drop";
  } else if (cursor_style == "context-menu") {
    cursor_name = "context-menu";
  } else if (cursor_style == "cell") {
    cursor_name = "cell";
  } else if (cursor_style == "copy") {
    cursor_name = "copy";
  } else if (cursor_style == "alias") {
    cursor_name = "alias";
  } else if (cursor_style == "none") {
    cursor_name = "none";
  } else if (cursor_style == "col-resize") {
    cursor_name = "col-resize";
  } else if (cursor_style == "row-resize") {
    cursor_name = "row-resize";
  } else if (cursor_style == "n-resize") {
    cursor_name = "n-resize";
  } else if (cursor_style == "s-resize") {
    cursor_name = "s-resize";
  } else if (cursor_style == "e-resize") {
    cursor_name = "e-resize";
  } else if (cursor_style == "w-resize") {
    cursor_name = "w-resize";
  } else if (cursor_style == "ns-resize") {
    cursor_name = "ns-resize";
  } else if (cursor_style == "ew-resize") {
    cursor_name = "ew-resize";
  } else if (cursor_style == "ne-resize") {
    cursor_name = "ne-resize";
  } else if (cursor_style == "nw-resize") {
    cursor_name = "nw-resize";
  } else if (cursor_style == "se-resize") {
    cursor_name = "se-resize";
  } else if (cursor_style == "sw-resize") {
    cursor_name = "sw-resize";
  } else if (cursor_style == "nesw-resize") {
    cursor_name = "nesw-resize";
  } else if (cursor_style == "nwse-resize") {
    cursor_name = "nwse-resize";
  } else if (cursor_style == "zoom-in") {
    cursor_name = "zoom-in";
  } else if (cursor_style == "zoom-out") {
    cursor_name = "zoom-out";
  }
  // default, auto, inherit -> "default"

  if (cursor_name != last_cursor_name_) {
    last_cursor_name_ = cursor_name;
    if (on_cursor_changed_) {
      on_cursor_changed_(cursor_name);
    }
  }
}

// === JavaScript Bridge ===

bool InAppWebView::handleScriptMessageWithReply(const std::string& body, WebKitScriptMessageReply* reply) {
  // === Security Check 1: javaScriptBridgeEnabled ===
  if (settings_ && !settings_->javaScriptBridgeEnabled) {
    return false;
  }

  // Parse the body as JSON
  json bodyJson;
  try {
    bodyJson = json::parse(body);
  } catch (const json::parse_error& e) {
    return false;
  }

  // === Security Check 2: Bridge Secret Validation ===
  std::string receivedSecret = "";
  if (bodyJson.contains("_bridgeSecret") && bodyJson["_bridgeSecret"].is_string()) {
    receivedSecret = bodyJson["_bridgeSecret"].get<std::string>();
  }

  if (receivedSecret != js_bridge_secret_) {
    std::string securityOrigin = "unknown";
    const gchar* uri = webkit_web_view_get_uri(webview_);
    if (uri != nullptr) {
      securityOrigin = std::string(uri);
    }
    errorLog("InAppWebView: Bridge access attempt with wrong secret token from origin " + securityOrigin);
    return false;
  }

  // === Build Source Origin ===
  std::string sourceOrigin = "";
  std::string requestUrl = "";
  bool isMainFrame = true;  // Default to true

  // Parse isMainFrame from the JSON body (sent from JavaScript bridge)
  if (bodyJson.contains("_isMainFrame") && bodyJson["_isMainFrame"].is_boolean()) {
    isMainFrame = bodyJson["_isMainFrame"].get<bool>();
  }

  const gchar* uri = webkit_web_view_get_uri(webview_);
  if (uri != nullptr) {
    requestUrl = std::string(uri);
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
  bool isOriginAllowed = true;
  if (settings_ && settings_->javaScriptHandlersOriginAllowList.has_value()) {
    const auto& allowList = settings_->javaScriptHandlersOriginAllowList.value();
    if (!allowList.empty()) {
      isOriginAllowed = false;
      for (const auto& allowedOrigin : allowList) {
        if (!sourceOrigin.empty() && sourceOrigin.find(allowedOrigin) != std::string::npos) {
          isOriginAllowed = true;
          break;
        }
      }
    }
  }

  if (!isOriginAllowed) {
    errorLog("InAppWebView: Bridge access attempt from origin not allowed: " + sourceOrigin);
    return false;
  }

  // === Extract handler name and args ===
  std::string handlerName = "";
  if (bodyJson.contains("handlerName") && bodyJson["handlerName"].is_string()) {
    handlerName = bodyJson["handlerName"].get<std::string>();
  }

  std::string argsJsonStr = "";
  if (bodyJson.contains("args") && bodyJson["args"].is_string()) {
    argsJsonStr = bodyJson["args"].get<std::string>();
  }

  // === Multi-Window Support: Extract _windowId ===
  std::optional<int64_t> windowId;
  if (bodyJson.contains("_windowId") && bodyJson["_windowId"].is_number()) {
    windowId = bodyJson["_windowId"].get<int64_t>();
  }

  InAppWebView* targetWebView = this;
  
  // Multi-window support: lookup by windowId if available
  if (windowId.has_value() && manager_ != nullptr) {
    WebViewTransport* transport = manager_->GetWindowWebView(windowId.value());
    if (transport != nullptr && transport->inAppWebView != nullptr) {
      targetWebView = transport->inAppWebView.get();
    }
  }

  // === Handle Internal Handlers ===
  
  if (handlerName == "onConsoleMessage") {
    // Handle console message interception
    std::string message = "";
    std::string level = "log";

    if (!argsJsonStr.empty()) {
      try {
        json argsJson = json::parse(argsJsonStr);
        if (argsJson.is_array() && !argsJson.empty()) {
          json firstArg = argsJson[0];
          if (firstArg.contains("level") && firstArg["level"].is_string()) {
            level = firstArg["level"].get<std::string>();
          }
          if (firstArg.contains("message") && firstArg["message"].is_string()) {
            message = firstArg["message"].get<std::string>();
          }
        }
      } catch (const json::parse_error& e) {}
    }

    int64_t messageLevel = 1;  // LOG
    if (level == "debug") {
      messageLevel = 0;
    } else if (level == "info" || level == "log") {
      messageLevel = 1;
    } else if (level == "warn") {
      messageLevel = 2;
    } else if (level == "error") {
      messageLevel = 3;
    }

    if (targetWebView->channel_delegate_) {
      targetWebView->channel_delegate_->onConsoleMessage(message, messageLevel);
    }
    ResolveInternalHandlerWithReply(reply, "null");
    return true;
  }
  
  if (handlerName == "onLoadResource") {
    // Handle resource load tracking
    std::string url = "";
    std::string initiatorType = "";
    double startTime = 0.0;
    double duration = 0.0;

    if (!argsJsonStr.empty()) {
      try {
        json argsJson = json::parse(argsJsonStr);
        if (argsJson.is_array() && !argsJson.empty()) {
          json firstArg = argsJson[0];
          if (firstArg.contains("url") && firstArg["url"].is_string()) {
            url = firstArg["url"].get<std::string>();
          }
          if (firstArg.contains("initiatorType") && firstArg["initiatorType"].is_string()) {
            initiatorType = firstArg["initiatorType"].get<std::string>();
          }
          if (firstArg.contains("startTime") && firstArg["startTime"].is_number()) {
            startTime = firstArg["startTime"].get<double>();
          }
          if (firstArg.contains("duration") && firstArg["duration"].is_number()) {
            duration = firstArg["duration"].get<double>();
          }
        }
      } catch (const json::parse_error& e) {}
    }

    if (targetWebView->channel_delegate_) {
      targetWebView->channel_delegate_->onLoadResource(url, initiatorType, startTime, duration);
    }
    ResolveInternalHandlerWithReply(reply, "null");
    return true;
  }

  if (handlerName == "onWebMessagePortMessageReceived") {
    // Handle WebMessageChannel port message
    std::string webMessageChannelId = "";
    int portIndex = 0;
    std::string messageData = "";
    int64_t messageType = 0;

    if (!argsJsonStr.empty()) {
      try {
        json argsJson = json::parse(argsJsonStr);
        if (argsJson.is_array() && !argsJson.empty()) {
          json firstArg = argsJson[0];
          if (firstArg.contains("webMessageChannelId") && firstArg["webMessageChannelId"].is_string()) {
            webMessageChannelId = firstArg["webMessageChannelId"].get<std::string>();
          }
          if (firstArg.contains("index") && firstArg["index"].is_number()) {
            portIndex = firstArg["index"].get<int>();
          }
          if (firstArg.contains("message") && firstArg["message"].is_object()) {
            json messageObj = firstArg["message"];
            if (messageObj.contains("type") && messageObj["type"].is_number()) {
              messageType = messageObj["type"].get<int64_t>();
            }
            if (messageObj.contains("data")) {
              if (messageType == 1 && messageObj["data"].is_array()) {
                std::string bytes;
                for (auto& byte : messageObj["data"]) {
                  if (!bytes.empty()) bytes += ",";
                  bytes += std::to_string(byte.get<int>());
                }
                messageData = bytes;
              } else if (messageObj["data"].is_string()) {
                messageData = messageObj["data"].get<std::string>();
              } else if (!messageObj["data"].is_null()) {
                messageData = messageObj["data"].dump();
              }
            }
          }
        }
      } catch (const json::parse_error& e) {}
    }

    if (!webMessageChannelId.empty()) {
      WebMessageChannel* channel = targetWebView->getWebMessageChannel(webMessageChannelId);
      if (channel != nullptr) {
        channel->onMessage(portIndex, messageData.empty() ? nullptr : &messageData, messageType);
      }
    }
    ResolveInternalHandlerWithReply(reply, "null");
    return true;
  }

  if (handlerName == "onWebMessageListenerPostMessageReceived") {
    // Handle WebMessageListener post message
    std::string jsObjectName = "";
    std::string messageData = "";
    int64_t messageType = 0;
    std::string sourceOriginStr = "";
    bool isMainFrameMsg = true;

    if (!argsJsonStr.empty()) {
      try {
        json argsJson = json::parse(argsJsonStr);
        if (argsJson.is_array() && !argsJson.empty()) {
          json firstArg = argsJson[0];
          if (firstArg.contains("jsObjectName") && firstArg["jsObjectName"].is_string()) {
            jsObjectName = firstArg["jsObjectName"].get<std::string>();
          }
          if (firstArg.contains("sourceOrigin") && firstArg["sourceOrigin"].is_string()) {
            sourceOriginStr = firstArg["sourceOrigin"].get<std::string>();
          }
          if (firstArg.contains("isMainFrame") && firstArg["isMainFrame"].is_boolean()) {
            isMainFrameMsg = firstArg["isMainFrame"].get<bool>();
          }
          if (firstArg.contains("message") && firstArg["message"].is_object()) {
            json messageObj = firstArg["message"];
            if (messageObj.contains("type") && messageObj["type"].is_number()) {
              messageType = messageObj["type"].get<int64_t>();
            }
            if (messageObj.contains("data")) {
              if (messageType == 1 && messageObj["data"].is_array()) {
                std::string bytes;
                for (auto& byte : messageObj["data"]) {
                  if (!bytes.empty()) bytes += ",";
                  bytes += std::to_string(byte.get<int>());
                }
                messageData = bytes;
              } else if (messageObj["data"].is_string()) {
                messageData = messageObj["data"].get<std::string>();
              } else if (!messageObj["data"].is_null()) {
                messageData = messageObj["data"].dump();
              }
            }
          }
        }
      } catch (const json::parse_error& e) {}
    }

    if (!jsObjectName.empty()) {
      auto it = targetWebView->web_message_listeners_.find(jsObjectName);
      if (it != targetWebView->web_message_listeners_.end() && it->second) {
        it->second->onPostMessage(
            messageData.empty() ? nullptr : &messageData,
            messageType,
            sourceOriginStr,
            isMainFrameMsg);
      }
    }
    ResolveInternalHandlerWithReply(reply, "null");
    return true;
  }

  if (handlerName == "onPrintRequest") {
    // Handle print request - currently just acknowledge it
    // Full print implementation would require platform-specific print dialog
    ResolveInternalHandlerWithReply(reply, "null");
    return true;
  }

  if (handlerName == "onFindResultReceived") {
    // Handle find result - this is typically sent by FindInteractionController
    // The find results are already handled via the native find API
    ResolveInternalHandlerWithReply(reply, "null");
    return true;
  }

  if (handlerName == "_cursorChanged") {
    if (!argsJsonStr.empty()) {
      try {
        json argsJson = json::parse(argsJsonStr);
        if (argsJson.is_array() && !argsJson.empty() && argsJson[0].is_string()) {
          const std::string cursorStyle = argsJson[0].get<std::string>();
          updateCursorFromCssStyle(cursorStyle);
        }
      } catch (...) {}
    }
    ResolveInternalHandlerWithReply(reply, "null");
    return true;
  }

  if (handlerName == "_onColorInputClicked") {
    // Handle color input click - args: { currentColor, elemRect, predefinedColors, alphaEnabled, colorSpace }
    std::string currentColor = "#000000";
    std::vector<std::string> predefinedColors;
    bool alphaEnabled = false;
    std::string colorSpace = "limited-srgb";

    if (!argsJsonStr.empty()) {
      try {
        json argsJson = json::parse(argsJsonStr);
        // Args is an array with a single object: [{ currentColor, elemRect, ... }]
        json argsObj;
        if (argsJson.is_array() && !argsJson.empty() && argsJson[0].is_object()) {
          argsObj = argsJson[0];
        } else if (argsJson.is_object()) {
          argsObj = argsJson;
        }
        
        if (!argsObj.is_null()) {
          if (argsObj.contains("currentColor") && argsObj["currentColor"].is_string()) {
            currentColor = argsObj["currentColor"].get<std::string>();
          }
          // elemRect is for positioning, we use screen cursor position instead
          if (argsObj.contains("predefinedColors") && argsObj["predefinedColors"].is_array()) {
            for (const auto& color : argsObj["predefinedColors"]) {
              if (color.is_string()) {
                predefinedColors.push_back(color.get<std::string>());
              }
            }
          }
          if (argsObj.contains("alphaEnabled") && argsObj["alphaEnabled"].is_boolean()) {
            alphaEnabled = argsObj["alphaEnabled"].get<bool>();
          }
          if (argsObj.contains("colorSpace") && argsObj["colorSpace"].is_string()) {
            colorSpace = argsObj["colorSpace"].get<std::string>();
          }
        }
      } catch (const json::parse_error& e) {
        debugLog("_onColorInputClicked: JSON parse error: " + std::string(e.what()));
      }
    }

    // Store the reply object for async response (add ref to keep it alive)
    if (pending_color_reply_ != nullptr) {
      webkit_script_message_reply_unref(pending_color_reply_);
    }
    pending_color_reply_ = reply;
    webkit_script_message_reply_ref(reply);

    // Get screen position of the cursor
    gint screenX = 0, screenY = 0;
    GdkDisplay* gdk_display = gdk_display_get_default();
    if (gdk_display != nullptr) {
      GdkSeat* seat = gdk_display_get_default_seat(gdk_display);
      if (seat != nullptr) {
        GdkDevice* pointer = gdk_seat_get_pointer(seat);
        if (pointer != nullptr) {
          gdk_device_get_position(pointer, nullptr, &screenX, &screenY);
        }
      }
    }

    // Show the color picker
    ShowColorPicker(currentColor, screenX, screenY, predefinedColors, alphaEnabled, colorSpace);
    
    // Return true to indicate async handling (dialog will respond later)
    return true;
  }

  if (handlerName == "_onDateInputClicked") {
    // Handle date input click - args: { inputType, currentValue, minValue, maxValue, step, elemRect }
    std::string inputType = "date";
    std::string currentValue = "";
    std::string minValue = "";
    std::string maxValue = "";
    std::string stepValue = "";

    if (!argsJsonStr.empty()) {
      try {
        json argsJson = json::parse(argsJsonStr);
        // Args is an array with a single object: [{ inputType, currentValue, ... }]
        json argsObj;
        if (argsJson.is_array() && !argsJson.empty() && argsJson[0].is_object()) {
          argsObj = argsJson[0];
        } else if (argsJson.is_object()) {
          argsObj = argsJson;
        }
        
        if (!argsObj.is_null()) {
          if (argsObj.contains("inputType") && argsObj["inputType"].is_string()) {
            inputType = argsObj["inputType"].get<std::string>();
          }
          if (argsObj.contains("currentValue") && argsObj["currentValue"].is_string()) {
            currentValue = argsObj["currentValue"].get<std::string>();
          }
          if (argsObj.contains("minValue") && argsObj["minValue"].is_string()) {
            minValue = argsObj["minValue"].get<std::string>();
          }
          if (argsObj.contains("maxValue") && argsObj["maxValue"].is_string()) {
            maxValue = argsObj["maxValue"].get<std::string>();
          }
          if (argsObj.contains("step") && argsObj["step"].is_string()) {
            stepValue = argsObj["step"].get<std::string>();
          }
          // elemRect is for positioning, we use screen cursor position instead
        }
      } catch (const json::parse_error& e) {
        debugLog("_onDateInputClicked: JSON parse error: " + std::string(e.what()));
      }
    }

    // Store the reply object for async response (add ref to keep it alive)
    if (pending_date_reply_ != nullptr) {
      webkit_script_message_reply_unref(pending_date_reply_);
    }
    pending_date_reply_ = reply;
    webkit_script_message_reply_ref(reply);

    // Get screen position of the cursor
    gint screenX = 0, screenY = 0;
    GdkDisplay* gdk_display = gdk_display_get_default();
    if (gdk_display != nullptr) {
      GdkSeat* seat = gdk_display_get_default_seat(gdk_display);
      if (seat != nullptr) {
        GdkDevice* pointer = gdk_seat_get_pointer(seat);
        if (pointer != nullptr) {
          gdk_device_get_position(pointer, nullptr, &screenX, &screenY);
        }
      }
    }

    // Show the date picker
    ShowDatePicker(inputType, currentValue, minValue, maxValue, stepValue, screenX, screenY);
    
    // Return true to indicate async handling (dialog will respond later)
    return true;
  }

  // === Internal Handler: _onPrintRequest ===
  if (handlerName == "_onPrintRequest") {
    // Print request from JavaScript (window.print() interception)
    // Send to Dart for handling
    if (targetWebView->channel_delegate_) {
      std::string printUrl = requestUrl;
      
      // Parse args for potential title
      std::string printTitle;
      if (!argsJsonStr.empty()) {
        try {
          auto argsArray = json::parse(argsJsonStr);
          if (argsArray.is_array() && !argsArray.empty()) {
            auto argsObj = argsArray[0];
            if (argsObj.is_object() && argsObj.contains("title") && argsObj["title"].is_string()) {
              printTitle = argsObj["title"].get<std::string>();
            }
          }
        } catch (const json::parse_error& e) {
          debugLog("_onPrintRequest: JSON parse error: " + std::string(e.what()));
        }
      }
      
      targetWebView->channel_delegate_->onPrintRequest(printUrl);
    }
    
    // Return false to JS - we handled it natively
    ResolveInternalHandlerWithReply(reply, "false");
    return true;
  }

  // === External Handler - Send to Dart ===
  if (targetWebView->channel_delegate_) {
    auto data = std::make_unique<JavaScriptHandlerFunctionData>(
        sourceOrigin, requestUrl, isMainFrame, argsJsonStr);

    auto callback = std::make_unique<WebViewChannelDelegate::CallJsHandlerCallback>();

    // Hold a reference to reply for async callback
    webkit_script_message_reply_ref(reply);
    InAppWebView* capturedTargetWebView = targetWebView;

    callback->defaultBehaviour = [capturedTargetWebView, reply](
        const std::optional<FlValue*>& response) {
      std::string jsonResult = "null";
      if (response.has_value() && response.value() != nullptr) {
        FlValue* val = response.value();
        if (fl_value_get_type(val) == FL_VALUE_TYPE_STRING) {
          jsonResult = fl_value_get_string(val);
        }
      }
      capturedTargetWebView->ResolveInternalHandlerWithReply(reply, jsonResult);
    };

    callback->error = [capturedTargetWebView, reply](
        const std::string& code, const std::string& message) {
      std::string errorMessage = code;
      if (!message.empty()) {
        errorMessage += ", " + message;
      }
      capturedTargetWebView->RejectInternalHandlerWithReply(reply, errorMessage);
    };

    targetWebView->channel_delegate_->onCallJsHandler(handlerName, std::move(data), std::move(callback));
    return true;  // We will reply asynchronously
  }

  return false;
}

void InAppWebView::dispatchPlatformReady() {
  std::string script = "window.dispatchEvent(new Event('flutterInAppWebViewPlatformReady'));";
  evaluateJavascript(script, std::nullopt, nullptr);
}

void InAppWebView::initializeWindowIdJS() {
  // Initialize Window ID for JS
  // Injects JavaScript to set the window ID variable for multi-window support
  if (!window_id_.has_value()) {
    return;
  }

  int64_t windowId = window_id_.value();

  // Build the JavaScript to initialize the window ID
  std::string script = R"JS(
(function() {
    )JS" + JavaScriptBridgeJS::WINDOW_ID_VARIABLE_JS_SOURCE() +
                       R"JS( = )JS" + std::to_string(windowId) + R"JS(;
    return )JS" + JavaScriptBridgeJS::WINDOW_ID_VARIABLE_JS_SOURCE() +
                       R"JS(;
})()
)JS";

  evaluateJavascript(script, std::nullopt, nullptr);
}

#ifdef HAVE_WPE_BACKEND_LEGACY
void InAppWebView::OnExportShmBuffer(struct wpe_fdo_shm_exported_buffer* buffer) {
  if (buffer == nullptr) {
    return;
  }

  // Get the wl_shm_buffer from the exported buffer
  struct wl_shm_buffer* shm_buffer = wpe_fdo_shm_exported_buffer_get_shm_buffer(buffer);
  if (shm_buffer == nullptr) {
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
  (void)wl_shm_buffer_get_format(shm_buffer);  // format not used

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
    // Using SIMD-optimized conversion for better performance on ARM (NEON) and x86 (SSE2/SSSE3)
    uint8_t* src = static_cast<uint8_t*>(data);
    uint8_t* dst = pixel_buffer.data.data();

    ConvertARGB32ToRGBA(src, dst, width, height, stride);

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
#endif  // HAVE_WPE_BACKEND_LEGACY

// === Custom Scheme Handler ===

void InAppWebView::RegisterCustomSchemes() {
  if (webview_ == nullptr || settings_ == nullptr) {
    return;
  }

  const auto& schemes = settings_->resourceCustomSchemes;
  if (schemes.empty()) {
    return;
  }

  WebKitWebContext* context = webkit_web_view_get_context(webview_);
  if (context == nullptr) {
    errorLog("InAppWebView: Could not get WebKitWebContext for custom scheme registration");
    return;
  }

  // Built-in schemes that cannot be overridden per WebKit API
  // WPE WebKit explicitly prohibits registering these - the warning says:
  // "Registering special URI scheme https is no longer allowed"
  static const std::set<std::string> builtInSchemes = {
    "http", "https", "file", "data", "about", "blob"
  };

  for (const auto& scheme : schemes) {
    if (scheme.empty()) {
      continue;
    }

    // Don't allow overriding built-in schemes - WebKit will reject them
    if (builtInSchemes.find(scheme) != builtInSchemes.end()) {
      continue;
    }

    // Register the custom URI scheme with the web context
    webkit_web_context_register_uri_scheme(
        context, scheme.c_str(), InAppWebView::OnCustomSchemeRequest, this, nullptr);
  }
}

void InAppWebView::OnCustomSchemeRequest(WebKitURISchemeRequest* request, gpointer user_data) {
  auto* self = static_cast<InAppWebView*>(user_data);
  if (self == nullptr || self->webview_ == nullptr || self->channel_delegate_ == nullptr) {
    // Finish with error if we can't handle it
    g_autoptr(GError) error =
        g_error_new(G_IO_ERROR, G_IO_ERROR_FAILED, "WebView not available");
    webkit_uri_scheme_request_finish_error(request, error);
    return;
  }

  // Get request details
  const gchar* uri = webkit_uri_scheme_request_get_uri(request);
  const gchar* http_method = webkit_uri_scheme_request_get_http_method(request);

  // Build WebResourceRequest
  std::optional<std::string> url_str =
      uri != nullptr ? std::optional<std::string>(uri) : std::nullopt;
  std::optional<std::string> method_str =
      http_method != nullptr ? std::optional<std::string>(http_method) : std::nullopt;

  // Get HTTP headers if available
  std::optional<std::map<std::string, std::string>> headers_map = std::nullopt;
  SoupMessageHeaders* headers = webkit_uri_scheme_request_get_http_headers(request);
  if (headers != nullptr) {
    std::map<std::string, std::string> hdrs;
    SoupMessageHeadersIter iter;
    const char* name;
    const char* value;
    soup_message_headers_iter_init(&iter, headers);
    while (soup_message_headers_iter_next(&iter, &name, &value)) {
      if (name != nullptr && value != nullptr) {
        hdrs[name] = value;
      }
    }
    if (!hdrs.empty()) {
      headers_map = hdrs;
    }
  }

  auto webResourceRequest =
      std::make_shared<WebResourceRequest>(url_str, method_str, headers_map, true);

  // Hold a reference to the request while we wait for the Dart callback
  g_object_ref(request);

  // Create callback to handle response from Dart
  auto callback = std::make_unique<WebViewChannelDelegate::LoadResourceWithCustomSchemeCallback>();

  // Set up the nonNullSuccess handler to process the response
  callback->nonNullSuccess = [request](const std::shared_ptr<CustomSchemeResponse>& response) -> bool {
    if (response == nullptr || response->data.empty()) {
      // No response provided - finish with error
      g_autoptr(GError) error =
          g_error_new(G_IO_ERROR, G_IO_ERROR_NOT_FOUND, "Resource not found");
      webkit_uri_scheme_request_finish_error(request, error);
    } else {
      // Create input stream from response data
      GInputStream* stream =
          g_memory_input_stream_new_from_data(g_memdup2(response->data.data(), response->data.size()),
                                              response->data.size(), g_free);

      // Finish the request with the response data
      webkit_uri_scheme_request_finish(request, stream, response->data.size(),
                                       response->contentType.c_str());

      g_object_unref(stream);
    }
    g_object_unref(request);
    return false;  // Don't run defaultBehaviour
  };

  // Set up the nullSuccess handler for when Dart returns null
  callback->nullSuccess = [request]() -> bool {
    g_autoptr(GError) error =
        g_error_new(G_IO_ERROR, G_IO_ERROR_NOT_FOUND, "Resource not found");
    webkit_uri_scheme_request_finish_error(request, error);
    g_object_unref(request);
    return false;  // Don't run defaultBehaviour
  };

  // Set up the error handler
  callback->error = [request](const std::string& code, const std::string& message) {
    g_autoptr(GError) error =
        g_error_new(G_IO_ERROR, G_IO_ERROR_FAILED, "%s: %s", code.c_str(), message.c_str());
    webkit_uri_scheme_request_finish_error(request, error);
    g_object_unref(request);
  };

  // Invoke the Dart callback
  self->channel_delegate_->onLoadResourceWithCustomScheme(webResourceRequest, std::move(callback));
}

}  // namespace flutter_inappwebview_plugin

#ifdef HAVE_WPE_BACKEND_LEGACY
// C-style callback implementation for WPE FDO EGL export
// Must be outside the namespace for C API compatibility
extern "C" {
static void wpe_export_fdo_egl_image_callback(void* data,
                                              struct wpe_fdo_egl_exported_image* image) {
  auto* self = static_cast<flutter_inappwebview_plugin::InAppWebView*>(data);
  self->OnExportDmaBuf(image);
}

static void wpe_export_shm_buffer_callback(void* data, struct wpe_fdo_shm_exported_buffer* buffer) {
  auto* self = static_cast<flutter_inappwebview_plugin::InAppWebView*>(data);
  self->OnExportShmBuffer(buffer);
}
}
#endif
