#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_PENDING_SCRIPT_REQUESTS_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_PENDING_SCRIPT_REQUESTS_H_

#include <cstddef>
#include <cstdint>
#include <functional>
#include <map>
#include <string>
#include <utility>

namespace flutter_inappwebview_plugin {

// WebView2 calls back on its owning UI thread. Clearing the registry before
// invoking callbacks prevents reentrancy and replies from a replaced WebView.
class PendingScriptRequests {
 public:
  using Callback = std::function<void(std::string)>;

  uint64_t add(Callback callback, std::string cancellationResult) {
    const auto id = ++nextId_;
    pending_.emplace(id, Entry{std::move(callback), std::move(cancellationResult)});
    return id;
  }

  bool contains(uint64_t id) const { return pending_.find(id) != pending_.end(); }
  size_t count() const { return pending_.size(); }

  bool complete(uint64_t id, std::string result) {
    auto it = pending_.find(id);
    if (it == pending_.end()) return false;
    auto callback = std::move(it->second.callback);
    pending_.erase(it);
    if (callback) callback(std::move(result));
    return true;
  }

  void cancelAll() {
    auto pending = std::move(pending_);
    pending_.clear();
    for (auto& item : pending) {
      if (item.second.callback) {
        item.second.callback(std::move(item.second.cancellationResult));
      }
    }
  }

 private:
  struct Entry {
    Callback callback;
    std::string cancellationResult;
  };
  uint64_t nextId_ = 0;
  std::map<uint64_t, Entry> pending_;
};

}  // namespace flutter_inappwebview_plugin

#endif
