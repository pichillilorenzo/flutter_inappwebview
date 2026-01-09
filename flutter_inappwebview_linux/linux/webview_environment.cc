#include "webview_environment.h"

#include <wpe/webkit.h>

#include <cstring>
#include <sstream>

#include "utils/log.h"

namespace flutter_inappwebview_plugin {

namespace {
// Helper to compare method names
bool string_equals(const gchar* a, const char* b) {
  return strcmp(a, b) == 0;
}
}  // namespace

WebViewEnvironment::WebViewEnvironment(FlPluginRegistrar* registrar)
    : ChannelDelegate(fl_plugin_registrar_get_messenger(registrar), METHOD_CHANNEL_NAME) {}

WebViewEnvironment::~WebViewEnvironment() {
  debugLog("dealloc WebViewEnvironment");
}

void WebViewEnvironment::HandleMethodCall(FlMethodCall* method_call) {
  const gchar* method = fl_method_call_get_name(method_call);

  if (string_equals(method, "getAvailableVersion")) {
    std::string version = getAvailableVersion();
    fl_method_call_respond_success(method_call, fl_value_new_string(version.c_str()), nullptr);
  } else {
    fl_method_call_respond_not_implemented(method_call, nullptr);
  }
}

std::string WebViewEnvironment::getAvailableVersion() {
  // Get the WPE WebKit version using the webkit version functions
  guint major = webkit_get_major_version();
  guint minor = webkit_get_minor_version();
  guint micro = webkit_get_micro_version();

  std::ostringstream version;
  version << major << "." << minor << "." << micro;
  return version.str();
}

}  // namespace flutter_inappwebview_plugin
