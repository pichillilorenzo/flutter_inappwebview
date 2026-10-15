#include <epoxy/egl.h>
#include <epoxy/gl.h>

#include "egl_texture_fallback_webview_stub.h"
#include "../in_app_webview/zero_copy.h"

// Exercise the real texture consumer with a deterministic frame producer.
#define FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_H_
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
    const bool zero_copy_enabled = !flutter_inappwebview_plugin::IsZeroCopyDisabled();
    webview.SetInlineFlutterTextureConsumer(true);
    webview.SetInlineFlutterEglImportEnabled(zero_copy_enabled);
    webview.SetSkipPixelReadback(zero_copy_enabled);
    // Simulate a current GLX context: GL works, but eglGetCurrentDisplay() is
    // EGL_NO_DISPLAY when the texture asks its fake producer to import.
    webview.force_no_egl_display = zero_copy_enabled;
    auto* texture = inappwebview_egl_texture_new(&webview);
    auto populate = [&](uint32_t expected_width, uint32_t expected_height) {
      uint32_t target = 0, name = 0, width = 0, height = 0;
      GError* error = nullptr;
      g_assert_true(inappwebview_egl_texture_populate(
          FL_TEXTURE_GL(texture), &target, &name, &width, &height, &error));
      g_assert_no_error(error);
      g_assert_cmpuint(width, ==, expected_width);
      g_assert_cmpuint(height, ==, expected_height);
      if (expected_width == 2) {
        glBindTexture(target, name);
        std::array<uint8_t, 16> rendered{};
        glGetTexImage(target, 0, GL_RGBA, GL_UNSIGNED_BYTE, rendered.data());
        g_assert_cmpmem(rendered.data(), rendered.size(),
                        webview.pixels.data(), webview.pixels.size());
        g_assert_cmpuint(glGetError(), ==, GL_NO_ERROR);
      }
    };

    // With no EGL target, no-frame and SHM results still cannot disable
    // eligibility. A real DMA-BUF on the same path must enter pixel fallback.
    webview.has_pixels = false;
    webview.frame_kind = flutter_inappwebview_plugin::InAppWebView::FrameKind::kNoFrame;
    populate(1, 1);
    webview.frame_kind = flutter_inappwebview_plugin::InAppWebView::FrameKind::kShm;
    webview.has_pixels = true;
    populate(2, 2);
    g_assert_cmpint(webview.import_state.IsFallbackActive(), ==, FALSE);
    g_assert_cmpint(webview.ShouldAttemptFlutterEglImport(), ==, zero_copy_enabled);

    // A failed actual DMA-BUF import switches both producer and consumer to
    // pixel mode; later populate calls must not repeat the EGL import attempt.
    webview.frame_kind = flutter_inappwebview_plugin::InAppWebView::FrameKind::kDmaBuf;
    webview.pixels[0] = 200;
    populate(2, 2);
    g_assert_cmpint(webview.import_state.IsFallbackActive(), ==, zero_copy_enabled);
    g_assert_cmpint(webview.skip_pixel_readback, ==, false);
    const int imports_after_dma_frame = webview.imports;
    webview.pixels[0] = 201;
    populate(2, 2);
    g_assert_cmpint(webview.imports, ==, imports_after_dma_frame);

    // Explicitly disabled zero-copy skips every EGL import attempt.
    if (!zero_copy_enabled) {
      g_assert_cmpint(webview.imports, ==, 0);
    }
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
