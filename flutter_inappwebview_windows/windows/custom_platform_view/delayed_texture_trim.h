#pragma once

#include <chrono>
#include <cstdint>
#include <functional>
#include <memory>
#include <utility>

namespace flutter_inappwebview_plugin
{
  // Owner-thread timer: no worker, polling while visible, or callback retaining
  // the bridge. A failed timer simply keeps the resources until a later hide.
  class DelayedTextureTrim {
  public:
    using Clock = std::chrono::steady_clock;
    using TimerId = uintptr_t;
    using Schedule = std::function<TimerId(std::function<void()>, uint32_t)>;
    using Cancel = std::function<void(TimerId)>;
    using Now = std::function<Clock::time_point()>;
    static constexpr uint32_t kDelayMs = 30000;

    DelayedTextureTrim(Schedule schedule, Cancel cancel,
      Now now = [] { return Clock::now(); })
      : schedule_(std::move(schedule)), cancel_(std::move(cancel)),
        now_(std::move(now)) {}

    ~DelayedTextureTrim() { CancelPending(); }
    DelayedTextureTrim(const DelayedTextureTrim&) = delete;
    DelayedTextureTrim& operator=(const DelayedTextureTrim&) = delete;

    // Return true only when a consumer still owns an otherwise trimmable
    // resource; retry after another quiet interval instead of waiting on it.
    void Start(std::function<bool()> trim)
    {
      CancelPending();
      state_ = std::make_shared<State>();
      state_->schedule = schedule_;
      state_->cancel = cancel_;
      state_->now = now_;
      state_->trim = std::move(trim);
      state_->deadline = now_() + std::chrono::milliseconds(kDelayMs);
      Arm(state_, kDelayMs);
    }

    void CancelPending()
    {
      auto state = std::move(state_);
      if (!state) {
        return;
      }
      state->active = false;
      state->trim = nullptr;
      if (state->timer != 0) {
        state->cancel(std::exchange(state->timer, 0));
      }
    }

  private:
    struct State {
      Schedule schedule;
      Cancel cancel;
      Now now;
      std::function<bool()> trim;
      Clock::time_point deadline;
      TimerId timer = 0;
      uint64_t generation = 0;
      bool active = true;
    };

    static void Arm(const std::shared_ptr<State>& state, uint32_t delay)
    {
      const auto generation = ++state->generation;
      state->timer = state->schedule(
        [weak = std::weak_ptr<State>(state), generation] {
          const auto current = weak.lock();
          if (!current || !current->active ||
            current->generation != generation) {
            return;
          }
          current->timer = 0;
          const auto now = current->now();
          if (now < current->deadline) {
            // KillTimer does not remove queued messages, and SetTimer may
            // reuse an ID. Even such an early notification must not trim a
            // newly hidden view before its full quiet interval has elapsed.
            const auto remaining = std::chrono::ceil<std::chrono::milliseconds>(
              current->deadline - now).count();
            Arm(current, static_cast<uint32_t>(remaining));
            return;
          }
          // The operation may cancel its owner. Invoke a local copy so that
          // cancellation does not destroy a callable while it is executing.
          const auto trim = current->trim;
          const bool retry = trim();
          if (retry && current->active) {
            current->deadline = current->now() +
              std::chrono::milliseconds(kDelayMs);
            Arm(current, kDelayMs);
          }
          else {
            current->active = false;
            current->trim = nullptr;
          }
        }, delay);
      if (state->timer == 0) {
        state->active = false;
        state->trim = nullptr;
      }
    }

    Schedule schedule_;
    Cancel cancel_;
    Now now_;
    std::shared_ptr<State> state_;
  };
}
