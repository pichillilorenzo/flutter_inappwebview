#pragma once

#include <mutex>
#include <optional>
#include <memory>
#include <string>
#include <utility>

namespace flutter_inappwebview_plugin
{
  // Owns a callback once and permits safe sharing between asynchronous paths.
  // The optional prepare action runs only for the first completion and before
  // the callback, which lets callers publish failure details consistently.
  template<typename Callback>
  class OneShotCallback
  {
  public:
    explicit OneShotCallback(Callback callback)
      : callback_(std::move(callback))
    {}

    template<typename... Args>
    bool invoke(Args&&... args)
    {
      return invokeWith([] {}, std::forward<Args>(args)...);
    }

    template<typename... Args>
    bool invokeWithFailureStage(const std::shared_ptr<std::string>& failureStage,
      const char* stage, Args&&... args)
    {
      return invokeWith([&failureStage, stage] {
        if (failureStage) {
          *failureStage = stage;
        }
      }, std::forward<Args>(args)...);
    }

    template<typename Prepare, typename... Args>
    bool invokeWith(Prepare&& prepare, Args&&... args)
    {
      std::optional<Callback> callback;
      {
        std::lock_guard<std::mutex> lock(mutex_);
        if (completed_) {
          return false;
        }
        completed_ = true;
        callback.emplace(std::move(callback_));
      }
      std::forward<Prepare>(prepare)();
      if (callback) {
        (*callback)(std::forward<Args>(args)...);
      }
      return true;
    }

  private:
    std::mutex mutex_;
    bool completed_ = false;
    Callback callback_;
  };
}
