#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_H_

#include <flutter_linux/flutter_linux.h>

// Use the appropriate WebKit header based on backend
#ifdef USE_WPE_WEBKIT
#include <wpe/webkit.h>
#else
#include <webkit2/webkit2.h>
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
#include <vector>

#include "../types/url_request.h"
#include "../types/user_script.h"
#include "in_app_webview_settings.h"

namespace flutter_inappwebview_plugin {

class UserContentController;

// Backend type detected at runtime
enum class GdkBackendType {
  Unknown = 0,
  X11 = 1,
  Wayland = 2,
  Broadway = 3,  // Web-based backend
};

class InAppWebViewManager;
class WebViewChannelDelegate;

struct InAppWebViewCreationParams {
  int64_t id;
  std::optional<std::shared_ptr<URLRequest>> initialUrlRequest;
  std::optional<std::string> initialFile;
  std::optional<std::string> initialData;
  std::optional<std::string> initialDataBaseUrl;
  std::optional<std::string> initialDataMimeType;
  std::optional<std::string> initialDataEncoding;
  std::shared_ptr<InAppWebViewSettings> initialSettings;
};

// Pointer event kind (matches Dart side)
enum class PointerEventKind {
  Activate = 0,
  Down = 1,
  Enter = 2,
  Leave = 3,
  Up = 4,
  Update = 5,
  Cancel = 6
};

// Pointer button type (matches Dart side)
enum class PointerButton { None = 0, Primary = 1, Secondary = 2, Tertiary = 3 };

class InAppWebView {
 public:
  static constexpr const char* METHOD_CHANNEL_NAME_PREFIX =
      "com.pichillilorenzo/flutter_inappwebview_";

  InAppWebView(FlBinaryMessenger* messenger, int64_t id,
               const InAppWebViewCreationParams& params);
  ~InAppWebView();

  int64_t id() const { return id_; }
  WebKitWebView* webview() const { return webview_; }
  WebViewChannelDelegate* channel_delegate() const {
    return channel_delegate_.get();
  }

  // Attach/recreate the Dart method channel using the given [channel_id].
  // This must match the id used on the Dart side for `MethodChannel('com.pichillilorenzo/flutter_inappwebview_$id')`.
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
  std::shared_ptr<InAppWebViewSettings> settings() const { return settings_; }
  FlValue* getSettings() const;
  void setSettings(const std::shared_ptr<InAppWebViewSettings> newSettings,
                   FlValue* newSettingsMap = nullptr);
  void setSettingsFromMap(const std::map<std::string, FlValue*>& settingsMap);

  // User content controller
  UserContentController* userContentController() const {
    return user_content_controller_.get();
  }

  // Size management
  void setSize(int width, int height);
  void setScaleFactor(double scale_factor);

  // Input handling (called by CustomPlatformView)
  void SetCursorPos(double x, double y);
  void SetPointerButton(int kind, int button, int clickCount = 1);
  void SetScrollDelta(double dx, double dy);
  void SendKeyEvent(int type, int64_t keyCode, int scanCode, int modifiers, const std::string& characters);

  // Texture pixel buffer access (called by InAppWebViewTexture)
  // These APIs are safe to call from the render thread.
  size_t GetPixelBufferSize(uint32_t* out_width, uint32_t* out_height) const;
  bool CopyPixelBufferTo(uint8_t* dst, size_t dst_size, uint32_t* out_width,
                         uint32_t* out_height) const;

  // Frame available callback (called when new frame is ready)
  void SetOnFrameAvailable(std::function<void()> callback);

  // Cursor change callback (called when cursor style changes)
  void SetOnCursorChanged(std::function<void(const std::string&)> callback);

  // Called from Dart when shouldOverrideUrlLoading decision is made
  void OnShouldOverrideUrlLoadingDecision(int64_t decision_id, bool allow);

 // Get the detected GDK backend type (cached at initialization)
  static GdkBackendType GetBackendType();
  
  // Returns true if the backend supports cursor warping (X11 does, Wayland doesn't)
  static bool SupportsCursorWarp();

 private:
  int64_t id_ = 0;
  int64_t channel_id_ = -1;

  // Settings
  std::shared_ptr<InAppWebViewSettings> settings_;

  // WebKit / GTK container (hidden window to host the webview)
  // NOTE: We use a minimal window approach that avoids forcing backend-specific
  // surfaces. The window is never mapped to the screen - we only use it as a
  // container for WebKitWebView which requires a parent widget.
  GtkWidget* container_window_ = nullptr;
  WebKitWebView* webview_ = nullptr;

  // Triple buffering for pixel data
  // Buffer 0: being written by snapshot callback
  // Buffer 1: ready for Flutter to read
  // Buffer 2: being read by Flutter (in-flight)
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
  
  // Legacy single-buffer for compatibility (will be removed)
  std::vector<uint8_t> rgba_;
  size_t pixel_buffer_width_ = 0;
  size_t pixel_buffer_height_ = 0;
  mutable std::mutex pixel_buffer_mutex_;

  // Snapshot scheduling
  guint snapshot_timer_id_ = 0;
  int fps_limit_ = 60;  // Target FPS for snapshot-based rendering
  std::atomic<bool> frame_pending_{false};
  int width_ = 800;
  int height_ = 600;
  double scale_factor_ = 1.0;

  // Channel delegate
  std::unique_ptr<WebViewChannelDelegate> channel_delegate_;

  // User content controller (handles user scripts and JS bridge)
  std::unique_ptr<UserContentController> user_content_controller_;

  // JavaScript bridge secret for security
  std::string js_bridge_secret_;

  // Pending policy decisions for async shouldOverrideUrlLoading
  std::map<int64_t, WebKitPolicyDecision*> pending_policy_decisions_;
  int64_t next_decision_id_ = 0;

  // Pending script dialogs for async handling
  std::map<int64_t, WebKitScriptDialog*> pending_script_dialogs_;
  int64_t next_dialog_id_ = 0;

  // Pending permission requests
  std::map<int64_t, WebKitPermissionRequest*> pending_permission_requests_;
  int64_t next_permission_id_ = 0;

  // Pending authentication requests
  std::map<int64_t, WebKitAuthenticationRequest*> pending_auth_requests_;
  int64_t next_auth_id_ = 0;

  // Window ID for child windows
  std::optional<int64_t> window_id_;

  // Frame available callback
  std::function<void()> on_frame_available_;

  // Cursor change callback
  std::function<void(const std::string&)> on_cursor_changed_;
  std::string last_cursor_name_;  // Track last cursor to avoid duplicate events

  // Mouse state for input simulation
  double cursor_x_ = 0;
  double cursor_y_ = 0;
  guint32 button_state_ = 0;

  // Scroll multiplier (matches Windows implementation)
  double scroll_multiplier_ = 1.0;

  // Progress tracking
  double last_progress_ = 0.0;

  // Cached backend type (detected once)
  static GdkBackendType cached_backend_type_;
  static bool backend_type_detected_;

  // === Initialization ===
  void InitWebView(const InAppWebViewCreationParams& params);
  void RegisterEventHandlers();
  void StartSnapshotTimer();
  static void DetectBackendType();

  // === WebKit signals ===
  static void OnLoadChanged(WebKitWebView* web_view,
                            WebKitLoadEvent load_event, gpointer user_data);

  static gboolean OnDecidePolicy(WebKitWebView* web_view,
                                 WebKitPolicyDecision* decision,
                                 WebKitPolicyDecisionType decision_type,
                                 gpointer user_data);

  static gboolean OnMotionNotify(GtkWidget* widget, GdkEventMotion* event,
                                 gpointer user_data);

  static void OnMouseTargetChanged(WebKitWebView* web_view,
                                   WebKitHitTestResult* hit_test_result,
                                   guint modifiers,
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

  static GtkWidget* OnCreateWebView(WebKitWebView* web_view,
                                    WebKitNavigationAction* navigation_action,
                                    gpointer user_data);

  static void OnReadyToShow(WebKitWebView* web_view, gpointer user_data);

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
                                GdkEvent* event,
                                WebKitHitTestResult* hit_test_result,
                                gpointer user_data);

  static gboolean OnEnterFullscreen(WebKitWebView* web_view, gpointer user_data);

  static gboolean OnLeaveFullscreen(WebKitWebView* web_view, gpointer user_data);

  static void OnNotifyFavicon(GObject* object, GParamSpec* pspec, gpointer user_data);

  // === Snapshot ===
  static gboolean SnapshotTick(gpointer user_data);
  void RequestSnapshot();
  void SwapBuffers();

  // === Input helpers ===
  void SendMouseEvent(GdkEventType type, double x, double y, guint button,
                      guint state);
  void SendScrollEvent(double x, double y, double dx, double dy);

  GdkDevice* GetPointerDevice() const;
  GdkDevice* GetKeyboardDevice() const;
  void EnsureFocused();

  // === JavaScript bridge ===
  void handleScriptMessage(const std::string& name, const std::string& body);
  void dispatchPlatformReady();
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_H_
