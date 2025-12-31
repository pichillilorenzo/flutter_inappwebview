#include "inappwebview_pbo_texture.h"

#include <epoxy/gl.h>

#include <cstring>

#include "../utils/log.h"
#include "in_app_webview.h"

/**
 * PBO-optimized GL texture for efficient WebView rendering.
 *
 * This implementation uses the double-buffered PBO streaming technique
 * described at https://www.songho.ca/opengl/gl_pbo.html
 *
 * Benefits:
 * 1. Asynchronous DMA transfer - GPU handles data copy while CPU continues
 * 2. Double buffering - one PBO uploads while the other receives new data
 * 3. glTexSubImage2D - avoids texture reallocation when size is unchanged
 * 4. Buffer orphaning - prevents GPU stalls with glBufferData(NULL)
 */

// Number of PBOs for double buffering
static constexpr int NUM_PBOS = 2;

// Private structure for the PBO texture
struct _InAppWebViewPBOTexture {
  FlTextureGL parent_instance;

  // Reference to the webview (not owned)
  flutter_inappwebview_plugin::WebViewType* webview;

  // Main texture
  GLuint texture_id;
  gboolean texture_initialized;
  uint32_t texture_width;
  uint32_t texture_height;

  // Double-buffered PBOs for async upload
  GLuint pbo_ids[NUM_PBOS];
  gboolean pbos_initialized;
  gboolean pbo_support_checked;
  gboolean pbo_supported;
  int current_pbo_index;  // Index of PBO being filled
  size_t pbo_size;        // Current allocated size of each PBO

  // Default texture for when no content is available
  GLuint default_texture_id;
  gboolean default_texture_initialized;

  // Frame data staging
  uint8_t* staging_buffer;
  size_t staging_buffer_size;

  // Cached dimensions
  uint32_t last_width;
  uint32_t last_height;

  // Frame counter for logging
  uint32_t frame_count;

  // Mutex to protect state
  GMutex mutex;
};

G_DEFINE_TYPE(InAppWebViewPBOTexture, inappwebview_pbo_texture, fl_texture_gl_get_type())

namespace {

// Check if PBOs are supported - must be called with GL context current
bool ArePBOsSupported() {
  // PBOs are part of OpenGL 2.1+ and OpenGL ES 3.0+
  // epoxy should handle the extension check automatically
  // Note: This must be called when GL context is current
  int gl_version = epoxy_gl_version();
  bool supported = gl_version >= 21 || epoxy_has_gl_extension("GL_ARB_pixel_buffer_object") ||
                   epoxy_has_gl_extension("GL_EXT_pixel_buffer_object");
  return supported;
}
}  // namespace

// Initialize PBOs
static gboolean init_pbos(InAppWebViewPBOTexture* self, size_t size) {
  if (self->pbos_initialized) {
    // Resize if needed
    if (self->pbo_size >= size) {
      return TRUE;
    }
    // Delete old PBOs
    glDeleteBuffers(NUM_PBOS, self->pbo_ids);
    self->pbos_initialized = FALSE;
  }

  glGenBuffers(NUM_PBOS, self->pbo_ids);

  for (int i = 0; i < NUM_PBOS; i++) {
    glBindBuffer(GL_PIXEL_UNPACK_BUFFER, self->pbo_ids[i]);
    // Use GL_STREAM_DRAW for streaming texture uploads
    glBufferData(GL_PIXEL_UNPACK_BUFFER, size, nullptr, GL_STREAM_DRAW);
  }

  glBindBuffer(GL_PIXEL_UNPACK_BUFFER, 0);

  self->pbo_size = size;
  self->pbos_initialized = TRUE;
  self->current_pbo_index = 0;

  return TRUE;
}

// Populate callback - called by Flutter to get the OpenGL texture
static gboolean inappwebview_pbo_texture_populate(FlTextureGL* texture, uint32_t* target,
                                                  uint32_t* name, uint32_t* width, uint32_t* height,
                                                  GError** error) {
  InAppWebViewPBOTexture* self = INAPPWEBVIEW_PBO_TEXTURE(texture);

  g_mutex_lock(&self->mutex);

  // Check if we have a valid webview
  if (self->webview == nullptr) {
    g_mutex_unlock(&self->mutex);
    return FALSE;
  }

  // Get frame dimensions
  uint32_t buf_width = 0;
  uint32_t buf_height = 0;
  size_t required_size = self->webview->GetPixelBufferSize(&buf_width, &buf_height);

  if (required_size == 0 || buf_width == 0 || buf_height == 0) {
    // No frame available, return default texture
    if (!self->default_texture_initialized) {
      glGenTextures(1, &self->default_texture_id);
      glBindTexture(GL_TEXTURE_2D, self->default_texture_id);
      uint8_t pixel[4] = {255, 255, 255, 255};  // White opaque
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

  // Check if PBOs are supported (cached after first check)
  if (!self->pbo_support_checked) {
    self->pbo_support_checked = TRUE;
    self->pbo_supported = ArePBOsSupported();
  }

  if (!self->pbo_supported) {
    // Fall back to direct texture upload
    if (self->staging_buffer_size < required_size) {
      g_free(self->staging_buffer);
      self->staging_buffer = static_cast<uint8_t*>(g_malloc(required_size));
      self->staging_buffer_size = required_size;
    }

    if (!self->webview->CopyPixelBufferTo(self->staging_buffer, required_size, &buf_width,
                                          &buf_height)) {
      g_mutex_unlock(&self->mutex);
      return FALSE;
    }

    if (!self->texture_initialized) {
      glGenTextures(1, &self->texture_id);
      self->texture_initialized = TRUE;
    }

    glBindTexture(GL_TEXTURE_2D, self->texture_id);

    if (buf_width != self->texture_width || buf_height != self->texture_height) {
      glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, buf_width, buf_height, 0, GL_RGBA, GL_UNSIGNED_BYTE,
                   self->staging_buffer);
      self->texture_width = buf_width;
      self->texture_height = buf_height;
    } else {
      glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, buf_width, buf_height, GL_RGBA, GL_UNSIGNED_BYTE,
                      self->staging_buffer);
    }

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

    *target = GL_TEXTURE_2D;
    *name = self->texture_id;
    *width = buf_width;
    *height = buf_height;

    g_mutex_unlock(&self->mutex);
    return TRUE;
  }

  // === PBO-optimized path ===

  // Initialize or resize PBOs
  if (!init_pbos(self, required_size)) {
    g_mutex_unlock(&self->mutex);
    g_set_error(error, g_quark_from_string("InAppWebViewPBOTexture"), 1,
                "Failed to initialize PBOs");
    return FALSE;
  }

  // Create texture if not initialized
  if (!self->texture_initialized) {
    glGenTextures(1, &self->texture_id);
    glBindTexture(GL_TEXTURE_2D, self->texture_id);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, buf_width, buf_height, 0, GL_RGBA, GL_UNSIGNED_BYTE,
                 nullptr);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    self->texture_initialized = TRUE;
    self->texture_width = buf_width;
    self->texture_height = buf_height;
  }

  // Use double-buffered PBO streaming:
  // - Bind PBO[index] for texture upload (this triggers DMA from previous frame)
  // - Map PBO[nextIndex] and copy new frame data into it

  int upload_index = self->current_pbo_index;
  int fill_index = (self->current_pbo_index + 1) % NUM_PBOS;

  // Step 1: Upload from the "upload" PBO to texture
  // This should be fast because the DMA transfer happened asynchronously
  glBindTexture(GL_TEXTURE_2D, self->texture_id);
  glBindBuffer(GL_PIXEL_UNPACK_BUFFER, self->pbo_ids[upload_index]);

  // Check if texture needs to be resized
  if (buf_width != self->texture_width || buf_height != self->texture_height) {
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, buf_width, buf_height, 0, GL_RGBA, GL_UNSIGNED_BYTE,
                 nullptr);  // nullptr = use PBO
    self->texture_width = buf_width;
    self->texture_height = buf_height;
  } else {
    // Use glTexSubImage2D for faster updates (no reallocation)
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, buf_width, buf_height, GL_RGBA, GL_UNSIGNED_BYTE,
                    nullptr);  // nullptr = use PBO
  }

  // Step 2: Fill the "fill" PBO with new frame data
  glBindBuffer(GL_PIXEL_UNPACK_BUFFER, self->pbo_ids[fill_index]);

  // Orphan the buffer to avoid GPU stall
  // This tells OpenGL we don't care about the old data anymore
  glBufferData(GL_PIXEL_UNPACK_BUFFER, required_size, nullptr, GL_STREAM_DRAW);

  // Map the buffer for writing
  GLubyte* ptr = static_cast<GLubyte*>(glMapBuffer(GL_PIXEL_UNPACK_BUFFER, GL_WRITE_ONLY));

  if (ptr != nullptr) {
    // Copy pixel data directly into the PBO
    if (!self->webview->CopyPixelBufferTo(ptr, required_size, &buf_width, &buf_height)) {
      glUnmapBuffer(GL_PIXEL_UNPACK_BUFFER);
      glBindBuffer(GL_PIXEL_UNPACK_BUFFER, 0);
      g_mutex_unlock(&self->mutex);
      return FALSE;
    }
    glUnmapBuffer(GL_PIXEL_UNPACK_BUFFER);
  } else {
    // Fallback: use staging buffer
    if (self->staging_buffer_size < required_size) {
      g_free(self->staging_buffer);
      self->staging_buffer = static_cast<uint8_t*>(g_malloc(required_size));
      self->staging_buffer_size = required_size;
    }

    if (self->webview->CopyPixelBufferTo(self->staging_buffer, required_size, &buf_width,
                                         &buf_height)) {
      glBufferSubData(GL_PIXEL_UNPACK_BUFFER, 0, required_size, self->staging_buffer);
    }
  }

  // Unbind PBO
  glBindBuffer(GL_PIXEL_UNPACK_BUFFER, 0);

  // Swap PBO indices for next frame
  self->current_pbo_index = fill_index;

  // Update frame counter
  self->frame_count++;

  *target = GL_TEXTURE_2D;
  *name = self->texture_id;
  *width = buf_width;
  *height = buf_height;

  g_mutex_unlock(&self->mutex);

  return TRUE;
}

static void inappwebview_pbo_texture_dispose(GObject* object) {
  InAppWebViewPBOTexture* self = INAPPWEBVIEW_PBO_TEXTURE(object);

  g_mutex_lock(&self->mutex);

  // We don't delete GL resources here because the GL context may not be current.
  // Flutter's texture registrar handles cleanup.
  self->texture_id = 0;
  self->texture_initialized = FALSE;
  self->default_texture_id = 0;
  self->default_texture_initialized = FALSE;

  // Note: PBOs would need to be deleted, but again, no GL context guarantee
  self->pbos_initialized = FALSE;

  g_free(self->staging_buffer);
  self->staging_buffer = nullptr;
  self->staging_buffer_size = 0;

  g_mutex_unlock(&self->mutex);
  g_mutex_clear(&self->mutex);

  G_OBJECT_CLASS(inappwebview_pbo_texture_parent_class)->dispose(object);
}

static void inappwebview_pbo_texture_class_init(InAppWebViewPBOTextureClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = inappwebview_pbo_texture_dispose;
  FL_TEXTURE_GL_CLASS(klass)->populate = inappwebview_pbo_texture_populate;
}

static void inappwebview_pbo_texture_init(InAppWebViewPBOTexture* self) {
  self->webview = nullptr;
  self->texture_id = 0;
  self->texture_initialized = FALSE;
  self->texture_width = 0;
  self->texture_height = 0;

  for (int i = 0; i < NUM_PBOS; i++) {
    self->pbo_ids[i] = 0;
  }
  self->pbos_initialized = FALSE;
  self->pbo_support_checked = FALSE;
  self->pbo_supported = FALSE;
  self->current_pbo_index = 0;
  self->pbo_size = 0;

  self->default_texture_id = 0;
  self->default_texture_initialized = FALSE;

  self->staging_buffer = nullptr;
  self->staging_buffer_size = 0;

  self->last_width = 0;
  self->last_height = 0;
  self->frame_count = 0;

  g_mutex_init(&self->mutex);
}

InAppWebViewPBOTexture* inappwebview_pbo_texture_new(
    flutter_inappwebview_plugin::WebViewType* webview) {
  InAppWebViewPBOTexture* self =
      INAPPWEBVIEW_PBO_TEXTURE(g_object_new(INAPPWEBVIEW_TYPE_PBO_TEXTURE, nullptr));
  self->webview = webview;
  flutter_inappwebview_plugin::debugLog("InAppWebViewPBOTexture: created");
  return self;
}
