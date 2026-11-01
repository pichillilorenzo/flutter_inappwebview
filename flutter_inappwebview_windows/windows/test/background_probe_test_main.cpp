#include <exception>
#include <iostream>
#include "background_probe_test_cases.h"

int main() {
  using namespace flutter_inappwebview_plugin::test::background_probe_test;
  try {
    pendingThenReady();
    unsupportedIsReady();
    throwingProbe();
    failedLaunch();
    offThreadAndDestroyedWhilePending();
  }
  catch (const std::exception& error) {
    std::cerr << error.what() << '\n';
    return 1;
  }
  std::cout << "BackgroundProbe: all 5 lifecycle cases passed\n";
}
