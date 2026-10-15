#include <cassert>
#include <cmath>

#include "../utils/gdk_scale.h"

using flutter_inappwebview_plugin::EffectiveWpeScale;
using flutter_inappwebview_plugin::ParseExplicitGdkScale;

int main() {
  assert(!ParseExplicitGdkScale(nullptr));
  assert(!ParseExplicitGdkScale(""));
  assert(!ParseExplicitGdkScale("0"));
  assert(!ParseExplicitGdkScale("0.5"));
  assert(!ParseExplicitGdkScale("1.5"));
  assert(!ParseExplicitGdkScale("5"));
  assert(!ParseExplicitGdkScale("2junk"));
  assert(!ParseExplicitGdkScale("nan"));
  assert(!ParseExplicitGdkScale("inf"));
  assert(ParseExplicitGdkScale("1").value() == 1.0);
  assert(ParseExplicitGdkScale("2").value() == 2.0);
  assert(ParseExplicitGdkScale("4").value() == 4.0);
  assert(EffectiveWpeScale(1.0, "2") == 2.0);
  assert(EffectiveWpeScale(3.0, "2") == 3.0);
  assert(EffectiveWpeScale(1.0, "2junk") == 1.0);
}
