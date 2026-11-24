#include "inappwebview_egl_texture.h"

#include <epoxy/egl.h>
#include <epoxy/gl.h>

#include <vector>

#include "../utils/gl_context.h"
#include "in_app_webview.h"

struct _InAppWebViewEGLTexture {
  FlTextureGL parent_instance;
  flutter_inappwebview_plugin::WebViewType* webview;
  GLuint texture;
  uint32_t width;
  uint32_t height;
  gboolean pixels_only;
  gboolean gpu_path_logged;
  gboolean pixel_path_logged;
  gboolean upload_error_logged;
  std::vector<uint8_t>* pixels;
  GMutex mutex;
};

G_DEFINE_TYPE(InAppWebViewEGLTexture, inappwebview_egl_texture, fl_texture_gl_get_type())

namespace {

void ClearGlErrors() {
  // Bound this even if the context has been lost.
  for (int i = 0; i < 16 && glGetError() != GL_NO_ERROR; ++i) {}
}

// Flutter owns the current context. Do not leak bindings or pixel-store state.
class GlState {
 public:
  GlState() {
    glGetIntegerv(GL_TEXTURE_BINDING_2D, &texture_);
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &framebuffer_);
    separate_framebuffers_ = epoxy_gl_version() >= 30;
    if (separate_framebuffers_) {
      glGetIntegerv(GL_READ_FRAMEBUFFER_BINDING, &read_framebuffer_);
    }
    glGetIntegerv(GL_UNPACK_ALIGNMENT, &alignment_);
    extended_unpack_ = epoxy_is_desktop_gl() || epoxy_gl_version() >= 30;
    if (extended_unpack_) {
      glGetIntegerv(GL_UNPACK_ROW_LENGTH, &row_length_);
      glGetIntegerv(GL_UNPACK_SKIP_ROWS, &skip_rows_);
      glGetIntegerv(GL_UNPACK_SKIP_PIXELS, &skip_pixels_);
      glGetIntegerv(GL_PIXEL_UNPACK_BUFFER_BINDING, &unpack_buffer_);
      glBindBuffer(GL_PIXEL_UNPACK_BUFFER, 0);
      glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
      glPixelStorei(GL_UNPACK_SKIP_ROWS, 0);
      glPixelStorei(GL_UNPACK_SKIP_PIXELS, 0);
    }
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
  }
  ~GlState() {
    glBindTexture(GL_TEXTURE_2D, texture_);
    if (separate_framebuffers_) {
      glBindFramebuffer(GL_DRAW_FRAMEBUFFER, framebuffer_);
      glBindFramebuffer(GL_READ_FRAMEBUFFER, read_framebuffer_);
    } else {
      glBindFramebuffer(GL_FRAMEBUFFER, framebuffer_);
    }
    glPixelStorei(GL_UNPACK_ALIGNMENT, alignment_);
    if (extended_unpack_) {
      glBindBuffer(GL_PIXEL_UNPACK_BUFFER, unpack_buffer_);
      glPixelStorei(GL_UNPACK_ROW_LENGTH, row_length_);
      glPixelStorei(GL_UNPACK_SKIP_ROWS, skip_rows_);
      glPixelStorei(GL_UNPACK_SKIP_PIXELS, skip_pixels_);
    }
  }

 private:
  GLint texture_ = 0, framebuffer_ = 0, read_framebuffer_ = 0;
  GLint alignment_ = 4, row_length_ = 0, skip_rows_ = 0, skip_pixels_ = 0;
  GLint unpack_buffer_ = 0;
  bool extended_unpack_ = false, separate_framebuffers_ = false;
};

void BindOutput(InAppWebViewEGLTexture* self) {
  if (!self->texture) {
    glGenTextures(1, &self->texture);
  }
  glBindTexture(GL_TEXTURE_2D, self->texture);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
}

bool CopyGpuFrame(InAppWebViewEGLTexture* self, void* image, uint32_t width, uint32_t height) {
  if (!epoxy_has_gl_extension("GL_OES_EGL_image")) {
    g_message("InAppWebView: GL_OES_EGL_image unavailable; using pixel transfer");
    self->pixels_only = TRUE;
    return false;
  }
  auto bind_image = reinterpret_cast<PFNGLEGLIMAGETARGETTEXTURE2DOESPROC>(
      eglGetProcAddress("glEGLImageTargetTexture2DOES"));
  if (!bind_image) {
    self->pixels_only = TRUE;
    return false;
  }

  ClearGlErrors();
  GLuint source_texture = 0, framebuffer = 0;
  glGenTextures(1, &source_texture);
  glGenFramebuffers(1, &framebuffer);
  glBindTexture(GL_TEXTURE_2D, source_texture);
  bind_image(GL_TEXTURE_2D, static_cast<GLeglImageOES>(image));
  GLenum gl_error = glGetError();
  if (gl_error == GL_NO_ERROR) {
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, source_texture, 0);
    const GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status == GL_FRAMEBUFFER_COMPLETE) {
      BindOutput(self);
      if (self->width != width || self->height != height) {
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE,
                     nullptr);
      }
      glCopyTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, 0, 0, width, height);
      gl_error = glGetError();
    } else {
      g_warning("InAppWebView: WPE framebuffer incomplete: 0x%x", status);
      gl_error = GL_INVALID_FRAMEBUFFER_OPERATION;
    }
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, 0, 0);
  }
  // The producer may recycle the buffer as soon as the WebView lock is released.
  // Flutter samples our own texture, not the borrowed WPE image.
  glFinish();
  glDeleteFramebuffers(1, &framebuffer);
  glDeleteTextures(1, &source_texture);
  if (gl_error != GL_NO_ERROR) {
    g_warning("InAppWebView: EGL frame copy failed: 0x%x; using pixel transfer", gl_error);
    self->pixels_only = TRUE;
    ClearGlErrors();
    return false;
  }
  self->width = width;
  self->height = height;
  if (!self->gpu_path_logged) {
    g_message("InAppWebView: GPU frame transfer active (%ux%u)", width, height);
    self->gpu_path_logged = TRUE;
  }
  return true;
}

}  // namespace

static gboolean inappwebview_egl_texture_populate(FlTextureGL* texture, uint32_t* target,
                                                  uint32_t* name, uint32_t* width, uint32_t* height,
                                                  GError** error) {
  auto* self = INAPPWEBVIEW_EGL_TEXTURE(texture);
  g_mutex_lock(&self->mutex);
  if (!flutter_inappwebview_plugin::HasCurrentGLContext()) {
    g_set_error_literal(error, g_quark_from_static_string("InAppWebViewEGLTexture"), 1,
                        "No current GL context");
    g_mutex_unlock(&self->mutex);
    return FALSE;
  }

  {
    GlState state;
    bool rendered = false;
    if (self->webview && !self->pixels_only) {
      rendered = self->webview->PaintCurrentEglImage(
          [self](void* image, uint32_t w, uint32_t h) { return CopyGpuFrame(self, image, w, h); });
    }
    uint32_t w = 0, h = 0;
    if (!rendered && self->webview &&
        self->webview->CopyCurrentFramePixels(*self->pixels, &w, &h)) {
      ClearGlErrors();
      BindOutput(self);
      // Reallocate also after a failed GPU import; its storage may be incomplete.
      glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, w, h, 0, GL_RGBA, GL_UNSIGNED_BYTE,
                   self->pixels->data());
      const GLenum gl_error = glGetError();
      if (gl_error == GL_NO_ERROR) {
        self->width = w;
        self->height = h;
        if (!self->pixel_path_logged) {
          g_message("InAppWebView: pixel transfer active (%ux%u); GPU rendering unchanged", w, h);
          self->pixel_path_logged = TRUE;
        }
      } else if (!self->upload_error_logged) {
        g_warning("InAppWebView: pixel upload failed: 0x%x", gl_error);
        self->upload_error_logged = TRUE;
      }
    }
    if (!self->width || !self->height) {
      BindOutput(self);
      const uint8_t transparent[4] = {};
      glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 1, 1, 0, GL_RGBA, GL_UNSIGNED_BYTE, transparent);
      // Keep dimensions at zero so the next real frame allocates its storage.
    }
  }
  *target = GL_TEXTURE_2D;
  *name = self->texture;
  *width = self->width ? self->width : 1;
  *height = self->height ? self->height : 1;
  g_mutex_unlock(&self->mutex);
  return TRUE;
}

void inappwebview_egl_texture_detach(InAppWebViewEGLTexture* self) {
  g_mutex_lock(&self->mutex);
  self->webview = nullptr;
  g_mutex_unlock(&self->mutex);
}

static void inappwebview_egl_texture_dispose(GObject* object) {
  auto* self = INAPPWEBVIEW_EGL_TEXTURE(object);
  inappwebview_egl_texture_detach(self);
  G_OBJECT_CLASS(inappwebview_egl_texture_parent_class)->dispose(object);
}

static void inappwebview_egl_texture_finalize(GObject* object) {
  auto* self = INAPPWEBVIEW_EGL_TEXTURE(object);
  delete self->pixels;
  // Destruction is not guaranteed to have Flutter's GL context current.
  g_mutex_clear(&self->mutex);
  G_OBJECT_CLASS(inappwebview_egl_texture_parent_class)->finalize(object);
}

static void inappwebview_egl_texture_class_init(InAppWebViewEGLTextureClass* klass) {
  FL_TEXTURE_GL_CLASS(klass)->populate = inappwebview_egl_texture_populate;
  G_OBJECT_CLASS(klass)->dispose = inappwebview_egl_texture_dispose;
  G_OBJECT_CLASS(klass)->finalize = inappwebview_egl_texture_finalize;
}

static void inappwebview_egl_texture_init(InAppWebViewEGLTexture* self) {
  self->pixels = new std::vector<uint8_t>();
  g_mutex_init(&self->mutex);
}

InAppWebViewEGLTexture* inappwebview_egl_texture_new(
    flutter_inappwebview_plugin::WebViewType* webview) {
  auto* self = INAPPWEBVIEW_EGL_TEXTURE(g_object_new(INAPPWEBVIEW_TYPE_EGL_TEXTURE, nullptr));
  self->webview = webview;
  return self;
}
