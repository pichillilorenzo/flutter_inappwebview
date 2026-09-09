#include <array>
#include <cstring>
#include <epoxy/egl.h>
#include <epoxy/gl.h>

#include "../in_app_webview/zero_copy.h"

// Exercise the real texture consumer with a deterministic frame producer.
#define FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_H_
namespace flutter_inappwebview_plugin {
class InAppWebView {
 public:
  int imports = 0;
  bool has_pixels = true;
  std::array<uint8_t, 16> pixels = {
      255, 0, 0, 255, 0, 255, 0, 255,
      0, 0, 255, 255, 255, 255, 255, 255};

  void* ImportCurrentBufferToEglImage(void*, uint32_t*, uint32_t*) {
    ++imports;
    return nullptr;
  }
  size_t GetPixelBufferSize(uint32_t* width, uint32_t* height) const {
    *width = *height = has_pixels ? 2 : 0;
    return has_pixels ? pixels.size() : 0;
  }
  bool CopyPixelBufferTo(uint8_t* dst, size_t size, uint32_t* width,
                         uint32_t* height) const {
    if (!has_pixels || size < pixels.size()) return false;
    *width = *height = 2;
    std::memcpy(dst, pixels.data(), pixels.size());
    return true;
  }
};
}  // namespace flutter_inappwebview_plugin

#include "../in_app_webview/inappwebview_egl_texture.cc"

int main() {
  // Mesa's surfaceless display keeps this test independent of a desktop session.
  auto get_display = reinterpret_cast<PFNEGLGETPLATFORMDISPLAYEXTPROC>(
      eglGetProcAddress("eglGetPlatformDisplayEXT"));
  g_assert_nonnull(get_display);
  EGLDisplay display = get_display(EGL_PLATFORM_SURFACELESS_MESA, nullptr, nullptr);
  g_assert_true(eglInitialize(display, nullptr, nullptr));
  g_assert_true(eglBindAPI(EGL_OPENGL_API));
  const EGLint config_attrs[] = {EGL_SURFACE_TYPE, EGL_PBUFFER_BIT,
      EGL_RENDERABLE_TYPE, EGL_OPENGL_BIT, EGL_RED_SIZE, 8, EGL_GREEN_SIZE, 8,
      EGL_BLUE_SIZE, 8, EGL_ALPHA_SIZE, 8, EGL_NONE};
  EGLConfig config;
  EGLint count = 0;
  g_assert_true(eglChooseConfig(display, config_attrs, &config, 1, &count));
  g_assert_cmpint(count, ==, 1);
  const EGLint surface_attrs[] = {EGL_WIDTH, 2, EGL_HEIGHT, 2, EGL_NONE};
  EGLSurface surface = eglCreatePbufferSurface(display, config, surface_attrs);
  EGLContext context = eglCreateContext(display, config, EGL_NO_CONTEXT, nullptr);
  g_assert_true(eglMakeCurrent(display, surface, surface, context));

  const char* option = "FLUTTER_INAPPWEBVIEW_LINUX_DISABLE_ZERO_COPY";
  for (const char* value : std::array<const char*, 4>{nullptr, "1", "0", ""}) {
    if (value) g_setenv(option, value, TRUE);
    else g_unsetenv(option);
    g_assert_cmpint(flutter_inappwebview_plugin::IsZeroCopyDisabled(), ==,
                    value != nullptr);
    flutter_inappwebview_plugin::InAppWebView webview;
    auto* texture = inappwebview_egl_texture_new(&webview);
    for (int frame = 0; frame < 2; ++frame) {
      webview.pixels[0] = static_cast<uint8_t>(200 + frame);
      uint32_t target = 0, name = 0, width = 0, height = 0;
      GError* error = nullptr;
      g_assert_true(inappwebview_egl_texture_populate(
          FL_TEXTURE_GL(texture), &target, &name, &width, &height, &error));
      g_assert_no_error(error);
      g_assert_cmpuint(width, ==, 2);
      g_assert_cmpuint(height, ==, 2);
      glBindTexture(target, name);
      std::array<uint8_t, 16> rendered{};
      glGetTexImage(target, 0, GL_RGBA, GL_UNSIGNED_BYTE, rendered.data());
      g_assert_cmpmem(rendered.data(), rendered.size(),
                      webview.pixels.data(), webview.pixels.size());
      g_assert_cmpuint(glGetError(), ==, GL_NO_ERROR);
    }
    // Presence follows the existing DISABLE_GL convention, including empty/0.
    g_assert_cmpint(webview.imports, ==, value ? 0 : 2);
    glDeleteTextures(1, &texture->texture_id);
    g_object_unref(texture);
  }
  g_unsetenv(option);
  g_assert_true(eglMakeCurrent(display, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT));
  eglDestroyContext(display, context);
  eglDestroySurface(display, surface);
  eglTerminate(display);
  g_print("EGL texture fallback: all tests passed\n");
}
