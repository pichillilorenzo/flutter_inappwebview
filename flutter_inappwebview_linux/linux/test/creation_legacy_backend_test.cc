#include <cassert>
#include <optional>
#include <string>

#include "../in_app_webview/webview_creation_error.h"

namespace flutter_inappwebview_plugin {
using EGLDisplay = void*;
using EGLint = int;
using gpointer = void*;
constexpr EGLDisplay EGL_NO_DISPLAY = nullptr;
constexpr void* EGL_DEFAULT_DISPLAY = nullptr;
struct GdkDisplay {};
struct wpe_view_backend {};
struct wpe_view_backend_exportable_fdo {};
struct WebKitWebViewBackend {};
struct wpe_view_backend_exportable_fdo_egl_client {
  void (*exportImage)();
  void (*exportFdoImage)();
  void (*exportShm)();
  void* reserved1;
  void* reserved2;
};
struct Scenario {
  bool eglInitializes = true;
  bool firstFdoAttempt = true;
  bool fallbackFdoAttempt = true;
  bool createExportable = true;
  bool getBackend = true;
  bool createWrapper = true;
  int fdoCalls = 0;
  int backendCalls = 0;
  int exportsDestroyed = 0;
} scenario;
int eglDisplay;
wpe_view_backend backend;
wpe_view_backend_exportable_fdo exportable;
WebKitWebViewBackend wrapper;
constexpr int wpe_view_activity_state_visible = 1;
constexpr int wpe_view_activity_state_in_window = 2;
constexpr int wpe_view_activity_state_focused = 4;

bool IsWpeWebKitAvailable() { return true; }
GdkDisplay* gdk_display_get_default() { return nullptr; }
EGLDisplay eglGetDisplay(void*) { return &eglDisplay; }
bool eglInitialize(EGLDisplay, EGLint*, EGLint*) { return scenario.eglInitializes; }
bool wpe_fdo_initialize_for_egl_display(EGLDisplay) {
  return ++scenario.fdoCalls == 1 ? scenario.firstFdoAttempt : scenario.fallbackFdoAttempt;
}
wpe_view_backend_exportable_fdo* wpe_view_backend_exportable_fdo_egl_create(
    wpe_view_backend_exportable_fdo_egl_client*, void*, int, int) {
  ++scenario.backendCalls;
  return scenario.createExportable ? &exportable : nullptr;
}
wpe_view_backend* wpe_view_backend_exportable_fdo_get_view_backend(
    wpe_view_backend_exportable_fdo*) {
  return scenario.getBackend ? &backend : nullptr;
}
void wpe_view_backend_exportable_fdo_destroy(wpe_view_backend_exportable_fdo*) {
  ++scenario.exportsDestroyed;
}
WebKitWebViewBackend* webkit_web_view_backend_new(wpe_view_backend*,
                                                void (*)(gpointer), gpointer) {
  return scenario.createWrapper ? &wrapper : nullptr;
}
void wpe_view_backend_dispatch_set_device_scale_factor(wpe_view_backend*, double) {}
void wpe_view_backend_add_activity_state(wpe_view_backend*, int) {}
void wpe_view_backend_set_fullscreen_handler(wpe_view_backend*, bool (*)(void*, bool), void*) {}
void wpe_view_backend_set_pointer_lock_handler(wpe_view_backend*, bool (*)(void*, bool), void*) {}
void errorLog(const std::string&) {}

class InAppWebView {
 public:
  bool InitWpeBackend();
  void SetCreationError(const std::string& stage, const std::string& message,
                        std::optional<int> nativeCode = std::nullopt,
                        std::optional<std::string> nativeDomain = std::nullopt);
  static void wpe_export_fdo_egl_image_callback() {}
  static void wpe_export_shm_buffer_callback() {}
  bool OnDomFullscreenRequest(bool) { return true; }
  bool OnPointerLockRequest(bool) { return true; }
  std::optional<WebViewCreationError> creation_error_;
  EGLDisplay egl_display_ = EGL_NO_DISPLAY;
  wpe_view_backend_exportable_fdo* exportable_ = nullptr;
  wpe_view_backend* wpe_backend_ = nullptr;
  WebKitWebViewBackend* backend_ = nullptr;
  int width_ = 800;
  int height_ = 600;
  double scale_factor_ = 1;
};

#include "creation_backend_under_test.inc"

void testLegacyBackendInitialization() {
  scenario = Scenario{};
  InAppWebView accelerated;
  assert(accelerated.InitWpeBackend());
  assert(!accelerated.creation_error_);
  assert(scenario.fdoCalls == 1);

  scenario = Scenario{};
  scenario.eglInitializes = false;
  scenario.firstFdoAttempt = false;
  InAppWebView softwareFallback;
  assert(softwareFallback.InitWpeBackend());
  assert(!softwareFallback.creation_error_);
  assert(softwareFallback.egl_display_ == EGL_NO_DISPLAY);
  assert(scenario.fdoCalls == 2);

  scenario = Scenario{};
  scenario.firstFdoAttempt = false;
  scenario.fallbackFdoAttempt = false;
  InAppWebView fdoFailure;
  assert(!fdoFailure.InitWpeBackend());
  assert(fdoFailure.creation_error_->stage == "wpe_fdo_initialize_for_egl_display");
  assert(!fdoFailure.creation_error_->nativeCode);
  assert(scenario.backendCalls == 0);

  scenario = Scenario{};
  scenario.createExportable = false;
  InAppWebView exportFailure;
  assert(!exportFailure.InitWpeBackend());
  assert(exportFailure.creation_error_->stage == "wpe_view_backend_exportable_fdo_egl_create");

  scenario = Scenario{};
  scenario.getBackend = false;
  InAppWebView missingBackend;
  assert(!missingBackend.InitWpeBackend());
  assert(missingBackend.creation_error_->stage == "wpe_view_backend_exportable_fdo_get_view_backend");
  assert(missingBackend.exportable_ == nullptr);
  assert(scenario.exportsDestroyed == 1);

  scenario = Scenario{};
  scenario.createWrapper = false;
  InAppWebView wrapperFailure;
  assert(!wrapperFailure.InitWpeBackend());
  assert(wrapperFailure.creation_error_->stage == "webkit_web_view_backend_new");
  assert(wrapperFailure.wpe_backend_ == nullptr && wrapperFailure.exportable_ == nullptr);
  assert(scenario.exportsDestroyed == 1);
}
}  // namespace flutter_inappwebview_plugin

int main() {
  flutter_inappwebview_plugin::testLegacyBackendInitialization();
}
