#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_PENDING_WEBKIT_JAVASCRIPT_CALLS_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_PENDING_WEBKIT_JAVASCRIPT_CALLS_H_

#include <cstddef>
#include <cstdint>
#include <functional>
#include <map>
#include <utility>

namespace flutter_inappwebview_plugin {

// GAsync still invokes its completion when cancelled. Resolve the Flutter
// request once, and let late GAsync callbacks release their resources only.
class PendingWebKitJavaScriptCalls {
 public:
  uint64_t add(std::function<void()> onCancel) {
    const uint64_t id = ++nextId_;
    pending_.emplace(id, std::move(onCancel));
    return id;
  }
  bool finish(uint64_t id) { return pending_.erase(id) != 0; }
  size_t count() const { return pending_.size(); }

  void cancelAll() {
    auto pending = std::move(pending_);
    pending_.clear();
    for (auto& entry : pending) {
      if (entry.second) entry.second();
    }
  }
 private:
  uint64_t nextId_ = 0;
  std::map<uint64_t, std::function<void()>> pending_;
};
}  // namespace flutter_inappwebview_plugin

#endif
