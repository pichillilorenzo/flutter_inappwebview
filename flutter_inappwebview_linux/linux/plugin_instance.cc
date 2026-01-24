#include "plugin_instance.h"

#include "flutter_inappwebview_linux_plugin_private.h"

namespace flutter_inappwebview_plugin {

PluginInstance::PluginInstance(FlPluginRegistrar* registrar)
    : registrar_(registrar) {
  // Cache the GTK window and FlView now while the registrar is still fully valid
  gtk_window_ = flutter_inappwebview_linux_plugin_get_window(registrar);
  fl_view_ = flutter_inappwebview_linux_plugin_get_view(registrar);
}

FlBinaryMessenger* PluginInstance::messenger() const {
  return fl_plugin_registrar_get_messenger(registrar_);
}

FlTextureRegistrar* PluginInstance::textureRegistrar() const {
  return fl_plugin_registrar_get_texture_registrar(registrar_);
}

}  // namespace flutter_inappwebview_plugin
