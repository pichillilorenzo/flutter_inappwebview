#pragma once

#include <memory>
#include <stdexcept>
#include <vector>

#include "../in_app_webview/webview_lifecycle_state.h"

namespace flutter_inappwebview_plugin::test::webview_lifecycle_test
{
  using Status = WebViewLifecycleStatus;
  using Result = WebViewLifecycleResult;

  inline void require(bool condition)
  {
    if (!condition) {
      throw std::runtime_error("WebView lifecycle regression");
    }
  }

  struct Replies
  {
    std::vector<Result> values;

    WebViewLifecycleState::Completion record()
    {
      return [this](Result result) { values.push_back(result); };
    }

    void expectOnly(Status status) const
    {
      require(values.size() == 1 && values.front().status == status);
    }
  };

  inline void waitsForSuspendCallback()
  {
    WebViewLifecycleState state;
    Replies replies;
    state.request(true, replies.record());
    require(replies.values.empty());
    require(state.hasPendingCompletion());
    const auto operation = state.beginSuspend();
    require(operation != nullptr);
    require(!state.needsApply());
    require(replies.values.empty());
    state.suspendCompleted(operation, Result::suspendResult(0, true));
    replies.expectOnly(Status::succeeded);
    require(!state.hasPendingCompletion());
  }

  inline void successfulHresultCanRejectSuspend()
  {
    WebViewLifecycleState state;
    Replies replies;
    state.request(true, replies.record());
    state.suspendCompleted(state.beginSuspend(), Result::suspendResult(0, false));
    replies.expectOnly(Status::suspendRejected);
    require(replies.values.front().errorCode == 0);
    require(!state.hasPendingCompletion());
  }

  inline void failedHresultCannotConfirmSuspend()
  {
    constexpr std::int32_t nativeFailure = -2147467259; // E_FAIL
    WebViewLifecycleState state;
    Replies replies;
    state.request(true, replies.record());
    const auto operation = state.beginSuspend();
    state.suspendCompleted(operation, Result::suspendResult(nativeFailure, true));
    // Covers an immediate native error followed by an unexpected late callback.
    state.suspendCompleted(operation, Result::suspendResult(0, true));
    replies.expectOnly(Status::nativeError);
    require(replies.values.front().errorCode == nativeFailure);
    require(!state.needsApply());
  }

  inline void resumePreemptsPauseWaitingAtGate()
  {
    WebViewLifecycleState state;
    Replies pause, resume;
    state.request(true, pause.record());
    const auto previous = state.current();
    state.request(false, resume.record());
    pause.expectOnly(Status::cancelled);
    require(!state.isCurrent(previous));
    require(!state.needsSuspend());
    require(state.needsResume());
    require(resume.values.empty());
    state.resumeCompleted(state.beginResume(), { Status::succeeded });
    resume.expectOnly(Status::succeeded);
  }

  inline void lateSuspendSuccessRequiresCorrectiveResume()
  {
    WebViewLifecycleState state;
    Replies pause, resume;
    state.request(true, pause.record());
    const auto nativePause = state.beginSuspend();
    state.request(false, resume.record());
    pause.expectOnly(Status::cancelled);
    // Resume must be delivered without waiting for nativePause. This also
    // applies when the window is minimized and showing it cannot auto-resume.
    state.resumeCompleted(state.beginResume(), { Status::succeeded });
    resume.expectOnly(Status::succeeded);
    state.suspendCompleted(nativePause, Result::suspendResult(0, true));
    require(state.needsResume());
    state.resumeCompleted(state.beginResume(), { Status::succeeded });
    require(!state.needsApply());
    pause.expectOnly(Status::cancelled);
    resume.expectOnly(Status::succeeded);
  }

  inline void lateRefusalDoesNotResumeAgain()
  {
    WebViewLifecycleState state;
    Replies pause, resume;
    state.request(true, pause.record());
    const auto nativePause = state.beginSuspend();
    state.request(false, resume.record());
    state.resumeCompleted(state.beginResume(), { Status::succeeded });
    state.suspendCompleted(nativePause, Result::suspendResult(0, false));
    require(!state.needsApply());
    pause.expectOnly(Status::cancelled);
    resume.expectOnly(Status::succeeded);
  }

  inline void rapidPauseResumePausePreservesNewestRequest()
  {
    WebViewLifecycleState state;
    Replies firstPause, resume, lastPause;
    state.request(true, firstPause.record());
    const auto firstNativePause = state.beginSuspend();
    state.request(false, resume.record());
    state.resumeCompleted(state.beginResume(), { Status::succeeded });
    state.request(true, lastPause.record());
    // The acknowledged Resume retires the previous pause. Its late callback
    // must not clear or complete this newer native request.
    require(state.needsSuspend());
    const auto lastNativePause = state.beginSuspend();
    state.suspendCompleted(firstNativePause, Result::suspendResult(0, true));
    require(!state.needsResume());
    require(!state.needsSuspend());
    require(lastPause.values.empty());
    state.suspendCompleted(lastNativePause, Result::suspendResult(0, true));
    firstPause.expectOnly(Status::cancelled);
    resume.expectOnly(Status::succeeded);
    lastPause.expectOnly(Status::succeeded);
  }

  inline void duplicatePausesWaitForOneNativeOperation()
  {
    WebViewLifecycleState state;
    Replies first, second;
    state.request(true, first.record());
    const auto firstNativePause = state.beginSuspend();
    state.request(true, second.record());
    first.expectOnly(Status::cancelled);
    require(!state.needsSuspend());
    state.suspendCompleted(firstNativePause, Result::suspendResult(0, false));
    require(state.needsSuspend());
    state.suspendCompleted(state.beginSuspend(), Result::suspendResult(0, true));
    second.expectOnly(Status::succeeded);
  }

  inline void timeoutBeforeDispatchClearsPendingWork()
  {
    for (const bool paused : { false, true }) {
      WebViewLifecycleState state;
      Replies replies;
      state.request(paused, replies.record());
      state.failPending({ Status::timedOut });
      replies.expectOnly(Status::timedOut);
      require(!state.needsApply());
      require(!state.hasPendingCompletion());
    }
  }

  inline void timeoutDuringSuspendIgnoresLateSuccess()
  {
    WebViewLifecycleState state;
    Replies replies;
    state.request(true, replies.record());
    const auto operation = state.beginSuspend();
    state.failPending({ Status::timedOut });
    state.suspendCompleted(operation, Result::suspendResult(0, true));
    replies.expectOnly(Status::timedOut);
    require(!state.hasPendingCompletion());
    require(!state.needsApply());
  }

  inline void lostCallbackCanRecoverAfterSuccessfulResume()
  {
    WebViewLifecycleState state;
    Replies timedOut, resumed, nextPause;
    state.request(true, timedOut.record());
    const auto lostNativePause = state.beginSuspend();
    state.failPending({ Status::timedOut });
    state.request(false, resumed.record());
    state.resumeCompleted(state.beginResume(), { Status::succeeded });
    state.request(true, nextPause.record());
    require(state.needsSuspend());
    state.suspendCompleted(state.beginSuspend(), Result::suspendResult(0, true));
    timedOut.expectOnly(Status::timedOut);
    resumed.expectOnly(Status::succeeded);
    nextPause.expectOnly(Status::succeeded);
    // Even after a subsequent successful pause, an old callback is harmless.
    state.suspendCompleted(lostNativePause, Result::suspendResult(0, true));
    require(!state.needsApply());
    nextPause.expectOnly(Status::succeeded);
  }

  inline void retiredCompletionCanResumeOnlyOnce()
  {
    WebViewLifecycleState state;
    Replies timedOut, resumed;
    state.request(true, timedOut.record());
    const auto lostNativePause = state.beginSuspend();
    state.failPending({ Status::timedOut });
    state.request(false, resumed.record());
    state.resumeCompleted(state.beginResume(), { Status::succeeded });
    state.suspendCompleted(lostNativePause, Result::suspendResult(0, true));
    require(state.needsResume());
    state.resumeCompleted(state.beginResume(), { Status::succeeded });
    require(!state.needsApply());
    state.suspendCompleted(lostNativePause, Result::suspendResult(0, true));
    require(!state.needsApply());
    timedOut.expectOnly(Status::timedOut);
    resumed.expectOnly(Status::succeeded);
  }

  inline void failedResumeDoesNotRetirePendingSuspend()
  {
    WebViewLifecycleState state;
    Replies firstPause, failedResume, secondPause;
    state.request(true, firstPause.record());
    const auto nativePause = state.beginSuspend();
    state.request(false, failedResume.record());
    state.resumeCompleted(state.beginResume(), { Status::nativeError });
    state.request(true, secondPause.record());
    require(!state.needsSuspend());
    // A callback can still unblock it when Resume was not acknowledged.
    state.suspendCompleted(nativePause, Result::suspendResult(0, false));
    require(state.needsSuspend());
    state.suspendCompleted(state.beginSuspend(), Result::suspendResult(0, true));
    firstPause.expectOnly(Status::cancelled);
    failedResume.expectOnly(Status::nativeError);
    secondPause.expectOnly(Status::succeeded);
  }

  inline void disposalCompletesAndPreventsLateAccess()
  {
    WebViewLifecycleState state;
    Replies pending, afterDispose;
    state.request(true, pending.record());
    const auto operation = state.beginSuspend();
    state.dispose();
    state.dispose();
    pending.expectOnly(Status::disposed);
    state.suspendCompleted(operation, Result::suspendResult(0, true));
    state.request(false, afterDispose.record());
    afterDispose.expectOnly(Status::disposed);
    require(!state.hasPendingCompletion());
    require(!state.needsApply());
  }

  inline void visibilityOrResumeFailureCannotSucceed()
  {
    WebViewLifecycleState state;
    Replies replies;
    state.request(false, replies.record());
    const auto operation = state.beginResume();
    // Resume succeeded but its visibility update failed: the whole request
    // must fail once, and the subsequent success path may not overwrite it.
    state.failPending({ Status::nativeError, -2147467259 });
    state.resumeCompleted(operation, { Status::succeeded });
    replies.expectOnly(Status::nativeError);

    Replies unavailable;
    state.request(true, unavailable.record());
    state.suspendCompleted(state.beginSuspend(), { Status::unavailable });
    unavailable.expectOnly(Status::unavailable);
  }

  inline void independentViewsNeverCancelEachOther()
  {
    WebViewLifecycleState a, b;
    Replies aPause, aResume, bPause;
    a.request(true, aPause.record());
    b.request(true, bPause.record());
    const auto nativeA = a.beginSuspend();
    const auto nativeB = b.beginSuspend();
    a.request(false, aResume.record());
    a.resumeCompleted(a.beginResume(), { Status::succeeded });
    b.suspendCompleted(nativeB, Result::suspendResult(0, true));
    a.suspendCompleted(nativeA, Result::suspendResult(0, true));
    bPause.expectOnly(Status::succeeded);
    require(!b.needsApply());
    require(a.needsResume());
  }

  inline void completionCanStartAnotherRequest()
  {
    WebViewLifecycleState state;
    Replies resumed;
    state.request(true, [&](Result result) {
      require(result.status == Status::succeeded);
      state.request(false, resumed.record());
    });
    state.suspendCompleted(state.beginSuspend(), Result::suspendResult(0, true));
    require(state.needsResume());
    state.resumeCompleted(state.beginResume(), { Status::succeeded });
    resumed.expectOnly(Status::succeeded);
  }

  inline void repeatedLifecyclesReleaseReplyOwners()
  {
    for (int cycle = 0; cycle < 1000; ++cycle) {
      auto payload = std::make_shared<int>(cycle);
      const std::weak_ptr<int> weak = payload;
      WebViewLifecycleState state;
      state.request(true, [payload](Result) {});
      payload.reset();
      const auto operation = state.beginSuspend();
      require(!weak.expired());
      if (cycle % 3 == 0) {
        state.failPending({ Status::timedOut });
      }
      else if (cycle % 3 == 1) {
        state.dispose();
      }
      else {
        state.suspendCompleted(operation, Result::suspendResult(0, true));
      }
      // Even a missing or very late native callback no longer owns a Flutter
      // MethodResult after the request has reached a terminal outcome.
      require(weak.expired());
      state.suspendCompleted(operation, Result::suspendResult(0, true));
    }
  }
}
