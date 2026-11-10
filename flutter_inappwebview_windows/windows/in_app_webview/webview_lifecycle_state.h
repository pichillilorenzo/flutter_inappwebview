#pragma once

#include <cstdint>
#include <functional>
#include <memory>
#include <utility>

namespace flutter_inappwebview_plugin
{
  enum class WebViewLifecycleStatus
  {
    succeeded,
    suspendRejected,
    nativeError,
    cancelled,
    disposed,
    timedOut,
    unavailable,
  };

  struct WebViewLifecycleResult
  {
    WebViewLifecycleStatus status;
    std::int32_t errorCode = 0;

    // WebView2 may report S_OK with isSuccessful=FALSE. Only the conjunction
    // confirms the best-effort suspend request, not merely a successful IPC.
    static WebViewLifecycleResult suspendResult(std::int32_t errorCode,
      bool isSuccessful)
    {
      return { errorCode < 0 ? WebViewLifecycleStatus::nativeError :
        isSuccessful ? WebViewLifecycleStatus::succeeded :
        WebViewLifecycleStatus::suspendRejected, errorCode };
    }
  };

  // UI-thread-only state shared by the native gate and TrySuspend callback.
  // Visibility is deliberately separate: a hidden view has not necessarily
  // accepted suspension. A request owns its reply until completion, timeout,
  // supersession or disposal; stale callbacks can never complete it twice.
  class WebViewLifecycleState
  {
  public:
    using Completion = std::function<void(WebViewLifecycleResult)>;

    class Operation
    {
    public:
      explicit Operation(Completion completion)
        : completion_(std::move(completion)) {}

      void complete(WebViewLifecycleResult result)
      {
        auto completion = std::move(completion_);
        completion_ = nullptr;
        if (completion) {
          completion(result);
        }
      }

      bool consumeNativeCompletion()
      {
        return !std::exchange(nativeCompletionConsumed_, true);
      }

    private:
      Completion completion_;
      bool nativeCompletionConsumed_ = false;
    };

    using OperationPtr = std::shared_ptr<Operation>;

    void request(bool paused, Completion completion)
    {
      if (disposed_) {
        if (completion) {
          completion({ WebViewLifecycleStatus::disposed });
        }
        return;
      }
      desiredPaused_ = paused;
      pendingSuspend_ = paused;
      pendingResume_ = !paused;
      auto previous = std::exchange(current_,
        std::make_shared<Operation>(std::move(completion)));
      if (previous) {
        previous->complete({ WebViewLifecycleStatus::cancelled });
      }
    }

    bool needsResume() const { return pendingResume_; }
    bool needsSuspend() const
    {
      return pendingSuspend_ && !inFlightSuspend_;
    }
    bool needsApply() const { return needsResume() || needsSuspend(); }
    bool hasPendingCompletion() const { return current_ != nullptr; }
    bool isCurrent(const OperationPtr& operation) const
    {
      return operation && current_ == operation;
    }
    OperationPtr current() const { return current_; }

    OperationPtr beginResume()
    {
      pendingResume_ = false;
      return current_;
    }

    OperationPtr beginSuspend()
    {
      if (!needsSuspend()) {
        return nullptr;
      }
      pendingSuspend_ = false;
      inFlightSuspend_ = current_;
      return inFlightSuspend_;
    }

    void resumeCompleted(const OperationPtr& operation,
      WebViewLifecycleResult result)
    {
      if (!desiredPaused_) {
        if (result.status == WebViewLifecycleStatus::succeeded &&
          (isCurrent(operation) || (!operation && !current_))) {
          // An acknowledged Resume makes later suspension possible even if a
          // previous TrySuspend callback was lost. Keep late-completion guards
          // in the operation itself, rather than retaining an eternal blocker.
          inFlightSuspend_.reset();
        }
        finish(operation, result);
      }
    }

    void suspendCompleted(const OperationPtr& operation,
      WebViewLifecycleResult result)
    {
      if (!operation || !operation->consumeNativeCompletion()) {
        return;
      }
      if (inFlightSuspend_ == operation) {
        inFlightSuspend_.reset();
      }
      if (disposed_) {
        return;
      }
      if (isCurrent(operation)) {
        finish(operation, result);
      }
      else if (!desiredPaused_ &&
        result.status == WebViewLifecycleStatus::succeeded) {
        // Resume can preempt TrySuspend. A successful late callback must be
        // followed by another Resume, including while the host is minimized
        // (where visibility alone cannot wake it). Do not undo a newer pause.
        pendingResume_ = true;
      }
    }

    void failPending(WebViewLifecycleResult result)
    {
      pendingSuspend_ = false;
      pendingResume_ = false;
      finish(current_, result);
    }

    void dispose()
    {
      disposed_ = true;
      failPending({ WebViewLifecycleStatus::disposed });
      inFlightSuspend_.reset();
    }

  private:
    void finish(OperationPtr operation, WebViewLifecycleResult result)
    {
      if (isCurrent(operation)) {
        current_.reset();
        operation->complete(result);
      }
    }

    bool disposed_ = false;
    bool desiredPaused_ = false;
    bool pendingSuspend_ = false;
    bool pendingResume_ = false;
    OperationPtr current_;
    // Consecutive pause requests wait for the native callback. A successful
    // Resume retires that blocker so a missing callback cannot poison this
    // WebView forever; retired operations still guard their own late replies.
    OperationPtr inFlightSuspend_;
  };
}
