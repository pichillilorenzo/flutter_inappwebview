#pragma once

#include <atomic>
#include <chrono>
#include <condition_variable>
#include <future>
#include <memory>
#include <mutex>
#include <stdexcept>

#include "../custom_platform_view/async_resource_build.h"

namespace flutter_inappwebview_plugin::test {
namespace async_resource_build_test {

inline void require(bool value, const char* message) {
  if (!value) throw std::runtime_error(message);
}

// Explicit handshakes, not sleeps: the simulated driver is stopped after the
// first resource is created, before the remaining resources can be published.
struct DriverGate {
  std::mutex mutex;
  std::condition_variable changed;
  bool entered = false;
  bool released = false;
  bool timedOut = false;

  void block() {
    std::unique_lock<std::mutex> lock(mutex);
    entered = true;
    changed.notify_all();
    timedOut = !changed.wait_for(lock, std::chrono::seconds(5),
        [this] { return released; });
  }

  void waitUntilEntered() {
    std::unique_lock<std::mutex> lock(mutex);
    require(changed.wait_for(lock, std::chrono::seconds(5),
        [this] { return entered; }), "worker did not reach driver gate");
  }

  void release() {
    const std::lock_guard<std::mutex> lock(mutex);
    released = true;
    changed.notify_all();
  }
};

struct ReleaseOnExit {
  std::shared_ptr<DriverGate> gate;
  ~ReleaseOnExit() { gate->release(); }
};

struct Counts {
  std::atomic<int> devices{0};
  std::atomic<int> resources{0};
  std::promise<void> resourcesReleased;
};

struct Device {
  std::shared_ptr<Counts> counts;
  explicit Device(std::shared_ptr<Counts> value) : counts(std::move(value)) {
    ++counts->devices;
  }
  ~Device() { --counts->devices; }
};

struct Resource {
  std::shared_ptr<Counts> counts;
  int value;
  Resource(std::shared_ptr<Counts> ownerCounts, int resourceValue)
      : counts(std::move(ownerCounts)), value(resourceValue) {
    ++counts->resources;
  }
  ~Resource() {
    if (--counts->resources == 0) counts->resourcesReleased.set_value();
  }
};

struct Resources {
  std::unique_ptr<Resource> shader;
  std::unique_ptr<Resource> result;
  std::unique_ptr<Resource> uav;
  std::unique_ptr<Resource> staging;
};

// Signals after publication and release of the builder's captured device.
// Resource destruction has its own signal because the thread also owns state.
struct Build {
  std::shared_ptr<std::promise<void>> exited;
  struct Captures {
    std::shared_ptr<Device> device;
    std::shared_ptr<DriverGate> gate;
    bool fail;
  };
  std::unique_ptr<Captures> captures;

  Build(std::shared_ptr<Device> ownerDevice, std::shared_ptr<DriverGate> driverGate,
      bool shouldFail, std::shared_ptr<std::promise<void>> exitSignal)
      : exited(std::move(exitSignal)),
        captures(std::make_unique<Captures>(
            Captures{ownerDevice, driverGate, shouldFail})) {}
  Build(Build&&) = default;
  ~Build() {
    if (captures) {
      captures.reset();
      exited->set_value();
    }
  }
  void operator()(Resources& out) {
    const auto counts = captures->device->counts;
    out.shader = std::make_unique<Resource>(counts, 1);
    captures->gate->block();
    out.result = std::make_unique<Resource>(counts, 2);
    if (captures->fail) {
      // Mirrors InitComparer's HRESULT failure after partial allocation.
      out.shader.reset();
      return;
    }
    out.uav = std::make_unique<Resource>(counts, 3);
    out.staging = std::make_unique<Resource>(counts, 4);
  }
};

struct Harness {
  std::shared_ptr<Counts> counts = std::make_shared<Counts>();
  std::shared_ptr<Device> device = std::make_shared<Device>(counts);
  std::shared_ptr<DriverGate> gate = std::make_shared<DriverGate>();
  std::shared_ptr<std::promise<void>> exited =
      std::make_shared<std::promise<void>>();
  std::future<void> done = exited->get_future();
  std::future<void> resourcesReleased = counts->resourcesReleased.get_future();
  ReleaseOnExit unblock{gate};

  std::unique_ptr<AsyncResourceBuild<Resources>> start(bool fail = false) {
    auto build = std::make_unique<AsyncResourceBuild<Resources>>(
        Build(device, gate, fail, exited));
    device.reset();  // Just like disposing the owner's GraphicsContext.
    gate->waitUntilEntered();
    return build;
  }

  void finish() {
    gate->release();
    require(done.wait_for(std::chrono::seconds(5)) == std::future_status::ready,
        "worker did not exit");
    require(!gate->timedOut, "consumer blocked until driver gate timed out");
    require(counts->devices == 0, "worker retained device after completion");
  }
};

inline void lateCompletion() {
  Harness h;
  auto build = h.start();
  Resources out;
  // Pending capture attempts must fail open without exposing the shader that
  // already exists on the worker. The consumer never waits for driver work.
  for (int frame = 0; frame < 3; ++frame) {
    require(!build->tryTake(out), "published an incomplete comparer");
    require(!out.shader && !out.result && !out.uav && !out.staging,
        "pending build changed consumer resources");
  }
  h.finish();
  require(build->tryTake(out), "late comparer was not adopted");
  require(out.shader && out.result && out.uav && out.staging,
      "late comparer is missing resources");
  require(out.shader->value == 1 && out.result->value == 2 &&
      out.uav->value == 3 && out.staging->value == 4,
      "worker resources were not transferred intact");
  require(!build->tryTake(out), "comparer was delivered twice");
  require(out.shader && out.staging, "second take changed adopted resources");
  build.reset();
  require(h.counts->resources == 4, "consumer lost adopted resources");
  out = Resources{};
  require(h.counts->resources == 0, "adopted resources leaked");
}

inline void closeDuringInitialization(bool fail = false) {
  Harness h;
  auto build = h.start(fail);
  // This is the pending-build member destroyed with TextureBridgeGpu when a
  // WebView closes. Neither its state nor device may die under the worker.
  build.reset();
  require(h.counts->devices == 1 && h.counts->resources == 1,
      "closing the consumer released resources still used by the worker");
  h.finish();
  require(h.resourcesReleased.wait_for(std::chrono::seconds(5)) ==
      std::future_status::ready, "abandoned comparer resources leaked");
  require(h.counts->resources == 0, "abandoned comparer resources leaked");
}

inline void unavailableComparer() {
  Harness h;
  auto build = h.start(true);
  h.finish();
  Resources out;
  require(build->tryTake(out), "failed build did not finish");
  require(!out.shader && out.result && !out.uav && !out.staging,
      "failed build did not preserve the unavailable-comparer fallback");
  require(!build->tryTake(out), "failed comparer was delivered twice");
  out = Resources{};
  require(h.counts->resources == 0, "partial resources leaked");
}

}  // namespace async_resource_build_test
}  // namespace flutter_inappwebview_plugin::test
