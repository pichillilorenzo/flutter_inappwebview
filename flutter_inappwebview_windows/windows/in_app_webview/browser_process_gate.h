#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_BROWSER_PROCESS_GATE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_BROWSER_PROCESS_GATE_H_

#include <algorithm>
#include <cstddef>
#include <functional>
#include <map>
#include <optional>
#include <utility>
#include <vector>

namespace flutter_inappwebview_plugin
{
  // Coalesces browser-process responsiveness probing across every webview that
  // shares a browser process: within one validity window at most one probe
  // (bounded by its timeout) runs per process, no matter how many webviews
  // have synchronous state waiting on it. Pure logic - the Win32 probe, clock
  // and retry timer are injected, which also makes it unit-testable.
  class BrowserProcessGateRegistry
  {
  public:
    using Owner = void*;
    using Waiter = Owner;
    using ProbeFn = std::function<bool(unsigned long pid)>;
    using ClockFn = std::function<unsigned long long()>;
    using ScheduleRetryFn = std::function<void(unsigned long pid)>;
    using CancelRetryFn = std::function<void(unsigned long pid)>;
    using ReleaseProcessFn = std::function<void(unsigned long pid)>;

    BrowserProcessGateRegistry(ProbeFn probe, ClockFn clock,
      ScheduleRetryFn scheduleRetry, CancelRetryFn cancelRetry,
      const unsigned long long probeValidityMs,
      ReleaseProcessFn releaseProcess = {})
      : probe_(std::move(probe)), clock_(std::move(clock)),
      scheduleRetry_(std::move(scheduleRetry)),
      cancelRetry_(std::move(cancelRetry)),
      probeValidityMs_(probeValidityMs),
      releaseProcess_(std::move(releaseProcess))
    {}

    // True: the browser answered a probe at most probeValidityMs ago and the
    // caller may issue its synchronous calls now. False: the caller is queued
    // and handed back by takeWaitersIfResponsive on a retry tick.
    bool tryAcquire(const unsigned long pid, const Waiter waiter)
    {
      // Ownership outlives pending work, including a responsive acquisition.
      // A view moving to another browser must release its previous process.
      const auto owner = owners_.find(waiter);
      if (owner == owners_.end() || owner->second != pid) {
        releaseOwner(waiter);
        owners_.emplace(waiter, pid);
        ++entries_[pid].ownerCount;
      }
      auto& entry = entries_[pid];
      if (verdict(pid, entry)) {
        return true;
      }
      if (std::find(entry.waiters.begin(), entry.waiters.end(), waiter) ==
        entry.waiters.end()) {
        entry.waiters.push_back(waiter);
      }
      if (!entry.retryScheduled) {
        entry.retryScheduled = true;
        scheduleRetry_(pid);
      }
      return false;
    }

    // Runs on the retry timer. Returns the drained waiters once the browser
    // answers again (and stops the timer); empty while it stays unresponsive.
    std::vector<Waiter> takeWaitersIfResponsive(const unsigned long pid)
    {
      const auto it = entries_.find(pid);
      if (it == entries_.end() || it->second.waiters.empty()) {
        stopRetry(pid);
        return {};
      }
      auto& entry = it->second;
      if (!verdict(pid, entry)) {
        return {};
      }
      std::vector<Waiter> drained;
      drained.swap(entry.waiters);
      stopRetry(pid);
      return drained;
    }

    // Completing or timing out a request only removes its pending work. The
    // live view still owns the process cache until releaseOwner is called.
    void removeWaiter(const Waiter waiter)
    {
      const auto owner = owners_.find(waiter);
      if (owner == owners_.end()) {
        return;
      }
      const auto pid = owner->second;
      auto& entry = entries_.at(pid);
      entry.waiters.erase(
        std::remove(entry.waiters.begin(), entry.waiters.end(), waiter),
        entry.waiters.end());
      if (entry.waiters.empty()) {
        stopRetry(pid);
      }
    }

    // Last-view cleanup drops the verdict and any borrowed platform cache.
    // Remove our ownership before invoking hooks so they see a consistent
    // registry, and so a reused PID always starts with a fresh probe.
    void releaseOwner(const Owner owner)
    {
      const auto ownerIt = owners_.find(owner);
      if (ownerIt == owners_.end()) {
        return;
      }
      const auto pid = ownerIt->second;
      owners_.erase(ownerIt);
      const auto entryIt = entries_.find(pid);
      auto& entry = entryIt->second;
      entry.waiters.erase(
        std::remove(entry.waiters.begin(), entry.waiters.end(), owner),
        entry.waiters.end());
      if (--entry.ownerCount == 0) {
        const bool cancelRetry = entry.retryScheduled;
        entries_.erase(entryIt);
        if (cancelRetry) {
          cancelRetry_(pid);
        }
        if (releaseProcess_) {
          releaseProcess_(pid);
        }
      }
      else if (entry.waiters.empty()) {
        stopRetry(pid);
      }
    }

    bool owns(const unsigned long pid, const Owner owner) const
    {
      const auto it = owners_.find(owner);
      return it != owners_.end() && it->second == pid;
    }

    size_t processCount() const { return entries_.size(); }
    size_t ownerCount() const { return owners_.size(); }

    // The browser process exited: its cached verdict no longer means anything.
    void invalidate(const unsigned long pid)
    {
      const auto it = entries_.find(pid);
      if (it != entries_.end()) {
        it->second.lastVerdict.reset();
      }
    }

  private:
    struct Entry
    {
      std::optional<bool> lastVerdict;
      unsigned long long verdictTick = 0;
      size_t ownerCount = 0;
      std::vector<Waiter> waiters;
      bool retryScheduled = false;
    };

    bool verdict(const unsigned long pid, Entry& entry)
    {
      const auto now = clock_();
      if (!entry.lastVerdict.has_value() ||
        now - entry.verdictTick >= probeValidityMs_) {
        entry.lastVerdict = probe_(pid);
        entry.verdictTick = now;
      }
      return entry.lastVerdict.value();
    }

    void stopRetry(const unsigned long pid)
    {
      const auto it = entries_.find(pid);
      if (it != entries_.end() && it->second.retryScheduled) {
        it->second.retryScheduled = false;
        cancelRetry_(pid);
      }
    }

    ProbeFn probe_;
    ClockFn clock_;
    ScheduleRetryFn scheduleRetry_;
    CancelRetryFn cancelRetry_;
    unsigned long long probeValidityMs_;
    ReleaseProcessFn releaseProcess_;
    std::map<unsigned long, Entry> entries_;
    std::map<Owner, unsigned long> owners_;
  };
}

#endif // FLUTTER_INAPPWEBVIEW_PLUGIN_BROWSER_PROCESS_GATE_H_
