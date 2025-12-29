#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_WPE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_WPE_H_

// WPE WebKit-based InAppWebView implementation
// 
// This is an alternative implementation using WPE WebKit instead of WebKitGTK.
// WPE WebKit is designed for embedded systems and offers better offscreen rendering
// capabilities through its backend system.
//
// Key differences from WebKitGTK:
// - No GTK widget hierarchy required
// - Uses WPEBackend-fdo for DMA-BUF based buffer sharing
// - Better suited for headless/offscreen rendering scenarios
// - Direct OpenGL texture export (when using fdo backend)
//
// To use this implementation:
// 1. Install libwpe, wpewebkit, and wpebackend-fdo
// 2. Set USE_WPE_WEBKIT=ON in CMake configuration
// 3. Set FLUTTER_INAPPWEBVIEW_LINUX_USE_WPE=1 at runtime (optional)
//
// Required packages (Ubuntu/Debian):
//   - libwpe-1.0-dev (or build from source)
//   - wpewebkit (build from source or use Flatpak)
//   - wpebackend-fdo-1.0-dev
//
// Build from source:
//   https://wpewebkit.org/about/get-wpe.html

#include <flutter_linux/flutter_linux.h>

// WPE WebKit includes - use wpe/webkit.h instead of webkit2/webkit2.h
#include <wpe/webkit.h>
#include <wpe/fdo.h>
#include <wpe/fdo-egl.h>

#include <array>
#include <atomic>
#include <cstdint>
#include <functional>
#include <map>
#include <memory>
#include <mutex>
#include <optional>
#include <string>
#include <vector>

#include "../types/url_request.h"
#include "../types/user_script.h"
#include "in_app_webview_settings_wpe.h"

// Forward declaration of WPE types in global scope to avoid namespace conflicts
struct wpe_fdo_egl_exported_image;

namespace flutter_inappwebview_plugin {

class UserContentControllerWpe;
class WebViewChannelDelegateWpe;

struct InAppWebViewWpeCreationParams {
  int64_t id;
  std::optional<std::shared_ptr<URLRequest>> initialUrlRequest;
  std::optional<std::string> initialFile;
  std::optional<std::string> initialData;
  std::optional<std::string> initialDataBaseUrl;
  std::optional<std::string> initialDataMimeType;
  std::optional<std::string> initialDataEncoding;
  std::shared_ptr<InAppWebViewSettingsWpe> initialSettings;
};

// Pointer event kind (matches Dart side)
enum class WpePointerEventKind {
  Activate = 0,
  Down = 1,
  Enter = 2,
  Leave = 3,
  Up = 4,
  Update = 5,
  Cancel = 6
};

// Pointer button type (matches Dart side)
enum class WpePointerButton { None = 0, Primary = 1, Secondary = 2, Tertiary = 3 };

/// InAppWebViewWpe - WPE WebKit based implementation
///
/// This class provides offscreen web rendering using WPE WebKit.
/// Unlike WebKitGTK, WPE doesn't require a GTK widget hierarchy
/// and can render directly to GPU textures via the FDO backend.
class InAppWebViewWpe {
 public:
  static constexpr const char* METHOD_CHANNEL_NAME_PREFIX =
      "com.pichillilorenzo/flutter_inappwebview_";

  InAppWebViewWpe(FlBinaryMessenger* messenger, int64_t id,
                  const InAppWebViewWpeCreationParams& params);
  ~InAppWebViewWpe();

  int64_t id() const { return id_; }
  WebKitWebView* webview() const { return webview_; }
  WebViewChannelDelegateWpe* channel_delegate() const {
    return channel_delegate_.get();
  }

  // Attach/recreate the Dart method channel using the given [channel_id].
  void AttachChannel(FlBinaryMessenger* messenger, int64_t channel_id);

  int64_t channel_id() const { return channel_id_; }

  // Navigation methods
  void loadUrl(const std::string& url);
  void loadUrl(const std::shared_ptr<URLRequest>& urlRequest);
  void loadData(const std::string& data, const std::string& mime_type,
                const std::string& encoding, const std::string& base_url);
  void loadFile(const std::string& asset_file_path);
  void reload();
  void goBack();
  void goForward();
  bool canGoBack() const;
  bool canGoForward() const;
  void stopLoading();
  bool isLoading() const;

  // Getters
  std::optional<std::string> getUrl() const;
  std::optional<std::string> getTitle() const;
  int64_t getProgress() const;

  // JavaScript execution
  void evaluateJavascript(
      const std::string& source,
      std::function<void(const std::optional<std::string>&)> callback);
  void injectJavascriptFileFromUrl(const std::string& urlFile);
  void injectCSSCode(const std::string& source);
  void injectCSSFileFromUrl(const std::string& urlFile);

  // User scripts
  void addUserScript(std::shared_ptr<UserScript> userScript);
  void removeUserScriptAt(size_t index, UserScriptInjectionTime injectionTime);
  void removeUserScriptsByGroupName(const std::string& groupName);
  void removeAllUserScripts();

  // HTML content
  void getHtml(std::function<void(const std::optional<std::string>&)> callback);

  // Zoom
  double getZoomScale() const;
  void setZoomScale(double zoomScale);

  // Scroll
  void scrollTo(int64_t x, int64_t y, bool animated);
  void scrollBy(int64_t x, int64_t y, bool animated);
  int64_t getScrollX() const;
  int64_t getScrollY() const;

  // Settings
  std::shared_ptr<InAppWebViewSettingsWpe> settings() const { return settings_; }
  FlValue* getSettings() const;
  void setSettings(const std::shared_ptr<InAppWebViewSettingsWpe> newSettings,
                   FlValue* newSettingsMap = nullptr);

  // User content controller
  UserContentControllerWpe* userContentController() const {
    return user_content_controller_.get();
  }

  // Size management
  void setSize(int width, int height);
  void setScaleFactor(double scale_factor);

  // Input handling
  void SetCursorPos(double x, double y);
  void SetPointerButton(int kind, int button, int clickCount = 1);
  void SetScrollDelta(double dx, double dy);
  void SendKeyEvent(int type, int64_t keyCode, int scanCode, int modifiers, 
                    const std::string& characters);

  // Texture pixel buffer access (called by texture classes)
  size_t GetPixelBufferSize(uint32_t* out_width, uint32_t* out_height) const;
  bool CopyPixelBufferTo(uint8_t* dst, size_t dst_size, uint32_t* out_width,
                         uint32_t* out_height) const;

  // DMA-BUF export (WPE-specific, for zero-copy GPU texture sharing)
  bool HasDmaBufExport() const;
  bool GetDmaBufFd(int* fd, uint32_t* stride, uint32_t* width, uint32_t* height) const;

  // Frame available callback (called when new frame is ready)
  void SetOnFrameAvailable(std::function<void()> callback);

  // Cursor change callback
  void SetOnCursorChanged(std::function<void(const std::string&)> callback);

  // Called from Dart when shouldOverrideUrlLoading decision is made
  void OnShouldOverrideUrlLoadingDecision(int64_t decision_id, bool allow);

  // Check if WPE WebKit is available on the system
  static bool IsWpeWebKitAvailable();

  // === Multi-Window Support (matches iOS) ===
  
  // Set the window ID for this webview (used in window.open scenarios)
  void setWindowId(int64_t windowId) { window_id_ = windowId; }
  
  // Get the window ID (null if not set)
  std::optional<int64_t> getWindowId() const { return window_id_; }
  
  // Initialize the window ID JavaScript variable in the webview
  // This injects JS to set window._flutter_inappwebview_windowId
  void initializeWindowIdJS();

 private:
  int64_t id_ = 0;
  int64_t channel_id_ = -1;

  // Settings
  std::shared_ptr<InAppWebViewSettingsWpe> settings_;

  // WPE WebKit view
  WebKitWebView* webview_ = nullptr;
  
  // WPE Backend (using FDO for DMA-BUF export)
  WebKitWebViewBackend* backend_ = nullptr;
  struct wpe_view_backend* wpe_backend_ = nullptr;
  
  // WPE FDO exportable (for DMA-BUF buffer export)
  struct wpe_view_backend_exportable_fdo* exportable_ = nullptr;
  ::wpe_fdo_egl_exported_image* exported_image_ = nullptr;

  // EGL context for reading back pixels
  void* egl_display_ = nullptr;  // EGLDisplay
  void* egl_context_ = nullptr;  // EGLContext for readback
  unsigned int fbo_ = 0;         // Framebuffer object for EGL image binding
  unsigned int readback_texture_ = 0;  // Texture for EGL image

  // Triple buffering for pixel data (fallback when DMA-BUF not available)
  static constexpr size_t kNumBuffers = 3;
  struct PixelBuffer {
    std::vector<uint8_t> data;
    size_t width = 0;
    size_t height = 0;
  };
  std::array<PixelBuffer, kNumBuffers> pixel_buffers_;
  std::atomic<size_t> write_buffer_index_{0};
  std::atomic<size_t> read_buffer_index_{1};
  mutable std::mutex buffer_swap_mutex_;

  // View dimensions
  int width_ = 800;
  int height_ = 600;
  double scale_factor_ = 1.0;

  // Channel delegate
  std::unique_ptr<WebViewChannelDelegateWpe> channel_delegate_;

  // User content controller
  std::unique_ptr<UserContentControllerWpe> user_content_controller_;

  // JavaScript bridge secret for security
  std::string js_bridge_secret_;
  
  // Window ID for multi-window support (matches iOS windowId)
  std::optional<int64_t> window_id_;
  
  // Flag to track if javaScriptBridgeEnabled
  bool java_script_bridge_enabled_ = true;

  // Pending policy decisions
  std::map<int64_t, WebKitPolicyDecision*> pending_policy_decisions_;
  int64_t next_decision_id_ = 0;

  // Pending script dialogs
  std::map<int64_t, WebKitScriptDialog*> pending_script_dialogs_;
  int64_t next_dialog_id_ = 0;

  // Pending permission requests
  std::map<int64_t, WebKitPermissionRequest*> pending_permission_requests_;
  int64_t next_permission_id_ = 0;

  // Pending authentication requests
  std::map<int64_t, WebKitAuthenticationRequest*> pending_auth_requests_;
  int64_t next_auth_id_ = 0;

  // Frame available callback
  std::function<void()> on_frame_available_;

  // Cursor change callback
  std::function<void(const std::string&)> on_cursor_changed_;
  std::string last_cursor_name_;

  // Mouse state
  double cursor_x_ = 0;
  double cursor_y_ = 0;
  uint32_t button_state_ = 0;
  uint32_t current_modifiers_ = 0;  // Current keyboard modifiers (shift, ctrl, alt, meta)

  // Scroll multiplier
  double scroll_multiplier_ = 1.0;

  // Progress tracking
  double last_progress_ = 0.0;

  // === Initialization ===
  void InitWpeBackend();
  void InitWebView(const InAppWebViewWpeCreationParams& params);
  void RegisterEventHandlers();

 public:  
  // === WPE backend callbacks ===
  // Instance method called from C callback (must be public)
  void OnExportDmaBuf(::wpe_fdo_egl_exported_image* image);
  void OnExportShmBuffer(struct wpe_fdo_shm_exported_buffer* buffer);

 private:
  static void OnFrameDisplayed(void* data);
  
  // Read pixels from EGL image to CPU buffer
  void ReadPixelsFromEglImage(void* egl_image, uint32_t width, uint32_t height);

  // === WebKit signals (same as WebKitGTK) ===
  static void OnLoadChanged(WebKitWebView* web_view,
                            WebKitLoadEvent load_event, gpointer user_data);

  static gboolean OnDecidePolicy(WebKitWebView* web_view,
                                 WebKitPolicyDecision* decision,
                                 WebKitPolicyDecisionType decision_type,
                                 gpointer user_data);

  static void OnNotifyEstimatedLoadProgress(GObject* object,
                                             GParamSpec* pspec,
                                             gpointer user_data);

  static void OnNotifyTitle(GObject* object,
                            GParamSpec* pspec,
                            gpointer user_data);

  static gboolean OnLoadFailed(WebKitWebView* web_view,
                               WebKitLoadEvent load_event,
                               gchar* failing_uri,
                               GError* error,
                               gpointer user_data);

  static gboolean OnLoadFailedWithTlsErrors(WebKitWebView* web_view,
                                             gchar* failing_uri,
                                             GTlsCertificate* certificate,
                                             GTlsCertificateFlags errors,
                                             gpointer user_data);

  static void OnCloseRequest(WebKitWebView* web_view, gpointer user_data);

  static WebKitWebView* OnCreateWebView(WebKitWebView* web_view,
                                    WebKitNavigationAction* navigation_action,
                                    gpointer user_data);

  static gboolean OnScriptDialog(WebKitWebView* web_view,
                                 WebKitScriptDialog* dialog,
                                 gpointer user_data);

  static gboolean OnPermissionRequest(WebKitWebView* web_view,
                                      WebKitPermissionRequest* request,
                                      gpointer user_data);

  static gboolean OnAuthenticate(WebKitWebView* web_view,
                                 WebKitAuthenticationRequest* request,
                                 gpointer user_data);

  static gboolean OnContextMenu(WebKitWebView* web_view,
                                WebKitContextMenu* context_menu,
                                WebKitHitTestResult* hit_test_result,
                                gpointer user_data);

  static gboolean OnEnterFullscreen(WebKitWebView* web_view, gpointer user_data);

  static gboolean OnLeaveFullscreen(WebKitWebView* web_view, gpointer user_data);

  static void OnMouseTargetChanged(WebKitWebView* web_view,
                                   WebKitHitTestResult* hit_test_result,
                                   guint modifiers,
                                   gpointer user_data);

  // === Input helpers ===
  void SendWpePointerEvent(uint32_t type, double x, double y, uint32_t button);
  void SendWpeAxisEvent(double x, double y, double dx, double dy);
  void SendWpeKeyboardEvent(uint32_t key, uint32_t state, uint32_t modifiers);

  // === JavaScript bridge ===
  void handleScriptMessage(const std::string& name, const std::string& body);
  void dispatchPlatformReady();
  
  // === Cursor detection ===
  void injectCursorDetectionScript();
  void updateCursorFromCssStyle(const std::string& cursor_style);
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_WPE_H_
