#include <gtest/gtest.h>

#include <vector>

#include "in_app_webview/in_app_webview_settings.h"

#ifdef HAVE_WPE_PLATFORM
#include <wpe/headless/wpe-headless.h>
#include <wpe/wpe-platform.h>

namespace flutter_inappwebview_plugin {

// Headless can release a frame before the Flutter raster thread consumes it.
// The guard must run before WebKit's handler, even though WebKit connects first.
TEST(WpePlatformBuffers, ReleaseHookPrecedesExistingHandlerAndFiltersView) {
  g_autoptr(WPEDisplay) display = wpe_display_headless_new();
  g_autoptr(WPEView) view = wpe_view_new(display);
  g_autoptr(WPEView) other_view = wpe_view_new(display);
  ASSERT_NE(view, nullptr);
  ASSERT_NE(other_view, nullptr);
  struct State {
    WPEView* view;
    std::vector<int> order;
  } state{view, {}};
  const auto handler = g_signal_connect(view, "buffer-released",
                                        G_CALLBACK(+[](WPEView*, WPEBuffer*, gpointer data) {
                                          static_cast<State*>(data)->order.push_back(2);
                                        }),
                                        &state);
  const guint signal = g_signal_lookup("buffer-released", WPE_TYPE_VIEW);
  const auto hook = g_signal_add_emission_hook(
      signal, 0,
      +[](GSignalInvocationHint*, guint count, const GValue* values, gpointer data) -> gboolean {
        auto* state = static_cast<State*>(data);
        if (count == 2 && g_value_get_object(&values[0]) == state->view) {
          state->order.push_back(1);
        }
        return TRUE;
      },
      &state, nullptr);
  // No graphics buffer is needed to verify the signal ordering contract.
  g_signal_emit_by_name(other_view, "buffer-released", nullptr);
  EXPECT_TRUE(state.order.empty());
  g_signal_emit_by_name(view, "buffer-released", nullptr);
  EXPECT_EQ(state.order, (std::vector<int>{1, 2}));
  g_signal_remove_emission_hook(signal, hook);
  state.order.clear();
  g_signal_emit_by_name(view, "buffer-released", nullptr);
  EXPECT_EQ(state.order, (std::vector<int>{2}));
  g_signal_handler_disconnect(view, handler);
}

// No display connection or WebProcess is needed to exercise WPESettings.
TEST(WpePlatformSettings, AppliesAndClearsReducedMotionPreference) {
  g_autoptr(WPEDisplay) display = wpe_display_headless_new();
  ASSERT_NE(display, nullptr);
  WPESettings* preferences = wpe_display_get_settings(display);
  ASSERT_NE(preferences, nullptr);
#ifdef WPE_SETTING_REDUCED_MOTION
  const char* key = WPE_SETTING_REDUCED_MOTION;
#else
  const char* key = WPE_SETTING_DISABLE_ANIMATIONS;
#endif

  InAppWebViewSettings settings;
  for (bool value : {true, false}) {
    settings.disableAnimations = value;
    settings.applyWpePlatformSettings(display);
    GError* error = nullptr;
    const bool actual = wpe_settings_get_boolean(preferences, key, &error);
    EXPECT_EQ(error, nullptr);
    EXPECT_EQ(actual, value);
    g_clear_error(&error);
  }
}

}  // namespace flutter_inappwebview_plugin
#endif
