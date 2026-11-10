#pragma once

#include <memory>
#include <stdexcept>
#include <thread>
#include "../webview_environment/prewarm_operation.h"

namespace flutter_inappwebview_plugin::test {
  inline void runPrewarmOperationTests() {
    using Clock = PrewarmOperation::Clock;
    const auto started = Clock::time_point{};
    const auto milliseconds = [](int value) { return std::chrono::milliseconds(value); };
    const auto require = [](bool value) {
      if (!value) throw std::runtime_error("PrewarmOperation assertion failed");
    };

    PrewarmOperation completed(started);
    require(!completed.take(started));
    completed.finish("ok", 0, started + milliseconds(12));
    const auto success = completed.take(started + milliseconds(50));
    require(success && success->status == "ok" && success->durationMs == 12);
    require(!completed.take(started + milliseconds(100)));
    completed.finish("create_failed", -1, started + milliseconds(120));
    require(!completed.take(started + milliseconds(150)));

    // The worker never publishes (e.g. blocked synchronous runtime loader).
    // The platform thread independently times out without a posted message.
    PrewarmOperation blocked(started);
    require(!blocked.take(started + milliseconds(29999)));
    const auto timeout = blocked.take(started + milliseconds(30000));
    require(timeout && timeout->status == "timeout" && timeout->errorCode == -2147023436);
    blocked.finish("ok", 0, started + milliseconds(31000));
    require(!blocked.take(started + milliseconds(31000)));

    // A callback that arrives after the deadline cannot turn timeout to success,
    // even if it runs before the platform thread next drains its mailbox.
    PrewarmOperation late(started);
    late.finish("ok", 0, started + milliseconds(30001));
    require(late.take(started + milliseconds(30002))->status == "timeout");

    // Manager teardown releases its copy. The worker can finish safely and can
    // never address a new manager/window; a new operation has separate state.
    auto detached = std::make_shared<PrewarmOperation>(started);
    auto worker = detached;
    detached.reset();
    PrewarmOperation replacement(started);
    std::thread([worker, started] { worker->finish("ok", 0, started); }).join();
    require(worker->take(started)->status == "ok");
    require(!replacement.take(started));

    // Concurrent worker completion and platform deadline still deliver once.
    for (int iteration = 0; iteration < 100; ++iteration) {
      PrewarmOperation race(started);
      std::thread finishing([&] { race.finish("ok", 0, started + milliseconds(1)); });
      auto first = race.take(started + milliseconds(30000));
      finishing.join();
      require(first.has_value());
      require(!race.take(started + milliseconds(30001)));
    }
  }
}
