#pragma once

#include <chrono>
#include <future>
#include <memory>
#include <optional>
#include <thread>
#include <utility>

namespace flutter_inappwebview_plugin {

struct DetachedProbeLauncher {
  template <typename Work>
  bool operator()(Work work) const {
    std::thread(std::move(work)).detach();
    return true;
  }
};

// The probe owns everything it uses. The consumer never waits, including during
// destruction. A failed launch/probe publishes Result{}, without an inline run.
// DLL clients must supply a launcher that retains their module until completion.
template <typename Result>
class BackgroundProbe {
 public:
  template <typename Probe, typename Launch = DetachedProbeLauncher>
  explicit BackgroundProbe(Probe probe, Launch launch = {}) {
    auto promise = std::make_shared<std::promise<Result>>();
    result_ = promise->get_future().share();
    try {
      if (!launch([promise, probe = std::move(probe)]() {
        try {
          promise->set_value(probe());
        }
        catch (...) {
          promise->set_value(Result{});
        }
      })) {
        promise->set_value(Result{});
      }
    }
    catch (...) {
      promise->set_value(Result{});
    }
  }

  BackgroundProbe(const BackgroundProbe&) = delete;
  BackgroundProbe& operator=(const BackgroundProbe&) = delete;

  std::optional<Result> tryGet() const {
    if (result_.wait_for(std::chrono::seconds(0)) != std::future_status::ready) {
      return std::nullopt;
    }
    return result_.get();
  }

 private:
  std::shared_future<Result> result_;
};

}  // namespace flutter_inappwebview_plugin
