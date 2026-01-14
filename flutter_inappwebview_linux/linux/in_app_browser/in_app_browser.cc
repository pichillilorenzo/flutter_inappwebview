#include "in_app_browser.h"

#include <gdk/gdk.h>
#include <epoxy/gl.h>
#include <epoxy/egl.h>

#include "../plugin_instance.h"
#include "../utils/flutter.h"
#include "../utils/log.h"
#include "../webview_environment.h"
#include "in_app_browser_manager.h"

namespace flutter_inappwebview_plugin {

// Convert color from #AARRGGBB (Flutter format) to rgba(r,g,b,a) (GTK CSS format)
// Flutter uses #AARRGGBB, but GTK CSS expects #RRGGBB, #RRGGBBAA, or rgba()
static std::string ConvertColorToGtkCss(const std::string& color) {
  if (color.empty()) {
    return color;
  }
  
  // Handle #AARRGGBB format (9 chars including #)
  if (color.length() == 9 && color[0] == '#') {
    // Extract components: #AARRGGBB
    std::string aa = color.substr(1, 2);
    std::string rr = color.substr(3, 2);
    std::string gg = color.substr(5, 2);
    std::string bb = color.substr(7, 2);
    
    // Parse hex values
    int a = std::stoi(aa, nullptr, 16);
    int r = std::stoi(rr, nullptr, 16);
    int g = std::stoi(gg, nullptr, 16);
    int b = std::stoi(bb, nullptr, 16);
    
    // Return rgba() format
    char buffer[64];
    snprintf(buffer, sizeof(buffer), "rgba(%d, %d, %d, %.3f)", r, g, b, a / 255.0);
    return std::string(buffer);
  }
  
  // Return as-is for other formats (#RGB, #RRGGBB, rgb(), rgba(), etc.)
  return color;
}

// InAppBrowserMenuItem implementation

InAppBrowserMenuItem::InAppBrowserMenuItem(FlValue* map) {
  if (map == nullptr || fl_value_get_type(map) != FL_VALUE_TYPE_MAP) {
    return;
  }
  id = get_fl_map_value<int32_t>(map, "id", 0);
  title = get_fl_map_value<std::string>(map, "title", "");
  order = get_fl_map_value<int32_t>(map, "order", 0);
}

// InAppBrowser implementation

InAppBrowser::InAppBrowser(InAppBrowserManager* manager, FlBinaryMessenger* messenger,
                           GtkWindow* parentWindow, const InAppBrowserCreationParams& params)
    : plugin_(params.plugin),
      manager_(manager),
      messenger_(messenger),
      parentWindow_(parentWindow),
      id_(params.id),
      settings_(params.initialSettings),
      menuItems_(params.menuItems) {
  // Validate messenger
  if (messenger_ == nullptr || !FL_IS_BINARY_MESSENGER(messenger_)) {
    errorLog("InAppBrowser: Invalid messenger");
    return;
  }

  // Create channel delegate
  std::string channelName = std::string(METHOD_CHANNEL_NAME_PREFIX) + id_;
  channelDelegate_ = std::make_unique<InAppBrowserChannelDelegate>(this, messenger_, channelName);

  // Setup the window and components
  setupWindow(params);
  setupToolbar();
  setupDrawingArea();
  setupWebView(params);
  applySettings();

  // Show window unless hidden
  if (!settings_->hidden) {
    gtk_widget_show_all(GTK_WIDGET(window_));
    // Apply toolbar visibility after show_all
    if (settings_->hideToolbarTop) {
      gtk_widget_hide(headerBar_);
    }
  }

  // Load initial content (async, WebView needs time to initialize)
  g_idle_add(
      [](gpointer user_data) -> gboolean {
        auto* browser = static_cast<InAppBrowser*>(user_data);
        if (browser && !browser->destroyed_) {
          // Notify Dart that browser is created
          if (browser->channelDelegate_) {
            browser->channelDelegate_->onBrowserCreated();
          }
        }
        return G_SOURCE_REMOVE;
      },
      this);
}

InAppBrowser::~InAppBrowser() {
  debugLog("dealloc InAppBrowser");
  cleanup();
}

void InAppBrowser::cleanup() {
  if (destroyed_) {
    return;
  }
  destroyed_ = true;

  // Cancel frame callback
  if (frameSourceId_ != 0) {
    g_source_remove(frameSourceId_);
    frameSourceId_ = 0;
  }

  // Clean up cursor
  if (currentCursor_ != nullptr) {
    g_object_unref(currentCursor_);
    currentCursor_ = nullptr;
  }

  // Clean up WebView
  webView_.reset();

  // Clean up channel delegate
  if (channelDelegate_) {
    channelDelegate_->unregisterMethodCallHandler();
    channelDelegate_.reset();
  }

  // Nullify window reference (GTK handles cleanup via destroy signal)
  window_ = nullptr;
  headerBar_ = nullptr;
  backButton_ = nullptr;
  forwardButton_ = nullptr;
  reloadButton_ = nullptr;
  urlEntry_ = nullptr;
  progressBar_ = nullptr;
  menuButton_ = nullptr;
  contentBox_ = nullptr;
  drawingArea_ = nullptr;

  // Clean up GL resources
  if (glArea_ != nullptr && gtk_widget_get_realized(glArea_)) {
    gtk_gl_area_make_current(GTK_GL_AREA(glArea_));
    if (glTexture_ != 0) {
      glDeleteTextures(1, &glTexture_);
      glTexture_ = 0;
    }
    if (glVBO_ != 0) {
      glDeleteBuffers(1, &glVBO_);
      glVBO_ = 0;
    }
    if (glProgram_ != 0) {
      glDeleteProgram(glProgram_);
      glProgram_ = 0;
    }
  }
  glArea_ = nullptr;
  glInitialized_ = false;
  glAttribPosition_ = -1;
  glAttribTexture_ = -1;
  glUniformTexture_ = -1;

  manager_ = nullptr;
  messenger_ = nullptr;
  parentWindow_ = nullptr;
  plugin_ = nullptr;
}

void InAppBrowser::setupWindow(const InAppBrowserCreationParams& params) {
  // Create top-level window
  window_ = GTK_WINDOW(gtk_window_new(GTK_WINDOW_TOPLEVEL));

  // Set window title
  if (!settings_->toolbarTopFixedTitle.empty()) {
    gtk_window_set_title(window_, settings_->toolbarTopFixedTitle.c_str());
  } else {
    gtk_window_set_title(window_, "InAppBrowser");
  }

  // Set window size
  int width = 1280;
  int height = 720;
  if (settings_->windowFrame) {
    width = static_cast<int>(settings_->windowFrame->width);
    height = static_cast<int>(settings_->windowFrame->height);
  }
  gtk_window_set_default_size(window_, width, height);

  // Set window position
  if (settings_->windowFrame) {
    gtk_window_move(window_, static_cast<int>(settings_->windowFrame->x),
                    static_cast<int>(settings_->windowFrame->y));
  }

  // Set window type hints
  if (settings_->windowType == InAppBrowserWindowType::child) {
    if (parentWindow_ != nullptr) {
      gtk_window_set_transient_for(window_, parentWindow_);
      gtk_window_set_destroy_with_parent(window_, TRUE);
    }
  }

  // Set opacity
  gtk_widget_set_opacity(GTK_WIDGET(window_), settings_->windowAlphaValue);

  // Create main vertical box
  contentBox_ = gtk_box_new(GTK_ORIENTATION_VERTICAL, 0);
  gtk_container_add(GTK_CONTAINER(window_), contentBox_);

  // Connect signals
  g_signal_connect(window_, "destroy", G_CALLBACK(OnWindowDestroy), this);
  g_signal_connect(window_, "delete-event", G_CALLBACK(OnWindowDeleteEvent), this);
}

void InAppBrowser::setupToolbar() {
  // Create header bar
  headerBar_ = gtk_header_bar_new();
  gtk_header_bar_set_show_close_button(GTK_HEADER_BAR(headerBar_), TRUE);

  // Apply background color if specified
  if (!settings_->toolbarTopBackgroundColor.empty()) {
    GtkCssProvider* provider = gtk_css_provider_new();
    std::string gtkColor = ConvertColorToGtkCss(settings_->toolbarTopBackgroundColor);
    std::string css = "headerbar { background-color: " + gtkColor + "; }";
    gtk_css_provider_load_from_data(provider, css.c_str(), -1, nullptr);
    GtkStyleContext* context = gtk_widget_get_style_context(headerBar_);
    gtk_style_context_add_provider(context, GTK_STYLE_PROVIDER(provider),
                                   GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);
    g_object_unref(provider);
  }

  // Create navigation buttons (unless hidden)
  if (!settings_->hideDefaultMenuItems) {
    // Navigation button box
    GtkWidget* navBox = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 0);
    gtk_style_context_add_class(gtk_widget_get_style_context(navBox), "linked");

    // Back button
    backButton_ = gtk_button_new_from_icon_name("go-previous-symbolic", GTK_ICON_SIZE_BUTTON);
    gtk_widget_set_tooltip_text(backButton_, "Go Back");
    gtk_widget_set_sensitive(backButton_, FALSE);
    g_signal_connect(backButton_, "clicked", G_CALLBACK(OnBackClicked), this);
    gtk_box_pack_start(GTK_BOX(navBox), backButton_, FALSE, FALSE, 0);

    // Forward button
    forwardButton_ = gtk_button_new_from_icon_name("go-next-symbolic", GTK_ICON_SIZE_BUTTON);
    gtk_widget_set_tooltip_text(forwardButton_, "Go Forward");
    gtk_widget_set_sensitive(forwardButton_, FALSE);
    g_signal_connect(forwardButton_, "clicked", G_CALLBACK(OnForwardClicked), this);
    gtk_box_pack_start(GTK_BOX(navBox), forwardButton_, FALSE, FALSE, 0);

    // Reload button
    reloadButton_ = gtk_button_new_from_icon_name("view-refresh-symbolic", GTK_ICON_SIZE_BUTTON);
    gtk_widget_set_tooltip_text(reloadButton_, "Reload");
    g_signal_connect(reloadButton_, "clicked", G_CALLBACK(OnReloadClicked), this);
    gtk_box_pack_start(GTK_BOX(navBox), reloadButton_, FALSE, FALSE, 0);

    gtk_header_bar_pack_start(GTK_HEADER_BAR(headerBar_), navBox);
  }

  // Create URL entry (unless hidden)
  if (!settings_->hideUrlBar) {
    urlEntry_ = gtk_entry_new();
    gtk_entry_set_placeholder_text(GTK_ENTRY(urlEntry_), "Enter URL...");
    gtk_widget_set_hexpand(urlEntry_, TRUE);
    gtk_entry_set_icon_from_icon_name(GTK_ENTRY(urlEntry_), GTK_ENTRY_ICON_PRIMARY, "globe-symbolic");
    g_signal_connect(urlEntry_, "activate", G_CALLBACK(OnUrlEntryActivated), this);
    gtk_header_bar_set_custom_title(GTK_HEADER_BAR(headerBar_), urlEntry_);
  }

  // Create menu button if there are menu items
  if (!menuItems_.empty()) {
    menuButton_ = gtk_menu_button_new();
    gtk_button_set_image(GTK_BUTTON(menuButton_),
                         gtk_image_new_from_icon_name("open-menu-symbolic", GTK_ICON_SIZE_BUTTON));
    gtk_widget_set_tooltip_text(menuButton_, "Menu");

    // Create menu
    GtkWidget* menu = gtk_menu_new();
    for (const auto& item : menuItems_) {
      GtkWidget* menuItem = gtk_menu_item_new_with_label(item.title.c_str());
      g_object_set_data(G_OBJECT(menuItem), "menu-item-id", GINT_TO_POINTER(item.id));
      g_signal_connect(menuItem, "activate", G_CALLBACK(OnMenuItemActivated), this);
      gtk_menu_shell_append(GTK_MENU_SHELL(menu), menuItem);
    }
    gtk_widget_show_all(menu);
    gtk_menu_button_set_popup(GTK_MENU_BUTTON(menuButton_), menu);

    gtk_header_bar_pack_end(GTK_HEADER_BAR(headerBar_), menuButton_);
  }

  // Use the header bar as the title bar
  gtk_window_set_titlebar(window_, headerBar_);

  // Create progress bar (in content area, below header)
  if (!settings_->hideProgressBar) {
    progressBar_ = gtk_progress_bar_new();
    gtk_widget_set_valign(progressBar_, GTK_ALIGN_START);
    gtk_progress_bar_set_fraction(GTK_PROGRESS_BAR(progressBar_), 0.0);
    gtk_box_pack_start(GTK_BOX(contentBox_), progressBar_, FALSE, FALSE, 0);

    // Style the progress bar to be thin
    GtkCssProvider* provider = gtk_css_provider_new();
    gtk_css_provider_load_from_data(
        provider,
        "progressbar { min-height: 3px; } "
        "progressbar trough { min-height: 3px; } "
        "progressbar progress { min-height: 3px; }",
        -1, nullptr);
    GtkStyleContext* context = gtk_widget_get_style_context(progressBar_);
    gtk_style_context_add_provider(context, GTK_STYLE_PROVIDER(provider),
                                   GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);
    g_object_unref(provider);
  }
}

void InAppBrowser::setupDrawingArea() {
  // Try to use GtkGLArea for hardware-accelerated zero-copy rendering
  // This provides better performance by avoiding GPU->CPU->GPU copies
  bool canUseGl = InAppWebView::IsWpeWebKitAvailable();

  if (canUseGl) {
    // Create GtkGLArea for zero-copy EGL texture rendering
    glArea_ = gtk_gl_area_new();
    gtk_widget_set_can_focus(glArea_, TRUE);
    gtk_widget_set_hexpand(glArea_, TRUE);
    gtk_widget_set_vexpand(glArea_, TRUE);

    // Use OpenGL ES for compatibility with WPE's EGL images
    gtk_gl_area_set_use_es(GTK_GL_AREA(glArea_), TRUE);

    // Enable events
    gtk_widget_add_events(glArea_,
                          GDK_BUTTON_PRESS_MASK | GDK_BUTTON_RELEASE_MASK |
                              GDK_POINTER_MOTION_MASK | GDK_SCROLL_MASK |
                              GDK_SMOOTH_SCROLL_MASK | GDK_KEY_PRESS_MASK |
                              GDK_KEY_RELEASE_MASK | GDK_FOCUS_CHANGE_MASK |
                              GDK_ENTER_NOTIFY_MASK | GDK_LEAVE_NOTIFY_MASK);

    // Connect GL-specific signals
    g_signal_connect(glArea_, "realize", G_CALLBACK(OnGlAreaRealize), this);
    g_signal_connect(glArea_, "render", G_CALLBACK(OnGlAreaRender), this);
    g_signal_connect(glArea_, "resize", G_CALLBACK(OnGlAreaResize), this);

    // Connect input signals (same as drawing area)
    g_signal_connect(glArea_, "button-press-event", G_CALLBACK(OnDrawingAreaButtonPress), this);
    g_signal_connect(glArea_, "button-release-event", G_CALLBACK(OnDrawingAreaButtonRelease), this);
    g_signal_connect(glArea_, "motion-notify-event", G_CALLBACK(OnDrawingAreaMotionNotify), this);
    g_signal_connect(glArea_, "scroll-event", G_CALLBACK(OnDrawingAreaScroll), this);
    g_signal_connect(glArea_, "key-press-event", G_CALLBACK(OnDrawingAreaKeyPress), this);
    g_signal_connect(glArea_, "key-release-event", G_CALLBACK(OnDrawingAreaKeyRelease), this);
    g_signal_connect(glArea_, "focus-in-event", G_CALLBACK(OnDrawingAreaFocusIn), this);
    g_signal_connect(glArea_, "focus-out-event", G_CALLBACK(OnDrawingAreaFocusOut), this);
    g_signal_connect(glArea_, "enter-notify-event", G_CALLBACK(OnDrawingAreaEnterNotify), this);
    g_signal_connect(glArea_, "leave-notify-event", G_CALLBACK(OnDrawingAreaLeaveNotify), this);
    g_signal_connect(glArea_, "map", G_CALLBACK(OnDrawingAreaMap), this);
    g_signal_connect(glArea_, "unmap", G_CALLBACK(OnDrawingAreaUnmap), this);
    g_signal_connect(glArea_, "size-allocate", G_CALLBACK(OnGlAreaSizeAllocate), this);

    gtk_box_pack_start(GTK_BOX(contentBox_), glArea_, TRUE, TRUE, 0);
    useGlRendering_ = true;
  } else {
    // Fall back to original GtkDrawingArea implementation
    setupDrawingAreaFallback();
  }
}

void InAppBrowser::setupDrawingAreaFallback() {
  // Original GtkDrawingArea code - used when GL rendering is not available
  drawingArea_ = gtk_drawing_area_new();
  gtk_widget_set_can_focus(drawingArea_, TRUE);
  gtk_widget_set_hexpand(drawingArea_, TRUE);
  gtk_widget_set_vexpand(drawingArea_, TRUE);

  // Enable events
  gtk_widget_add_events(drawingArea_,
                        GDK_BUTTON_PRESS_MASK | GDK_BUTTON_RELEASE_MASK | GDK_POINTER_MOTION_MASK |
                            GDK_SCROLL_MASK | GDK_SMOOTH_SCROLL_MASK | GDK_KEY_PRESS_MASK |
                            GDK_KEY_RELEASE_MASK | GDK_FOCUS_CHANGE_MASK | GDK_ENTER_NOTIFY_MASK |
                            GDK_LEAVE_NOTIFY_MASK);

  // Connect signals
  g_signal_connect(drawingArea_, "draw", G_CALLBACK(OnDrawingAreaDraw), this);
  g_signal_connect(drawingArea_, "realize", G_CALLBACK(OnDrawingAreaRealize), this);
  g_signal_connect(drawingArea_, "button-press-event", G_CALLBACK(OnDrawingAreaButtonPress), this);
  g_signal_connect(drawingArea_, "button-release-event", G_CALLBACK(OnDrawingAreaButtonRelease),
                   this);
  g_signal_connect(drawingArea_, "motion-notify-event", G_CALLBACK(OnDrawingAreaMotionNotify),
                   this);
  g_signal_connect(drawingArea_, "scroll-event", G_CALLBACK(OnDrawingAreaScroll), this);
  g_signal_connect(drawingArea_, "key-press-event", G_CALLBACK(OnDrawingAreaKeyPress), this);
  g_signal_connect(drawingArea_, "key-release-event", G_CALLBACK(OnDrawingAreaKeyRelease), this);
  g_signal_connect(drawingArea_, "size-allocate", G_CALLBACK(OnDrawingAreaSizeAllocate), this);
  g_signal_connect(drawingArea_, "focus-in-event", G_CALLBACK(OnDrawingAreaFocusIn), this);
  g_signal_connect(drawingArea_, "focus-out-event", G_CALLBACK(OnDrawingAreaFocusOut), this);
  g_signal_connect(drawingArea_, "map", G_CALLBACK(OnDrawingAreaMap), this);
  g_signal_connect(drawingArea_, "unmap", G_CALLBACK(OnDrawingAreaUnmap), this);
  g_signal_connect(drawingArea_, "enter-notify-event", G_CALLBACK(OnDrawingAreaEnterNotify), this);
  g_signal_connect(drawingArea_, "leave-notify-event", G_CALLBACK(OnDrawingAreaLeaveNotify), this);

  gtk_box_pack_start(GTK_BOX(contentBox_), drawingArea_, TRUE, TRUE, 0);
  useGlRendering_ = false;
}

void InAppBrowser::setupWebView(const InAppBrowserCreationParams& params) {
  if (messenger_ == nullptr || !FL_IS_BINARY_MESSENGER(messenger_)) {
    errorLog("InAppBrowser::setupWebView - messenger is null or invalid");
    return;
  }

  // Create InAppWebView creation params
  InAppWebViewCreationParams webViewParams;
  webViewParams.plugin = plugin_;
  webViewParams.id = 0;  // Will be set by channel attachment
  webViewParams.gtkWindow = window_;
  webViewParams.initialSettings = params.initialWebViewSettings;
  webViewParams.contextMenu = params.contextMenu;

  if (params.initialUserScripts.has_value()) {
    webViewParams.initialUserScripts = params.initialUserScripts.value();
  }

  // Check for WebViewEnvironment
  if (params.webViewEnvironmentId.has_value() && !params.webViewEnvironmentId->empty()) {
    WebViewEnvironment* webViewEnv = plugin_ ? plugin_->webViewEnvironment : nullptr;
    WebKitWebContext* webContext = nullptr;
    if (webViewEnv != nullptr) {
      webContext = webViewEnv->getWebContext(params.webViewEnvironmentId.value());
    }
    if (webContext != nullptr) {
      webViewParams.webContext = webContext;
    }
  }

  // Create the InAppWebView - pass nullptr for registrar since we have messenger directly
  webView_ = std::make_shared<InAppWebView>(nullptr, messenger_, 0, webViewParams);

  // Attach channel with browser-specific ID
  webView_->AttachChannel(messenger_, METHOD_CHANNEL_NAME_PREFIX + id_, true);

  // Set initial size (will be updated on realize)
  webView_->setSize(800, 600);

  // Set up frame callback - uses GL queue_render for GPU path, scheduleFrame for CPU path
  webView_->SetOnFrameAvailable([this]() {
    if (useGlRendering_ && glArea_ != nullptr) {
      gtk_gl_area_queue_render(GTK_GL_AREA(glArea_));
    } else {
      scheduleFrame();
    }
  });

  // Set up cursor change callback
  webView_->SetOnCursorChanged([this](const std::string& cursorName) {
    OnCursorChanged(cursorName);
  });

  // Set up progress change callback for progress bar
  webView_->SetOnProgressChanged([this](double progress) {
    didChangeProgress(progress);
  });

  // Set up navigation state change callback for back/forward buttons
  webView_->SetOnNavigationStateChanged([this]() {
    didChangeNavigationState();
  });

  // Load initial content
  loadInitialContent(params);
}

void InAppBrowser::loadInitialContent(const InAppBrowserCreationParams& params) {
  if (!webView_) {
    return;
  }

  if (params.urlRequest.has_value()) {
    webView_->loadUrl(params.urlRequest.value());
  } else if (params.assetFilePath.has_value()) {
    webView_->loadFile(params.assetFilePath.value());
  } else if (params.data.has_value()) {
    webView_->loadData(params.data.value(), "text/html", "UTF-8", "");
  }
}

void InAppBrowser::applySettings() {
  if (!settings_) {
    return;
  }

  // Apply visibility
  if (settings_->hideToolbarTop && headerBar_) {
    gtk_widget_hide(headerBar_);
  }

  // Apply window opacity
  gtk_widget_set_opacity(GTK_WIDGET(window_), settings_->windowAlphaValue);
}

void InAppBrowser::close() {
  if (window_ != nullptr && !destroyed_) {
    gtk_window_close(window_);
  }
}

void InAppBrowser::show() {
  if (window_ != nullptr && !destroyed_) {
    gtk_widget_show_all(GTK_WIDGET(window_));
    // Reapply visibility settings
    if (settings_->hideToolbarTop && headerBar_) {
      gtk_widget_hide(headerBar_);
    }
    if (settings_->hideProgressBar && progressBar_) {
      gtk_widget_hide(progressBar_);
    }
  }
}

void InAppBrowser::hide() {
  if (window_ != nullptr && !destroyed_) {
    gtk_widget_hide(GTK_WIDGET(window_));
  }
}

bool InAppBrowser::isHidden() const {
  if (window_ == nullptr || destroyed_) {
    return true;
  }
  return !gtk_widget_is_visible(GTK_WIDGET(window_));
}

void InAppBrowser::setSettings(const std::shared_ptr<InAppBrowserSettings>& newSettings,
                               FlValue* newSettingsMap) {
  if (!newSettings) {
    return;
  }

  // Update WebView settings
  if (webView_ && newSettingsMap != nullptr) {
    webView_->setSettings(std::make_shared<InAppWebViewSettings>(newSettingsMap), newSettingsMap);
  }

  // Handle hidden change
  if (fl_map_contains_not_null(newSettingsMap, "hidden") &&
      settings_->hidden != newSettings->hidden) {
    if (newSettings->hidden) {
      hide();
    } else {
      show();
    }
  }

  // Handle toolbar visibility change
  if (fl_map_contains_not_null(newSettingsMap, "hideToolbarTop") && headerBar_ != nullptr) {
    if (newSettings->hideToolbarTop) {
      gtk_widget_hide(headerBar_);
    } else {
      gtk_widget_show(headerBar_);
    }
  }

  // Handle progress bar visibility
  if (fl_map_contains_not_null(newSettingsMap, "hideProgressBar") && progressBar_ != nullptr) {
    if (newSettings->hideProgressBar) {
      gtk_widget_hide(progressBar_);
    } else {
      gtk_widget_show(progressBar_);
    }
  }

  // Handle title change
  if (fl_map_contains_not_null(newSettingsMap, "toolbarTopFixedTitle") &&
      settings_->toolbarTopFixedTitle != newSettings->toolbarTopFixedTitle) {
    if (!newSettings->toolbarTopFixedTitle.empty()) {
      gtk_window_set_title(window_, newSettings->toolbarTopFixedTitle.c_str());
    }
  }

  // Handle opacity change
  if (fl_map_contains_not_null(newSettingsMap, "windowAlphaValue") &&
      settings_->windowAlphaValue != newSettings->windowAlphaValue) {
    gtk_widget_set_opacity(GTK_WIDGET(window_), newSettings->windowAlphaValue);
  }

  // Handle window frame change
  if (fl_map_contains_not_null(newSettingsMap, "windowFrame") && newSettings->windowFrame) {
    gtk_window_move(window_, static_cast<int>(newSettings->windowFrame->x),
                    static_cast<int>(newSettings->windowFrame->y));
    gtk_window_resize(window_, static_cast<int>(newSettings->windowFrame->width),
                      static_cast<int>(newSettings->windowFrame->height));
  }

  settings_ = newSettings;
}

FlValue* InAppBrowser::getSettings() const {
  if (!settings_) {
    return fl_value_new_null();
  }

  FlValue* settingsMap = settings_->getRealSettings(this);

  // Merge with WebView settings
  if (webView_) {
    FlValue* webViewSettings = webView_->getSettings();
    if (webViewSettings != nullptr && fl_value_get_type(webViewSettings) == FL_VALUE_TYPE_MAP) {
      size_t len = fl_value_get_length(webViewSettings);
      for (size_t i = 0; i < len; i++) {
        FlValue* key = fl_value_get_map_key(webViewSettings, i);
        FlValue* value = fl_value_get_map_value(webViewSettings, i);
        if (fl_value_get_type(key) == FL_VALUE_TYPE_STRING) {
          fl_value_set_string_take(settingsMap, fl_value_get_string(key), fl_value_ref(value));
        }
      }
    }
  }

  return settingsMap;
}

void InAppBrowser::didChangeTitle(const std::optional<std::string>& title) {
  if (title.has_value() && settings_->toolbarTopFixedTitle.empty()) {
    updateTitle(title.value());
  }
}

void InAppBrowser::didChangeUrl(const std::optional<std::string>& url) {
  if (url.has_value()) {
    updateUrlEntry(url.value());
  }
  updateNavigationButtons();
}

void InAppBrowser::didChangeProgress(double progress) {
  updateProgressBar(progress);
}

void InAppBrowser::didChangeNavigationState() {
  updateNavigationButtons();
}

void InAppBrowser::updateNavigationButtons() {
  if (!webView_) {
    return;
  }

  if (backButton_ != nullptr) {
    gtk_widget_set_sensitive(backButton_, webView_->canGoBack());
  }
  if (forwardButton_ != nullptr) {
    gtk_widget_set_sensitive(forwardButton_, webView_->canGoForward());
  }
}

void InAppBrowser::updateProgressBar(double progress) {
  if (progressBar_ == nullptr) {
    return;
  }

  gtk_progress_bar_set_fraction(GTK_PROGRESS_BAR(progressBar_), progress);

  // Hide progress bar when complete
  if (progress >= 1.0) {
    gtk_widget_hide(progressBar_);
  } else if (!settings_->hideProgressBar) {
    gtk_widget_show(progressBar_);
  }
}

void InAppBrowser::updateUrlEntry(const std::string& url) {
  if (urlEntry_ != nullptr) {
    gtk_entry_set_text(GTK_ENTRY(urlEntry_), url.c_str());
  }
}

void InAppBrowser::updateTitle(const std::string& title) {
  if (window_ != nullptr && !destroyed_) {
    gtk_window_set_title(window_, title.c_str());
  }
}

void InAppBrowser::scheduleFrame() {
  if (destroyed_ || frameSourceId_ != 0) {
    return;
  }
  frameSourceId_ = g_idle_add(OnFrameCallback, this);
}

gboolean InAppBrowser::OnFrameCallback(gpointer user_data) {
  auto* browser = static_cast<InAppBrowser*>(user_data);
  if (browser && !browser->destroyed_) {
    browser->frameSourceId_ = 0;
    // This callback is only used for the CPU rendering path (GtkDrawingArea)
    if (browser->drawingArea_ != nullptr) {
      gtk_widget_queue_draw(browser->drawingArea_);
    }
  } else if (browser) {
    browser->frameSourceId_ = 0;
  }
  return G_SOURCE_REMOVE;
}

// Convert GDK modifier flags to WPE modifier flags
// GDK: Shift=1, Lock=2, Control=4, Mod1(Alt)=8, Mod4(Super)=64
// WPE: Control=1, Shift=2, Alt=4, Meta=8
static int ConvertGdkModifiersToWpe(guint gdkState) {
  int wpeModifiers = 0;
  if (gdkState & GDK_CONTROL_MASK)  // GDK bit 2 -> WPE bit 0
    wpeModifiers |= 1;
  if (gdkState & GDK_SHIFT_MASK)    // GDK bit 0 -> WPE bit 1
    wpeModifiers |= 2;
  if (gdkState & GDK_MOD1_MASK)     // GDK bit 3 (Alt) -> WPE bit 2
    wpeModifiers |= 4;
  if (gdkState & GDK_MOD4_MASK)     // GDK bit 6 (Super/Meta) -> WPE bit 3
    wpeModifiers |= 8;
  return wpeModifiers;
}

// Convert RGBA to BGRA for Cairo ARGB32 format (which is BGRA on little-endian)
static void ConvertRGBAToBGRA(uint8_t* buffer, size_t size) {
  // Process 4 bytes at a time (one pixel: RGBA -> BGRA)
  for (size_t i = 0; i + 3 < size; i += 4) {
    // Swap R and B channels
    uint8_t r = buffer[i];
    buffer[i] = buffer[i + 2];     // B
    buffer[i + 2] = r;              // R
    // G and A stay in place
  }
}

// GTK Signal handlers

void InAppBrowser::OnWindowDestroy(GtkWidget* widget, gpointer user_data) {
  auto* browser = static_cast<InAppBrowser*>(user_data);
  if (browser && !browser->destroyed_) {
    // Notify Dart about exit
    if (browser->channelDelegate_) {
      browser->channelDelegate_->onExit();
    }

    // Remove from manager
    if (browser->manager_) {
      browser->manager_->removeBrowser(browser->id_);
    }
  }
}

gboolean InAppBrowser::OnWindowDeleteEvent(GtkWidget* widget, GdkEvent* event, gpointer user_data) {
  // Allow the window to be destroyed
  return FALSE;
}

void InAppBrowser::OnBackClicked(GtkButton* button, gpointer user_data) {
  auto* browser = static_cast<InAppBrowser*>(user_data);
  if (browser && browser->webView_) {
    browser->webView_->goBack();
  }
}

void InAppBrowser::OnForwardClicked(GtkButton* button, gpointer user_data) {
  auto* browser = static_cast<InAppBrowser*>(user_data);
  if (browser && browser->webView_) {
    browser->webView_->goForward();
  }
}

void InAppBrowser::OnReloadClicked(GtkButton* button, gpointer user_data) {
  auto* browser = static_cast<InAppBrowser*>(user_data);
  if (browser && browser->webView_) {
    browser->webView_->reload();
  }
}

void InAppBrowser::OnUrlEntryActivated(GtkEntry* entry, gpointer user_data) {
  auto* browser = static_cast<InAppBrowser*>(user_data);
  if (browser && browser->webView_) {
    const gchar* text = gtk_entry_get_text(entry);
    if (text != nullptr && strlen(text) > 0) {
      std::string url(text);
      // Add http:// if no scheme specified
      if (url.find("://") == std::string::npos) {
        url = "https://" + url;
      }
      browser->webView_->loadUrl(url);
    }
  }
}

gboolean InAppBrowser::OnDrawingAreaDraw(GtkWidget* widget, cairo_t* cr, gpointer user_data) {
  auto* browser = static_cast<InAppBrowser*>(user_data);
  if (!browser || browser->destroyed_ || !browser->webView_) {
    return FALSE;
  }

  // Get the pixel buffer from WebView
  uint32_t width = 0, height = 0;
  size_t bufferSize = browser->webView_->GetPixelBufferSize(&width, &height);

  if (bufferSize == 0 || width == 0 || height == 0) {
    // Fill with white background when no content
    cairo_set_source_rgb(cr, 1.0, 1.0, 1.0);
    cairo_paint(cr);
    return TRUE;
  }

  // Allocate buffer and copy pixels
  std::vector<uint8_t> buffer(bufferSize);
  if (!browser->webView_->CopyPixelBufferTo(buffer.data(), bufferSize, &width, &height)) {
    return FALSE;
  }

  // Convert RGBA to BGRA for Cairo
  ConvertRGBAToBGRA(buffer.data(), bufferSize);

  // Create Cairo surface from pixel buffer (BGRA format)
  cairo_surface_t* surface = cairo_image_surface_create_for_data(
      buffer.data(), CAIRO_FORMAT_ARGB32, width, height, width * 4);

  if (cairo_surface_status(surface) == CAIRO_STATUS_SUCCESS) {
    // Scale to fit drawing area
    GtkAllocation alloc;
    gtk_widget_get_allocation(widget, &alloc);

    double scaleX = static_cast<double>(alloc.width) / width;
    double scaleY = static_cast<double>(alloc.height) / height;

    cairo_scale(cr, scaleX, scaleY);
    cairo_set_source_surface(cr, surface, 0, 0);
    cairo_paint(cr);
  }

  cairo_surface_destroy(surface);
  return TRUE;
}

void InAppBrowser::OnDrawingAreaRealize(GtkWidget* widget, gpointer user_data) {
  auto* browser = static_cast<InAppBrowser*>(user_data);
  if (browser && browser->webView_) {
    GtkAllocation alloc;
    gtk_widget_get_allocation(widget, &alloc);
    browser->webView_->setSize(alloc.width, alloc.height);
  }
}

gboolean InAppBrowser::OnDrawingAreaButtonPress(GtkWidget* widget, GdkEventButton* event,
                                                gpointer user_data) {
  auto* browser = static_cast<InAppBrowser*>(user_data);
  if (!browser || !browser->webView_) {
    return FALSE;
  }

  gtk_widget_grab_focus(widget);

  int button = 0;
  switch (event->button) {
    case 1:
      button = 1;
      break;  // Primary
    case 2:
      button = 3;
      break;  // Tertiary (middle)
    case 3:
      button = 2;
      break;  // Secondary (right)
    default:
      button = static_cast<int>(event->button);
  }

  browser->webView_->SetCursorPos(event->x, event->y);
  browser->webView_->SetPointerButton(1, button, 1);  // Down
  return TRUE;
}

gboolean InAppBrowser::OnDrawingAreaButtonRelease(GtkWidget* widget, GdkEventButton* event,
                                                  gpointer user_data) {
  auto* browser = static_cast<InAppBrowser*>(user_data);
  if (!browser || !browser->webView_) {
    return FALSE;
  }

  int button = 0;
  switch (event->button) {
    case 1:
      button = 1;
      break;
    case 2:
      button = 3;
      break;
    case 3:
      button = 2;
      break;
    default:
      button = static_cast<int>(event->button);
  }

  browser->webView_->SetCursorPos(event->x, event->y);
  browser->webView_->SetPointerButton(4, button, 1);  // Up
  return TRUE;
}

gboolean InAppBrowser::OnDrawingAreaMotionNotify(GtkWidget* widget, GdkEventMotion* event,
                                                 gpointer user_data) {
  auto* browser = static_cast<InAppBrowser*>(user_data);
  if (!browser || !browser->webView_) {
    return FALSE;
  }

  browser->webView_->SetCursorPos(event->x, event->y);
  browser->webView_->SetPointerButton(5, 0, 0);  // Update (motion)
  return TRUE;
}

gboolean InAppBrowser::OnDrawingAreaScroll(GtkWidget* widget, GdkEventScroll* event,
                                           gpointer user_data) {
  auto* browser = static_cast<InAppBrowser*>(user_data);
  if (!browser || !browser->webView_) {
    return FALSE;
  }

  double dx = 0, dy = 0;

  if (event->direction == GDK_SCROLL_SMOOTH) {
    dx = event->delta_x * -53.0;
    dy = event->delta_y * -53.0;
  } else {
    switch (event->direction) {
      case GDK_SCROLL_UP:
        dy = 53.0;
        break;
      case GDK_SCROLL_DOWN:
        dy = -53.0;
        break;
      case GDK_SCROLL_LEFT:
        dx = 53.0;
        break;
      case GDK_SCROLL_RIGHT:
        dx = -53.0;
        break;
      default:
        break;
    }
  }

  browser->webView_->SetScrollDelta(dx, dy);
  return TRUE;
}

gboolean InAppBrowser::OnDrawingAreaKeyPress(GtkWidget* widget, GdkEventKey* event,
                                             gpointer user_data) {
  auto* browser = static_cast<InAppBrowser*>(user_data);
  if (!browser || !browser->webView_) {
    return FALSE;
  }

  std::string characters;
  if (event->string != nullptr && event->string[0] != '\0') {
    characters = event->string;
  }

  // Convert GDK modifiers to WPE format
  int wpeModifiers = ConvertGdkModifiersToWpe(event->state);

  // type: 0=down, 1=up for WPE
  browser->webView_->SendKeyEvent(0, event->keyval, event->hardware_keycode, wpeModifiers,
                                  characters);
  return TRUE;
}

gboolean InAppBrowser::OnDrawingAreaKeyRelease(GtkWidget* widget, GdkEventKey* event,
                                               gpointer user_data) {
  auto* browser = static_cast<InAppBrowser*>(user_data);
  if (!browser || !browser->webView_) {
    return FALSE;
  }

  // Convert GDK modifiers to WPE format
  int wpeModifiers = ConvertGdkModifiersToWpe(event->state);

  // type: 0=down, 1=up for WPE
  browser->webView_->SendKeyEvent(1, event->keyval, event->hardware_keycode, wpeModifiers, "");
  return TRUE;
}

void InAppBrowser::OnMenuItemActivated(GtkMenuItem* item, gpointer user_data) {
  auto* browser = static_cast<InAppBrowser*>(user_data);
  if (browser && browser->channelDelegate_) {
    int32_t menuItemId = GPOINTER_TO_INT(g_object_get_data(G_OBJECT(item), "menu-item-id"));
    browser->channelDelegate_->onMenuItemClicked(menuItemId);
  }
}

void InAppBrowser::OnDrawingAreaSizeAllocate(GtkWidget* widget, GdkRectangle* allocation,
                                              gpointer user_data) {
  auto* browser = static_cast<InAppBrowser*>(user_data);
  if (browser && browser->webView_ && allocation) {
    browser->webView_->setSize(allocation->width, allocation->height);
  }
}

gboolean InAppBrowser::OnDrawingAreaFocusIn(GtkWidget* widget, GdkEventFocus* event,
                                             gpointer user_data) {
  auto* browser = static_cast<InAppBrowser*>(user_data);
  if (browser && browser->webView_) {
    browser->webView_->setFocused(true);
  }
  return FALSE;
}

gboolean InAppBrowser::OnDrawingAreaFocusOut(GtkWidget* widget, GdkEventFocus* event,
                                              gpointer user_data) {
  auto* browser = static_cast<InAppBrowser*>(user_data);
  if (browser && browser->webView_) {
    browser->webView_->setFocused(false);
  }
  return FALSE;
}

void InAppBrowser::OnDrawingAreaMap(GtkWidget* widget, gpointer user_data) {
  auto* browser = static_cast<InAppBrowser*>(user_data);
  if (browser && browser->webView_) {
    browser->webView_->setVisible(true);
  }
}

void InAppBrowser::OnDrawingAreaUnmap(GtkWidget* widget, gpointer user_data) {
  auto* browser = static_cast<InAppBrowser*>(user_data);
  if (browser && browser->webView_) {
    browser->webView_->setVisible(false);
  }
}

gboolean InAppBrowser::OnDrawingAreaEnterNotify(GtkWidget* widget, GdkEventCrossing* event,
                                                 gpointer user_data) {
  // Mouse entered the drawing area - no special action needed
  return FALSE;
}

gboolean InAppBrowser::OnDrawingAreaLeaveNotify(GtkWidget* widget, GdkEventCrossing* event,
                                                 gpointer user_data) {
  auto* browser = static_cast<InAppBrowser*>(user_data);
  if (browser) {
    // Reset cursor to default when leaving the drawing area
    GdkWindow* gdkWindow = gtk_widget_get_window(widget);
    if (gdkWindow) {
      gdk_window_set_cursor(gdkWindow, nullptr);
    }
    if (browser->currentCursor_ != nullptr) {
      g_object_unref(browser->currentCursor_);
      browser->currentCursor_ = nullptr;
    }
  }
  return FALSE;
}

// === GtkGLArea Signal Handlers for GPU-Accelerated Rendering ===

void InAppBrowser::OnGlAreaRealize(GtkGLArea* area, gpointer user_data) {
  auto* browser = static_cast<InAppBrowser*>(user_data);

  gtk_gl_area_make_current(area);
  GError* error = gtk_gl_area_get_error(area);
  if (error != nullptr) {
    errorLog("InAppBrowser: GtkGLArea error during realize: %s", error->message);
    return;
  }

  // Create texture for EGL image binding
  glGenTextures(1, &browser->glTexture_);

  // === Shader-based rendering setup (OpenGL ES compatible) ===
  // Vertex shader - transforms position and passes texture coords
  const char* vertexSource =
      "#version 100\n"
      "attribute vec2 position;\n"
      "attribute vec2 texture;\n"
      "varying vec2 v_texture;\n"
      "void main() {\n"
      "  v_texture = texture;\n"
      "  gl_Position = vec4(position, 0.0, 1.0);\n"
      "}\n";

  // Fragment shader - samples texture
  const char* fragmentSource =
      "#version 100\n"
      "precision mediump float;\n"
      "uniform sampler2D u_texture;\n"
      "varying vec2 v_texture;\n"
      "void main() {\n"
      "  gl_FragColor = texture2D(u_texture, v_texture);\n"
      "}\n";

  // Compile vertex shader
  GLuint vertexShader = glCreateShader(GL_VERTEX_SHADER);
  glShaderSource(vertexShader, 1, &vertexSource, nullptr);
  glCompileShader(vertexShader);

  GLint compiled = 0;
  glGetShaderiv(vertexShader, GL_COMPILE_STATUS, &compiled);
  if (!compiled) {
    GLchar infoLog[512];
    glGetShaderInfoLog(vertexShader, 512, nullptr, infoLog);
    errorLog("InAppBrowser: Vertex shader compilation failed: %s", infoLog);
    glDeleteShader(vertexShader);
    return;
  }

  // Compile fragment shader
  GLuint fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
  glShaderSource(fragmentShader, 1, &fragmentSource, nullptr);
  glCompileShader(fragmentShader);

  glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, &compiled);
  if (!compiled) {
    GLchar infoLog[512];
    glGetShaderInfoLog(fragmentShader, 512, nullptr, infoLog);
    errorLog("InAppBrowser: Fragment shader compilation failed: %s", infoLog);
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
    return;
  }

  // Create and link program
  browser->glProgram_ = glCreateProgram();
  glAttachShader(browser->glProgram_, vertexShader);
  glAttachShader(browser->glProgram_, fragmentShader);
  glLinkProgram(browser->glProgram_);

  GLint linked = 0;
  glGetProgramiv(browser->glProgram_, GL_LINK_STATUS, &linked);
  if (!linked) {
    GLchar infoLog[512];
    glGetProgramInfoLog(browser->glProgram_, 512, nullptr, infoLog);
    errorLog("InAppBrowser: Shader program linking failed: %s", infoLog);
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
    glDeleteProgram(browser->glProgram_);
    browser->glProgram_ = 0;
    return;
  }

  // Shaders are linked into program, can delete them now
  glDeleteShader(vertexShader);
  glDeleteShader(fragmentShader);

  // Get attribute and uniform locations
  browser->glAttribPosition_ = glGetAttribLocation(browser->glProgram_, "position");
  browser->glAttribTexture_ = glGetAttribLocation(browser->glProgram_, "texture");
  browser->glUniformTexture_ = glGetUniformLocation(browser->glProgram_, "u_texture");

  // Create VBO with fullscreen quad vertex data (matching COG's layout)
  // Non-interleaved: positions first, then texture coords
  // Position (NDC): forms a quad covering -1 to 1 in both axes using TRIANGLE_STRIP
  // Order: top-left, top-right, bottom-left, bottom-right
  static const GLfloat vertexData[] = {
      // Positions (8 floats)
      -1.0f,  1.0f,  // Top-left
       1.0f,  1.0f,  // Top-right
      -1.0f, -1.0f,  // Bottom-left
       1.0f, -1.0f,  // Bottom-right
      // Texture coordinates (8 floats) - Y flipped for correct orientation
       0.0f,  0.0f,  // Top-left
       1.0f,  0.0f,  // Top-right
       0.0f,  1.0f,  // Bottom-left
       1.0f,  1.0f,  // Bottom-right
  };

  glGenBuffers(1, &browser->glVBO_);
  glBindBuffer(GL_ARRAY_BUFFER, browser->glVBO_);
  glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW);
  glBindBuffer(GL_ARRAY_BUFFER, 0);
  browser->glInitialized_ = true;

  // Set initial size
  GtkAllocation alloc;
  gtk_widget_get_allocation(GTK_WIDGET(area), &alloc);
  if (browser->webView_) {
    browser->webView_->setSize(alloc.width, alloc.height);
  }
}

gboolean InAppBrowser::OnGlAreaRender(GtkGLArea* area, GdkGLContext* context,
                                       gpointer user_data) {
  auto* browser = static_cast<InAppBrowser*>(user_data);

  if (!browser || browser->destroyed_ || !browser->webView_ || !browser->glInitialized_) {
    return FALSE;
  }

  // Clear the framebuffer with white background
  glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
  glClear(GL_COLOR_BUFFER_BIT);

  // Get viewport dimensions - need to account for device scale factor
  GtkAllocation alloc;
  gtk_widget_get_allocation(GTK_WIDGET(area), &alloc);
  gint scaleFactor = gtk_widget_get_scale_factor(GTK_WIDGET(area));
  
  // For high-DPI displays, the actual framebuffer is larger
  int fbWidth = alloc.width * scaleFactor;
  int fbHeight = alloc.height * scaleFactor;
  
  glViewport(0, 0, fbWidth, fbHeight);

  // Try to get EGL image for zero-copy rendering
  uint32_t imgWidth = 0, imgHeight = 0;
  void* eglImage = browser->webView_->GetCurrentEglImage(&imgWidth, &imgHeight);

  if (eglImage != nullptr && imgWidth > 0 && imgHeight > 0) {
    // Get the glEGLImageTargetTexture2DOES function
    static PFNGLEGLIMAGETARGETTEXTURE2DOESPROC glEGLImageTargetTexture2DOES =
        (PFNGLEGLIMAGETARGETTEXTURE2DOESPROC)eglGetProcAddress("glEGLImageTargetTexture2DOES");

    if (glEGLImageTargetTexture2DOES != nullptr && browser->glProgram_ != 0) {
      // Zero-copy path: bind EGL image directly as GL texture
      glActiveTexture(GL_TEXTURE0);
      glBindTexture(GL_TEXTURE_2D, browser->glTexture_);
      glEGLImageTargetTexture2DOES(GL_TEXTURE_2D, static_cast<GLeglImageOES>(eglImage));

      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

      // Use shader program for rendering
      glUseProgram(browser->glProgram_);
      glUniform1i(browser->glUniformTexture_, 0);

      // Bind VBO and set up vertex attributes (non-interleaved layout)
      glBindBuffer(GL_ARRAY_BUFFER, browser->glVBO_);

      // Position attribute: 2 floats, stride 0 (tightly packed), offset 0
      glVertexAttribPointer(browser->glAttribPosition_, 2, GL_FLOAT, GL_FALSE,
                            0, (void*)0);
      glEnableVertexAttribArray(browser->glAttribPosition_);

      // Texture attribute: 2 floats, stride 0, offset = 4 positions * 2 floats = 8 floats
      glVertexAttribPointer(browser->glAttribTexture_, 2, GL_FLOAT, GL_FALSE,
                            0, (void*)(8 * sizeof(GLfloat)));
      glEnableVertexAttribArray(browser->glAttribTexture_);

      // Draw fullscreen quad as triangle strip
      glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);



      // Cleanup state
      glDisableVertexAttribArray(browser->glAttribPosition_);
      glDisableVertexAttribArray(browser->glAttribTexture_);
      glBindBuffer(GL_ARRAY_BUFFER, 0);
      glBindTexture(GL_TEXTURE_2D, 0);
      glUseProgram(0);

      return TRUE;
    }
  }

  // Fallback: use pixel buffer rendering
  return browser->RenderFromPixelBuffer(area);
}

void InAppBrowser::OnGlAreaResize(GtkGLArea* area, gint width, gint height,
                                   gpointer user_data) {
  auto* browser = static_cast<InAppBrowser*>(user_data);
  if (browser && browser->webView_ && width > 0 && height > 0) {
    // GtkGLArea resize signal provides physical pixel dimensions
    // WebView needs logical dimensions, so divide by scale factor
    gint scaleFactor = gtk_widget_get_scale_factor(GTK_WIDGET(area));
    gint logicalWidth = width / scaleFactor;
    gint logicalHeight = height / scaleFactor;
    // Set scale factor for HiDPI rendering - WebView will render at physical resolution
    browser->webView_->setScaleFactor(static_cast<double>(scaleFactor));
    browser->webView_->setSize(logicalWidth, logicalHeight);
  }
}

void InAppBrowser::OnGlAreaSizeAllocate(GtkWidget* widget, GdkRectangle* allocation,
                                         gpointer user_data) {
  auto* browser = static_cast<InAppBrowser*>(user_data);
  if (browser && browser->webView_ && allocation) {
    if (allocation->width > 0 && allocation->height > 0) {
      // size-allocate gives logical dimensions, which is what WebView needs
      // Also set scale factor for HiDPI rendering
      gint scaleFactor = gtk_widget_get_scale_factor(widget);
      browser->webView_->setScaleFactor(static_cast<double>(scaleFactor));
      browser->webView_->setSize(allocation->width, allocation->height);
      // Queue a redraw to ensure the GL content is re-rendered at new size
      if (browser->glArea_ != nullptr) {
        gtk_gl_area_queue_render(GTK_GL_AREA(browser->glArea_));
      }
    }
  }
}

gboolean InAppBrowser::RenderFromPixelBuffer(GtkGLArea* area) {
  // Fallback: upload pixel buffer to texture and render
  // This handles SHM mode where EGL images aren't available

  if (!webView_ || !glInitialized_ || glProgram_ == 0) {
    return TRUE;  // Nothing to render, but handled
  }

  uint32_t width = 0, height = 0;
  size_t bufferSize = webView_->GetPixelBufferSize(&width, &height);

  if (bufferSize == 0 || width == 0 || height == 0) {
    return TRUE;  // Nothing to render
  }

  std::vector<uint8_t> buffer(bufferSize);
  if (!webView_->CopyPixelBufferTo(buffer.data(), bufferSize, &width, &height)) {
    return FALSE;
  }

  // Get viewport dimensions - account for device scale factor
  GtkAllocation alloc;
  gtk_widget_get_allocation(GTK_WIDGET(area), &alloc);
  gint scaleFactor = gtk_widget_get_scale_factor(GTK_WIDGET(area));
  int fbWidth = alloc.width * scaleFactor;
  int fbHeight = alloc.height * scaleFactor;
  
  glViewport(0, 0, fbWidth, fbHeight);

  // Upload pixel buffer to texture
  glActiveTexture(GL_TEXTURE0);
  glBindTexture(GL_TEXTURE_2D, glTexture_);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0,
               GL_RGBA, GL_UNSIGNED_BYTE, buffer.data());

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

  // Use shader program for rendering
  glUseProgram(glProgram_);
  glUniform1i(glUniformTexture_, 0);

  // Bind VBO and set up vertex attributes (non-interleaved layout)
  glBindBuffer(GL_ARRAY_BUFFER, glVBO_);

  // Position attribute: 2 floats, stride 0 (tightly packed), offset 0
  glVertexAttribPointer(glAttribPosition_, 2, GL_FLOAT, GL_FALSE,
                        0, (void*)0);
  glEnableVertexAttribArray(glAttribPosition_);

  // Texture attribute: 2 floats, stride 0, offset = 4 positions * 2 floats = 8 floats
  glVertexAttribPointer(glAttribTexture_, 2, GL_FLOAT, GL_FALSE,
                        0, (void*)(8 * sizeof(GLfloat)));
  glEnableVertexAttribArray(glAttribTexture_);

  // Draw fullscreen quad as triangle strip
  glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

  // Cleanup state
  glDisableVertexAttribArray(glAttribPosition_);
  glDisableVertexAttribArray(glAttribTexture_);
  glBindBuffer(GL_ARRAY_BUFFER, 0);
  glBindTexture(GL_TEXTURE_2D, 0);
  glUseProgram(0);

  return TRUE;
}

void InAppBrowser::OnCursorChanged(const std::string& cursorName) {
  // Handle cursor changes for both GL area and drawing area
  GtkWidget* targetWidget = useGlRendering_ ? glArea_ : drawingArea_;
  if (destroyed_ || targetWidget == nullptr) {
    return;
  }

  GdkWindow* gdkWindow = gtk_widget_get_window(targetWidget);
  if (!gdkWindow) {
    return;
  }

  // Clean up previous cursor
  if (currentCursor_ != nullptr) {
    g_object_unref(currentCursor_);
    currentCursor_ = nullptr;
  }

  if (cursorName == "none") {
    currentCursor_ = gdk_cursor_new_for_display(gdk_display_get_default(), GDK_BLANK_CURSOR);
    gdk_window_set_cursor(gdkWindow, currentCursor_);
    return;
  }

  // Use gdk_cursor_new_from_name which accepts CSS cursor names (GTK 3.16+)
  GdkDisplay* display = gdk_display_get_default();
  currentCursor_ = gdk_cursor_new_from_name(display, cursorName.c_str());

  // Fallback if cursor name not recognized
  if (!currentCursor_) {
    currentCursor_ = gdk_cursor_new_from_name(display, "default");
  }

  // Ultimate fallback to GDK_LEFT_PTR
  if (!currentCursor_) {
    currentCursor_ = gdk_cursor_new_for_display(display, GDK_LEFT_PTR);
  }

  gdk_window_set_cursor(gdkWindow, currentCursor_);
}

}  // namespace flutter_inappwebview_plugin
