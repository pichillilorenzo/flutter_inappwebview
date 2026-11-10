#include "plugin_instance.h"

#include "flutter_inappwebview_linux_plugin_private.h"

namespace flutter_inappwebview_plugin {

PluginInstance::PluginInstance(FlPluginRegistrar* registrar)
    : registrar_(registrar) {
  // Cache the GTK window and FlView now while the registrar is still fully valid
  gtk_window_ = flutter_inappwebview_linux_plugin_get_window(registrar);
  fl_view_ = flutter_inappwebview_linux_plugin_get_view(registrar);
  if (gtk_window_ != nullptr) {
    host_window_destroy_handler_ = g_signal_connect(
        gtk_window_, "destroy", G_CALLBACK(+[](GtkWidget* widget, gpointer data) {
          static_cast<PluginInstance*>(data)->InvalidateHost(GTK_WINDOW(widget), nullptr);
        }), this);
  }
  if (fl_view_ != nullptr) {
    host_view_destroy_handler_ = g_signal_connect(
        fl_view_, "destroy", G_CALLBACK(+[](GtkWidget* widget, gpointer data) {
          static_cast<PluginInstance*>(data)->InvalidateHost(nullptr, FL_VIEW(widget));
        }), this);
  }
}

PluginInstance::~PluginInstance() {
  if (gtk_window_ != nullptr && host_window_destroy_handler_ != 0) {
    g_signal_handler_disconnect(gtk_window_, host_window_destroy_handler_);
  }
  if (fl_view_ != nullptr && host_view_destroy_handler_ != 0) {
    g_signal_handler_disconnect(fl_view_, host_view_destroy_handler_);
  }
}

void PluginInstance::InvalidateHost(GtkWindow* window, FlView* view) {
  if (window != nullptr && gtk_window_ == window) {
    if (host_window_destroy_handler_ != 0) {
      g_signal_handler_disconnect(window, host_window_destroy_handler_);
    }
    gtk_window_ = nullptr;
    host_window_destroy_handler_ = 0;
  }
  if (view != nullptr && fl_view_ == view) {
    if (host_view_destroy_handler_ != 0) {
      g_signal_handler_disconnect(view, host_view_destroy_handler_);
    }
    fl_view_ = nullptr;
    host_view_destroy_handler_ = 0;
  }
}

FlBinaryMessenger* PluginInstance::messenger() const {
  return fl_plugin_registrar_get_messenger(registrar_);
}

FlTextureRegistrar* PluginInstance::textureRegistrar() const {
  return fl_plugin_registrar_get_texture_registrar(registrar_);
}

}  // namespace flutter_inappwebview_plugin
