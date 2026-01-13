#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_BROWSER_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_BROWSER_H_

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>

#include <memory>
#include <optional>
#include <string>
#include <vector>

#include "../in_app_webview/in_app_webview.h"
#include "../in_app_webview/in_app_webview_settings.h"
#include "../types/url_request.h"
#include "in_app_browser_channel_delegate.h"
#include "in_app_browser_settings.h"

namespace flutter_inappwebview_plugin {

class InAppBrowserManager;
class PluginInstance;

/// Menu item for InAppBrowser
struct InAppBrowserMenuItem {
  int32_t id = 0;
  std::string title;
  int32_t order = 0;

  InAppBrowserMenuItem() = default;
  explicit InAppBrowserMenuItem(FlValue* map);
};

/// Creation parameters for InAppBrowser
struct InAppBrowserCreationParams {
  PluginInstance* plugin = nullptr;
  std::string id;
  std::optional<std::shared_ptr<URLRequest>> urlRequest;
  std::optional<std::string> assetFilePath;
  std::optional<std::string> data;
  std::shared_ptr<InAppBrowserSettings> initialSettings;
  std::shared_ptr<InAppWebViewSettings> initialWebViewSettings;
  std::optional<std::vector<std::shared_ptr<UserScript>>> initialUserScripts;
  std::optional<std::string> webViewEnvironmentId;
  std::optional<std::shared_ptr<ContextMenu>> contextMenu;
  std::vector<InAppBrowserMenuItem> menuItems;
};

/// InAppBrowser - A standalone browser window with embedded WebView
///
/// Creates a GTK window with an optional toolbar and an embedded WPE WebView.
/// Supports navigation controls, URL bar, progress indicator, and custom menus.
///
/// The browser window can be shown, hidden, and configured with various settings
/// like window size, position, opacity, and toolbar visibility.
class InAppBrowser {
 public:
  static constexpr const char* METHOD_CHANNEL_NAME_PREFIX =
      "com.pichillilorenzo/flutter_inappbrowser_";

  /// Create an InAppBrowser with the given parameters
  /// @param manager The manager that owns this browser
  /// @param messenger The Flutter binary messenger for channel communication
  /// @param parentWindow The parent GTK window (optional, for child window type)
  /// @param params Creation parameters
  InAppBrowser(InAppBrowserManager* manager, FlBinaryMessenger* messenger,
               GtkWindow* parentWindow, const InAppBrowserCreationParams& params);
  ~InAppBrowser();

  /// Get the unique ID of this browser
  const std::string& id() const { return id_; }

  /// Get the GTK window
  GtkWindow* getWindow() const { return window_; }

  /// Get the embedded WebView
  InAppWebView* webView() const { return webView_.get(); }

  /// Get the channel delegate
  InAppBrowserChannelDelegate* channelDelegate() const { return channelDelegate_.get(); }

  /// Get the current settings
  std::shared_ptr<InAppBrowserSettings> settings() const { return settings_; }

  /// Close the browser window
  void close();

  /// Show the browser window
  void show();

  /// Hide the browser window
  void hide();

  /// Check if the browser is hidden
  bool isHidden() const;

  /// Update the browser settings
  /// @param newSettings The new settings to apply
  /// @param newSettingsMap The FlValue map of new settings (for checking which changed)
  void setSettings(const std::shared_ptr<InAppBrowserSettings>& newSettings,
                   FlValue* newSettingsMap);

  /// Get the current settings as FlValue
  FlValue* getSettings() const;

  /// Called when the WebView title changes
  void didChangeTitle(const std::optional<std::string>& title);

  /// Called when the WebView URL changes
  void didChangeUrl(const std::optional<std::string>& url);

  /// Called when the load progress changes
  void didChangeProgress(double progress);

  /// Called when navigation state changes (can go back/forward)
  void didChangeNavigationState();

 private:
  PluginInstance* plugin_ = nullptr;
  InAppBrowserManager* manager_ = nullptr;
  FlBinaryMessenger* messenger_ = nullptr;
  GtkWindow* parentWindow_ = nullptr;  // Parent window for child window type
  std::string id_;
  bool destroyed_ = false;

  // GTK Window (created by this browser)
  GtkWindow* window_ = nullptr;

  // Toolbar widgets
  GtkWidget* headerBar_ = nullptr;
  GtkWidget* backButton_ = nullptr;
  GtkWidget* forwardButton_ = nullptr;
  GtkWidget* reloadButton_ = nullptr;
  GtkWidget* urlEntry_ = nullptr;
  GtkWidget* progressBar_ = nullptr;
  GtkWidget* menuButton_ = nullptr;
  GtkWidget* contentBox_ = nullptr;

  // WebView rendering
  std::shared_ptr<InAppWebView> webView_;
  GtkWidget* drawingArea_ = nullptr;
  guint frameSourceId_ = 0;
  GdkCursor* currentCursor_ = nullptr;

  // GPU rendering with GtkGLArea (zero-copy EGL texture path)
  GtkWidget* glArea_ = nullptr;
  bool useGlRendering_ = false;
  unsigned int glTexture_ = 0;
  bool glInitialized_ = false;

  // Shader-based rendering (OpenGL ES compatible)
  unsigned int glProgram_ = 0;
  unsigned int glVBO_ = 0;
  int glAttribPosition_ = -1;
  int glAttribTexture_ = -1;
  int glUniformTexture_ = -1;

  // Channel delegate
  std::unique_ptr<InAppBrowserChannelDelegate> channelDelegate_;

  // Settings
  std::shared_ptr<InAppBrowserSettings> settings_;

  // Menu items
  std::vector<InAppBrowserMenuItem> menuItems_;

  // Window setup methods
  void setupWindow(const InAppBrowserCreationParams& params);
  void setupToolbar();
  void setupWebView(const InAppBrowserCreationParams& params);
  void setupDrawingArea();
  void applySettings();
  void loadInitialContent(const InAppBrowserCreationParams& params);

  // Update toolbar state
  void updateNavigationButtons();
  void updateProgressBar(double progress);
  void updateUrlEntry(const std::string& url);
  void updateTitle(const std::string& title);

  // GTK Signal handlers (static callbacks)
  static void OnWindowDestroy(GtkWidget* widget, gpointer user_data);
  static gboolean OnWindowDeleteEvent(GtkWidget* widget, GdkEvent* event, gpointer user_data);
  static void OnBackClicked(GtkButton* button, gpointer user_data);
  static void OnForwardClicked(GtkButton* button, gpointer user_data);
  static void OnReloadClicked(GtkButton* button, gpointer user_data);
  static void OnUrlEntryActivated(GtkEntry* entry, gpointer user_data);
  static gboolean OnDrawingAreaDraw(GtkWidget* widget, cairo_t* cr, gpointer user_data);
  static void OnDrawingAreaRealize(GtkWidget* widget, gpointer user_data);
  static gboolean OnDrawingAreaButtonPress(GtkWidget* widget, GdkEventButton* event,
                                           gpointer user_data);
  static gboolean OnDrawingAreaButtonRelease(GtkWidget* widget, GdkEventButton* event,
                                             gpointer user_data);
  static gboolean OnDrawingAreaMotionNotify(GtkWidget* widget, GdkEventMotion* event,
                                            gpointer user_data);
  static gboolean OnDrawingAreaScroll(GtkWidget* widget, GdkEventScroll* event,
                                      gpointer user_data);
  static gboolean OnDrawingAreaKeyPress(GtkWidget* widget, GdkEventKey* event,
                                        gpointer user_data);
  static gboolean OnDrawingAreaKeyRelease(GtkWidget* widget, GdkEventKey* event,
                                          gpointer user_data);
  static void OnDrawingAreaSizeAllocate(GtkWidget* widget, GdkRectangle* allocation, gpointer user_data);
  static gboolean OnDrawingAreaFocusIn(GtkWidget* widget, GdkEventFocus* event, gpointer user_data);
  static gboolean OnDrawingAreaFocusOut(GtkWidget* widget, GdkEventFocus* event, gpointer user_data);
  static void OnDrawingAreaMap(GtkWidget* widget, gpointer user_data);
  static void OnDrawingAreaUnmap(GtkWidget* widget, gpointer user_data);
  static gboolean OnDrawingAreaEnterNotify(GtkWidget* widget, GdkEventCrossing* event, gpointer user_data);
  static gboolean OnDrawingAreaLeaveNotify(GtkWidget* widget, GdkEventCrossing* event, gpointer user_data);
  static void OnMenuItemActivated(GtkMenuItem* item, gpointer user_data);

  // GtkGLArea signal handlers (for GPU-accelerated rendering)
  static void OnGlAreaRealize(GtkGLArea* area, gpointer user_data);
  static gboolean OnGlAreaRender(GtkGLArea* area, GdkGLContext* context, gpointer user_data);
  static void OnGlAreaResize(GtkGLArea* area, gint width, gint height, gpointer user_data);
  static void OnGlAreaSizeAllocate(GtkWidget* widget, GdkRectangle* allocation, gpointer user_data);
  
  // Fallback pixel buffer rendering (for SHM mode or when EGL is unavailable)
  gboolean RenderFromPixelBuffer(GtkGLArea* area);
  
  // Fallback setup for GtkDrawingArea (when GtkGLArea fails)
  void setupDrawingAreaFallback();

  // Cursor change handler
  void OnCursorChanged(const std::string& cursorName);

  // Schedule frame redraw
  void scheduleFrame();
  static gboolean OnFrameCallback(gpointer user_data);

  // Clean up
  void cleanup();
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_BROWSER_H_
