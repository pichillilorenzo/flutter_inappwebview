#include <gtest/gtest.h>

#include <memory>

#include "in_app_webview/webview_visibility_state.h"
#include "types/base_callback_result.h"

namespace flutter_inappwebview_plugin::test {

namespace {

std::unique_ptr<BaseCallbackResult<bool>> makeCallback(bool* ran) {
  auto callback = std::make_unique<BaseCallbackResult<bool>>();
  callback->decodeResult = [](const flutter::EncodableValue* value) {
    return std::make_optional(std::get<bool>(*value));
  };
  callback->defaultBehaviour = [ran](const std::optional<bool>) {
    *ran = true;
  };
  callback->error = [ran](const std::string&, const std::string&,
                          const flutter::EncodableValue*) { *ran = true; };
  return callback;
}

}  // namespace

TEST(BaseCallbackResult, RunsHandlersWithoutOwner) {
  auto ran = false;
  auto callback = makeCallback(&ran);
  callback->Success(flutter::EncodableValue(true));
  EXPECT_TRUE(ran);
}

TEST(BaseCallbackResult, RunsHandlersWhileOwnerIsAlive) {
  auto ran = false;
  auto owner = std::make_shared<int>(0);
  auto callback = makeCallback(&ran);
  callback->owner = owner;
  callback->Success(flutter::EncodableValue(true));
  EXPECT_TRUE(ran);
}

TEST(BaseCallbackResult, DropsHandlersOnceOwnerIsGone) {
  auto ran = false;
  auto owner = std::make_shared<int>(0);
  auto callback = makeCallback(&ran);
  callback->owner = owner;
  owner.reset();
  callback->Success(flutter::EncodableValue(true));
  EXPECT_FALSE(ran);
}

TEST(BaseCallbackResult, DropsErrorAndNotImplementedOnceOwnerIsGone) {
  auto ran = false;
  auto owner = std::make_shared<int>(0);
  auto errorCallback = makeCallback(&ran);
  errorCallback->owner = owner;
  auto notImplementedCallback = makeCallback(&ran);
  notImplementedCallback->owner = owner;
  owner.reset();
  errorCallback->Error("code", "message");
  notImplementedCallback->NotImplemented();
  EXPECT_FALSE(ran);
}

TEST(BaseCallbackResult, RunsOwnerGoneCleanupExactlyOnce) {
  auto owner = std::make_shared<int>(0);
  auto callback = std::make_unique<BaseCallbackResult<bool>>();
  auto cleanupCount = 0;
  callback->owner = owner;
  callback->onOwnerGone = [&cleanupCount] { ++cleanupCount; };
  owner.reset();

  callback->Success(flutter::EncodableValue(true));
  callback->Error("code", "message");
  callback->NotImplemented();

  EXPECT_EQ(cleanupCount, 1);
}

TEST(BaseCallbackResult, DoesNotRunOwnerGoneCleanupWhileOwnerIsAlive) {
  auto owner = std::make_shared<int>(0);
  auto callback = std::make_unique<BaseCallbackResult<bool>>();
  auto cleanupCount = 0;
  callback->owner = owner;
  callback->onOwnerGone = [&cleanupCount] { ++cleanupCount; };

  callback->Success(flutter::EncodableValue(true));

  EXPECT_EQ(cleanupCount, 0);
}

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
