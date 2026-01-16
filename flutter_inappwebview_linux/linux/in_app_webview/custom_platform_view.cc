#include "custom_platform_view.h"

#include <gdk/gdk.h>

#include <cstring>

#include "../utils/flutter.h"
#include "../utils/log.h"
#include "inappwebview_egl_texture.h"
#include "inappwebview_texture.h"

namespace flutter_inappwebview_plugin {

namespace {
// Check if GL textures should be used (enabled by default, can be disabled)
// Disable with FLUTTER_INAPPWEBVIEW_LINUX_DISABLE_GL=1 to force software rendering.
bool UseGLTextureEnvOverride() {
  if (g_getenv("FLUTTER_INAPPWEBVIEW_LINUX_DISABLE_GL") != nullptr) {
    return false;
  }
  return true;
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
    debugLog("CustomPlatformView: No GDK display available");
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
    debugLog("CustomPlatformView: Failed to create test window for GL check");
    return false;
  }

  GError* error = nullptr;
  GdkGLContext* gl_context = gdk_window_create_gl_context(test_window, &error);

  if (gl_context != nullptr) {
    available = true;
    g_object_unref(gl_context);
    debugLog("CustomPlatformView: OpenGL is available");
  } else {
    debugLog(std::string("CustomPlatformView: OpenGL not available: ") +
             (error ? error->message : "unknown error"));
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
    errorLog("CustomPlatformView: messenger is null");
    return;
  }

  if (texture_registrar_ == nullptr) {
    errorLog("CustomPlatformView: texture_registrar is null");
    return;
  }

  // Create texture - two modes:
  // 1. EGL/GL texture (hardware accelerated) - uses zero-copy EGL when available,
  //    falls back to pixel buffer upload when EGL is not available (e.g., in VMs)
  // 2. Pixel buffer texture (software) - pure software fallback when GL is disabled
  //
  // The EGL texture handles both EGL and SHM modes internally, providing the best
  // performance for each environment.
  if (UseGLTexture()) {
    texture_ = FL_TEXTURE(inappwebview_egl_texture_new(webview_.get()));
    egl_texture_ = INAPPWEBVIEW_EGL_TEXTURE(texture_);
    // In zero-copy EGL mode, we don't need pixel readback - the EGL image is passed
    // directly to Flutter. This improves performance and avoids GL context issues.
    webview_->SetSkipPixelReadback(true);
    debugLog("CustomPlatformView: using GL texture (hardware accelerated)");
  } else {
    texture_ = FL_TEXTURE(inappwebview_texture_new(webview_.get()));
    debugLog("CustomPlatformView: using pixel buffer texture (software)");
  }

  if (texture_ == nullptr) {
    errorLog("CustomPlatformView: failed to create texture");
    return;
  }

  // Register the texture - this assigns the texture ID
  gboolean registered = fl_texture_registrar_register_texture(texture_registrar_, texture_);
  if (!registered) {
    errorLog("CustomPlatformView: failed to register texture");
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
  // For EGL texture, we also update the EGL image reference
  webview_->SetOnFrameAvailable([this]() {
    // If using EGL texture, update the EGL image reference before marking available
    if (egl_texture_ != nullptr && webview_ != nullptr) {
      uint32_t width = 0;
      uint32_t height = 0;
      void* egl_image = webview_->GetCurrentEglImage(&width, &height);
      if (egl_image != nullptr) {
        inappwebview_egl_texture_set_egl_image(egl_texture_, egl_image, width, height);
      }
    }
    MarkTextureFrameAvailable();
  });

  // Set up cursor change callback
  webview_->SetOnCursorChanged(
      [this](const std::string& cursor_name) { EmitCursorChanged(cursor_name); });

  // Create method channel for platform view operations
  std::string method_channel_name =
      "com.pichillilorenzo/custom_platform_view_" + std::to_string(texture_id_);
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  method_channel_ =
      fl_method_channel_new(messenger, method_channel_name.c_str(), FL_METHOD_CODEC(codec));
  if (method_channel_ != nullptr) {
    fl_method_channel_set_method_call_handler(method_channel_, HandleMethodCall, this, nullptr);
  }

  // Create event channel for cursor changes, etc.
  std::string event_channel_name =
      "com.pichillilorenzo/custom_platform_view_" + std::to_string(texture_id_) + "_events";
  g_autoptr(FlStandardMethodCodec) event_codec = fl_standard_method_codec_new();
  event_channel_ =
      fl_event_channel_new(messenger, event_channel_name.c_str(), FL_METHOD_CODEC(event_codec));
  if (event_channel_ != nullptr) {
    fl_event_channel_set_stream_handlers(event_channel_, OnListen, OnCancel, this, nullptr);
  }
}

CustomPlatformView::~CustomPlatformView() {
  debugLog("dealloc CustomPlatformView");

  if (method_channel_ != nullptr) {
    fl_method_channel_set_method_call_handler(method_channel_, nullptr, nullptr, nullptr);
    g_object_unref(method_channel_);
    method_channel_ = nullptr;
  }

  if (event_channel_ != nullptr) {
    fl_event_channel_set_stream_handlers(event_channel_, nullptr, nullptr, nullptr, nullptr);
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
    fl_texture_registrar_mark_texture_frame_available(texture_registrar_, texture_);
  }
}

void CustomPlatformView::HandleMethodCall(FlMethodChannel* channel, FlMethodCall* method_call,
                                          gpointer user_data) {
  auto* self = static_cast<CustomPlatformView*>(user_data);
  self->HandleMethodCallImpl(method_call);
}

void CustomPlatformView::HandleMethodCallImpl(FlMethodCall* method_call) {
  const gchar* method = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);

  // setSize: [double width, double height, double scaleFactor]
  if (strcmp(method, "setSize") == 0) {
    if (fl_value_get_type(args) == FL_VALUE_TYPE_LIST && fl_value_get_length(args) >= 2) {
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
      }
    }
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  // setTextureOffset: [double x, double y]
  if (strcmp(method, "setTextureOffset") == 0) {
    if (fl_value_get_type(args) == FL_VALUE_TYPE_LIST && fl_value_get_length(args) >= 2) {
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
        webview_->SetTextureOffset(x, y);
      }
    }
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  // setCursorPos: [double x, double y]
  if (strcmp(method, "setCursorPos") == 0) {
    if (fl_value_get_type(args) == FL_VALUE_TYPE_LIST && fl_value_get_length(args) >= 2) {
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
        if (click_count_value != nullptr &&
            fl_value_get_type(click_count_value) == FL_VALUE_TYPE_INT) {
          clickCount = static_cast<int>(fl_value_get_int(click_count_value));
        }

        if (webview_) {
          webview_->SetPointerButton(kind, button, clickCount);
        }
      }
    }
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  // setScrollDelta: [double dx, double dy]
  if (strcmp(method, "setScrollDelta") == 0) {
    if (fl_value_get_type(args) == FL_VALUE_TYPE_LIST && fl_value_get_length(args) >= 2) {
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
      }
    }
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  // sendKeyEvent: {"type": int, "keyCode": int64, "scanCode": int, "modifiers": int, "characters":
  // string}
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
      if (characters_value != nullptr &&
          fl_value_get_type(characters_value) == FL_VALUE_TYPE_STRING) {
        characters = fl_value_get_string(characters_value);
      }

      if (webview_) {
        webview_->SendKeyEvent(type, keyCode, scanCode, modifiers, characters);
      }
    }
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  // sendTouchEvent: {"type": int, "id": int, "x": double, "y": double, "touchPoints": list}
  if (strcmp(method, "sendTouchEvent") == 0) {
    if (fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
      FlValue* type_value = fl_value_lookup_string(args, "type");
      FlValue* id_value = fl_value_lookup_string(args, "id");
      FlValue* x_value = fl_value_lookup_string(args, "x");
      FlValue* y_value = fl_value_lookup_string(args, "y");
      FlValue* touchPoints_value = fl_value_lookup_string(args, "touchPoints");

      int type = 0, id = 0;
      double x = 0, y = 0;
      std::vector<std::tuple<int, double, double, int>> touchPoints;

      if (type_value != nullptr && fl_value_get_type(type_value) == FL_VALUE_TYPE_INT) {
        type = static_cast<int>(fl_value_get_int(type_value));
      }
      if (id_value != nullptr && fl_value_get_type(id_value) == FL_VALUE_TYPE_INT) {
        id = static_cast<int>(fl_value_get_int(id_value));
      }
      if (x_value != nullptr && fl_value_get_type(x_value) == FL_VALUE_TYPE_FLOAT) {
        x = fl_value_get_float(x_value);
      }
      if (y_value != nullptr && fl_value_get_type(y_value) == FL_VALUE_TYPE_FLOAT) {
        y = fl_value_get_float(y_value);
      }

      // Parse touch points list
      if (touchPoints_value != nullptr &&
          fl_value_get_type(touchPoints_value) == FL_VALUE_TYPE_LIST) {
        size_t len = fl_value_get_length(touchPoints_value);
        for (size_t i = 0; i < len; i++) {
          FlValue* point = fl_value_get_list_value(touchPoints_value, i);
          if (fl_value_get_type(point) == FL_VALUE_TYPE_MAP) {
            int point_id = 0, point_type = 0;
            double point_x = 0, point_y = 0;

            FlValue* pid = fl_value_lookup_string(point, "id");
            FlValue* px = fl_value_lookup_string(point, "x");
            FlValue* py = fl_value_lookup_string(point, "y");
            FlValue* ptype = fl_value_lookup_string(point, "type");

            if (pid && fl_value_get_type(pid) == FL_VALUE_TYPE_INT) {
              point_id = static_cast<int>(fl_value_get_int(pid));
            }
            if (px && fl_value_get_type(px) == FL_VALUE_TYPE_FLOAT) {
              point_x = fl_value_get_float(px);
            }
            if (py && fl_value_get_type(py) == FL_VALUE_TYPE_FLOAT) {
              point_y = fl_value_get_float(py);
            }
            if (ptype && fl_value_get_type(ptype) == FL_VALUE_TYPE_INT) {
              point_type = static_cast<int>(fl_value_get_int(ptype));
            }

            touchPoints.emplace_back(point_id, point_x, point_y, point_type);
          }
        }
      }

      if (webview_) {
        webview_->SendTouchEvent(type, id, x, y, touchPoints);
      }
    }
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  // setFocused: bool focused
  if (strcmp(method, "setFocused") == 0) {
    bool focused = false;
    if (fl_value_get_type(args) == FL_VALUE_TYPE_BOOL) {
      focused = fl_value_get_bool(args);
    } else if (fl_value_get_type(args) == FL_VALUE_TYPE_INT) {
      focused = fl_value_get_int(args) != 0;
    }

    if (webview_) {
      webview_->setFocused(focused);
    }
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  // setVisible: bool visible
  if (strcmp(method, "setVisible") == 0) {
    bool visible = true;
    if (fl_value_get_type(args) == FL_VALUE_TYPE_BOOL) {
      visible = fl_value_get_bool(args);
    } else if (fl_value_get_type(args) == FL_VALUE_TYPE_INT) {
      visible = fl_value_get_int(args) != 0;
    }

    if (webview_) {
      webview_->setVisible(visible);
    }
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  // getActivityState: returns uint32
  if (strcmp(method, "getActivityState") == 0) {
    uint32_t state = 0;
    if (webview_) {
      state = webview_->getActivityState();
    }
    g_autoptr(FlValue) result = fl_value_new_int(static_cast<int64_t>(state));
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  // setTargetRefreshRate: int rate
  if (strcmp(method, "setTargetRefreshRate") == 0) {
    uint32_t rate = 0;
    if (fl_value_get_type(args) == FL_VALUE_TYPE_INT) {
      rate = static_cast<uint32_t>(fl_value_get_int(args));
    }

    if (webview_) {
      webview_->setTargetRefreshRate(rate);
    }
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  // getTargetRefreshRate: returns uint32
  if (strcmp(method, "getTargetRefreshRate") == 0) {
    uint32_t rate = 0;
    if (webview_) {
      rate = webview_->getTargetRefreshRate();
    }
    g_autoptr(FlValue) result = fl_value_new_int(static_cast<int64_t>(rate));
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  // requestEnterFullscreen
  if (strcmp(method, "requestEnterFullscreen") == 0) {
    if (webview_) {
      webview_->requestEnterFullscreen();
    }
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  // requestExitFullscreen
  if (strcmp(method, "requestExitFullscreen") == 0) {
    if (webview_) {
      webview_->requestExitFullscreen();
    }
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  // isInFullscreen: returns bool
  if (strcmp(method, "isInFullscreen") == 0) {
    bool fullscreen = false;
    if (webview_) {
      fullscreen = webview_->isInFullscreen();
    }
    g_autoptr(FlValue) result = fl_value_new_bool(fullscreen);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  // requestPointerLock: returns bool
  if (strcmp(method, "requestPointerLock") == 0) {
    bool success = false;
    if (webview_) {
      success = webview_->requestPointerLock();
    }
    g_autoptr(FlValue) result = fl_value_new_bool(success);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  // requestPointerUnlock: returns bool
  if (strcmp(method, "requestPointerUnlock") == 0) {
    bool success = false;
    if (webview_) {
      success = webview_->requestPointerUnlock();
    }
    g_autoptr(FlValue) result = fl_value_new_bool(success);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  fl_method_call_respond_not_implemented(method_call, nullptr);
}

FlMethodErrorResponse* CustomPlatformView::OnListen(FlEventChannel* channel, FlValue* args,
                                                    gpointer user_data) {
  auto* self = static_cast<CustomPlatformView*>(user_data);
  self->event_sink_active_ = true;
  return nullptr;
}

FlMethodErrorResponse* CustomPlatformView::OnCancel(FlEventChannel* channel, FlValue* args,
                                                    gpointer user_data) {
  auto* self = static_cast<CustomPlatformView*>(user_data);
  self->event_sink_active_ = false;
  return nullptr;
}

void CustomPlatformView::EmitCursorChanged(const std::string& cursor_name) {
  if (!event_sink_active_ || event_channel_ == nullptr) {
    return;
  }

  g_autoptr(FlValue) event = to_fl_map({
      {"type", make_fl_value(std::string("cursorChanged"))},
      {"value", make_fl_value(cursor_name)},
  });

  fl_event_channel_send(event_channel_, event, nullptr, nullptr);
}

}  // namespace flutter_inappwebview_plugin
