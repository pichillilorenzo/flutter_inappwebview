#pragma once

#include <future>
#include <memory>
#include <system_error>
#include <thread>

namespace flutter_inappwebview_plugin {

// Starts |probe| once on a detached thread; get() waits for its result. The
// probe must own everything it uses; failures yield Result{}, never an inline run.
template <typename Result>
class BackgroundProbe {
 public:
  template <typename Probe>
  explicit BackgroundProbe(Probe probe) {
    auto promise = std::make_shared<std::promise<Result>>();
    result_ = promise->get_future().share();
    try {
      std::thread([promise, probe]() {
        try {
          promise->set_value(probe());
        }
        catch (...) {
          promise->set_value(Result{});
        }
      }).detach();
    }
    catch (const std::system_error&) {
      promise->set_value(Result{});
    }
  }

  BackgroundProbe(const BackgroundProbe&) = delete;
  BackgroundProbe& operator=(const BackgroundProbe&) = delete;

  Result get() const { return result_.get(); }

 private:
  std::shared_future<Result> result_;
};

}  // namespace flutter_inappwebview_plugin
