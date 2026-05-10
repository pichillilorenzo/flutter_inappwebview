#ifndef FLUTTER_INAPPWEBVIEW_WEBKITGTK_VIEW_H_
#define FLUTTER_INAPPWEBVIEW_WEBKITGTK_VIEW_H_

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <webkit2/webkit2.h>

#include <map>
#include <mutex>
#include <string>
#include <vector>

namespace flutter_inappwebview_webkit {

// JS bridge name (matches the flutter_inappwebview convention)
static constexpr const char* kJsBridgeName = "flutter_inappwebview";

// Struct for tracking pending JS evaluations
struct PendingEval {
  FlMethodCall* method_call;  // NOT ref-counted – we own the native call
};

class WebKitGTKView {
 public:
  WebKitGTKView(int64_t id, FlBinaryMessenger* messenger, FlTextureRegistrar* texture_registrar,
                GtkWindow* gtk_window);
  ~WebKitGTKView();

  int64_t id() const { return id_; }
  int64_t texture_id() const { return texture_id_; }

  // Called by platform view channel
  void SetSize(double width, double height, double scale_factor);
  void SetOffset(double dx, double dy);
  void SetCursorPos(double dx, double dy);
  void SetPointerButton(int kind, int button, int click_count);
  void SetScrollDelta(double dx, double dy);
  void SendKeyEvent(int type, int key_code, int scan_code, int modifiers, const char* characters);

  // Called by webview controller channel
  void LoadUrl(const std::string& url);
  void LoadData(const std::string& data, const std::string& mime_type, const std::string& base_url);
  void EvaluateJavascript(const std::string& js, FlMethodCall* method_call);
  std::string GetUrl();
  std::string GetTitle();
  void Reload();
  void StopLoading();
  bool CanGoBack();
  bool CanGoForward();
  void GoBack();
  void GoForward();
  void AddUserScript(const std::string& source, bool at_document_start);
  void RemoveAllUserScripts();
  void AddJavaScriptHandler(const std::string& handler_name);
  void RemoveJavaScriptHandler(const std::string& handler_name);
  void InjectBridgeScript();

  // Texture pixel populate callback – called from Flutter render thread
  gboolean PopulatePixelBuffer(const uint8_t** out_buffer, uint32_t* out_width,
                               uint32_t* out_height);

 private:
  int64_t id_;
  FlBinaryMessenger* messenger_ = nullptr;
  FlTextureRegistrar* texture_registrar_ = nullptr;
  GtkWindow* gtk_window_ = nullptr;

  GtkWidget* offscreen_window_ = nullptr;
  WebKitWebView* webkit_view_ = nullptr;
  WebKitUserContentManager* content_manager_ = nullptr;

  FlTexture* texture_ = nullptr;
  int64_t texture_id_ = -1;

  // Method channels
  FlMethodChannel* webview_channel_ = nullptr;        // flutter_inappwebview_$id
  FlMethodChannel* platform_view_channel_ = nullptr;  // custom_platform_view_$id
  FlEventChannel* event_channel_ = nullptr;           // custom_platform_view_${id}_events
  bool event_listening_ = false;

  // Current size
  double width_ = 800.0;
  double height_ = 600.0;
  double scale_factor_ = 1.0;
  double cursor_x_ = 0.0;
  double cursor_y_ = 0.0;

  // Pixel buffer (protected by mutex, written from GTK thread, read from render thread)
  std::mutex pixel_mutex_;
  std::vector<uint8_t> pixel_buffer_;
  uint32_t pixel_width_ = 0;
  uint32_t pixel_height_ = 0;

  // JS handlers registered
  std::vector<std::string> js_handlers_;

  // Damage timer for periodic refresh
  guint damage_timer_id_ = 0;

  // ---- static GTK/WebKit signal handlers ----
  static void OnLoadChanged(WebKitWebView* view, WebKitLoadEvent event, gpointer user_data);
  static void OnLoadFailed(WebKitWebView* view, WebKitLoadEvent event, const gchar* failing_uri,
                           GError* error, gpointer user_data);
  static void OnEstimatedProgress(GObject* object, GParamSpec* pspec, gpointer user_data);
  static void OnScriptMessageReceived(WebKitUserContentManager* manager,
                                      WebKitJavascriptResult* result, gpointer user_data);
  static void OnJavascriptFinished(GObject* source_object, GAsyncResult* res, gpointer user_data);
  static gboolean OnDamageEvent(GtkWidget* widget, GdkEventExpose* event, gpointer user_data);
  static gboolean OnTimerTick(gpointer user_data);
  static FlMethodErrorResponse* OnEventListen(FlEventChannel* channel, FlValue* args,
                                              gpointer user_data);
  static FlMethodErrorResponse* OnEventCancel(FlEventChannel* channel, FlValue* args,
                                              gpointer user_data);

  // ---- method channel handlers ----
  static void HandleWebviewMethodCall(FlMethodChannel* channel, FlMethodCall* method_call,
                                      gpointer user_data);
  static void HandlePlatformViewMethodCall(FlMethodChannel* channel, FlMethodCall* method_call,
                                           gpointer user_data);
  void HandleWebviewMethodCallImpl(FlMethodCall* method_call);
  void HandlePlatformViewMethodCallImpl(FlMethodCall* method_call);

  // ---- rendering ----
  void UpdatePixelBuffer();
  void MarkFrameAvailable();

  // ---- helpers ----
  GdkWindow* GetGdkWindow() const;
  void SendEventToDart(const char* event_name, FlValue* args);
};

}  // namespace flutter_inappwebview_webkit

#endif  // FLUTTER_INAPPWEBVIEW_WEBKITGTK_VIEW_H_
