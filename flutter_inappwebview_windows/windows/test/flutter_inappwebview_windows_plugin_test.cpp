#include <gtest/gtest.h>

#include <memory>

#include "in_app_webview/browser_process_gate.h"
#include "in_app_webview/webview_visibility_state.h"
#include "types/base_callback_result.h"

namespace flutter_inappwebview_plugin::test {

namespace {

// Injects a counting fake probe, a manual clock and recording timer hooks.
struct GateHarness {
  int probeCount = 0;
  bool probeResult = false;
  unsigned long long now = 0;
  int scheduled = 0;
  int canceled = 0;
  BrowserProcessGateRegistry gate;

  GateHarness()
      : gate([this](unsigned long) { ++probeCount; return probeResult; },
             [this] { return now; },
             [this](unsigned long) { ++scheduled; },
             [this](unsigned long) { ++canceled; },
             250) {}
};

}  // namespace

TEST(BrowserProcessGateRegistry, OneProbeSharedByAllWaitersInInterval) {
  GateHarness h;
  int a = 0, b = 0, c = 0;
  EXPECT_FALSE(h.gate.tryAcquire(7, &a));
  EXPECT_FALSE(h.gate.tryAcquire(7, &b));
  EXPECT_FALSE(h.gate.tryAcquire(7, &c));
  EXPECT_EQ(h.probeCount, 1);
  EXPECT_EQ(h.scheduled, 1);
}

TEST(BrowserProcessGateRegistry, RetryTickProbesOncePerInterval) {
  GateHarness h;
  int a = 0;
  h.gate.tryAcquire(7, &a);
  h.now += 250;
  EXPECT_TRUE(h.gate.takeWaitersIfResponsive(7).empty());
  EXPECT_EQ(h.probeCount, 2);
}

TEST(BrowserProcessGateRegistry, DrainsAllWaitersWhenBrowserAnswers) {
  GateHarness h;
  int a = 0, b = 0;
  h.gate.tryAcquire(7, &a);
  h.gate.tryAcquire(7, &b);
  h.probeResult = true;
  h.now += 250;
  const auto drained = h.gate.takeWaitersIfResponsive(7);
  EXPECT_EQ(drained.size(), 2u);
  EXPECT_EQ(h.canceled, 1);
  // A drained waiter re-enters tryAcquire on the cached verdict, probe-free.
  const int probesBefore = h.probeCount;
  EXPECT_TRUE(h.gate.tryAcquire(7, &a));
  EXPECT_EQ(h.probeCount, probesBefore);
}

TEST(BrowserProcessGateRegistry, ResponsiveVerdictCachedWithinInterval) {
  GateHarness h;
  h.probeResult = true;
  int a = 0, b = 0;
  EXPECT_TRUE(h.gate.tryAcquire(7, &a));
  EXPECT_TRUE(h.gate.tryAcquire(7, &b));
  EXPECT_EQ(h.probeCount, 1);
}

TEST(BrowserProcessGateRegistry, SeparateBrowsersProbeIndependently) {
  GateHarness h;
  int a = 0;
  h.gate.tryAcquire(7, &a);
  h.gate.tryAcquire(8, &a);
  EXPECT_EQ(h.probeCount, 2);
  EXPECT_EQ(h.scheduled, 2);
}

TEST(BrowserProcessGateRegistry, RemovedWaiterIsNotDrained) {
  GateHarness h;
  int a = 0, b = 0;
  h.gate.tryAcquire(7, &a);
  h.gate.tryAcquire(7, &b);
  h.gate.removeWaiter(&a);
  h.probeResult = true;
  h.now += 250;
  const auto drained = h.gate.takeWaitersIfResponsive(7);
  ASSERT_EQ(drained.size(), 1u);
  EXPECT_EQ(drained[0], &b);
}

TEST(BrowserProcessGateRegistry, EmptyQueueStopsRetryWithoutProbing) {
  GateHarness h;
  int a = 0;
  h.gate.tryAcquire(7, &a);
  h.gate.removeWaiter(&a);
  const int probesBefore = h.probeCount;
  h.now += 250;
  EXPECT_TRUE(h.gate.takeWaitersIfResponsive(7).empty());
  EXPECT_EQ(h.probeCount, probesBefore);
  EXPECT_EQ(h.canceled, 1);
}

TEST(BrowserProcessGateRegistry, InvalidateForcesFreshProbe) {
  GateHarness h;
  h.probeResult = true;
  int a = 0;
  h.gate.tryAcquire(7, &a);
  h.gate.invalidate(7);
  h.gate.tryAcquire(7, &a);
  EXPECT_EQ(h.probeCount, 2);
}

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

TEST(WebViewVisibilityState, NeedsApplyUntilFirstDelivery) {
  WebViewVisibilityState state;
  EXPECT_TRUE(state.needsApply());
  state.markApplied();
  EXPECT_FALSE(state.needsApply());
}

TEST(WebViewVisibilityState, RedundantTransitionNeedsNoDelivery) {
  WebViewVisibilityState state;
  state.markApplied();
  state.setPaused(true);
  state.markApplied();
  state.setPaused(true);
  EXPECT_FALSE(state.needsApply());
}

TEST(WebViewVisibilityState, DeferredDeliveryCoalescesToLatestState) {
  WebViewVisibilityState state;
  state.markApplied();
  // Visible -> paused -> resumed while delivery was deferred: nothing to send.
  state.setPaused(true);
  state.setPaused(false);
  EXPECT_FALSE(state.needsApply());
  // A net state change still needs one delivery.
  state.setHostWindowMinimized(true);
  EXPECT_TRUE(state.needsApply());
  state.markApplied();
  EXPECT_FALSE(state.needsApply());
}

}  // namespace flutter_inappwebview_plugin::test
