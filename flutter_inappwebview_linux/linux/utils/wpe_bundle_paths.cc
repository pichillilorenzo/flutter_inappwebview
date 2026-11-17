// dladdr is a GNU extension declared only under _GNU_SOURCE.
#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif

#include "wpe_bundle_paths.h"

#include <dlfcn.h>
#include <glib.h>
#include <glib/gstdio.h>

#include <string>

#include "log.h"

namespace flutter_inappwebview_plugin {

namespace {

// Directory that contains this plugin's shared library. Resolved via dladdr so
// it is correct regardless of the working directory the app is launched from.
std::string PluginBundleDirectory() {
  Dl_info info;
  if (dladdr(reinterpret_cast<void*>(&PluginBundleDirectory), &info) == 0 ||
      info.dli_fname == nullptr) {
    return {};
  }
  gchar* dir = g_path_get_dirname(info.dli_fname);
  std::string result = dir ? dir : "";
  g_free(dir);
  return result;
}

// A bundled file is installed via CMake install(FILES), which drops the exec bit,
// so restore it before use. Silently ignores chmod failures (e.g. read-only mount)
// and reports whether the file ends up runnable.
bool EnsureExecutable(const std::string& path) {
  if (!g_file_test(path.c_str(), G_FILE_TEST_EXISTS)) {
    return false;
  }
  if (!g_file_test(path.c_str(), G_FILE_TEST_IS_EXECUTABLE)) {
    g_chmod(path.c_str(), 0755);
  }
  return g_file_test(path.c_str(), G_FILE_TEST_IS_EXECUTABLE);
}

// Prepend dir to LD_LIBRARY_PATH so spawned helper processes resolve the bundled
// libWPEWebKit; their own RPATH points at the (absent) system install dir.
// Idempotent: register_with_registrar may run once per FlView.
void PrependLibraryPath(const std::string& dir) {
  const char* current = g_getenv("LD_LIBRARY_PATH");
  if (current && *current) {
    const std::string path(current);
    if (path == dir || path.rfind(dir + ":", 0) == 0) {
      return;
    }
    g_setenv("LD_LIBRARY_PATH", (dir + ":" + path).c_str(), TRUE);
  } else {
    g_setenv("LD_LIBRARY_PATH", dir.c_str(), TRUE);
  }
}

}  // namespace

void ConfigureBundledWebKitPaths() {
  // An explicit developer override wins outright; also skip the LD_LIBRARY_PATH
  // change so a custom setup is left untouched.
  if (g_getenv("WEBKIT_EXEC_PATH") != nullptr ||
      g_getenv("WEBKIT_INJECTED_BUNDLE_PATH") != nullptr) {
    return;
  }

  const std::string bundleDir = PluginBundleDirectory();
  if (bundleDir.empty()) {
    return;
  }

  // All-or-nothing: with WEBKIT_EXEC_PATH set but no runnable injected bundle
  // beside it, WebKit falls back to the compile-time PKGLIBDIR bundle — absent
  // or version-mismatched on a clean machine. Validate the full set first.
  bool useBundled = EnsureExecutable(bundleDir + "/WPEWebProcess") &&
                    EnsureExecutable(bundleDir + "/WPENetworkProcess") &&
                    g_file_test((bundleDir + "/libWPEInjectedBundle.so").c_str(),
                                G_FILE_TEST_EXISTS);

  // WPEGPUProcess is optional, but when present it must be runnable too.
  if (useBundled &&
      g_file_test((bundleDir + "/WPEGPUProcess").c_str(), G_FILE_TEST_EXISTS)) {
    useBundled = EnsureExecutable(bundleDir + "/WPEGPUProcess");
  }
  if (!useBundled) {
    return;
  }

  g_setenv("WEBKIT_EXEC_PATH", bundleDir.c_str(), FALSE);
  g_setenv("WEBKIT_INJECTED_BUNDLE_PATH", bundleDir.c_str(), FALSE);
  PrependLibraryPath(bundleDir);
  debugLog("Using bundled WPE runtime (helpers + injected bundle) from " +
           bundleDir);
}

}  // namespace flutter_inappwebview_plugin
