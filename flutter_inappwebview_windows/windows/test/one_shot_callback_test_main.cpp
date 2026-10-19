#include <exception>
#include <iostream>

#include "one_shot_callback_test_cases.h"

int main()
{
  try {
    flutter_inappwebview_plugin::test::runOneShotCallbackTests();
  }
  catch (const std::exception& error) {
    std::cerr << "OneShotCallback tests failed: " << error.what() << '\n';
    return 1;
  }
  std::cout << "OneShotCallback tests passed\n";
  return 0;
}
