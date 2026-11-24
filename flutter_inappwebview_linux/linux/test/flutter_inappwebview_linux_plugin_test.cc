#include <gtest/gtest.h>

#include "flutter_inappwebview_linux_plugin_private.h"

namespace flutter_inappwebview_linux {
namespace test {

// A missing registrar/window must be handled without a display or WebView.
TEST(FlutterInappwebviewLinuxPlugin, HandlesMissingRegistrarAndWindow) {
  EXPECT_EQ(flutter_inappwebview_linux_plugin_get_view(nullptr), nullptr);
  EXPECT_EQ(flutter_inappwebview_linux_plugin_get_window(nullptr), nullptr);
  EXPECT_EQ(flutter_inappwebview_linux_plugin_get_monitor_refresh_rate(nullptr), 0);
  EXPECT_EQ(
      flutter_inappwebview_linux_plugin_get_monitor_refresh_rate_for_window(nullptr),
      0);
}

}  // namespace test
}  // namespace flutter_inappwebview_linux
