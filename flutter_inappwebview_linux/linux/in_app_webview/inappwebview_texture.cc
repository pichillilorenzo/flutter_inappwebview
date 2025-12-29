#include "inappwebview_texture.h"

#include <cstring>

#include "in_app_webview.h"

// Private structure
struct _InAppWebViewTexture {
  FlPixelBufferTexture parent_instance;
  flutter_inappwebview_plugin::WebViewType* webview;
  // Default buffer for when no content is available
  uint8_t default_buffer[4];  // 1x1 RGBA pixel

  // Staging buffer returned to Flutter from copy_pixels.
  // Must remain valid until the next copy_pixels call.
  uint8_t* staging_buffer;
  size_t staging_buffer_size;
};

G_DEFINE_TYPE(InAppWebViewTexture, inappwebview_texture,
              fl_pixel_buffer_texture_get_type())

static gboolean inappwebview_texture_copy_pixels(FlPixelBufferTexture* texture,
                                                  const uint8_t** out_buffer,
                                                  uint32_t* width,
                                                  uint32_t* height,
                                                  GError** error) {
  InAppWebViewTexture* self = INAPPWEBVIEW_TEXTURE(texture);

  static uint32_t fallback_log_counter = 0;
  static bool did_log_first_success = false;

  if (self->webview == nullptr) {
    // Return a 1x1 transparent pixel as fallback
    if (g_getenv("FLUTTER_INAPPWEBVIEW_LINUX_DEBUG_TEXTURE") != nullptr &&
        (++fallback_log_counter % 120) == 0) {
      g_message("InAppWebViewTexture: fallback (no webview)");
    }
    *out_buffer = self->default_buffer;
    *width = 1;
    *height = 1;
    return TRUE;
  }

  uint32_t buf_width = 0;
  uint32_t buf_height = 0;
  size_t required_size = self->webview->GetPixelBufferSize(&buf_width, &buf_height);

  if (required_size == 0 || buf_width == 0 || buf_height == 0) {
    if (g_getenv("FLUTTER_INAPPWEBVIEW_LINUX_DEBUG_TEXTURE") != nullptr &&
        (++fallback_log_counter % 120) == 0) {
      g_message("InAppWebViewTexture: fallback (no frame yet)");
    }
    *out_buffer = self->default_buffer;
    *width = 1;
    *height = 1;
    return TRUE;
  }

  if (self->staging_buffer_size < required_size) {
    self->staging_buffer = static_cast<uint8_t*>(
        g_realloc(self->staging_buffer, required_size));
    self->staging_buffer_size = required_size;
  }

  if (self->staging_buffer == nullptr) {
    if (g_getenv("FLUTTER_INAPPWEBVIEW_LINUX_DEBUG_TEXTURE") != nullptr &&
        (++fallback_log_counter % 120) == 0) {
      g_message("InAppWebViewTexture: fallback (staging alloc failed)");
    }
    *out_buffer = self->default_buffer;
    *width = 1;
    *height = 1;
    return TRUE;
  }

  if (!self->webview->CopyPixelBufferTo(self->staging_buffer,
                                       self->staging_buffer_size,
                                       &buf_width, &buf_height)) {
    if (g_getenv("FLUTTER_INAPPWEBVIEW_LINUX_DEBUG_TEXTURE") != nullptr &&
        (++fallback_log_counter % 120) == 0) {
      g_message("InAppWebViewTexture: fallback (copy failed)");
    }
    *out_buffer = self->default_buffer;
    *width = 1;
    *height = 1;
    return TRUE;
  }

  if (!did_log_first_success && g_getenv("FLUTTER_INAPPWEBVIEW_LINUX_DEBUG_TEXTURE") != nullptr) {
    did_log_first_success = true;
    g_message("InAppWebViewTexture: first copy_pixels %ux%u (%zu bytes)",
              buf_width, buf_height, static_cast<size_t>(buf_width) * static_cast<size_t>(buf_height) * 4);
  }

  *out_buffer = self->staging_buffer;
  *width = buf_width;
  *height = buf_height;
  return TRUE;
}

static void inappwebview_texture_finalize(GObject* object) {
  InAppWebViewTexture* self = INAPPWEBVIEW_TEXTURE(object);
  if (self->staging_buffer != nullptr) {
    g_free(self->staging_buffer);
    self->staging_buffer = nullptr;
    self->staging_buffer_size = 0;
  }
  G_OBJECT_CLASS(inappwebview_texture_parent_class)->finalize(object);
}

static void inappwebview_texture_class_init(InAppWebViewTextureClass* klass) {
  FL_PIXEL_BUFFER_TEXTURE_CLASS(klass)->copy_pixels =
      inappwebview_texture_copy_pixels;

  G_OBJECT_CLASS(klass)->finalize = inappwebview_texture_finalize;
}

static void inappwebview_texture_init(InAppWebViewTexture* self) {
  self->webview = nullptr;
  // Initialize default buffer to transparent pixel (RGBA)
  self->default_buffer[0] = 0;
  self->default_buffer[1] = 0;
  self->default_buffer[2] = 0;
  self->default_buffer[3] = 0;

  self->staging_buffer = nullptr;
  self->staging_buffer_size = 0;
}

InAppWebViewTexture* inappwebview_texture_new(
    flutter_inappwebview_plugin::WebViewType* webview) {
  InAppWebViewTexture* self = INAPPWEBVIEW_TEXTURE(
      g_object_new(INAPPWEBVIEW_TYPE_TEXTURE, nullptr));
  self->webview = webview;
  return self;
}
