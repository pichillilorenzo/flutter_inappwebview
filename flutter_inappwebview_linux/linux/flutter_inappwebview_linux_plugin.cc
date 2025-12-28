#include "include/flutter_inappwebview_linux/flutter_inappwebview_linux_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>

#include <cstring>
#include <memory>

#include "cookie_manager.h"
#include "in_app_webview/in_app_webview_manager.h"

#define FLUTTER_INAPPWEBVIEW_LINUX_PLUGIN(obj)                              \
  (G_TYPE_CHECK_INSTANCE_CAST((obj),                                        \
                              flutter_inappwebview_linux_plugin_get_type(), \
                              FlutterInappwebviewLinuxPlugin))

struct _FlutterInappwebviewLinuxPlugin {
  GObject parent_instance;
  FlPluginRegistrar* registrar;
  std::unique_ptr<flutter_inappwebview_plugin::InAppWebViewManager>
      in_app_webview_manager;
  std::unique_ptr<flutter_inappwebview_plugin::CookieManager>
      cookie_manager;
};

G_DEFINE_TYPE(FlutterInappwebviewLinuxPlugin,
              flutter_inappwebview_linux_plugin, g_object_get_type())

static void flutter_inappwebview_linux_plugin_dispose(GObject* object) {
  FlutterInappwebviewLinuxPlugin* self =
      FLUTTER_INAPPWEBVIEW_LINUX_PLUGIN(object);

  // Clean up the managers
  self->in_app_webview_manager.reset();
  self->cookie_manager.reset();

  G_OBJECT_CLASS(flutter_inappwebview_linux_plugin_parent_class)
      ->dispose(object);
}

static void flutter_inappwebview_linux_plugin_class_init(
    FlutterInappwebviewLinuxPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = flutter_inappwebview_linux_plugin_dispose;
}

static void flutter_inappwebview_linux_plugin_init(
    FlutterInappwebviewLinuxPlugin* self) {
  self->registrar = nullptr;
  // Note: in_app_webview_manager is initialized by its default constructor
}

void flutter_inappwebview_linux_plugin_register_with_registrar(
    FlPluginRegistrar* registrar) {
  FlutterInappwebviewLinuxPlugin* plugin = FLUTTER_INAPPWEBVIEW_LINUX_PLUGIN(
      g_object_new(flutter_inappwebview_linux_plugin_get_type(), nullptr));

  plugin->registrar = registrar;

  // Create the InAppWebViewManager
  plugin->in_app_webview_manager =
      std::make_unique<flutter_inappwebview_plugin::InAppWebViewManager>(
          registrar);

  // Create the CookieManager
  plugin->cookie_manager =
      std::make_unique<flutter_inappwebview_plugin::CookieManager>(registrar);

  // Note: We don't unref the plugin here as it needs to stay alive
  // for the lifetime of the application
  g_object_ref(plugin);
}
