#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_JAVASCRIPT_ORIGIN_RULES_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_JAVASCRIPT_ORIGIN_RULES_H_

#include <algorithm>
#include <optional>
#include <regex>
#include <string>
#include <utility>
#include <vector>

namespace flutter_inappwebview_plugin {

// Compile once when WebView settings change, never per JavaScript callHandler.
// Null list = default allow; empty list = deny. Invalid patterns fail closed.
// Uses the same ECMAScript std::regex_match behavior as the previous bridge.
class JavaScriptOriginRules {
 public:
  void configure(const std::optional<std::vector<std::string>>& patterns) {
    if (!patterns.has_value()) {
      rules_.reset();
      return;
    }
    std::vector<std::regex> compiled;
    compiled.reserve(patterns->size());
    for (const auto& pattern : *patterns) {
      try {
        compiled.emplace_back(pattern, std::regex::ECMAScript);
      } catch (const std::regex_error&) {
        // Invalid patterns must not crash the UI message pump or allow access.
      }
    }
    rules_ = std::move(compiled);
  }

  bool allows(const std::string& origin) const {
    if (!rules_.has_value()) return true;
    return std::any_of(rules_->begin(), rules_->end(),
                       [&origin](const std::regex& pattern) {
                         return std::regex_match(origin, pattern);
                       });
  }

  size_t ruleCount() const { return rules_ ? rules_->size() : 0; }

 private:
  std::optional<std::vector<std::regex>> rules_;
};
} // namespace flutter_inappwebview_plugin
#endif
