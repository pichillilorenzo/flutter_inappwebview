#include <gtest/gtest.h>

#include "in_app_webview/webview_visibility_state.h"

namespace flutter_inappwebview_plugin::test {

TEST(WebViewVisibilityState, StartsVisible) {
  WebViewVisibilityState state;
  EXPECT_TRUE(state.shouldBeVisible());
}

TEST(WebViewVisibilityState, StartsHiddenWhenCreatedWhileMinimized) {
  WebViewVisibilityState state(true);
  EXPECT_TRUE(state.isHostWindowMinimized());
  EXPECT_FALSE(state.shouldBeVisible());
}

TEST(WebViewVisibilityState, MinimizeAndRestoreVisibleView) {
  WebViewVisibilityState state;
  state.setHostWindowMinimized(true);
  EXPECT_FALSE(state.shouldBeVisible());
  state.setHostWindowMinimized(false);
  EXPECT_TRUE(state.shouldBeVisible());
}

TEST(WebViewVisibilityState, PausedBeforeMinimizeStaysHiddenAfterRestore) {
  WebViewVisibilityState state;
  state.setPaused(true);
  state.setHostWindowMinimized(true);
  state.setHostWindowMinimized(false);
  EXPECT_TRUE(state.isPaused());
  EXPECT_FALSE(state.shouldBeVisible());
}

TEST(WebViewVisibilityState, PausedDuringMinimizeStaysHiddenAfterRestore) {
  WebViewVisibilityState state;
  state.setHostWindowMinimized(true);
  state.setPaused(true);
  state.setHostWindowMinimized(false);
  EXPECT_FALSE(state.shouldBeVisible());
}

TEST(WebViewVisibilityState, ResumeDuringMinimizeWaitsForRestore) {
  WebViewVisibilityState state;
  state.setPaused(true);
  state.setHostWindowMinimized(true);
  state.setPaused(false);
  EXPECT_FALSE(state.shouldBeVisible());
  state.setHostWindowMinimized(false);
  EXPECT_TRUE(state.shouldBeVisible());
}

TEST(WebViewVisibilityState, DuplicateWindowTransitionsAreIdempotent) {
  WebViewVisibilityState state;
  state.setHostWindowMinimized(true);
  state.setHostWindowMinimized(true);
  EXPECT_FALSE(state.shouldBeVisible());
  state.setHostWindowMinimized(false);
  state.setHostWindowMinimized(false);
  EXPECT_TRUE(state.shouldBeVisible());
}

}  // namespace flutter_inappwebview_plugin::test
