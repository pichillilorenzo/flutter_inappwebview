#ifndef FLUTTER_INAPPWEBVIEW_LINUX_TEST_PIXEL_BUFFER_SUPPORT_H_
#define FLUTTER_INAPPWEBVIEW_LINUX_TEST_PIXEL_BUFFER_SUPPORT_H_

// Fake EGL/Wayland APIs shared by production-method rendering tests.
#include <array>
#include <atomic>
#include <cassert>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <functional>
#include <mutex>
#include <string>
#include <vector>

#include "../in_app_webview/simd_convert.h"

using EGLDisplay = void*;
using EGLImageKHR = void*;
using GLenum = unsigned int;
using PFNGLEGLIMAGETARGETTEXTURE2DOESPROC = void (*)(GLenum, EGLImageKHR);
constexpr EGLDisplay EGL_NO_DISPLAY = nullptr;
constexpr EGLImageKHR EGL_NO_IMAGE_KHR = nullptr;
constexpr GLenum GL_TEXTURE_2D = 1;
constexpr GLenum GL_FRAMEBUFFER = 2;
constexpr GLenum GL_COLOR_ATTACHMENT0 = 3;
constexpr GLenum GL_FRAMEBUFFER_COMPLETE = 4;
constexpr GLenum GL_RGBA = 5;
constexpr GLenum GL_UNSIGNED_BYTE = 6;

struct Frame {
  uint32_t width;
  uint32_t height;
  int32_t stride;
  std::vector<uint8_t> rgba;
  std::vector<uint8_t> bgra;

  Frame(uint32_t w, uint32_t h, uint8_t seed)
      : width(w), height(h), stride(w * 4 + 16),
        rgba(static_cast<size_t>(w) * h * 4),
        bgra(static_cast<size_t>(stride) * h, 0xEE) {
    for (uint32_t y = 0; y < h; ++y) {
      for (uint32_t x = 0; x < w; ++x) {
        const size_t packed = (static_cast<size_t>(y) * w + x) * 4;
        const size_t padded = static_cast<size_t>(y) * stride + x * 4;
        rgba[packed] = bgra[padded + 2] = static_cast<uint8_t>(x + seed);
        rgba[packed + 1] = bgra[padded + 1] = static_cast<uint8_t>(y + seed);
        rgba[packed + 2] = bgra[padded] = static_cast<uint8_t>(x + y + seed);
        rgba[packed + 3] = bgra[padded + 3] = 255;
      }
    }
  }
};

Frame* bound_frame = nullptr;
unsigned int bound_texture = 0;
unsigned int bound_framebuffer = 0;
std::function<void()> before_gl_read_pixels;
bool HasCurrentGLContext() { return true; }
void glGenTextures(int, unsigned int* texture) { *texture = 1; }
void glGenFramebuffers(int, unsigned int* framebuffer) { *framebuffer = 2; }
void glBindTexture(GLenum, unsigned int texture) { bound_texture = texture; }
void glBindFramebuffer(GLenum, unsigned int framebuffer) { bound_framebuffer = framebuffer; }
void glFramebufferTexture2D(GLenum, GLenum, GLenum, unsigned int, int) {}
GLenum glCheckFramebufferStatus(GLenum) { return GL_FRAMEBUFFER_COMPLETE; }
void BindEglImage(GLenum, EGLImageKHR image) { bound_frame = static_cast<Frame*>(image); }
PFNGLEGLIMAGETARGETTEXTURE2DOESPROC eglGetProcAddress(const char*) {
  return BindEglImage;
}
void glReadPixels(int, int, uint32_t width, uint32_t height,
                  GLenum format, GLenum type, void* destination) {
  assert(bound_frame != nullptr);
  assert(bound_frame->width == width && bound_frame->height == height);
  assert(format == GL_RGBA && type == GL_UNSIGNED_BYTE);
  if (before_gl_read_pixels) before_gl_read_pixels();
  std::memcpy(destination, bound_frame->rgba.data(), bound_frame->rgba.size());
}

struct wl_shm_buffer {
  Frame* frame;
  bool accessing = false;
  bool ended = false;
};
struct wpe_fdo_shm_exported_buffer {
  wl_shm_buffer* shm;
  bool released = false;
};
struct wpe_view_backend_exportable_fdo {
  size_t completed = 0;
};
wl_shm_buffer* wpe_fdo_shm_exported_buffer_get_shm_buffer(
    wpe_fdo_shm_exported_buffer* buffer) { return buffer->shm; }
int32_t wl_shm_buffer_get_width(wl_shm_buffer* buffer) { return buffer->frame->width; }
int32_t wl_shm_buffer_get_height(wl_shm_buffer* buffer) { return buffer->frame->height; }
int32_t wl_shm_buffer_get_stride(wl_shm_buffer* buffer) { return buffer->frame->stride; }
uint32_t wl_shm_buffer_get_format(wl_shm_buffer*) { return 0; }
void wl_shm_buffer_begin_access(wl_shm_buffer* buffer) {
  assert(!buffer->accessing);
  buffer->accessing = true;
}
void* wl_shm_buffer_get_data(wl_shm_buffer* buffer) {
  assert(buffer->accessing);
  return buffer->frame->bgra.data();
}
void wl_shm_buffer_end_access(wl_shm_buffer* buffer) {
  assert(buffer->accessing);
  buffer->accessing = false;
  buffer->ended = true;
}
void wpe_view_backend_exportable_fdo_dispatch_release_shm_exported_buffer(
    wpe_view_backend_exportable_fdo*, wpe_fdo_shm_exported_buffer* buffer) {
  assert(buffer->shm->ended && !buffer->shm->accessing && !buffer->released);
  buffer->released = true;
}
void wpe_view_backend_exportable_fdo_dispatch_frame_complete(
    wpe_view_backend_exportable_fdo* backend) { ++backend->completed; }


#endif
