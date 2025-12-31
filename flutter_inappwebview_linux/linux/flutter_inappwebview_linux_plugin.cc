#include "include/flutter_inappwebview_linux/flutter_inappwebview_linux_plugin.h"

#include "flutter_inappwebview_linux_plugin_private.h"

#include <flutter_linux/flutter_linux.h>
#include <gdk/gdk.h>
#include <gtk/gtk.h>

#include <cstring>
#include <memory>

#include "cookie_manager.h"
#include "in_app_webview/in_app_webview_manager.h"

#define FLUTTER_INAPPWEBVIEW_LINUX_PLUGIN(obj)                                     \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), flutter_inappwebview_linux_plugin_get_type(), \
                              FlutterInappwebviewLinuxPlugin))

struct _FlutterInappwebviewLinuxPlugin {
  GObject parent_instance;
  FlPluginRegistrar* registrar;
  std::unique_ptr<flutter_inappwebview_plugin::InAppWebViewManager> in_app_webview_manager;
  std::unique_ptr<flutter_inappwebview_plugin::CookieManager> cookie_manager;
};

G_DEFINE_TYPE(FlutterInappwebviewLinuxPlugin, flutter_inappwebview_linux_plugin,
              g_object_get_type())

static void flutter_inappwebview_linux_plugin_dispose(GObject* object) {
  FlutterInappwebviewLinuxPlugin* self = FLUTTER_INAPPWEBVIEW_LINUX_PLUGIN(object);

  // Clean up the managers
  self->in_app_webview_manager.reset();
  self->cookie_manager.reset();

  G_OBJECT_CLASS(flutter_inappwebview_linux_plugin_parent_class)->dispose(object);
}

static void flutter_inappwebview_linux_plugin_class_init(
    FlutterInappwebviewLinuxPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = flutter_inappwebview_linux_plugin_dispose;
}

static void flutter_inappwebview_linux_plugin_init(FlutterInappwebviewLinuxPlugin* self) {
  self->registrar = nullptr;
  // Note: in_app_webview_manager is initialized by its default constructor
}

void flutter_inappwebview_linux_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  FlutterInappwebviewLinuxPlugin* plugin = FLUTTER_INAPPWEBVIEW_LINUX_PLUGIN(
      g_object_new(flutter_inappwebview_linux_plugin_get_type(), nullptr));

  plugin->registrar = registrar;

  // Create the InAppWebViewManager
  plugin->in_app_webview_manager =
      std::make_unique<flutter_inappwebview_plugin::InAppWebViewManager>(registrar);

  // Create the CookieManager
  plugin->cookie_manager = std::make_unique<flutter_inappwebview_plugin::CookieManager>(registrar);

  // Note: We don't unref the plugin here as it needs to stay alive
  // for the lifetime of the application
  g_object_ref(plugin);
}

// === Helper functions for accessing Flutter view and window ===

FlView* flutter_inappwebview_linux_plugin_get_view(FlPluginRegistrar* registrar) {
  if (registrar == nullptr) {
    return nullptr;
  }
  return fl_plugin_registrar_get_view(registrar);
}

GtkWindow* flutter_inappwebview_linux_plugin_get_window(FlPluginRegistrar* registrar) {
  FlView* view = flutter_inappwebview_linux_plugin_get_view(registrar);
  if (view == nullptr) {
    return nullptr;
  }

  GtkWidget* widget = GTK_WIDGET(view);
  if (widget == nullptr) {
    return nullptr;
  }

  GtkWidget* toplevel = gtk_widget_get_toplevel(widget);
  if (toplevel == nullptr || !GTK_IS_WINDOW(toplevel)) {
    return nullptr;
  }

  return GTK_WINDOW(toplevel);
}

int flutter_inappwebview_linux_plugin_get_monitor_refresh_rate(FlPluginRegistrar* registrar) {
  GtkWindow* window = flutter_inappwebview_linux_plugin_get_window(registrar);
  return flutter_inappwebview_linux_plugin_get_monitor_refresh_rate_for_window(window);
}

int flutter_inappwebview_linux_plugin_get_monitor_refresh_rate_for_window(GtkWindow* window) {
  if (window == nullptr) {
    return 0;
  }

  GdkWindow* gdk_window = gtk_widget_get_window(GTK_WIDGET(window));
  if (gdk_window == nullptr) {
    return 0;
  }

  GdkDisplay* display = gdk_display_get_default();
  if (display == nullptr) {
    return 0;
  }

  GdkMonitor* monitor = gdk_display_get_monitor_at_window(display, gdk_window);
  if (monitor == nullptr) {
    return 0;
  }

  // gdk_monitor_get_refresh_rate returns the refresh rate in millihertz
  // (e.g., 60000 for 60 Hz)
  return gdk_monitor_get_refresh_rate(monitor);
}

