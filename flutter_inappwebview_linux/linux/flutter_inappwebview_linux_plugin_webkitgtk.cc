#ifndef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_IMPL
#endif
#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>

#include <memory>

#include "include/flutter_inappwebview_linux/flutter_inappwebview_linux_plugin.h"
#include "webkitgtk/webkitgtk_manager.h"

// GObject plugin struct
struct _FlutterInappwebviewLinuxPlugin {
  GObject parent_instance;
  std::unique_ptr<flutter_inappwebview_webkit::WebKitGTKManager> manager;
};

G_DEFINE_TYPE(FlutterInappwebviewLinuxPlugin, flutter_inappwebview_linux_plugin, G_TYPE_OBJECT)

static void flutter_inappwebview_linux_plugin_dispose(GObject* object) {
  FlutterInappwebviewLinuxPlugin* self = reinterpret_cast<FlutterInappwebviewLinuxPlugin*>(object);
  self->manager.reset();
  G_OBJECT_CLASS(flutter_inappwebview_linux_plugin_parent_class)->dispose(object);
}

static void flutter_inappwebview_linux_plugin_class_init(
    FlutterInappwebviewLinuxPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = flutter_inappwebview_linux_plugin_dispose;
}

static void flutter_inappwebview_linux_plugin_init(FlutterInappwebviewLinuxPlugin* self) {
  self->manager = nullptr;
}

void flutter_inappwebview_linux_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  FlutterInappwebviewLinuxPlugin* plugin = reinterpret_cast<FlutterInappwebviewLinuxPlugin*>(
      g_object_new(flutter_inappwebview_linux_plugin_get_type(), nullptr));

  plugin->manager = std::make_unique<flutter_inappwebview_webkit::WebKitGTKManager>(registrar);

  g_object_unref(plugin);
}
