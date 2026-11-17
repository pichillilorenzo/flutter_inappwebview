#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_PREWARM_OPERATION_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_PREWARM_OPERATION_H_

#include <chrono>
#include <cstdint>
#include <mutex>
#include <optional>
#include <string>

namespace flutter_inappwebview_plugin {
  struct PrewarmOutcome {
    std::string status;
    int64_t errorCode;
    int64_t durationMs;
  };

  // The worker owns only this mailbox, never a manager, HWND or MethodResult.
  // The platform thread drains it on its own timer, including when a worker is
  // stuck inside the synchronous runtime loader. No posted pointer can outlive
  // its destination window or accidentally reach a recycled HWND.
  class PrewarmOperation {
  public:
    using Clock = std::chrono::steady_clock;
    static constexpr auto timeout = std::chrono::seconds(30);

    explicit PrewarmOperation(Clock::time_point startedAt = Clock::now())
      : startedAt_(startedAt) {}

    Clock::time_point deadline() const { return startedAt_ + timeout; }

    void finish(const std::string& status, int64_t errorCode,
      Clock::time_point now = Clock::now()) {
      std::lock_guard<std::mutex> lock(mutex_);
      if (!delivered_ && !outcome_) {
        outcome_ = now >= deadline()
          ? PrewarmOutcome{ "timeout", timeoutErrorCode, elapsed(now) }
          : PrewarmOutcome{ status, errorCode, elapsed(now) };
      }
    }

    std::optional<PrewarmOutcome> take(Clock::time_point now = Clock::now()) {
      std::lock_guard<std::mutex> lock(mutex_);
      if (delivered_) return std::nullopt;
      if (!outcome_ && now >= deadline()) {
        outcome_ = PrewarmOutcome{ "timeout", timeoutErrorCode, elapsed(now) };
      }
      if (!outcome_) return std::nullopt;
      delivered_ = true;
      return std::move(outcome_);
    }

  private:
    // HRESULT_FROM_WIN32(ERROR_TIMEOUT), without depending on Windows headers.
    static constexpr int64_t timeoutErrorCode = -2147023436;
    int64_t elapsed(Clock::time_point now) const {
      return std::chrono::duration_cast<std::chrono::milliseconds>(now - startedAt_).count();
    }
    const Clock::time_point startedAt_;
    std::mutex mutex_;
    std::optional<PrewarmOutcome> outcome_;
    bool delivered_ = false;
  };
}
#endif
