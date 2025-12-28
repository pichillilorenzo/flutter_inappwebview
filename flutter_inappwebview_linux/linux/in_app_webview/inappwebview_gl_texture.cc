#include "inappwebview_gl_texture.h"

#include <epoxy/gl.h>
#include <cstring>

// Include the appropriate backend
#ifdef USE_WPE_WEBKIT
#include "in_app_webview_wpe.h"
#else
#include "in_app_webview.h"
#endif

// Private structure for the OpenGL texture
struct _InAppWebViewGLTexture {
  FlTextureGL parent_instance;

  // Reference to the webview (not owned)
  flutter_inappwebview_plugin::WebViewType* webview;

  // OpenGL texture state
  GLuint texture_id;
  gboolean texture_initialized;

  // Default texture for when no content is available
  GLuint default_texture_id;
  gboolean default_texture_initialized;

  // Frame data (copied from webview's pixel buffer)
  uint8_t* frame_buffer;
  uint32_t width;
  uint32_t height;
  gboolean has_new_frame;

  // Mutex to protect frame data access
  GMutex mutex;
};

G_DEFINE_TYPE(InAppWebViewGLTexture, inappwebview_gl_texture,
              fl_texture_gl_get_type())

namespace {
bool DebugLogEnabled() {
  static bool enabled = g_getenv("FLUTTER_INAPPWEBVIEW_LINUX_DEBUG_TEXTURE") != nullptr;
  return enabled;
}
}  // namespace

// Populate callback - called by Flutter to get the OpenGL texture
static gboolean inappwebview_gl_texture_populate(FlTextureGL* texture,
                                                  uint32_t* target,
                                                  uint32_t* name,
                                                  uint32_t* width,
                                                  uint32_t* height,
                                                  GError** error) {
  InAppWebViewGLTexture* self = INAPPWEBVIEW_GL_TEXTURE(texture);

  g_mutex_lock(&self->mutex);

  // Check if we have a valid webview and can get frame data
  if (self->webview == nullptr) {
    g_mutex_unlock(&self->mutex);
    if (DebugLogEnabled()) {
      g_message("InAppWebViewGLTexture: populate failed - no webview");
    }
    return FALSE;
  }

  // Get the current frame dimensions from the webview
  uint32_t buf_width = 0;
  uint32_t buf_height = 0;
  size_t required_size = self->webview->GetPixelBufferSize(&buf_width, &buf_height);

  if (required_size == 0 || buf_width == 0 || buf_height == 0) {
    // No frame available yet, use default 1x1 transparent texture
    if (!self->default_texture_initialized) {
      glGenTextures(1, &self->default_texture_id);
      glBindTexture(GL_TEXTURE_2D, self->default_texture_id);
      uint8_t pixel[4] = {0, 0, 0, 0}; // Transparent
      glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, 1, 1, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixel);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
      self->default_texture_initialized = TRUE;
    }
    
    *target = GL_TEXTURE_2D;
    *name = self->default_texture_id;
    *width = 1;
    *height = 1;
    
    g_mutex_unlock(&self->mutex);
    return TRUE;
  }

  // Reallocate frame buffer if size changed
  if (self->width != buf_width || self->height != buf_height) {
    g_free(self->frame_buffer);
    self->frame_buffer = static_cast<uint8_t*>(g_malloc(required_size));
    self->width = buf_width;
    self->height = buf_height;
    if (DebugLogEnabled()) {
      g_message("InAppWebViewGLTexture: resized frame buffer to %ux%u (%zu bytes)",
                buf_width, buf_height, required_size);
    }
  }

  if (self->frame_buffer == nullptr) {
    g_mutex_unlock(&self->mutex);
    g_set_error(error, g_quark_from_string("InAppWebViewGLTexture"), 1,
                "Failed to allocate frame buffer");
    return FALSE;
  }

  // Copy the pixel data from the webview
  if (!self->webview->CopyPixelBufferTo(self->frame_buffer, required_size,
                                        &buf_width, &buf_height)) {
    g_mutex_unlock(&self->mutex);
    if (DebugLogEnabled()) {
      g_message("InAppWebViewGLTexture: failed to copy pixel buffer");
    }
    return FALSE;
  }

  // Create OpenGL texture if not initialized
  if (!self->texture_initialized) {
    glGenTextures(1, &self->texture_id);
    self->texture_initialized = TRUE;
    if (DebugLogEnabled()) {
      g_message("InAppWebViewGLTexture: created GL texture id=%u", self->texture_id);
    }
  }

  // Bind the texture
  glBindTexture(GL_TEXTURE_2D, self->texture_id);

  // Upload frame data to the GPU texture
  // Flutter expects GL_RGBA8 format
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8,
               static_cast<GLsizei>(self->width),
               static_cast<GLsizei>(self->height),
               0, GL_RGBA, GL_UNSIGNED_BYTE,
               self->frame_buffer);

  // Set texture parameters for proper rendering
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

  // Return the texture information to Flutter
  *target = GL_TEXTURE_2D;
  *name = self->texture_id;
  *width = self->width;
  *height = self->height;

  g_mutex_unlock(&self->mutex);

  static bool did_log_first_success = false;
  if (!did_log_first_success && DebugLogEnabled()) {
    did_log_first_success = true;
    g_message("InAppWebViewGLTexture: first successful populate %ux%u texture_id=%u",
              self->width, self->height, self->texture_id);
  }

  return TRUE;
}

static void inappwebview_gl_texture_dispose(GObject* object) {
  InAppWebViewGLTexture* self = INAPPWEBVIEW_GL_TEXTURE(object);

  g_mutex_lock(&self->mutex);

  // Note: We don't call glDeleteTextures here because:
  // 1. The GL context may not be current
  // 2. Flutter's texture registrar will handle texture cleanup
  // Just reset our tracking variables
  self->texture_id = 0;
  self->texture_initialized = FALSE;
  self->default_texture_id = 0;
  self->default_texture_initialized = FALSE;

  g_free(self->frame_buffer);
  self->frame_buffer = nullptr;
  self->width = 0;
  self->height = 0;

  g_mutex_unlock(&self->mutex);
  g_mutex_clear(&self->mutex);

  G_OBJECT_CLASS(inappwebview_gl_texture_parent_class)->dispose(object);
}

static void inappwebview_gl_texture_class_init(InAppWebViewGLTextureClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = inappwebview_gl_texture_dispose;
  FL_TEXTURE_GL_CLASS(klass)->populate = inappwebview_gl_texture_populate;
}

static void inappwebview_gl_texture_init(InAppWebViewGLTexture* self) {
  self->webview = nullptr;
  self->texture_id = 0;
  self->texture_initialized = FALSE;
  self->default_texture_id = 0;
  self->default_texture_initialized = FALSE;
  self->frame_buffer = nullptr;
  self->width = 0;
  self->height = 0;
  self->has_new_frame = FALSE;
  g_mutex_init(&self->mutex);
}

InAppWebViewGLTexture* inappwebview_gl_texture_new(
    flutter_inappwebview_plugin::WebViewType* webview) {
  InAppWebViewGLTexture* self = INAPPWEBVIEW_GL_TEXTURE(
      g_object_new(INAPPWEBVIEW_TYPE_GL_TEXTURE, nullptr));
  self->webview = webview;
  return self;
}
