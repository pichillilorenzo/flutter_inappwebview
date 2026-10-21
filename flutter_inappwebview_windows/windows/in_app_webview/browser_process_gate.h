#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_BROWSER_PROCESS_GATE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_BROWSER_PROCESS_GATE_H_

#include <algorithm>
#include <functional>
#include <map>
#include <optional>
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
    using Waiter = void*;
    using ProbeFn = std::function<bool(unsigned long pid)>;
    using ClockFn = std::function<unsigned long long()>;
    using ScheduleRetryFn = std::function<void(unsigned long pid)>;
    using CancelRetryFn = std::function<void(unsigned long pid)>;

    BrowserProcessGateRegistry(ProbeFn probe, ClockFn clock,
      ScheduleRetryFn scheduleRetry, CancelRetryFn cancelRetry,
      const unsigned long long probeValidityMs)
      : probe_(std::move(probe)), clock_(std::move(clock)),
      scheduleRetry_(std::move(scheduleRetry)),
      cancelRetry_(std::move(cancelRetry)),
      probeValidityMs_(probeValidityMs)
    {}

    // True: the browser answered a probe at most probeValidityMs ago and the
    // caller may issue its synchronous calls now. False: the caller is queued
    // and handed back by takeWaitersIfResponsive on a retry tick.
    bool tryAcquire(const unsigned long pid, const Waiter waiter)
    {
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
      stopRetry(pid);
      std::vector<Waiter> drained;
      drained.swap(entry.waiters);
      return drained;
    }

    void removeWaiter(const Waiter waiter)
    {
      for (auto& [pid, entry] : entries_) {
        entry.waiters.erase(
          std::remove(entry.waiters.begin(), entry.waiters.end(), waiter),
          entry.waiters.end());
      }
    }

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
    std::map<unsigned long, Entry> entries_;
  };
}

#endif // FLUTTER_INAPPWEBVIEW_PLUGIN_BROWSER_PROCESS_GATE_H_
