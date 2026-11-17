#include <exception>
#include <iostream>

#include "async_resource_build_test_cases.h"

int main() {
  using namespace flutter_inappwebview_plugin::test::async_resource_build_test;
  try {
    lateCompletion();
    closeDuringInitialization();
    closeDuringInitialization(true);
    unavailableComparer();
  }
  catch (const std::exception& error) {
    std::cerr << error.what() << '\n';
    return 1;
  }
  std::cout << "AsyncResourceBuild: all 4 lifecycle cases passed\n";
}
