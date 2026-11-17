#pragma once

#include <memory>
#include <mutex>
#include <thread>
#include <utility>

namespace flutter_inappwebview_plugin {

// One worker and one consumer. The builder must own everything it uses (never
// capture the WebView/bridge). Destroying the consumer does not wait for driver
// calls: the worker retains its state and releases unused resources on exit.
template <typename Resources>
class AsyncResourceBuild {
 public:
  template <typename Build>
  explicit AsyncResourceBuild(Build build) : state_(std::make_shared<State>()) {
    std::thread([state = state_, build = std::move(build)]() mutable {
      build(state->resources);
      const std::lock_guard<std::mutex> lock(state->mutex);
      state->done = true;
    }).detach();
  }

  AsyncResourceBuild(const AsyncResourceBuild&) = delete;
  AsyncResourceBuild& operator=(const AsyncResourceBuild&) = delete;

  // Called only by the consumer. Pending work leaves |out| untouched; completed
  // resources are transferred exactly once, including an unavailable comparer.
  bool tryTake(Resources& out) {
    if (!state_) {
      return false;
    }
    {
      const std::lock_guard<std::mutex> lock(state_->mutex);
      if (!state_->done) {
        return false;
      }
    }
    out = std::move(state_->resources);
    state_.reset();
    return true;
  }

 private:
  struct State {
    std::mutex mutex;
    bool done = false;
    Resources resources;
  };
  std::shared_ptr<State> state_;
};

}  // namespace flutter_inappwebview_plugin
