// GL context utilities for checking if EGL/GLX context is current.
//
// IMPORTANT: We use dlsym to call eglGetCurrentContext/glXGetCurrentContext
// directly from libEGL/libGLX because libepoxy's wrappers go through
// epoxy_get_proc_address which ASSERTS that a context must be current,
// causing a catch-22 situation when we need to check if a context exists.

#ifndef FLUTTER_INAPPWEBVIEW_LINUX_UTILS_GL_CONTEXT_H_
#define FLUTTER_INAPPWEBVIEW_LINUX_UTILS_GL_CONTEXT_H_

#include <dlfcn.h>
#include <glib.h>

// EGL_NO_CONTEXT is typically defined as nullptr/0, but we define it here
// to avoid including EGL headers which would conflict with epoxy
#ifndef EGL_NO_CONTEXT
#define EGL_NO_CONTEXT nullptr
#endif

namespace flutter_inappwebview_plugin {

/**
 * Check if we have a current EGL or GLX context.
 * This MUST be called before any GL/EGL operations to avoid crashes from
 * libepoxy when no context is current.
 *
 * @return true if a GL context is current on this thread, false otherwise.
 */
inline bool HasCurrentGLContext() {
  // Use cached function pointers to avoid repeated dlsym calls
  static void* (*egl_get_current_context)(void) = nullptr;
  static void* (*glx_get_current_context)(void) = nullptr;
  static bool initialized = false;

  if (!initialized) {
    initialized = true;

    // Try to load and get eglGetCurrentContext
    // First try NOLOAD (already loaded), then try loading it
    void* egl_lib = dlopen("libEGL.so.1", RTLD_NOW | RTLD_NOLOAD);
    if (egl_lib == nullptr) {
      egl_lib = dlopen("libEGL.so", RTLD_NOW | RTLD_NOLOAD);
    }
    if (egl_lib == nullptr) {
      // Library not loaded yet, try to load it
      egl_lib = dlopen("libEGL.so.1", RTLD_NOW);
    }
    if (egl_lib != nullptr) {
      egl_get_current_context = reinterpret_cast<void* (*)(void)>(
          dlsym(egl_lib, "eglGetCurrentContext"));
    }

    // Also try GLX for X11 environments
    void* glx_lib = dlopen("libGLX.so.0", RTLD_NOW | RTLD_NOLOAD);
    if (glx_lib == nullptr) {
      glx_lib = dlopen("libGL.so.1", RTLD_NOW | RTLD_NOLOAD);
    }
    if (glx_lib == nullptr) {
      glx_lib = dlopen("libGL.so", RTLD_NOW | RTLD_NOLOAD);
    }
    if (glx_lib != nullptr) {
      glx_get_current_context = reinterpret_cast<void* (*)(void)>(
          dlsym(glx_lib, "glXGetCurrentContext"));
    }
  }

  // Check EGL context first
  if (egl_get_current_context != nullptr) {
    void* ctx = egl_get_current_context();
    if (ctx != nullptr && ctx != EGL_NO_CONTEXT) {
      return true;
    }
  }

  // Check GLX context
  if (glx_get_current_context != nullptr) {
    void* ctx = glx_get_current_context();
    if (ctx != nullptr) {
      return true;
    }
  }

  return false;
}

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_LINUX_UTILS_GL_CONTEXT_H_
