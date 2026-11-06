#include "delayed_texture_trim_test_cases.h"
#include <iostream>

int main() {
  try {
    flutter_inappwebview_plugin::test::delayed_texture_trim_test::RunAll();
    std::cout << "6 delayed texture trim tests passed (virtual clock)\n";
    return 0;
  }
  catch (const std::exception& error) {
    std::cerr << error.what() << "\n";
    return 1;
  }
}
