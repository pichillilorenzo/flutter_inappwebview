#pragma once

#include <chrono>
#include <functional>
#include <future>
#include <stdexcept>
#include <thread>

#include "../custom_platform_view/background_probe.h"

namespace flutter_inappwebview_plugin::test::background_probe_test {

inline void require(bool condition) {
  if (!condition) throw std::runtime_error("BackgroundProbe regression");
}

inline void pendingThenReady() {
  std::function<void()> complete;
  int calls = 0;
  BackgroundProbe<bool> probe([&]() { ++calls; return true; },
    [&](auto work) { complete = std::move(work); return true; });
  // Repeated early views must return immediately and must not turn pending
  // into a cached false result. No timing assumption or worker scheduling race.
  require(!probe.tryGet().has_value());
  require(!probe.tryGet().has_value());
  require(calls == 0);
  complete();
  require(probe.tryGet() == true);
  require(probe.tryGet() == true);
  require(calls == 1);
}

inline void unsupportedIsReady() {
  BackgroundProbe<bool> probe([]() { return false; },
    [](auto work) { work(); return true; });
  require(probe.tryGet().has_value());
  require(probe.tryGet() == false);
}

inline void throwingProbe() {
  BackgroundProbe<bool> probe([]() -> bool { throw std::runtime_error("probe"); },
    [](auto work) { work(); return true; });
  require(probe.tryGet() == false);
}

inline void failedLaunch() {
  bool called = false;
  BackgroundProbe<bool> probe([&]() { called = true; return true; },
    [](auto) { return false; });
  require(probe.tryGet() == false);
  require(!called);
  BackgroundProbe<bool> throwing([&]() { called = true; return true; },
    [](auto) -> bool { throw std::runtime_error("launch"); });
  require(throwing.tryGet() == false);
  require(!called);
}

inline void offThreadAndDestroyedWhilePending() {
  auto release = std::make_shared<std::promise<void>>();
  auto released = release->get_future().share();
  auto started = std::make_shared<std::promise<std::thread::id>>();
  auto startedFuture = started->get_future();
  auto finished = std::make_shared<std::promise<void>>();
  auto finishedFuture = finished->get_future();
  {
    BackgroundProbe<bool> probe([=]() {
      started->set_value(std::this_thread::get_id());
      released.wait();
      finished->set_value();
      return true;
    });
    require(startedFuture.wait_for(std::chrono::seconds(5)) == std::future_status::ready);
    require(startedFuture.get() != std::this_thread::get_id());
    require(!probe.tryGet().has_value());
  }
  // The consumer's destructor must not join a blocked worker.
  release->set_value();
  require(finishedFuture.wait_for(std::chrono::seconds(5)) == std::future_status::ready);
}

}  // namespace flutter_inappwebview_plugin::test::background_probe_test
