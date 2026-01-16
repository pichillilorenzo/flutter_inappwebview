#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_H_

// WPE WebKit-based InAppWebView implementation
//
// Uses WPE WebKit for offscreen web rendering.
// Supports two APIs:
// - WPEPlatform (HAVE_WPE_PLATFORM): New modern API for WPE WebKit 2.40+
// - WPEBackend-FDO (HAVE_WPE_BACKEND_LEGACY): Legacy API for older systems
//
// WPE WebKit is designed for embedded systems and offers excellent offscreen rendering
// capabilities through its backend system.
//
// Key features:
// - No GTK widget hierarchy required
// - Uses DMA-BUF based buffer sharing for GPU efficiency
// - Better suited for headless/offscreen rendering scenarios
// - Direct OpenGL texture export (zero-copy when supported)
//
// Required packages (Ubuntu/Debian):
//   - libwpe-1.0-dev (or build from source)
//   - wpewebkit (build from source or use Flatpak)
//   - wpe-platform-headless-2.0 (recommended) OR wpebackend-fdo-1.0-dev (legacy)
//
// Build from source:
//   See WPE_BACKEND.md or https://wpewebkit.org/about/get-wpe.html

#include <flutter_linux/flutter_linux.h>

// WPE WebKit core includes (always available)
#include <wpe/webkit.h>
#include <jsc/jsc.h>

// WPEPlatform API (new modern API - default)
#ifdef HAVE_WPE_PLATFORM
#include <wpe/wpe-platform.h>
#include <wpe/headless/wpe-headless.h>
#endif

// WPEBackend-FDO API (legacy fallback)
#ifdef HAVE_WPE_BACKEND_LEGACY
#include <wpe/fdo-egl.h>
#include <wpe/fdo.h>
#endif

#include <array>
#include <atomic>
#include <cstdint>
#include <functional>
#include <map>
#include <memory>
#include <mutex>
#include <optional>
#include <string>
#include <tuple>
#include <vector>

#include "../content_blocker/content_blocker_handler.h"
#include "../types/context_menu.h"
#include "../types/context_menu_popup.h"
#include "../types/option_menu_popup.h"
#include "../types/find_session.h"
#include "../types/hit_test_result.h"
#include "../types/ssl_certificate.h"
#include "../types/url_request.h"
#include "../types/user_script.h"
#include "../find_interaction/find_interaction_controller.h"
#include "in_app_webview_settings.h"

// Forward declaration of WPE types in global scope to avoid namespace conflicts
#ifdef HAVE_WPE_BACKEND_LEGACY
struct wpe_fdo_egl_exported_image;
#endif

namespace flutter_inappwebview_plugin {

class InAppBrowser;
class InAppWebViewManager;
class PluginInstance;
class UserContentController;
class WebMessageChannel;
class WebMessageListener;
class WebViewChannelDelegate;

struct InAppWebViewCreationParams {
  int64_t id;
  PluginInstance* plugin = nullptr;  // Plugin instance for accessing managers
  GtkWindow* gtkWindow = nullptr;  // Cached GTK window from manager
  FlView* flView = nullptr;  // Cached FlView for focus restoration
  InAppWebViewManager* manager = nullptr;  // Manager reference for multi-window support
  std::optional<std::shared_ptr<URLRequest>> initialUrlRequest;
  std::optional<std::string> initialFile;
  std::optional<std::string> initialData;
  std::optional<std::string> initialDataBaseUrl;
  std::optional<std::string> initialDataMimeType;
  std::optional<std::string> initialDataEncoding;
  std::shared_ptr<InAppWebViewSettings> initialSettings;
  std::optional<std::shared_ptr<ContextMenu>> contextMenu;
  std::optional<int64_t> windowId;  // For windows created via onCreateWindow
  WebKitWebView* relatedWebView = nullptr;  // For creating related WebViews (shares web process)
  std::vector<std::shared_ptr<UserScript>> initialUserScripts;  // User scripts to inject
  WebKitWebContext* webContext = nullptr;  // Custom WebKitWebContext from WebViewEnvironment
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

/// InAppWebView - WPE WebKit based implementation
///
/// This class provides offscreen web rendering using WPE WebKit.
/// Unlike WebKitGTK, WPE doesn't require a GTK widget hierarchy
/// and can render directly to GPU textures via the FDO backend.
class InAppWebView {
 public:
  static constexpr const char* METHOD_CHANNEL_NAME_PREFIX =
      "com.pichillilorenzo/flutter_inappwebview_";

  InAppWebView(FlPluginRegistrar* registrar, FlBinaryMessenger* messenger, int64_t id,
               const InAppWebViewCreationParams& params);
  ~InAppWebView();

  int64_t id() const { return id_; }
  WebKitWebView* webview() const { return webview_; }
  WebViewChannelDelegate* channel_delegate() const { return channel_delegate_.get(); }
  FlPluginRegistrar* registrar() const { return registrar_; }

  // Attach/recreate the Dart method channel using the given [channel_id].
  void AttachChannel(FlBinaryMessenger* messenger, int64_t channel_id);
  
  // Attach/recreate the Dart method channel using a string-based channel ID.
  // This is used for HeadlessInAppWebView where the ID is a long string from Dart.
  void AttachChannel(FlBinaryMessenger* messenger, const std::string& channel_id, const bool is_full_channel_name);

  int64_t channel_id() const { return channel_id_; }
  const std::string& string_channel_id() const { return string_channel_id_; }

  // Navigation methods
  void loadUrl(const std::string& url);
  void loadUrl(const std::shared_ptr<URLRequest>& urlRequest);
  void loadData(const std::string& data, const std::string& mime_type, const std::string& encoding,
                const std::string& base_url);
  void loadFile(const std::string& asset_file_path);
  void postUrl(const std::string& url, const std::vector<uint8_t>& postData);
  void reload();
  void reloadFromOrigin();
  void goBack();
  void goForward();
  void goBackOrForward(int steps);
  bool canGoBack() const;
  bool canGoForward() const;
  bool canGoBackOrForward(int steps) const;
  void stopLoading();
  bool isLoading() const;

  // Navigation history
  FlValue* getCopyBackForwardList() const;

  // Getters
  std::optional<std::string> getUrl() const;
  std::optional<std::string> getTitle() const;
  int64_t getProgress() const;

  // TLS/SSL certificate
  // Returns the SSL certificate info for the current page (or nullopt if not HTTPS)
  std::optional<SslCertificate> getCertificate() const;

  // Hit test result
  // Returns the last hit test result from mouse-target-changed signal
  HitTestResult getHitTestResult() const;

  // JavaScript execution
  void evaluateJavascript(const std::string& source,
                          const std::optional<std::string>& worldName,
                          std::function<void(const std::optional<std::string>&)> callback);
  void callAsyncJavaScript(
      const std::string& functionBody,
      const std::string& argumentsJson,
      const std::vector<std::string>& argumentKeys,
      const std::optional<std::string>& worldName,
      std::function<void(const std::string&)> callback);
  void injectJavascriptFileFromUrl(const std::string& urlFile);
  void injectCSSCode(const std::string& source);
  void injectCSSFileFromUrl(const std::string& urlFile);

  // User scripts
  void addUserScript(std::shared_ptr<UserScript> userScript);
  void removeUserScriptAt(size_t index, UserScriptInjectionTime injectionTime);
  void removeUserScriptsByGroupName(const std::string& groupName);
  void removeAllUserScripts();

  // Web Message Listener
  void addWebMessageListener(const std::string& jsObjectName,
                              const std::vector<std::string>& allowedOriginRules);

  // Web Message Channel
  void createWebMessageChannel(std::function<void(const std::optional<std::string>&)> callback);
  void postWebMessage(const std::string& messageData, const std::string& targetOrigin, int64_t messageType);
  void setWebMessageCallback(const std::string& channelId, int portIndex);
  void postWebMessageOnPort(const std::string& channelId, int portIndex,
                            const std::string& messageData, int64_t messageType);
  void closeWebMessagePort(const std::string& channelId, int portIndex);
  void disposeWebMessageChannel(const std::string& channelId);
  WebMessageChannel* getWebMessageChannel(const std::string& channelId) const;

  // HTML content
  void getHtml(std::function<void(const std::optional<std::string>&)> callback);

  // Screenshot - captures the current visible content as PNG data
  void takeScreenshot(std::function<void(const std::optional<std::vector<uint8_t>>&)> callback);

  // Session state - save and restore navigation state
  std::optional<std::vector<uint8_t>> saveState() const;
  bool restoreState(const std::vector<uint8_t>& stateData);

  // Zoom
  double getZoomScale() const;
  void setZoomScale(double zoomScale);

  // Scroll
  void scrollTo(int64_t x, int64_t y, bool animated);
  void scrollBy(int64_t x, int64_t y, bool animated);
  void getScrollX(std::function<void(int64_t)> callback);
  void getScrollY(std::function<void(int64_t)> callback);
  void canScrollVertically(std::function<void(bool)> callback);
  void canScrollHorizontally(std::function<void(bool)> callback);

  // Content dimensions (async - via JavaScript)
  void getContentHeight(std::function<void(int64_t)> callback);
  void getContentWidth(std::function<void(int64_t)> callback);

  // Find interaction controller (now managed separately)
  FindInteractionController* findInteractionController() const { return findInteractionController_.get(); }

  // Settings
  std::shared_ptr<InAppWebViewSettings> settings() const { return settings_; }
  FlValue* getSettings() const;
  void setSettings(const std::shared_ptr<InAppWebViewSettings> newSettings,
                   FlValue* newSettingsMap = nullptr);

  // User content controller
  UserContentController* userContentController() const { return user_content_controller_.get(); }

  // Size management
  void setSize(int width, int height);
  void setScaleFactor(double scale_factor);

  // Focus/Activity state management (from WPE view-backend API)
  void setFocused(bool focused);
  void setVisible(bool visible);
  uint32_t getActivityState() const;

  // Refresh rate management (from WPE view-backend API)
  void setTargetRefreshRate(uint32_t rate);
  uint32_t getTargetRefreshRate() const;

  // Screen scale management (from WPE Platform API)
  double getScreenScale() const;
  void setScreenScale(double scale);

  // Visibility management (from WPE Platform API)
  bool isVisible() const;

  // Fullscreen control (from WPE view-backend API)
  void requestEnterFullscreen();
  void requestExitFullscreen();
  bool isInFullscreen() const { return is_fullscreen_; }

  // Pointer lock support (from WPE view-backend API) - for games/immersive apps
  void setPointerLockHandler(std::function<bool(bool)> handler);
  bool requestPointerLock();
  bool requestPointerUnlock();

  // Input handling
  void SetTextureOffset(double x, double y);
  void SetCursorPos(double x, double y);
  void SetPointerButton(int kind, int button, int clickCount = 1);
  void SetScrollDelta(double dx, double dy);
  void SendKeyEvent(int type, int64_t keyCode, int scanCode, int modifiers,
                    const std::string& characters);
  void SendTouchEvent(int type, int id, double x, double y,
                      const std::vector<std::tuple<int, double, double, int>>& touchPoints);

  // Texture pixel buffer access (called by texture classes)
  size_t GetPixelBufferSize(uint32_t* out_width, uint32_t* out_height) const;
  bool CopyPixelBufferTo(uint8_t* dst, size_t dst_size, uint32_t* out_width,
                         uint32_t* out_height) const;

  // DMA-BUF export (WPE-specific, for zero-copy GPU texture sharing)
  bool HasDmaBufExport() const;
  bool GetDmaBufFd(int* fd, uint32_t* stride, uint32_t* width, uint32_t* height) const;

  // EGL image access (for zero-copy texture sharing with Flutter)
  // Returns the current EGL image handle (EGLImageKHR) and dimensions.
  // The EGL image is owned by WPE and remains valid until the next frame.
  void* GetCurrentEglImage(uint32_t* out_width, uint32_t* out_height) const;

  // Skip pixel readback - when using zero-copy EGL texture mode, we don't need
  // to read pixels back to CPU. This improves performance and avoids GL context issues.
  void SetSkipPixelReadback(bool skip) { skip_pixel_readback_ = skip; }

  // Frame available callback (called when new frame is ready)
  void SetOnFrameAvailable(std::function<void()> callback);

  // Cursor change callback
  void SetOnCursorChanged(std::function<void(const std::string&)> callback);

  // Progress change callback (for InAppBrowser progress bar)
  void SetOnProgressChanged(std::function<void(double)> callback);

  // Navigation state change callback (for InAppBrowser back/forward buttons)
  void SetOnNavigationStateChanged(std::function<void()> callback);

  // InAppBrowser delegate (when this WebView is embedded in an InAppBrowser)
  // Used by WebViewChannelDelegate to forward browser-specific methods
  void setInAppBrowserDelegate(InAppBrowser* browser) { inAppBrowserDelegate_ = browser; }
  InAppBrowser* getInAppBrowserDelegate() const { return inAppBrowserDelegate_; }

  // Called from Dart when shouldOverrideUrlLoading decision is made
  void OnShouldOverrideUrlLoadingDecision(int64_t decision_id, bool allow);

  // Context menu methods
  // Context menu methods
  // Show the native GTK context menu using pending WebKit menu and custom items
  void ShowNativeContextMenu();
  // Hide and cleanup any visible context menu
  void HideContextMenu();

  // Color picker methods (for <input type="color"> support in WPE)
  // Show the native color picker popup with optional predefined colors and alpha support
  void ShowColorPicker(const std::string& initialColor, int x, int y,
                       const std::vector<std::string>& predefinedColors = {},
                       bool alphaEnabled = false,
                       const std::string& colorSpace = "limited-srgb");
  // Hide and cleanup any visible color picker
  void HideColorPicker();
  // Hide and cleanup any visible file chooser dialog
  void HideFileChooser();
  // Hide and cleanup any visible option menu (HTML <select>)
  void HideOptionMenu();

  // Date picker methods (for <input type="date/time"> support in WPE)
  // Show the native date/time picker dialog
  void ShowDatePicker(const std::string& inputType, const std::string& value,
                      const std::string& min, const std::string& max,
                      const std::string& step, int x, int y);
  // Hide and cleanup any visible date picker
  void HideDatePicker();

  // Resolve an internal handler's Promise with a JSON result via WebKitScriptMessageReply
  // Used by color/date picker dialogs to send the result back to JavaScript (works for iframes)
  void ResolveInternalHandlerWithReply(WebKitScriptMessageReply* reply, const std::string& jsonResult);

  // JavaScript bridge handler using with_reply API (enables iframe support)
  // Returns true if handled, false otherwise
  bool handleScriptMessageWithReply(const std::string& body, WebKitScriptMessageReply* reply);
  
  // Reject an internal handler's Promise with an error message via WebKitScriptMessageReply
  void RejectInternalHandlerWithReply(WebKitScriptMessageReply* reply, const std::string& errorMessage);

  // Hide all custom popups (context menu, color picker, file chooser, option menu, etc.)
  // Use this when the webview state changes (resize, scroll, load, focus loss, etc.)
  void HideAllPopups();

  // Clipboard operations (syncs WPE WebKit clipboard with system clipboard)
  void copyToClipboard();
  void cutToClipboard();
  void pasteFromClipboard();
  void pasteAsPlainText();
  void copyTextToClipboard(const std::string& text);  // Copy arbitrary text to both clipboards
  void getSelectedText(std::function<void(const std::optional<std::string>&)> callback);
  void isSecureContext(std::function<void(bool)> callback);

  // Media playback control
  void pauseAllMediaPlayback();
  void setAllMediaPlaybackSuspended(bool suspended);
  void closeAllMediaPresentations();
  void requestMediaPlaybackState(std::function<void(int)> callback);

  // Media capture state (camera and microphone)
  int getCameraCaptureState() const;
  void setCameraCaptureState(int state);
  int getMicrophoneCaptureState() const;
  void setMicrophoneCaptureState(int state);

  // Theme color (from <meta name="theme-color"> tag)
  std::optional<std::string> getMetaThemeColor() const;

  // Audio state (mute and playback)
  bool isPlayingAudio() const;
  bool isMuted() const;
  void setMuted(bool muted);

  // Web process control
  void terminateWebProcess();

  // Focus control
  bool clearFocus();
  bool requestFocus();

  // Web archive (save page to file)
  void saveWebArchive(const std::string& filePath, bool autoname,
                      std::function<void(const std::optional<std::string>&)> callback);

  // Editing commands (WebKit editing commands)
  void selectAll();
  void undo();
  void redo();
  void insertImage(const std::string& imageUri);
  void createLink(const std::string& linkUri);

  // Check if WPE WebKit is available on the system
  static bool IsWpeWebKitAvailable();

#ifdef HAVE_WPE_PLATFORM
  // Check if DMA-BUF rendering should be used
  // Returns true if DMA-BUF rendering is expected to work, false if SHM should be used
  // Note: Environment detection is done at plugin registration via utils/software_rendering.h
  static bool PreflightDmaBufSupport();
#endif

  // === Multi-Window Support ===

  // Set the window ID for this webview (used in window.open scenarios)
  void setWindowId(int64_t windowId) { window_id_ = windowId; }

  // Get the window ID (null if not set)
  std::optional<int64_t> getWindowId() const { return window_id_; }

  // Initialize the window ID JavaScript variable in the webview
  // This injects JS to set window._flutter_inappwebview_windowId
  void initializeWindowIdJS();

  // Get the GTK window (for focus restoration after popup dialogs)
  GtkWindow* getGtkWindow() const { return gtk_window_; }

  // Get the FlView (for focus restoration after popup dialogs)
  FlView* getFlView() const { return fl_view_; }

 private:
  PluginInstance* plugin_ = nullptr;  // Plugin instance for accessing managers
  FlPluginRegistrar* registrar_ = nullptr;
  FlBinaryMessenger* messenger_ = nullptr;  // Cached messenger from constructor
  GtkWindow* gtk_window_ = nullptr;  // Cached GTK window for context menu display
  FlView* fl_view_ = nullptr;  // Cached FlView for focus restoration
  InAppWebViewManager* manager_ = nullptr;  // Manager reference for multi-window support
  int64_t id_ = 0;
  int64_t channel_id_ = -1;
  std::string string_channel_id_;  // String-based channel ID for headless webviews

  // Settings
  std::shared_ptr<InAppWebViewSettings> settings_;

  // Context menu configuration
  std::shared_ptr<ContextMenu> context_menu_config_;

  // WPE WebKit view
  WebKitWebView* webview_ = nullptr;

#ifdef HAVE_WPE_PLATFORM
  // === WPEPlatform API members (modern) ===
  WPEDisplay* wpe_display_ = nullptr;     // Owned headless display
  WPEView* wpe_view_ = nullptr;           // From webkit_web_view_get_wpe_view, not owned
  WPEToplevel* wpe_toplevel_ = nullptr;   // From wpe_view_get_toplevel, not owned
  
  // Buffer rendering for WPEPlatform
  WPEBuffer* current_buffer_ = nullptr;   // Current frame buffer (borrowed, not owned)
  void* current_egl_image_ = nullptr;     // EGL image created from current buffer
  uint32_t current_buffer_width_ = 0;     // Width of current buffer
  uint32_t current_buffer_height_ = 0;    // Height of current buffer
  gulong buffer_rendered_handler_ = 0;    // Signal handler ID for buffer-rendered
  gulong scale_changed_handler_ = 0;      // Signal handler ID for notify::scale-factor
  mutable std::mutex wpe_buffer_mutex_;   // Mutex for thread-safe buffer access
#endif

#ifdef HAVE_WPE_BACKEND_LEGACY
  // === WPEBackend-FDO API members (legacy) ===
  WebKitWebViewBackend* backend_ = nullptr;
  struct wpe_view_backend* wpe_backend_ = nullptr;

  // WPE FDO exportable (for DMA-BUF buffer export)
  struct wpe_view_backend_exportable_fdo* exportable_ = nullptr;
  
  // Current EGL image from WPE (for zero-copy GPU texture sharing).
  ::wpe_fdo_egl_exported_image* exported_image_ = nullptr;
  
  // Mutex for protecting exported_image_ access from multiple threads
  mutable std::mutex exported_image_mutex_;
  
  // Flag to indicate the WebProcess has crashed and EGL resources are invalid
  // This prevents using stale EGL images after a crash
  std::atomic<bool> web_process_crashed_{false};
#endif

  // EGL context for reading back pixels (both APIs)
  void* egl_display_ = nullptr;        // EGLDisplay
  void* egl_context_ = nullptr;        // EGLContext for readback
  unsigned int fbo_ = 0;               // Framebuffer object for EGL image binding
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
  
  // Flag to skip pixel readback when using zero-copy EGL texture mode
  // When true, OnExportDmaBuf won't call ReadPixelsFromEglImage
  bool skip_pixel_readback_ = false;

  // View dimensions
  int width_ = 800;
  int height_ = 600;
  double scale_factor_ = 1.0;

  // Channel delegate
  std::unique_ptr<WebViewChannelDelegate> channel_delegate_;

  // User content controller
  std::unique_ptr<UserContentController> user_content_controller_;

  // Find interaction controller
  std::unique_ptr<FindInteractionController> findInteractionController_;

  // Content blocker handler for Safari-style content blocking rules
  std::unique_ptr<ContentBlockerHandler> content_blocker_handler_;

  // Web message channels (for WebMessageChannel support)
  std::map<std::string, std::unique_ptr<WebMessageChannel>> web_message_channels_;

  // Web message listeners (for WebMessageListener support - federated plugin pattern)
  // Key is jsObjectName, value is the WebMessageListener
  std::map<std::string, std::unique_ptr<WebMessageListener>> web_message_listeners_;

  // Initial user scripts from params
  std::vector<std::shared_ptr<UserScript>> initial_user_scripts_;

  // JavaScript bridge secret for security
  std::string js_bridge_secret_;

  // Window ID for multi-window support
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

  // Pending custom scheme requests (for async handling)
  std::map<WebKitURISchemeRequest*, int64_t> pending_custom_scheme_requests_;

  // Frame available callback
  std::function<void()> on_frame_available_;

  // Cursor change callback
  std::function<void(const std::string&)> on_cursor_changed_;
  std::string last_cursor_name_ = "default";

  // Progress change callback (for InAppBrowser)
  std::function<void(double)> on_progress_changed_;

  // Navigation state change callback (for InAppBrowser back/forward buttons)
  std::function<void()> on_navigation_state_changed_;

  // InAppBrowser delegate (when embedded in an InAppBrowser)
  // This allows WebViewChannelDelegate to forward browser-specific method calls
  InAppBrowser* inAppBrowserDelegate_ = nullptr;

  // Last hit test result from mouse-target-changed signal
  // Used by getHitTestResult() to return the current element under the cursor
  WebKitHitTestResult* last_hit_test_result_ = nullptr;

  // Disposing flag to prevent callbacks during destruction
  std::atomic<bool> is_disposing_{false};

  // Mouse state
  double cursor_x_ = 0;
  double cursor_y_ = 0;
  uint32_t button_state_ = 0;
  uint32_t current_modifiers_ = 0;  // Current keyboard modifiers (shift, ctrl, alt, meta)

  // Scroll multiplier
  double scroll_multiplier_ = 1.0;

  // Progress tracking
  double last_progress_ = 0.0;

  // Media capture state tracking (for onCameraCaptureStateChanged/onMicrophoneCaptureStateChanged)
  int last_camera_capture_state_ = 0;       // WebKitMediaCaptureState: NONE=0, ACTIVE=1, MUTED=2
  int last_microphone_capture_state_ = 0;   // WebKitMediaCaptureState: NONE=0, ACTIVE=1, MUTED=2

  // Fullscreen state (for DOM fullscreen requests)
  bool is_fullscreen_ = false;
  bool waiting_fullscreen_notify_ = false;

  // Activity/focus state
  bool is_focused_ = true;
  bool is_visible_ = true;

  // Target refresh rate (0 = default)
  uint32_t target_refresh_rate_ = 0;

  // Monitor change tracking for refresh rate updates
  gulong monitors_changed_handler_id_ = 0;
  gulong configure_event_handler_id_ = 0;

  // Download signal handler ID
  gulong download_started_handler_id_ = 0;

  // Context menu state
  std::unique_ptr<ContextMenuPopup> context_menu_popup_;
  WebKitContextMenu* pending_context_menu_ = nullptr;
  WebKitHitTestResult* pending_hit_test_result_ = nullptr;
  double context_menu_x_ = 0;  // Mouse position when context menu was requested
  double context_menu_y_ = 0;
  double texture_offset_x_ = 0;  // Texture offset within the Flutter window
  double texture_offset_y_ = 0;

  // Option menu state (for HTML <select> dropdowns)
  std::unique_ptr<OptionMenuPopup> option_menu_popup_;

  // Pointer lock handler
  std::function<bool(bool)> pointer_lock_handler_;
  bool pointer_locked_ = false;

  // === Initialization ===
  void InitWpeBackend();
  void InitWebView(const InAppWebViewCreationParams& params);
  void RegisterEventHandlers();
  void PrepareAndAddUserScripts();  // Add plugin scripts based on settings
  void SetupMonitorChangeHandlers();
  void CleanupMonitorChangeHandlers();
  void UpdateMonitorRefreshRate();

 public:
#ifdef HAVE_WPE_BACKEND_LEGACY
  // === WPE FDO backend callbacks (legacy API only) ===
  // Instance method called from C callback (must be public)
  void OnExportDmaBuf(::wpe_fdo_egl_exported_image* image);
  void OnExportShmBuffer(struct wpe_fdo_shm_exported_buffer* buffer);
#endif

#ifdef HAVE_WPE_PLATFORM
  // === WPEPlatform buffer rendering callback ===
  // Called when a new frame buffer is rendered by WPEView
  void OnWpePlatformBufferRendered(WPEBuffer* buffer);
#endif

  // DOM fullscreen request handler (called from WPE backend)
  bool OnDomFullscreenRequest(bool fullscreen);
  
  // Color picker state (for <input type="color"> support in WPE)
  // Public because accessed from C-style GTK callback
  std::string pending_color_input_value_;  // Current color from the input
  GtkWidget* active_color_dialog_ = nullptr;  // Active color picker dialog (non-blocking)
  bool active_color_alpha_enabled_ = false;   // Alpha enabled for active dialog
  int64_t color_dialog_show_time_ = 0;         // Time when dialog was shown (to prevent immediate close)
  WebKitScriptMessageReply* pending_color_reply_ = nullptr;  // WebKit reply for Promise resolution

  // Date picker state (for <input type="date/time/etc.> support in WPE)
  // Public because accessed from C-style GTK callback
  std::string pending_date_input_value_;     // Current value from the input
  std::string pending_date_input_type_;      // Type: date, datetime-local, time, month, week
  std::string pending_date_input_min_;       // Min constraint
  std::string pending_date_input_max_;       // Max constraint
  GtkWidget* active_date_dialog_ = nullptr;  // Active date picker dialog
  int64_t date_dialog_show_time_ = 0;        // Time when dialog was shown
  WebKitScriptMessageReply* pending_date_reply_ = nullptr;  // WebKit reply for Promise resolution

  // File chooser state (for <input type="file"> support)
  // Public because accessed from C-style GTK callback
  GtkWidget* active_file_dialog_ = nullptr;   // Active file chooser dialog (non-blocking)
  int64_t file_dialog_show_time_ = 0;          // Time when dialog was shown (to prevent immediate close)
  void* file_chooser_context_ = nullptr;       // Opaque pointer to FileChooserContext (for cleanup)

  // Option menu state (for HTML <select> support)
  WebKitOptionMenu* webkit_option_menu_ = nullptr;  // WebKit's option menu object (kept alive during popup)

  // Pointer lock handler (called from WPE backend)
  bool OnPointerLockRequest(bool lock);

 private:
  static void OnFrameDisplayed(void* data);

  // Read pixels from EGL image to CPU buffer
  void ReadPixelsFromEglImage(void* egl_image, uint32_t width, uint32_t height);

  // === WebKit signals (same as WebKitGTK) ===
  static void OnLoadChanged(WebKitWebView* web_view, WebKitLoadEvent load_event,
                            gpointer user_data);

  static gboolean OnDecidePolicy(WebKitWebView* web_view, WebKitPolicyDecision* decision,
                                 WebKitPolicyDecisionType decision_type, gpointer user_data);

  static void OnNotifyEstimatedLoadProgress(GObject* object, GParamSpec* pspec, gpointer user_data);

  static void OnNotifyTitle(GObject* object, GParamSpec* pspec, gpointer user_data);

  static void OnNotifyUri(GObject* object, GParamSpec* pspec, gpointer user_data);

  static gboolean OnLoadFailed(WebKitWebView* web_view, WebKitLoadEvent load_event,
                               gchar* failing_uri, GError* error, gpointer user_data);

  static gboolean OnLoadFailedWithTlsErrors(WebKitWebView* web_view, gchar* failing_uri,
                                            GTlsCertificate* certificate,
                                            GTlsCertificateFlags errors, gpointer user_data);

  static void OnCloseRequest(WebKitWebView* web_view, gpointer user_data);

  static WebKitWebView* OnCreateWebView(WebKitWebView* web_view,
                                        WebKitNavigationAction* navigation_action,
                                        gpointer user_data);

  static gboolean OnScriptDialog(WebKitWebView* web_view, WebKitScriptDialog* dialog,
                                 gpointer user_data);

  static gboolean OnPermissionRequest(WebKitWebView* web_view, WebKitPermissionRequest* request,
                                      gpointer user_data);

  static gboolean OnAuthenticate(WebKitWebView* web_view, WebKitAuthenticationRequest* request,
                                 gpointer user_data);

  static gboolean OnContextMenu(WebKitWebView* web_view, WebKitContextMenu* context_menu,
                                WebKitHitTestResult* hit_test_result, gpointer user_data);

  static void OnContextMenuDismissed(WebKitWebView* web_view, gpointer user_data);

  static gboolean OnEnterFullscreen(WebKitWebView* web_view, gpointer user_data);

  static gboolean OnLeaveFullscreen(WebKitWebView* web_view, gpointer user_data);

  static void OnMouseTargetChanged(WebKitWebView* web_view, WebKitHitTestResult* hit_test_result,
                                   guint modifiers, gpointer user_data);

  static void OnWebProcessTerminated(WebKitWebView* web_view,
                                     WebKitWebProcessTerminationReason reason,
                                     gpointer user_data);

  static gboolean OnRunFileChooser(WebKitWebView* web_view,
                                   WebKitFileChooserRequest* request,
                                   gpointer user_data);

  static gboolean OnShowOptionMenu(WebKitWebView* web_view,
                                   WebKitOptionMenu* menu,
                                   WebKitRectangle* rectangle,
                                   gpointer user_data);

  // === Download Signals ===
  static void OnDownloadStarted(WebKitNetworkSession* network_session,
                                WebKitDownload* download,
                                gpointer user_data);

  // === Navigation State Signals ===
  static void OnBackForwardListChanged(WebKitBackForwardList* list,
                                       WebKitBackForwardListItem* item_added,
                                       gpointer items_removed,
                                       gpointer user_data);

  // === Media Capture State Signals ===
  static void OnNotifyCameraCaptureState(GObject* object, GParamSpec* pspec, gpointer user_data);
  static void OnNotifyMicrophoneCaptureState(GObject* object, GParamSpec* pspec, gpointer user_data);

  // === Input helpers ===
  void SendWpePointerEvent(uint32_t type, double x, double y, uint32_t button);
  void SendWpeAxisEvent(double x, double y, double dx, double dy);
  void SendWpeKeyboardEvent(uint32_t key, uint32_t state, uint32_t modifiers);

  // === JavaScript bridge ===
  void dispatchPlatformReady();

  // === Custom Scheme Handler ===
  void RegisterCustomSchemes();
  static void OnCustomSchemeRequest(WebKitURISchemeRequest* request, gpointer user_data);

  // === Cursor detection ===
  void updateCursorFromCssStyle(const std::string& cursor_style);
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_H_
