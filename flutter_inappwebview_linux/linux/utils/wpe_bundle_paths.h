// Utility to redirect WPE WebKit to helper processes / injected bundle that are
// bundled next to the plugin, so the app runs without a system WPE install.

#ifndef FLUTTER_INAPPWEBVIEW_LINUX_UTILS_WPE_BUNDLE_PATHS_H_
#define FLUTTER_INAPPWEBVIEW_LINUX_UTILS_WPE_BUNDLE_PATHS_H_

namespace flutter_inappwebview_plugin {

// If the WPE helper processes / injected bundle were bundled next to the plugin
// (see CMakeLists.txt), point WebKit at them via environment variables.
//
// Must be called ONCE at plugin registration, BEFORE any WebKitWebContext is
// created, because WebKit reads these paths (and the child processes inherit the
// environment) only at initialization time.
//
// All-or-nothing: the bundled path is activated only when WPEWebProcess,
// WPENetworkProcess and libWPEInjectedBundle.so are all present and runnable
// (plus WPEGPUProcess when it exists) — a partial redirect would mix bundled
// and compile-time paths. Note: WEBKIT_EXEC_PATH only takes effect when
// libWPEWebKit was built with DEVELOPER_MODE; falls back silently otherwise.
void ConfigureBundledWebKitPaths();

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_LINUX_UTILS_WPE_BUNDLE_PATHS_H_
