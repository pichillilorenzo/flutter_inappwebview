// cl /nologo /std:c++17 /EHsc /W4 native_focus_test_main.cpp user32.lib
#include <exception>
#include <iostream>
#include "native_focus_test_cases.h"

int main() {
  using namespace flutter_inappwebview_plugin::test::native_focus_test;
  try {
    focusInsideHostOnly();
  }
  catch (const std::exception& error) {
    std::cerr << "native focus tests failed: " << error.what() << '\n';
    return 1;
  }
  std::cout << "NativeFocus: all cases passed\n";
}
