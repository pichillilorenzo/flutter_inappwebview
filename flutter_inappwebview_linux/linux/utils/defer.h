#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_UTIL_DEFER_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_UTIL_DEFER_H_

#include <functional>
#include <memory>

namespace flutter_inappwebview_plugin {

// Utility to defer cleanup operations using RAII
static inline std::shared_ptr<void> defer(void* handle,
                                          const std::function<void(void*)>& callback) {
  return std::shared_ptr<void>(handle, callback);
}

// RAII helper for scoped cleanup
template <typename Func>
class ScopeGuard {
 public:
  explicit ScopeGuard(Func&& func) : func_(std::move(func)), active_(true) {}

  ScopeGuard(ScopeGuard&& other) noexcept : func_(std::move(other.func_)), active_(other.active_) {
    other.dismiss();
  }

  ~ScopeGuard() {
    if (active_) {
      func_();
    }
  }

  void dismiss() noexcept { active_ = false; }

  ScopeGuard(const ScopeGuard&) = delete;
  ScopeGuard& operator=(const ScopeGuard&) = delete;

 private:
  Func func_;
  bool active_;
};

template <typename Func>
ScopeGuard<Func> make_scope_guard(Func&& func) {
  return ScopeGuard<Func>(std::forward<Func>(func));
}

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_UTIL_DEFER_H_
