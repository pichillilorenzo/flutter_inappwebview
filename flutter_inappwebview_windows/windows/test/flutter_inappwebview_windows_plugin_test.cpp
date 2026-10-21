#include <gtest/gtest.h>

#include <memory>
#include <string>
#include <vector>

#include "in_app_webview/browser_process_gate.h"
#include "custom_platform_view/frame_compare_gate.h"
#include "surface_pool_slot_test_cases.h"
#include "one_shot_callback_test_cases.h"
#include "in_app_webview/webview_visibility_state.h"
#include "plugin_scripts_js/javascript_bridge_message.h"
#include "types/base_callback_result.h"
#include "types/lifetime_token.h"
#include "utils/flutter_view_hwnd.h"

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

TEST(OneShotCallback, CallbackOwnershipAndCompletionBehavior) {
  runOneShotCallbackTests();
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

// Mirrors CallJsHandlerCallback: Dart replies null for an unregistered
// handler, and the codec delivers it as Success() without a value.
TEST(BaseCallbackResult, NullReplyToPointerResultHasNoValue) {
  BaseCallbackResult<const flutter::EncodableValue*> callback;
  callback.decodeResult = [](const flutter::EncodableValue* value) {
    return std::optional<const flutter::EncodableValue*>(value);
  };
  auto ran = false;
  auto hadValue = true;
  callback.defaultBehaviour =
      [&](const std::optional<const flutter::EncodableValue*> response) {
        ran = true;
        hadValue = response.has_value();
      };

  callback.Success();

  EXPECT_TRUE(ran);
  EXPECT_FALSE(hadValue);
}

TEST(BaseCallbackResult, PointerReplyKeepsItsValue) {
  BaseCallbackResult<const flutter::EncodableValue*> callback;
  callback.decodeResult = [](const flutter::EncodableValue* value) {
    return std::optional<const flutter::EncodableValue*>(value);
  };
  std::string seen;
  callback.defaultBehaviour =
      [&](const std::optional<const flutter::EncodableValue*> response) {
        if (response.has_value()) {
          seen = std::get<std::string>(*response.value());
        }
      };

  callback.Success(flutter::EncodableValue(std::string("\"ok\"")));

  EXPECT_EQ(seen, "\"ok\"");
}

TEST(JavaScriptBridgeMessage, SplitsHeaderFromUnparsedArguments) {
  const auto call = JavaScriptBridgeMessage::parseCall(
      std::string(R"(fiaw1:{"name":"callHandler","body":{"handlerName":"h"}})") +
      "\n" + R"(["line\nbreak",{"k":1}])");
  ASSERT_TRUE(call.has_value());
  EXPECT_EQ(call->header["body"]["handlerName"], "h");
  EXPECT_EQ(call->argsJson, R"(["line\nbreak",{"k":1}])");
}

TEST(JavaScriptBridgeMessage, IgnoresStringsThatAreNotCalls) {
  EXPECT_FALSE(JavaScriptBridgeMessage::parseCall("hello").has_value());
  EXPECT_FALSE(
      JavaScriptBridgeMessage::parseCall(R"(fiaw1:{"a":1})").has_value());
  EXPECT_FALSE(
      JavaScriptBridgeMessage::parseCall("fiaw1:not json\n[]").has_value());
}

TEST(JavaScriptBridgeMessage, ResolutionEmbedsTheDartJson) {
  EXPECT_EQ(JavaScriptBridgeMessage::resolution("flutter_inappwebview", 7,
                                                R"({"a":[1,2]})"),
            R"({"flutter_inappwebview":{"id":7,"v":{"a":[1,2]}}})");
}

TEST(JavaScriptBridgeMessage, ErrorsAreEscapedInBothPaths) {
  const std::string message = "bad 'quote'\nand \\ slash";
  const auto rejection = nlohmann::json::parse(
      JavaScriptBridgeMessage::rejection("b", 3, message));
  EXPECT_EQ(rejection["b"]["e"], message);
  const auto script =
      JavaScriptBridgeMessage::settleScript("b", 3, "null", message);
  EXPECT_NE(script.find(R"(new Error("bad 'quote'\nand \\ slash"))"),
            std::string::npos);
}

TEST(SurfacePoolSlot, PreservesOwnershipAcrossCaptureAndRasterThreads) {
  EXPECT_NO_THROW(RunSurfacePoolSlotTests());
}

TEST(FrameCompareGate, KeepsComparingWhileIdenticalFramesArrive) {
  FrameCompareGate gate(4, 10);
  for (int i = 0; i < 50; ++i) {
    ASSERT_TRUE(gate.shouldCompare());
    gate.recordResult(i % 3 == 0);
  }
}

TEST(FrameCompareGate, PausesAfterARunOfChangedFramesAndRetries) {
  FrameCompareGate gate(4, 10);
  for (int i = 0; i < 4; ++i) {
    ASSERT_TRUE(gate.shouldCompare());
    gate.recordResult(true);
  }
  for (int i = 0; i < 10; ++i) {
    EXPECT_FALSE(gate.shouldCompare());
  }
  EXPECT_TRUE(gate.shouldCompare());
}

TEST(FrameCompareGate, AnIdenticalFrameRestartsTheRun) {
  FrameCompareGate gate(4, 10);
  for (int i = 0; i < 3; ++i) {
    gate.shouldCompare();
    gate.recordResult(true);
  }
  gate.shouldCompare();
  gate.recordResult(false);
  gate.shouldCompare();
  gate.recordResult(true);
  EXPECT_TRUE(gate.shouldCompare());
}

TEST(FrameCompareGate, ResetEndsAPause) {
  FrameCompareGate gate(1, 10);
  gate.shouldCompare();
  gate.recordResult(true);
  EXPECT_FALSE(gate.shouldCompare());
  gate.reset();
  EXPECT_TRUE(gate.shouldCompare());
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

TEST(LifetimeToken, WeakHandleTracksOwnerLifetime) {
  std::weak_ptr<void> alive;
  {
    LifetimeToken token;
    alive = token.weak();
    EXPECT_FALSE(alive.expired());
    EXPECT_FALSE(token.expired());
  }
  EXPECT_TRUE(alive.expired());
}

TEST(LifetimeToken, ExpireInvalidatesHandlesBeforeDestruction) {
  LifetimeToken token;
  const auto alive = token.weak();
  token.expire();
  EXPECT_TRUE(alive.expired());
  EXPECT_TRUE(token.expired());
}

}  // namespace flutter_inappwebview_plugin::test

namespace flutter_inappwebview_plugin::test {

TEST(PendingWebViewHosts, SurvivesSourceWindowClosureAndReattaches) {
  const auto source = CreateWindowEx(0, L"STATIC", L"", WS_POPUP,
    0, 0, 100, 100, nullptr, nullptr, nullptr, nullptr);
  const auto destination = CreateWindowEx(0, L"STATIC", L"", WS_POPUP,
    0, 0, 100, 100, nullptr, nullptr, nullptr, nullptr);
  const auto parking = CreateWindowEx(0, L"STATIC", L"", WS_POPUP,
    0, 0, 0, 0, nullptr, nullptr, nullptr, nullptr);
  const auto pendingHost = CreateWindowEx(0, L"STATIC", L"", WS_CHILD,
    0, 0, 50, 50, source, nullptr, nullptr, nullptr);
  const auto otherHost = CreateWindowEx(0, L"STATIC", L"", WS_CHILD,
    0, 0, 50, 50, destination, nullptr, nullptr, nullptr);
  ASSERT_TRUE(source && destination && parking && pendingHost && otherHost);

  const std::set<HWND> pending{ pendingHost, otherHost };
  ParkPendingWebViewHosts(pending, source, parking);
  DestroyWindow(source);
  EXPECT_TRUE(IsWindow(pendingHost));
  EXPECT_EQ(GetParent(pendingHost), parking);
  EXPECT_EQ(GetParent(otherHost), destination);
  SetParent(pendingHost, destination);
  DestroyWindow(parking);
  EXPECT_TRUE(IsWindow(pendingHost));
  EXPECT_EQ(GetParent(pendingHost), destination);
  DestroyWindow(destination);
  EXPECT_FALSE(IsWindow(pendingHost));
  EXPECT_FALSE(IsWindow(otherHost));
}

}  // namespace flutter_inappwebview_plugin::test
