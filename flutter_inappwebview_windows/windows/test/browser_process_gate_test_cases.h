#pragma once

#include <set>
#include <stdexcept>
#include <vector>

#include "../in_app_webview/browser_process_gate.h"

namespace flutter_inappwebview_plugin::test::browser_process_gate_test
{
  inline void require(bool condition, const char* message)
  {
    if (!condition) {
      throw std::runtime_error(message);
    }
  }

  struct Harness
  {
    unsigned long long now = 0;
    bool responsive = false;
    int probes = 0;
    int scheduled = 0;
    int canceled = 0;
    int released = 0;
    std::set<unsigned long> retries;
    // Models the borrowed HWND cache owned by the Win32 integration.
    std::set<unsigned long> probeWindows;
    BrowserProcessGateRegistry gate;

    Harness()
      : gate([this](unsigned long pid) {
          ++probes;
          probeWindows.insert(pid);
          return responsive;
        },
        [this] { return now; },
        [this](unsigned long pid) {
          ++scheduled;
          require(retries.insert(pid).second, "duplicate process retry");
        },
        [this](unsigned long pid) {
          ++canceled;
          require(retries.erase(pid) == 1, "canceled an unowned retry");
        },
        250,
        [this](unsigned long pid) {
          ++released;
          require(retries.count(pid) == 0, "released process still has a retry");
          probeWindows.erase(pid);
        })
    {}

    void expectEmpty() const
    {
      require(gate.processCount() == 0, "retained process after last close");
      require(gate.ownerCount() == 0, "retained owner after last close");
      require(retries.empty(), "retained retry after last close");
      require(probeWindows.empty(), "retained borrowed window after last close");
    }
  };

  inline void responsiveOwnersOutlivePendingWork()
  {
    Harness h;
    h.responsive = true;
    int a = 0, b = 0;
    require(h.gate.tryAcquire(7, &a), "responsive acquisition failed");
    require(h.gate.tryAcquire(7, &b), "shared responsive acquisition failed");
    require(h.probes == 1, "responsive owners did not share probe");
    h.gate.removeWaiter(&a);
    h.gate.removeWaiter(&b);
    for (int i = 0; i < 10; ++i) {
      require(h.gate.tryAcquire(7, &a), "repeat acquisition failed");
    }
    require(h.gate.processCount() == 1 && h.gate.ownerCount() == 2,
      "responsive owner registration missing or duplicated");
    h.gate.releaseOwner(&a);
    require(h.gate.owns(7, &b), "closing one released another owner");
    require(h.released == 0 && h.probeWindows.count(7) == 1,
      "shared cache released before last owner");
    h.gate.releaseOwner(&b);
    h.expectEmpty();
    require(h.released == 1 && h.canceled == 0,
      "responsive release touched a retry or released twice");
  }

  inline void closingOnePreservesSharedRetry()
  {
    Harness h;
    int a = 0, b = 0;
    require(!h.gate.tryAcquire(7, &a), "unresponsive gate opened");
    require(!h.gate.tryAcquire(7, &b), "shared unresponsive gate opened");
    h.gate.releaseOwner(&a);
    require(h.canceled == 0 && h.retries.count(7) == 1,
      "closing one canceled another owner's retry");
    require(h.gate.ownerCount() == 1 && h.gate.processCount() == 1,
      "closing one lost the shared process");
    h.now += 250;
    h.responsive = true;
    const auto ready = h.gate.takeWaitersIfResponsive(7);
    require(ready.size() == 1 && ready.front() == &b,
      "retry returned a closed owner or lost a live owner");
    require(h.canceled == 1 && h.gate.owns(7, &b),
      "draining work released a live owner");
    h.gate.releaseOwner(&b);
    h.expectEmpty();
  }

  inline void lastOwnerCancelsAndReleasesCaches()
  {
    Harness h;
    int owner = 0;
    h.gate.tryAcquire(7, &owner);
    h.gate.releaseOwner(&owner);
    h.expectEmpty();
    require(h.canceled == 1 && h.released == 1,
      "last owner did not release retry and process exactly once");
    const auto probes = h.probes;
    require(h.gate.takeWaitersIfResponsive(7).empty(),
      "stale retry returned a released owner");
    require(h.probes == probes && h.canceled == 1,
      "stale retry probed or canceled an unowned timer");
    h.gate.releaseOwner(&owner);
    h.gate.removeWaiter(&owner);
    h.gate.invalidate(7);
    h.expectEmpty();
    require(h.released == 1, "duplicate release was not idempotent");
  }

  inline void timeoutRetainsOwnership()
  {
    Harness h;
    int owner = 0;
    h.gate.tryAcquire(7, &owner);
    // This is the lifecycle deadline's operation; the view remains alive.
    h.gate.removeWaiter(&owner);
    require(h.gate.owns(7, &owner) && h.gate.processCount() == 1,
      "timed out request released its live view");
    require(h.canceled == 1 && h.released == 0 &&
      h.probeWindows.count(7) == 1, "timeout released a retained process");
    require(!h.gate.tryAcquire(7, &owner), "cached refusal was lost");
    require(h.probes == 1 && h.scheduled == 2,
      "new request did not reuse verdict or restart retry");
    h.gate.releaseOwner(&owner);
    h.expectEmpty();
  }

  inline void pidReuseRequiresFreshProbe()
  {
    Harness h;
    int first = 0, replacement = 0;
    h.responsive = true;
    h.gate.tryAcquire(7, &first);
    h.gate.releaseOwner(&first);
    h.expectEmpty();
    // The clock has not advanced: a retained verdict would incorrectly pass.
    h.responsive = false;
    require(!h.gate.tryAcquire(7, &replacement),
      "reused PID inherited the previous process verdict");
    require(h.probes == 2 && h.gate.owns(7, &replacement),
      "reused PID was not probed and owned independently");
    h.gate.releaseOwner(&replacement);
    h.expectEmpty();
  }

  inline void movingOwnerPreservesOtherOwners()
  {
    Harness h;
    int moving = 0, staying = 0;
    h.gate.tryAcquire(7, &moving);
    h.gate.tryAcquire(7, &staying);
    h.gate.tryAcquire(8, &moving);
    require(!h.gate.owns(7, &moving) && h.gate.owns(8, &moving) &&
      h.gate.owns(7, &staying), "PID change transferred the wrong owner");
    require(h.gate.processCount() == 2 && h.gate.ownerCount() == 2 &&
      h.retries.size() == 2, "PID change lost live process bookkeeping");
    h.gate.releaseOwner(&staying);
    require(h.retries.count(7) == 0 && h.retries.count(8) == 1,
      "old-process cleanup canceled the replacement process");
    h.gate.tryAcquire(9, &moving);
    require(h.gate.processCount() == 1 && h.gate.ownerCount() == 1 &&
      h.probeWindows.size() == 1 && h.probeWindows.count(9) == 1,
      "last-owner PID change retained the old process");
    h.gate.releaseOwner(&moving);
    h.expectEmpty();
  }

  inline void processFailurePreservesOtherOwners()
  {
    Harness h;
    h.responsive = true;
    int closing = 0, staying = 0;
    h.gate.tryAcquire(7, &closing);
    h.gate.tryAcquire(7, &staying);
    // ProcessFailed invalidates shared state but releases only this view.
    h.gate.invalidate(7);
    h.probeWindows.erase(7);
    h.gate.releaseOwner(&closing);
    require(h.gate.owns(7, &staying) && h.gate.processCount() == 1 &&
      h.released == 0, "process failure released another live owner");
    h.responsive = false;
    require(!h.gate.tryAcquire(7, &staying),
      "process failure kept the old successful verdict");
    require(h.probes == 2, "process failure did not force a fresh probe");
    h.gate.releaseOwner(&staying);
    h.expectEmpty();
  }

  inline void drainedWaitersRecheckOwnership()
  {
    Harness h;
    int first = 0, closed = 0, moved = 0;
    h.gate.tryAcquire(7, &first);
    h.gate.tryAcquire(7, &closed);
    h.gate.tryAcquire(7, &moved);
    h.responsive = true;
    h.now += 250;
    const auto ready = h.gate.takeWaitersIfResponsive(7);
    require(ready.size() == 3, "responsive retry did not drain shared work");
    std::vector<void*> applied;
    for (const auto waiter : ready) {
      if (!h.gate.owns(7, waiter)) {
        continue;
      }
      applied.push_back(waiter);
      if (waiter == &first) {
        // An earlier delivery can synchronously close or move another view.
        h.gate.releaseOwner(&closed);
        h.gate.tryAcquire(8, &moved);
      }
    }
    require(applied.size() == 1 && applied.front() == &first,
      "drained work dereferenced a released or moved owner");
    h.gate.releaseOwner(&first);
    h.gate.releaseOwner(&moved);
    h.expectEmpty();
  }

  inline void releaseHooksObserveConsistentOwnership()
  {
    int owner = 0;
    BrowserProcessGateRegistry* registry = nullptr;
    int canceled = 0, released = 0;
    BrowserProcessGateRegistry gate(
      [](unsigned long) { return false; }, [] { return 0; },
      [](unsigned long) {},
      [&](unsigned long pid) {
        ++canceled;
        require(!registry->owns(pid, &owner) && registry->processCount() == 0,
          "cancel hook observed a half-released owner");
      },
      250,
      [&](unsigned long pid) {
        ++released;
        require(!registry->owns(pid, &owner) && registry->ownerCount() == 0 &&
          registry->processCount() == 0,
          "release hook observed a half-released process");
      });
    registry = &gate;
    gate.tryAcquire(7, &owner);
    gate.releaseOwner(&owner);
    require(canceled == 1 && released == 1, "cleanup hooks did not run");
  }

  inline void retryCancellationCanReleaseLastOwner()
  {
    int owner = 0;
    unsigned long long now = 0;
    bool responsive = false;
    int canceled = 0, released = 0;
    BrowserProcessGateRegistry* registry = nullptr;
    BrowserProcessGateRegistry gate(
      [&](unsigned long) { return responsive; }, [&] { return now; },
      [](unsigned long) {},
      [&](unsigned long) {
        ++canceled;
        registry->releaseOwner(&owner);
      },
      250,
      [&](unsigned long) { ++released; });
    registry = &gate;
    require(!gate.tryAcquire(7, &owner), "unresponsive owner was not queued");
    responsive = true;
    now += 250;
    // Canceling the retry deletes its Entry. The drained work must already
    // have moved out, and the caller must reject the now-released owner.
    const auto ready = gate.takeWaitersIfResponsive(7);
    require(ready.size() == 1 && ready.front() == &owner,
      "retry cancellation lost the safely drained work");
    require(!gate.owns(7, &owner) && gate.ownerCount() == 0 &&
      gate.processCount() == 0, "cancel hook retained its released owner");
    require(canceled == 1 && released == 1,
      "reentrant last-owner cleanup did not run exactly once");
  }

  inline void repeatedCloseReleasesBookkeeping()
  {
    Harness h;
    int a = 0, b = 0;
    for (unsigned long cycle = 0; cycle < 1000; ++cycle) {
      const auto pid = 1000 + cycle;
      h.responsive = cycle % 2 == 0;
      h.gate.tryAcquire(pid, &a);
      h.gate.tryAcquire(pid, &b);
      require(h.gate.processCount() == 1 && h.gate.ownerCount() == 2 &&
        h.probeWindows.size() == 1 && h.retries.size() <= 1,
        "bookkeeping grew across open/close cycles");
      if (cycle % 3 == 0) {
        h.gate.removeWaiter(&a);
      }
      h.gate.releaseOwner(&a);
      require(h.gate.owns(pid, &b), "repeated close released the surviving view");
      h.gate.releaseOwner(&b);
      h.expectEmpty();
    }
    require(h.probes == 1000 && h.released == 1000 &&
      h.scheduled == 500 && h.canceled == 500,
      "repeated cycles left stale probes, retries or process caches");
  }
}
