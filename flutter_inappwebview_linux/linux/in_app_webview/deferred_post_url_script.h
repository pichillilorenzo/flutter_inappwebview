#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_DEFERRED_POST_URL_SCRIPT_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_DEFERRED_POST_URL_SCRIPT_H_

#include <cstdint>
#include <memory>
#include <string>
#include <utility>

namespace flutter_inappwebview_plugin {

// A queued postUrl script is tied to one WebView and one navigation attempt.
// The weak lifetime check must precede any use of the raw view pointer.
struct DeferredPostUrlScript {
  std::weak_ptr<int> lifetime;
  uint64_t navigation_generation = 0;
  std::string javascript;

  bool ownerAlive() const { return !lifetime.expired(); }
  bool matchesGeneration(uint64_t current) const {
    return navigation_generation == current;
  }
};

} // namespace flutter_inappwebview_plugin

#endif
