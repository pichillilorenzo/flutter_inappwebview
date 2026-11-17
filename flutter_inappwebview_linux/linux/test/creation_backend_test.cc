// The runner injects the production backend initialization methods. Only the
// external WPE/GLib calls are fakes, so these cases exercise actual failure and
// software-fallback decisions without requiring a display server or WebKit.
#include <cassert>
#include <optional>
#include <string>

#include "../in_app_webview/webview_creation_error.h"

namespace flutter_inappwebview_plugin {
struct WPEDisplay {};
struct GError {
  int code = 12;
  int domain = 1;
  const char* message = "connection refused";
};

struct Scenario {
  bool available = true;
  bool createDisplay = true;
  bool connect = true;
  bool provideError = true;
  bool eglAvailable = true;
  int displayCalls = 0;
  int eglCalls = 0;
  int errorsFreed = 0;
  int displaysReleased = 0;
} scenario;
WPEDisplay display;
int eglDisplay;

bool IsWpeWebKitAvailable() { return scenario.available; }
WPEDisplay* wpe_display_headless_new() {
  ++scenario.displayCalls;
  return scenario.createDisplay ? &display : nullptr;
}
bool wpe_display_connect(WPEDisplay*, GError** error) {
  if (!scenario.connect && scenario.provideError) *error = new GError;
  return scenario.connect;
}
void* wpe_display_get_egl_display(WPEDisplay*, GError** error) {
  ++scenario.eglCalls;
  if (!scenario.eglAvailable) {
    *error = new GError;
    return nullptr;
  }
  return &eglDisplay;
}
const char* g_quark_to_string(int) { return "wpe-test-domain"; }
void g_clear_error(GError** error) {
  if (*error) {
    ++scenario.errorsFreed;
    delete *error;
    *error = nullptr;
  }
}
void g_clear_object(WPEDisplay** object) {
  if (*object) ++scenario.displaysReleased;
  *object = nullptr;
}
void errorLog(const std::string&) {}

class InAppWebView {
 public:
  bool InitWpeBackend();
  void SetCreationError(const std::string& stage, const std::string& message,
                        std::optional<int> nativeCode = std::nullopt,
                        std::optional<std::string> nativeDomain = std::nullopt);
  std::optional<WebViewCreationError> creation_error_;
  WPEDisplay* wpe_display_ = nullptr;
  void* egl_display_ = nullptr;
};

#include "creation_backend_under_test.inc"

void testBackendInitialization() {
  scenario = Scenario{};
  scenario.available = false;
  InAppWebView unavailable;
  assert(!unavailable.InitWpeBackend());
  assert(unavailable.creation_error_->stage == "wpe_loader_init");
  assert(scenario.displayCalls == 0);

  scenario = Scenario{};
  scenario.createDisplay = false;
  InAppWebView noDisplay;
  assert(!noDisplay.InitWpeBackend());
  assert(noDisplay.creation_error_->stage == "wpe_display_headless_new");
  assert(!noDisplay.creation_error_->nativeCode.has_value());
  assert(scenario.eglCalls == 0);

  scenario = Scenario{};
  scenario.connect = false;
  InAppWebView connectionFailure;
  assert(!connectionFailure.InitWpeBackend());
  assert(connectionFailure.creation_error_->stage == "wpe_display_connect");
  assert(connectionFailure.creation_error_->message == "connection refused");
  assert(connectionFailure.creation_error_->nativeCode == 12);
  assert(connectionFailure.creation_error_->nativeDomain == "wpe-test-domain");
  assert(connectionFailure.wpe_display_ == nullptr);
  assert(scenario.errorsFreed == 1 && scenario.displaysReleased == 1);
  assert(scenario.eglCalls == 0);

  scenario = Scenario{};
  scenario.connect = false;
  scenario.provideError = false;
  InAppWebView noNativeError;
  assert(!noNativeError.InitWpeBackend());
  assert(!noNativeError.creation_error_->nativeCode.has_value());
  assert(!noNativeError.creation_error_->nativeDomain.has_value());
  assert(!noNativeError.creation_error_->message.empty());

  scenario = Scenario{};
  scenario.eglAvailable = false;
  InAppWebView software;
  assert(software.InitWpeBackend());
  assert(!software.creation_error_.has_value());
  assert(software.wpe_display_ != nullptr && software.egl_display_ == nullptr);
  assert(scenario.errorsFreed == 1 && scenario.displaysReleased == 0);

  scenario = Scenario{};
  InAppWebView accelerated;
  assert(accelerated.InitWpeBackend());
  assert(!accelerated.creation_error_.has_value());
  assert(accelerated.egl_display_ == &eglDisplay);
}
}  // namespace flutter_inappwebview_plugin

int main() {
  flutter_inappwebview_plugin::testBackendInitialization();
}
