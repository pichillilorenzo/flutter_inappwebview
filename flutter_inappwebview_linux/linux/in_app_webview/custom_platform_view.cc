#include "custom_platform_view.h"

#include <cstring>
#include <gdk/gdk.h>

#include "inappwebview_gl_texture.h"
#include "inappwebview_pbo_texture.h"
#include "inappwebview_texture.h"

namespace flutter_inappwebview_plugin {

namespace {
bool DebugLogEnabled() {
  static bool enabled = g_getenv("FLUTTER_INAPPWEBVIEW_LINUX_DEBUG") != nullptr;
  return enabled;
}

// Check if GL textures should be used (enabled by default, can be disabled)
bool UseGLTextureEnvOverride() {
  // User can force disable GL texture with this env var
  if (g_getenv("FLUTTER_INAPPWEBVIEW_LINUX_DISABLE_GL") != nullptr) {
    return false;
  }
  return true;
}

// Check if PBO texture should be used (disabled by default due to resize issues)
// PBO provides async DMA transfers but has synchronization issues during resize.
// Enable with FLUTTER_INAPPWEBVIEW_LINUX_USE_PBO=1 for testing.
bool UsePBOTexture() {
  // PBO is opt-in due to resize artifacts
  if (g_getenv("FLUTTER_INAPPWEBVIEW_LINUX_USE_PBO") != nullptr) {
    return true;
  }
  return false;
}

// Check if OpenGL is actually available in the current GDK backend
bool IsOpenGLAvailable() {
  static bool checked = false;
  static bool available = false;
  
  if (checked) {
    return available;
  }
  checked = true;
  
  GdkDisplay* display = gdk_display_get_default();
  if (display == nullptr) {
    if (DebugLogEnabled()) {
      g_message("CustomPlatformView: No GDK display available");
    }
    return false;
  }
  
  // Try to create a temporary window to test GL support
  GdkWindowAttr attrs;
  memset(&attrs, 0, sizeof(attrs));
  attrs.width = 1;
  attrs.height = 1;
  attrs.wclass = GDK_INPUT_OUTPUT;
  attrs.window_type = GDK_WINDOW_TOPLEVEL;
  
  GdkWindow* test_window = gdk_window_new(nullptr, &attrs, 0);
  if (test_window == nullptr) {
    if (DebugLogEnabled()) {
      g_message("CustomPlatformView: Failed to create test window for GL check");
    }
    return false;
  }
  
  GError* error = nullptr;
  GdkGLContext* gl_context = gdk_window_create_gl_context(test_window, &error);
  
  if (gl_context != nullptr) {
    available = true;
    g_object_unref(gl_context);
    if (DebugLogEnabled()) {
      g_message("CustomPlatformView: OpenGL is available");
    }
  } else {
    if (DebugLogEnabled()) {
      g_message("CustomPlatformView: OpenGL not available: %s", 
                error ? error->message : "unknown error");
    }
    if (error) {
      g_error_free(error);
    }
  }
  
  gdk_window_destroy(test_window);
  
  return available;
}

bool UseGLTexture() {
  if (!UseGLTextureEnvOverride()) {
    return false;
  }
  return IsOpenGLAvailable();
}
}  // namespace

CustomPlatformView::CustomPlatformView(FlBinaryMessenger* messenger,
                                       FlTextureRegistrar* texture_registrar,
                                       std::shared_ptr<WebViewType> webview)
    : webview_(std::move(webview)), texture_registrar_(texture_registrar) {
  
  if (messenger == nullptr) {
    g_warning("CustomPlatformView: messenger is null");
    return;
  }
  
  if (texture_registrar_ == nullptr) {
    g_warning("CustomPlatformView: texture_registrar is null");
    return;
  }
  
  // Create texture - prefer PBO texture for best performance (async DMA),
  // fall back to basic GL texture, then pixel buffer texture if GL not available
  if (UseGLTexture()) {
    if (UsePBOTexture()) {
      texture_ = FL_TEXTURE(inappwebview_pbo_texture_new(webview_.get()));
      if (DebugLogEnabled()) {
        g_message("CustomPlatformView: using PBO texture (async DMA, hardware accelerated)");
      }
    } else {
      texture_ = FL_TEXTURE(inappwebview_gl_texture_new(webview_.get()));
      if (DebugLogEnabled()) {
        g_message("CustomPlatformView: using OpenGL texture (hardware accelerated)");
      }
    }
  } else {
    texture_ = FL_TEXTURE(inappwebview_texture_new(webview_.get()));
    if (DebugLogEnabled()) {
      g_message("CustomPlatformView: using pixel buffer texture (software)");
    }
  }
  
  if (texture_ == nullptr) {
    g_warning("CustomPlatformView: failed to create texture");
    return;
  }

  // Register the texture - this assigns the texture ID
  gboolean registered = fl_texture_registrar_register_texture(texture_registrar_, texture_);
  if (!registered) {
    g_warning("CustomPlatformView: failed to register texture");
    g_object_unref(texture_);
    texture_ = nullptr;
    return;
  }
  
  // Now get the texture ID after registration
  texture_id_ = fl_texture_get_id(texture_);

  // Attach the webview method channel using the same id used on Dart side.
  // Dart uses the returned id from createInAppWebView as both textureId and
  // controller/view id.
  if (webview_ != nullptr) {
    webview_->AttachChannel(messenger, texture_id_);
  }

  // Set up the webview's callback to mark frame available
  webview_->SetOnFrameAvailable([this]() { MarkTextureFrameAvailable(); });

  // Set up cursor change callback
  webview_->SetOnCursorChanged([this](const std::string& cursor_name) {
    EmitCursorChanged(cursor_name);
  });

  // Create method channel for platform view operations
  std::string method_channel_name =
      "com.pichillilorenzo/custom_platform_view_" + std::to_string(texture_id_);
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  method_channel_ = fl_method_channel_new(messenger, method_channel_name.c_str(),
                                          FL_METHOD_CODEC(codec));
  if (method_channel_ != nullptr) {
    fl_method_channel_set_method_call_handler(method_channel_, HandleMethodCall,
                                              this, nullptr);
  }

  // Create event channel for cursor changes, etc.
  std::string event_channel_name =
      "com.pichillilorenzo/custom_platform_view_" + std::to_string(texture_id_) +
      "_events";
  g_autoptr(FlStandardMethodCodec) event_codec = fl_standard_method_codec_new();
  event_channel_ = fl_event_channel_new(messenger, event_channel_name.c_str(),
                                        FL_METHOD_CODEC(event_codec));
  if (event_channel_ != nullptr) {
    fl_event_channel_set_stream_handlers(event_channel_, OnListen, OnCancel, this,
                                         nullptr);
  }
}

CustomPlatformView::~CustomPlatformView() {
  if (method_channel_ != nullptr) {
    fl_method_channel_set_method_call_handler(method_channel_, nullptr, nullptr,
                                              nullptr);
    g_object_unref(method_channel_);
    method_channel_ = nullptr;
  }

  if (event_channel_ != nullptr) {
    fl_event_channel_set_stream_handlers(event_channel_, nullptr, nullptr,
                                         nullptr, nullptr);
    g_object_unref(event_channel_);
    event_channel_ = nullptr;
  }

  if (texture_registrar_ != nullptr && texture_ != nullptr) {
    fl_texture_registrar_unregister_texture(texture_registrar_, texture_);
  }

  if (texture_ != nullptr) {
    g_object_unref(texture_);
    texture_ = nullptr;
  }
}

void CustomPlatformView::MarkTextureFrameAvailable() {
  if (texture_registrar_ != nullptr && texture_ != nullptr) {
    fl_texture_registrar_mark_texture_frame_available(texture_registrar_,
                                                      texture_);
  }
}

void CustomPlatformView::HandleMethodCall(FlMethodChannel* channel,
                                          FlMethodCall* method_call,
                                          gpointer user_data) {
  auto* self = static_cast<CustomPlatformView*>(user_data);
  self->HandleMethodCallImpl(method_call);
}

void CustomPlatformView::HandleMethodCallImpl(FlMethodCall* method_call) {
  const gchar* method = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);

  if (DebugLogEnabled()) {
    g_message("CustomPlatformView[%ld]: method=%s", static_cast<long>(texture_id_), method);
  }

  // setSize: [double width, double height, double scaleFactor]
  if (strcmp(method, "setSize") == 0) {
    if (fl_value_get_type(args) == FL_VALUE_TYPE_LIST &&
        fl_value_get_length(args) >= 2) {
      FlValue* width_value = fl_value_get_list_value(args, 0);
      FlValue* height_value = fl_value_get_list_value(args, 1);
      double width = 0, height = 0;
      double scale_factor = 1.0;

      if (fl_value_get_type(width_value) == FL_VALUE_TYPE_FLOAT) {
        width = fl_value_get_float(width_value);
      } else if (fl_value_get_type(width_value) == FL_VALUE_TYPE_INT) {
        width = static_cast<double>(fl_value_get_int(width_value));
      }

      if (fl_value_get_type(height_value) == FL_VALUE_TYPE_FLOAT) {
        height = fl_value_get_float(height_value);
      } else if (fl_value_get_type(height_value) == FL_VALUE_TYPE_INT) {
        height = static_cast<double>(fl_value_get_int(height_value));
      }

      if (webview_ && width > 0 && height > 0) {
        if (fl_value_get_length(args) >= 3) {
          FlValue* scale_value = fl_value_get_list_value(args, 2);
          if (scale_value != nullptr) {
            if (fl_value_get_type(scale_value) == FL_VALUE_TYPE_FLOAT) {
              scale_factor = fl_value_get_float(scale_value);
            } else if (fl_value_get_type(scale_value) == FL_VALUE_TYPE_INT) {
              scale_factor = static_cast<double>(fl_value_get_int(scale_value));
            }
          }
        }
        webview_->setScaleFactor(scale_factor);
        // IMPORTANT: GTK/WebKit may already apply the monitor scale factor to
        // offscreen rendering. Passing physical pixels here can double-scale
        // the snapshot size. Keep the widget size in logical pixels and use
        // scaleFactor only for input coordinate conversion.
        webview_->setSize(static_cast<int>(width), static_cast<int>(height));

        if (DebugLogEnabled()) {
          g_message("CustomPlatformView[%ld]: setSize %.1fx%.1f scale=%.2f (logical=%dx%d)",
                    static_cast<long>(texture_id_), width, height, scale_factor,
                    static_cast<int>(width), static_cast<int>(height));
        }
      }
    }
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  // setCursorPos: [double x, double y]
  if (strcmp(method, "setCursorPos") == 0) {
    if (fl_value_get_type(args) == FL_VALUE_TYPE_LIST &&
        fl_value_get_length(args) >= 2) {
      FlValue* x_value = fl_value_get_list_value(args, 0);
      FlValue* y_value = fl_value_get_list_value(args, 1);
      double x = 0, y = 0;

      if (fl_value_get_type(x_value) == FL_VALUE_TYPE_FLOAT) {
        x = fl_value_get_float(x_value);
      } else if (fl_value_get_type(x_value) == FL_VALUE_TYPE_INT) {
        x = static_cast<double>(fl_value_get_int(x_value));
      }

      if (fl_value_get_type(y_value) == FL_VALUE_TYPE_FLOAT) {
        y = fl_value_get_float(y_value);
      } else if (fl_value_get_type(y_value) == FL_VALUE_TYPE_INT) {
        y = static_cast<double>(fl_value_get_int(y_value));
      }

      if (webview_) {
        webview_->SetCursorPos(x, y);
        if (DebugLogEnabled()) {
          g_message("CustomPlatformView[%ld]: setCursorPos %.1f,%.1f", static_cast<long>(texture_id_), x, y);
        }
      }
    }
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  // setPointerButton: {"kind": int, "button": int, "clickCount": int}
  if (strcmp(method, "setPointerButton") == 0) {
    if (fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
      FlValue* kind_value = fl_value_lookup_string(args, "kind");
      FlValue* button_value = fl_value_lookup_string(args, "button");
      FlValue* click_count_value = fl_value_lookup_string(args, "clickCount");

      if (kind_value != nullptr && button_value != nullptr) {
        int kind = 0, button = 0, clickCount = 1;

        if (fl_value_get_type(kind_value) == FL_VALUE_TYPE_INT) {
          kind = static_cast<int>(fl_value_get_int(kind_value));
        }
        if (fl_value_get_type(button_value) == FL_VALUE_TYPE_INT) {
          button = static_cast<int>(fl_value_get_int(button_value));
        }
        if (click_count_value != nullptr && fl_value_get_type(click_count_value) == FL_VALUE_TYPE_INT) {
          clickCount = static_cast<int>(fl_value_get_int(click_count_value));
        }

        if (webview_) {
          webview_->SetPointerButton(kind, button, clickCount);
          if (DebugLogEnabled()) {
            g_message("CustomPlatformView[%ld]: setPointerButton kind=%d button=%d clicks=%d", 
                      static_cast<long>(texture_id_), kind, button, clickCount);
          }
        }
      }
    }
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  // setScrollDelta: [double dx, double dy]
  if (strcmp(method, "setScrollDelta") == 0) {
    if (fl_value_get_type(args) == FL_VALUE_TYPE_LIST &&
        fl_value_get_length(args) >= 2) {
      FlValue* dx_value = fl_value_get_list_value(args, 0);
      FlValue* dy_value = fl_value_get_list_value(args, 1);
      double dx = 0, dy = 0;

      if (fl_value_get_type(dx_value) == FL_VALUE_TYPE_FLOAT) {
        dx = fl_value_get_float(dx_value);
      } else if (fl_value_get_type(dx_value) == FL_VALUE_TYPE_INT) {
        dx = static_cast<double>(fl_value_get_int(dx_value));
      }

      if (fl_value_get_type(dy_value) == FL_VALUE_TYPE_FLOAT) {
        dy = fl_value_get_float(dy_value);
      } else if (fl_value_get_type(dy_value) == FL_VALUE_TYPE_INT) {
        dy = static_cast<double>(fl_value_get_int(dy_value));
      }

      if (webview_) {
        webview_->SetScrollDelta(dx, dy);
        if (DebugLogEnabled()) {
          g_message("CustomPlatformView[%ld]: setScrollDelta %.2f,%.2f", static_cast<long>(texture_id_), dx, dy);
        }
      }
    }
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  // sendKeyEvent: {"type": int, "keyCode": int64, "scanCode": int, "modifiers": int, "characters": string}
  if (strcmp(method, "sendKeyEvent") == 0) {
    if (fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
      FlValue* type_value = fl_value_lookup_string(args, "type");
      FlValue* keyCode_value = fl_value_lookup_string(args, "keyCode");
      FlValue* scanCode_value = fl_value_lookup_string(args, "scanCode");
      FlValue* modifiers_value = fl_value_lookup_string(args, "modifiers");
      FlValue* characters_value = fl_value_lookup_string(args, "characters");

      int type = 0, scanCode = 0, modifiers = 0;
      int64_t keyCode = 0;
      std::string characters;

      if (type_value != nullptr && fl_value_get_type(type_value) == FL_VALUE_TYPE_INT) {
        type = static_cast<int>(fl_value_get_int(type_value));
      }
      if (keyCode_value != nullptr && fl_value_get_type(keyCode_value) == FL_VALUE_TYPE_INT) {
        keyCode = fl_value_get_int(keyCode_value);
      }
      if (scanCode_value != nullptr && fl_value_get_type(scanCode_value) == FL_VALUE_TYPE_INT) {
        scanCode = static_cast<int>(fl_value_get_int(scanCode_value));
      }
      if (modifiers_value != nullptr && fl_value_get_type(modifiers_value) == FL_VALUE_TYPE_INT) {
        modifiers = static_cast<int>(fl_value_get_int(modifiers_value));
      }
      if (characters_value != nullptr && fl_value_get_type(characters_value) == FL_VALUE_TYPE_STRING) {
        characters = fl_value_get_string(characters_value);
      }

      if (webview_) {
        webview_->SendKeyEvent(type, keyCode, scanCode, modifiers, characters);
        if (DebugLogEnabled()) {
          g_message("CustomPlatformView[%ld]: sendKeyEvent type=%d keyCode=0x%lx scanCode=%d modifiers=%d chars=%s", 
                    static_cast<long>(texture_id_), type, static_cast<long>(keyCode), scanCode, modifiers, characters.c_str());
        }
      }
    }
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  fl_method_call_respond_not_implemented(method_call, nullptr);
}

FlMethodErrorResponse* CustomPlatformView::OnListen(FlEventChannel* channel,
                                                    FlValue* args,
                                                    gpointer user_data) {
  auto* self = static_cast<CustomPlatformView*>(user_data);
  self->event_sink_active_ = true;
  return nullptr;
}

FlMethodErrorResponse* CustomPlatformView::OnCancel(FlEventChannel* channel,
                                                    FlValue* args,
                                                    gpointer user_data) {
  auto* self = static_cast<CustomPlatformView*>(user_data);
  self->event_sink_active_ = false;
  return nullptr;
}

void CustomPlatformView::EmitCursorChanged(const std::string& cursor_name) {
  if (!event_sink_active_ || event_channel_ == nullptr) {
    return;
  }

  g_autoptr(FlValue) event = fl_value_new_map();
  fl_value_set_string_take(event, "type",
                           fl_value_new_string("cursorChanged"));
  fl_value_set_string_take(event, "value",
                           fl_value_new_string(cursor_name.c_str()));

  fl_event_channel_send(event_channel_, event, nullptr, nullptr);
}

}  // namespace flutter_inappwebview_plugin
