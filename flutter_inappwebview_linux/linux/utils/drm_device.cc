#include "drm_device.h"

#include <epoxy/egl.h>
#include <gdk/gdk.h>

#ifdef GDK_WINDOWING_WAYLAND
#include <gdk/gdkwayland.h>
#endif
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif

#include <cstdlib>
#include <cstring>
#include <string>

#include "log.h"

// EGL_EXT_device_drm_render_node, missing from older epoxy headers.
#ifndef EGL_DRM_RENDER_NODE_FILE_EXT
#define EGL_DRM_RENDER_NODE_FILE_EXT 0x3377
#endif

namespace flutter_inappwebview_plugin {

namespace {

// The EGL display Flutter renders with, obtained the same way GDK does.
EGLDisplay GetFlutterEGLDisplay() {
  GdkDisplay* gdk_display = gdk_display_get_default();

  if (gdk_display != nullptr && epoxy_has_egl_extension(EGL_NO_DISPLAY, "EGL_EXT_platform_base")) {
#ifdef GDK_WINDOWING_WAYLAND
    if (GDK_IS_WAYLAND_DISPLAY(gdk_display)) {
      auto* wl_display = gdk_wayland_display_get_wl_display(GDK_WAYLAND_DISPLAY(gdk_display));
      if (wl_display != nullptr) {
        return eglGetPlatformDisplayEXT(EGL_PLATFORM_WAYLAND_KHR, wl_display, nullptr);
      }
    }
#endif
#ifdef GDK_WINDOWING_X11
    if (GDK_IS_X11_DISPLAY(gdk_display)) {
      auto* x11_display = gdk_x11_display_get_xdisplay(GDK_X11_DISPLAY(gdk_display));
      if (x11_display != nullptr) {
        return eglGetPlatformDisplayEXT(EGL_PLATFORM_X11_KHR, x11_display, nullptr);
      }
    }
#endif
  }

  return eglGetDisplay(EGL_DEFAULT_DISPLAY);
}

// Prefers the render node, the primary node is only a fallback for drivers that
// don't expose EGL_EXT_device_drm_render_node.
std::string GetDRMDeviceOf(EGLDisplay egl_display) {
  if (egl_display == EGL_NO_DISPLAY) {
    return {};
  }

  EGLint major = 0;
  EGLint minor = 0;
  // Never terminated on purpose: GDK uses this very display, eglInitialize is
  // refcounted and eglTerminate would pull the context out from under it.
  if (!eglInitialize(egl_display, &major, &minor)) {
    return {};
  }

  if (!epoxy_has_egl_extension(EGL_NO_DISPLAY, "EGL_EXT_device_query")) {
    return {};
  }

  EGLAttrib device_attr = 0;
  if (!eglQueryDisplayAttribEXT(egl_display, EGL_DEVICE_EXT, &device_attr)) {
    return {};
  }

  auto device = reinterpret_cast<EGLDeviceEXT>(device_attr);
  const char* render_node = eglQueryDeviceStringEXT(device, EGL_DRM_RENDER_NODE_FILE_EXT);
  if (render_node != nullptr && *render_node != '\0') {
    return render_node;
  }

  const char* primary_node = eglQueryDeviceStringEXT(device, EGL_DRM_DEVICE_FILE_EXT);
  if (primary_node != nullptr && *primary_node != '\0') {
    return primary_node;
  }

  return {};
}

}  // namespace

bool ApplyWpeDrmDeviceIfNeeded() {
  const char* existing = getenv("WPE_DRM_DEVICE");
  if (existing != nullptr && *existing != '\0') {
    debugLog("WPE_DRM_DEVICE already set to " + std::string(existing));
    return false;
  }

  // Software rendering makes WPE drop GBM entirely, there is no device to pin.
  const char* software = getenv("LIBGL_ALWAYS_SOFTWARE");
  if (software != nullptr && (strcmp(software, "1") == 0 || strcasecmp(software, "true") == 0)) {
    return false;
  }

  const std::string device = GetDRMDeviceOf(GetFlutterEGLDisplay());
  if (device.empty()) {
    debugLog("Could not resolve the DRM device of the EGL display, letting WPE infer it");
    return false;
  }

  setenv("WPE_DRM_DEVICE", device.c_str(), 0);
  debugLog("Pinned WPE to the DRM device Flutter renders with: " + device);
  return true;
}

}  // namespace flutter_inappwebview_plugin
