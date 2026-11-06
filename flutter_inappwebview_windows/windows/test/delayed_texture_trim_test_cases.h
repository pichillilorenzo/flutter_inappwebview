#pragma once

#include "../custom_platform_view/delayed_texture_trim.h"

#include <map>
#include <stdexcept>
#include <vector>

namespace flutter_inappwebview_plugin::test {
namespace delayed_texture_trim_test {

inline void Require(bool condition, const char* message) {
  if (!condition) throw std::runtime_error(message);
}

struct TimerQueue {
  using Id = DelayedTextureTrim::TimerId;
  struct Entry {
    std::function<void()> callback;
    uint32_t delay;
  };
  DelayedTextureTrim::Clock::time_point now;
  std::map<Id, Entry> entries;
  std::vector<Id> cancelled;
  Id last_id = 0;
  bool fail_next = false;

  DelayedTextureTrim::Schedule schedule() {
    return [this](std::function<void()> callback, uint32_t delay) {
      if (std::exchange(fail_next, false)) return Id{0};
      const auto id = ++last_id;
      entries.emplace(id, Entry{std::move(callback), delay});
      return id;
    };
  }
  DelayedTextureTrim::Cancel cancel() {
    // Preserve already queued callables to exercise stale delivery explicitly.
    return [this](Id id) { cancelled.push_back(id); };
  }
  DelayedTextureTrim::Now clock() {
    return [this] { return now; };
  }
  void Advance(uint32_t milliseconds) {
    now += std::chrono::milliseconds(milliseconds);
  }
  void Fire(Id id) {
    const auto callback = entries.at(id).callback;
    callback();
  }
};

inline void DoesNotTrimShortHidesOrStaleTimers() {
  TimerQueue queue;
  DelayedTextureTrim trim(queue.schedule(), queue.cancel(), queue.clock());
  int calls = 0;
  Require(queue.entries.empty(), "Visible views must not schedule trim");
  trim.Start([&] { ++calls; return false; });
  const auto first = queue.last_id;
  queue.Advance(1000);
  trim.CancelPending();
  Require(queue.cancelled == std::vector<TimerQueue::Id>{first},
    "Resume must cancel the physical timer");
  queue.Advance(30000);
  queue.Fire(first);
  Require(calls == 0, "A stale hidden callback trimmed a resumed view");

  trim.Start([&] { ++calls; return false; });
  queue.Advance(29999);
  queue.Fire(queue.last_id);
  Require(calls == 0, "A reused timer ID shortened the quiet interval");
  Require(queue.entries.at(queue.last_id).delay == 1,
    "Early timer must wait for the remaining quiet interval");
  queue.Advance(1);
  queue.Fire(queue.last_id);
  Require(calls == 1, "Long hide did not trim at its deadline");
  queue.Fire(queue.last_id);
  Require(calls == 1, "Completed trim must not repeat");
}

inline void RehideStartsANewDeadline() {
  TimerQueue queue;
  DelayedTextureTrim trim(queue.schedule(), queue.cancel(), queue.clock());
  int calls = 0;
  trim.Start([&] { ++calls; return false; });
  const auto old = queue.last_id;
  queue.Advance(5000);
  trim.CancelPending();
  trim.Start([&] { ++calls; return false; });
  const auto current = queue.last_id;
  queue.Advance(25000);
  queue.Fire(old);
  queue.Fire(current); // ID reuse can dispatch the current callable early.
  Require(calls == 0, "A previous hide's deadline trimmed the next hide");
  const auto remaining = queue.last_id;
  Require(queue.entries.at(remaining).delay == 5000,
    "Rehide must receive a complete quiet interval");
  queue.Fire(current);
  Require(queue.last_id == remaining, "Stale generation scheduled another timer");
  queue.Advance(5000);
  queue.Fire(remaining);
  Require(calls == 1, "Rehidden resources were not trimmed");
}

inline void RetriesOnlyWhileAConsumerOwnsTheSpare() {
  TimerQueue queue;
  DelayedTextureTrim trim(queue.schedule(), queue.cancel(), queue.clock());
  bool leased = true;
  int calls = 0;
  trim.Start([&] { ++calls; return leased; });
  const auto first = queue.last_id;
  queue.Advance(30000);
  queue.Fire(first);
  const auto retry = queue.last_id;
  Require(calls == 1 && retry != first,
    "A leased spare must be retried without waiting for the consumer");
  queue.Fire(first);
  Require(calls == 1 && queue.last_id == retry,
    "A stale callback must not replace an outstanding retry");
  leased = false;
  queue.Advance(30000);
  queue.Fire(retry);
  Require(calls == 2 && queue.last_id == retry,
    "No periodic timer may remain once the spare is detached");
}

inline void DisposeReleasesTheOperationAndRejectsQueuedCallbacks() {
  TimerQueue queue;
  int calls = 0;
  auto owner = std::make_shared<int>(0);
  std::weak_ptr<int> owner_weak = owner;
  {
    DelayedTextureTrim trim(queue.schedule(), queue.cancel(), queue.clock());
    trim.Start([owner, &calls] { ++calls; return true; });
    owner.reset();
    Require(!owner_weak.expired(), "Test owner was not retained by its action");
  }
  Require(owner_weak.expired(), "Queued timer retained the disposed bridge");
  queue.Advance(60000);
  queue.Fire(queue.last_id);
  Require(calls == 0, "Queued callback used a disposed owner");
  Require(queue.cancelled.size() == 1, "Dispose did not cancel its timer");
}

inline void AllocationFailureKeepsResourcesWithoutCallingTrim() {
  TimerQueue queue;
  DelayedTextureTrim trim(queue.schedule(), queue.cancel(), queue.clock());
  int calls = 0;
  queue.fail_next = true;
  trim.Start([&] { ++calls; return false; });
  Require(calls == 0 && queue.entries.empty(),
    "Timer failure must preserve resources and avoid synchronous trim");
  trim.Start([&] { ++calls; return false; });
  queue.Advance(30000);
  queue.Fire(queue.last_id);
  Require(calls == 1, "A later hide must recover from timer creation failure");
}

inline void CancellingInsideTheOperationDoesNotRearm() {
  TimerQueue queue;
  auto trim = std::make_unique<DelayedTextureTrim>(queue.schedule(),
    queue.cancel(), queue.clock());
  trim->Start([&] { trim.reset(); return true; });
  queue.Advance(30000);
  queue.Fire(queue.last_id);
  Require(!trim && queue.entries.size() == 1,
    "A callback that disposed its owner must not rearm");
}

inline void RunAll() {
  DoesNotTrimShortHidesOrStaleTimers();
  RehideStartsANewDeadline();
  RetriesOnlyWhileAConsumerOwnsTheSpare();
  DisposeReleasesTheOperationAndRejectsQueuedCallbacks();
  AllocationFailureKeepsResourcesWithoutCallingTrim();
  CancellingInsideTheOperationDoesNotRearm();
}
} // namespace delayed_texture_trim_test
} // namespace flutter_inappwebview_plugin::test
