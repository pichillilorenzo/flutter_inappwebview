#include <cstdlib>
#include <iostream>

#include "../utils/wpe_bundle_paths.h"

int main() {
  flutter_inappwebview_plugin::ConfigureBundledWebKitPaths();

  const char* execPath = std::getenv("WEBKIT_EXEC_PATH");
  const char* bundlePath = std::getenv("WEBKIT_INJECTED_BUNDLE_PATH");
  const char* libraryPath = std::getenv("LD_LIBRARY_PATH");
  std::cout << "EXEC=" << (execPath ? execPath : "<unset>") << '\n'
            << "BUNDLE=" << (bundlePath ? bundlePath : "<unset>") << '\n'
            << "LD=" << (libraryPath ? libraryPath : "<unset>") << '\n';
}
