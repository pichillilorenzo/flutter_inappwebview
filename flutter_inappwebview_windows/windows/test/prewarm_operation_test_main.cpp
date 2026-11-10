#include <exception>
#include <iostream>
#include "prewarm_operation_test_cases.h"

int main() {
  try {
    flutter_inappwebview_plugin::test::runPrewarmOperationTests();
  }
  catch (const std::exception& error) {
    std::cerr << error.what() << '\n';
    return 1;
  }
  std::cout << "PrewarmOperation tests passed\n";
}
