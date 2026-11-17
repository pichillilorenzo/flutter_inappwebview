#include "surface_pool_slot_test_cases.h"
#include <iostream>

int main() {
  try {
    flutter_inappwebview_plugin::test::RunSurfacePoolSlotTests();
    std::cout << "Surface slot ownership tests passed\n";
    return 0;
  }
  catch (const std::exception& error) {
    std::cerr << error.what() << "\n";
    return 1;
  }
}
