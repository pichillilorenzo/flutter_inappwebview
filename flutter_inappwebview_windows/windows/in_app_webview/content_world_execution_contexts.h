#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_CONTENT_WORLD_EXECUTION_CONTEXTS_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_CONTENT_WORLD_EXECUTION_CONTEXTS_H_

#include <cstddef>
#include <map>
#include <optional>
#include <string>
#include <utility>

namespace flutter_inappwebview_plugin {

// A CDP executionContextId is only valid until Runtime.executionContextDestroyed
// or Runtime.executionContextsCleared. Never reuse it across documents.
class ContentWorldExecutionContexts {
 public:
  void put(std::string name, int id) { worlds_.insert_or_assign(std::move(name), id); }

  std::optional<int> get(const std::string& name) const {
    auto it = worlds_.find(name);
    if (it == worlds_.end()) return std::nullopt;
    return it->second;
  }

  void eraseId(int id) {
    for (auto it = worlds_.begin(); it != worlds_.end();) {
      if (it->second == id) {
        it = worlds_.erase(it);
      } else {
        ++it;
      }
    }
  }

  void clear() { worlds_.clear(); }
  size_t count() const { return worlds_.size(); }

 private:
  std::map<std::string, int> worlds_;
};

}  // namespace flutter_inappwebview_plugin
#endif
